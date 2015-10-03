# Description:
#   SDT manages show don't tell sessions held at MagmaLabs
#
# Commands:
#   hubot sdt schedule - Shows current session schedule
#   hubot sdt schedule clear - (admin) Clears current session schedule
#   hubot sdt sessions create <Sep 15 2015> - (admin) Create session for a specific date
#   hubot sdt sessions list [5] - List sessions with optional limit
#   hubot sdt submit <topic> - Submit a proposal to the current session
#   hubot sdt group submit with <username> <topic>- Submit a group proposal to the current session
#
# Dependencies:
#   moment
#   underscore
#
# Authors:
#   Ignacio Galindo <ignacio.galindo@magmalabs.io>
#

moment     = require "moment"
_          = require "underscore"
repository = null

class ListDecorator
  @speakers: (speakers)->
    sortedSpeakers = _.sortBy speakers, (s)-> s.real_name
    names = sortedSpeakers.map (s)-> "#{s.real_name} (#{s.name})"
    "_by #{names.join(' & ')}_"
  @talks: (talks)->
    details = talks.map (t)=> "- *#{t.title}* #{@speakers(t.speakers)}"
    if talks.length > 0 then details.join("\n") else "- No talks"

class Repository
  constructor: (@db)->
    @db.data.sdt ||= { sessions: [] }

  addSession: (session)->
    @db.data.sdt.sessions.push session

  currentSession: ->
    _.find @sessions(), (s)->
      moment().startOf("day").isBefore(moment(new Date(s.date)).endOf("day"))

  findUser: (username)->
    @db.usersForFuzzyName(username)

  sessions: ->
    _.sortBy @db.data.sdt.sessions, (s)->
      - new Date(s.date)

class Session
  constructor: (date, @talks = [])->
    @date = moment(date).format("L")

class Talk
  constructor: (@title, @speakers...)->

module.exports = (reylero)->

  # Brain load
  reylero.brain.on "loaded", =>
    repository = new Repository(reylero.brain)
    reylero.brain.data.sdt ||= repository.db.data.sdt

  # Sessions create
  reylero.respond /sdt sessions create (\w{3} \d{1,2} \d{4})$/, (res)->

    unless reylero.auth.isAdmin(res.message.user)
      res.reply "Sorry, I'm afraid only admins are allowed to create sessions."
      return

    date = new Date res.match[1]

    unless moment(date).isValid()
      res.reply "Excuse me master, that date seems invalid."
      return

    session = new Session(date)

    if _.findWhere repository.sessions(), { date: session.date }
      res.reply "Excuse me master, that session already exists."
      return

    repository.addSession(session)
    res.reply "Sure master, consider it done."

  # Show current session's schedule
  reylero.respond /sdt schedule$/i, (res)->
    session = repository.currentSession()

    unless session
      res.send "Sorry, there aren't sessions scheduled yet."
      return

    res.send if session.talks.length > 0
               "These are the talks scheduled for the next session on #{session.date}:\n" +
               ListDecorator.talks(session.talks)
             else
               "There aren't talks scheduled for the next session on #{session.date} :("

   # Clear current session's schedule
   reylero.respond /sdt schedule clear$/i, (res)->

     unless reylero.auth.isAdmin(res.message.user)
       res.reply "Sorry, I'm afraid only admins are allowed to create sessions."
       return

     session = repository.currentSession()

     unless session
       res.send "Sorry, there aren't sessions scheduled yet."
       return

     session.talks = []

     res.reply "Sure master, consider it done."

   # Sessions list
   reylero.respond /sdt sessions(?: list|)\s?(\d+)?$/i, (res)->

     limit    = res.match[1] || 5
     sessions = repository.sessions()[0...limit]

     if sessions.length == 0
       res.send "Sorry, there aren't sessions scheduled yet."
       return

     list = sessions.map (s)-> "#{s.date}:\n" + ListDecorator.talks(s.talks)

     res.send "These are the last #{sessions.length} sessions details:\n" + list.join("\n")

   reylero.respond /sdt submit ("|')?(.+)\1$/i, (res)->
     session = repository.currentSession()

     unless session
       res.send "Sorry, there aren't sessions scheduled yet."
       return

     talk = new Talk(res.match[2], { name: res.message.user.name, real_name: res.message.user.real_name || '' })

     res.reply if session.talks.length < 2
                 session.talks.push talk
                 "Sure, your talk _#{talk.title}_ has been scheduled for session on #{session.date}."
               else
                 "Sorry, we reached the limit of talks for session on #{session.date}."

   reylero.respond /sdt group submit with (\w+) ("|')?(.+)\2$/i, (res)->
     session = repository.currentSession(reylero)

     unless session
       res.reply "Sorry, there aren't sessions scheduled yet."
       return

     unless session.talks.length < 2
       res.reply "Sorry, we reached the limit of talks for session on #{session.date}."
       return

     users = repository.findUser(res.match[1])

     switch users.length
       when 0
         res.reply "Sorry, I don't know who #{res.match[1]} is."
       when 1
         talk = new Talk(res.match[3], res.message.user, users[0])
         session.talks.push talk
         res.reply "Sure, your talk _#{talk.title}_ with #{users[0].name} has been scheduled for session on #{session.date}."
       else
         res.reply "Sorry there are many users that match that name:\n" + users.map((u)-> u.name ).join(", ")
