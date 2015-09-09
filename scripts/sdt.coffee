class Schedule
  constructor: (@talks)->
  toString: ->
    @talks.map((talk)->
      "- *#{talk.title}* _by #{talk.speaker.name}_"
    ).join("\n")

class Talk
  constructor: (@title, @speaker)->

module.exports = (reylero)->

  reylero.brain.on "loaded", =>
    reylero.brain.data.sdt ||= {
      talks: []
    }

  reylero.respond /(.)+sdt schedule$/i, (res)->
    reylero.logger.info "[sdt] Listing schedule for #{res.message.user.name}"

    schedule = new Schedule reylero.brain.data.sdt.talks

    res.send if schedule.talks.length > 0
               "These are the talks scheduled for the next show don't tell session: \n#{schedule}"
             else
               "There are no talks scheduled for the next show don't tell session :("

  reylero.respond /sdt schedule clear$/i, (res)->
    reylero.logger.info "[sdt] Clearing schedule for #{res.message.user.name}"
    reylero.brain.data.sdt = {
      talks: []
    }
    res.reply "Schedule has been cleared"

  reylero.respond /sdt submit (.+)/i, (res)->
    reylero.logger.info "[sdt] Scheduling talk '#{res.match[1]}' by  #{res.message.user.name}"

    talk = new Talk(res.match[1], res.message.user)

    talks = reylero.brain.data.sdt.talks

    if talks.length < 2
      reylero.brain.data.sdt.talks.push talk
      res.reply "Sure, your talk _#{talk.title}_ is scheduled for the next show don't tell session"
    else
      res.reply "Sorry, we reached the limit of talks for the next show don't tell session"
