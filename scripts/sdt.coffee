# Show dont tell
module.exports = (reylero)->

  reylero.brain.on "loaded", =>
    console.log "Waking up"
    reylero.brain.data.sdt ||= {
      talks: []
    }

  reylero.respond /sdt schedule/i, (res)->
    console.log "Listing SDT schedule for #{res.message.user.name}"

    talks = reylero.brain.data.sdt.talks

    message = if talks.length > 0
      "These are the talks scheduled for the next show don't tell session: \n" + talks.map((talk)->
        "#{talk.title} by #{talk.speaker}"
      ).join("\n")
    else
      "There are no talks scheduled for the next show don't tell session :("

    res.send message
