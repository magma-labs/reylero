chai   = require "chai"
hubot  = require "hubot"
sinon  = require "sinon"

global.expect = chai.expect

global.robot = ->
  hubot.loadBot "./adapters", "shell", false
