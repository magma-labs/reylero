chai   = require "chai"
hubot  = require "hubot"
moment = require "moment"
sinon  = require "sinon"

chai.use require "sinon-chai"

global.expect = chai.expect
global.moment = moment
global.sinon  = sinon

global.newTestRobot = -> hubot.loadBot "./adapters", "shell", false
