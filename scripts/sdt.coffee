# Description:
#   SDT manages show don't tell sessions at MagmaLabs
#
# Commands:
#   reylero sdt schedule                      - Shows current session schedule
#   reylero sdt schedule clear                - Clears current session schedule
#   reylero sdt sessions create <Sep 15 2015> - Create session for a specific date
#   reylero sdt sessions list   [5]           - List sessions with optional limit
#   reylero sdt submit <topic>                - Submit a proposal to the current session
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

class Database
  constructor: ->
    @sessions = []

class Session
  constructor:(date)->
    @date = moment(date).format('L')
    @talks = []

class Talk
  constructor: (@title, @speaker)->

formatTalksList = (talks)->
  if talks.length == 0
    "- No talks\n"
  else
    talks.map (talk)->
      "- *#{talk.title}* _by #{talk.speaker}_\n"

getCurrentSession = (reylero)->
  _.find getSortedSessions(reylero), (s)->
    moment(new Date(s.date)).isBetween(moment().startOf('week'), moment().add(1, 'week'))

getSessions = (reylero)->
  reylero.brain.data.sdt.sessions

getSortedSessions = (reylero)->
  _.sortBy getSessions(reylero), (s)->
    - new Date(s.date)


module.exports = (reylero)->

  # Brain load
  reylero.brain.on "loaded", =>

    reylero.brain.data.sdt ||= new Database

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

    if _.findWhere getSessions(reylero), { date: session.date }
      res.reply "Excuse me master, that session already exists."
      return

    reylero.brain.data.sdt.sessions.push session
    reylero.brain.save()
    res.reply "Sure master, consider it done."

  # Show current session's schedule
  reylero.respond /sdt schedule$/i, (res)->

    session = getCurrentSession(reylero)

    unless session
      res.send "Sorry, there aren't sessions scheduled yet."
      return

    res.send if session.talks.length > 0
               "These are the talks scheduled for the next session on #{session.date}:\n" +
               formatTalksList(session)
             else
               "There aren't talks scheduled for the next session on #{session.date} :("

   # Clear current session's schedule
   reylero.respond /sdt schedule clear$/i, (res)->

     unless reylero.auth.isAdmin(res.message.user)
       res.reply "Sorry, I'm afraid only admins are allowed to create sessions."
       return

     session = getCurrentSession(reylero)

     unless session
       res.send "Sorry, there aren't sessions scheduled yet."
       return

     session.talks = []
     reylero.brain.save()

     res.reply "Sure master, consider it done."

   # Sessions list
   reylero.respond /sdt sessions(?: list|)\s?(\d+)?$/i, (res)->

     limit    = res.match[1] || 5
     sessions = getSortedSessions(reylero)[0...limit]

     if sessions.length == 0
       res.send "Sorry, there aren't sessions scheduled yet."
       return

     list = ""

     for session in sessions
       list += "#{session.date}:\n" + formatTalksList(session.talks)

     res.send list

  reylero.respond /sdt submit (.+)/i, (res)->
    session = getCurrentSession(reylero)
    unless session
      res.send "Sorry, there aren't sessions scheduled yet."
      return

    talk = new Talk(res.match[1], res.message.user)

    res.reply if session.talks.length < 2
                session.talks.push talk
                "Sure, your talk _#{talk.title}_ has been scheduled for session on #{session.date}."
              else
                "Sorry, we reached the limit of talks for session on #{session.date}."
