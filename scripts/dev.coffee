# Description:
#   DEV provides developer and debugging tooling
#
# Dependencies:
#   "hubot-auth":"~1.2.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot dev what is my id? - Show current user id
#   hubot dev what is <username>'s id? - (admin) Show given username id
#
# Notes:
#   None
#
# Authors:
#   Ignacio Galindo <ignacio.galindo@magmalabs.io>
#

module.exports = (robot) ->

  robot.respond /dev what is my id\?/i, (res)->
    res.reply res.message.user.id


  robot.respond /dev what is (.+)\'s id?/i, (res)->

    unless robot.auth.isAdmin(res.message.user)
      res.reply "Sorry, I'm afraid I can't help"
      return

    users = robot.brain.usersForFuzzyName(res.match[1])

    if users.length > 0
      res.reply users[0].id
    else
      res.reply "Sorry, I don't know #{res.match[1]}"
