require "./test_helper"

describe "dev", ->

  beforeEach ->
    @robot = newTestRobot("dev")
  afterEach ->
    @robot.shutdown()


  describe "what is my id?", ->
    it "returns current user id", (done) ->
      @robot.adapter.on "reply", (envelope, strings) ->
        expect(strings).to.include(envelope.user.id)
        done()

      message = "reylero dev what is my id?"
      @robot.adapter.receive newTestMessage(@robot, message)


  describe "what is <username>'s id?", (done) ->
    context "as admin", ->
      it "returns matching username's id", (done)->
        @robot.adapter.on "reply", (envelope, strings) ->
          expect(strings).to.include(@robot.brain.userForName("user").id)
          done()

        message = "reylero dev what is user's id?"
        @robot.adapter.receive newTestMessage(@robot, message, "admin")

      it "apologizes for not finding given user id", (done)->
        @robot.adapter.on "reply", (envelope, strings) ->
          expect(strings).to.include("Sorry, I don't know john")
          done()

        message = "reylero dev what is john's id?"
        @robot.adapter.receive newTestMessage(@robot, message, "admin")

    context "as regular user", ->
      it "apologizes for being unauthorized", (done) ->
        @robot.adapter.on "reply", (envelope, strings) ->
          expect(strings).to.include("Sorry, I'm afraid I can't help")
          done()

        message = "reylero dev what is admin's id?"
        @robot.adapter.receive newTestMessage(@robot, message)
