chai   = require "chai"
hubot  = require "hubot"
moment = require "moment"
sinon  = require "sinon"

chai.use require "sinon-chai"

Robot       = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

global.expect = chai.expect
global.moment = moment
global.sinon  = sinon

process.env.HUBOT_AUTH_ADMIN = "1"

global.newTestRobot = (script) ->
  robot = new Robot null, "mock-adapter", false

  robot.adapter.on "connected", ->

    require("hubot-auth")(robot)
    require(script)(robot)

    adminUser = robot.brain.userForId "1",
      name: "admin"
      real_name: "An admin"
      room: "#test"

    normalUser = robot.brain.userForId "2",
      name: "user"
      real_name: "An user"
      room: "#test"

  robot

global.newTestMessage = (robot, message, user = "user") ->
  new TextMessage(robot.brain.userForName(user), message)
