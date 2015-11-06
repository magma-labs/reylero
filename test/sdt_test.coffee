require "./test_helper"

describe "sdt", ->

  beforeEach ->
    @robot = newTestRobot("../scripts/sdt")
    @robot.run()
    @robot.brain.emit("loaded")

  afterEach ->
    @robot.shutdown()

  describe "callbacks", ->

    context "on brain load", ->
      it "initializes a repository with the sdt namespace", ->
        expect(@robot.brain.data.sdt).not.to.be.empty

  describe "group submit", ->

    context "when no sessions are scheduled", ->
      it "does not accept the submission", (done) ->
        @robot.adapter.on "reply", (envelope, strings) ->
          expect(strings).to
            .include("Sorry, there aren't sessions scheduled yet.")
          done()
        message = "hubot sdt group submit with admin Hello World"
        @robot.adapter.receive newTestMessage(@robot, message)

    context "when there's a session scheduled without talks", ->
      beforeEach ->
        @date = moment().format('L')
        @session = { date: @date, talks: [] }
        @robot.brain.data.sdt.sessions = [@session]

      context "but peer is unknown", ->
        before -> @peer = "john"

        it "does not accept group submission", (done) ->
          @robot.adapter.on "reply", (envelope, strings) =>
            expect(strings).to
              .include "Sorry, I don't know who #{@peer} is."
            done()

          message = "hubot sdt group submit with john Hello World"
          @robot.adapter.receive newTestMessage(@robot, message)

      context "and peer is known", ->
        before -> @peer = "admin"

        it "registers group proposal submission", (done) ->
          @talk = "Hello World!"
          @robot.adapter.on "reply", (envelope, strings) =>
            expect(strings).to
              .include "Sure, your talk _#{@talk}_ with #{@peer} has been " +
                "scheduled for session on #{@date}."
            done()

          message = "hubot sdt group submit with #{@peer} #{@talk}"
          @robot.adapter.receive newTestMessage(@robot, message)

    context "when there's a session with full schedule", ->
      beforeEach ->
        @date = moment().format('L')
        @session = { date: @date, talks: [{}, {}] }
        @robot.brain.data.sdt.sessions = [@session]

      it "does not accept group submission", (done) ->
        @robot.adapter.on "reply", (envelope, strings) =>
          expect(strings).to.include "Sorry, we reached the limit of talks " +
            "for session on #{@date}."

          done()

        message = "hubot sdt group submit with admin Hello World"
        @robot.adapter.receive newTestMessage(@robot, message)

  describe "schedule", ->
    context "when no sessions are scheduled", ->
      it "does not show session details", (done) ->
        @robot.adapter.on "send", (envelope, strings) ->
          expect(strings).to
            .include "Sorry, there aren't sessions scheduled yet."
          done()

        message = "hubot sdt schedule"
        @robot.adapter.receive newTestMessage(@robot, message)

    context "when there's a session scheduled", ->
      context "and has at least one talk", ->
        beforeEach ->
          @date = moment().format('L')
          @talk = {
            title: "Hello world!",
            speakers: [{ name: "john", real_name: "John Doe" }]
          }
          @session = { date: @date, talks: [@talk] }
          @robot.brain.data.sdt.sessions = [@session]

        it "shows the session talk details", (done) ->
          @robot.adapter.on "send", (envelope, strings) ->
            expect(strings).to
              .include "These are the talks scheduled for the next session " +
                       "on 11/05/2015:\n - *Hello world!* _by John Doe (john)_"
            done()

          message = "hubot sdt schedule"
          @robot.adapter.receive newTestMessage(@robot, message)

      context "and doesn't have any talk", ->
        beforeEach ->
          @date = moment().format('L')
          @session = { date: @date, talks: [] }
          @robot.brain.data.sdt.sessions = [@session]

        it "says there are no talks for session", (done) ->
          @robot.adapter.on "send", (envelope, strings) =>
            expect(strings).to
              .include "There aren't talks scheduled for the next session " +
                       "on #{@date} :("
            done()

          message = "hubot sdt schedule"
          @robot.adapter.receive newTestMessage(@robot, message)

  describe "schedule clear", ->
    context "when user is not an admin", ->
      it "does not clear schedule", (done) ->
        @robot.adapter.on "reply", (envelope, strings) ->
          expect(strings).to
            .include "Sorry, you are not allowed to create sessions."

          done()
        message = "hubot sdt schedule clear"
        @robot.adapter.receive newTestMessage(@robot, message)

    context "when user is an admin", ->
      context "and there's not session scheduled", ->
        it "does not clear schedule", (done) ->
          @robot.adapter.on "reply", (envelope, strings) ->
            expect(strings).to
              .include "Sorry, there aren't sessions scheduled yet."

            done()

          message = "hubot sdt schedule clear"
          @robot.adapter.receive newTestMessage(@robot, message, "admin")

      context "and there's session scheduled", ->
        beforeEach ->
          @date = moment().format('L')
          @session = { date: @date, talks: [] }
          @robot.brain.data.sdt.sessions = [@session]

        it "clears the schedule", (done) ->
          @robot.adapter.on "reply", (envelope, strings) =>
            expect(@session.talks).to.be.empty
            expect(strings).to
              .include "Sure master, consider it done."
            done()

          message = "hubot sdt schedule clear"
          @robot.adapter.receive newTestMessage(@robot, message, "admin")

  describe "sessions create", ->

    context "when user is not an admin", ->
      it "does not allow session creation", (done) ->
        @robot.adapter.on "reply", (envelope, strings) ->
          expect(strings).to
            .include "Sorry, I'm afraid only admins can create sessions."
          done()

        message = "hubot sdt sessions create Sep 15 2015"
        @robot.adapter.receive newTestMessage(@robot, message)

    context "when user is an admin", ->
      context "and session is invalid", ->
        it "does not allow session creation", (done) ->
          @robot.adapter.on "reply", (envelope, strings) ->
            expect(strings).to
              .include "Excuse me master, that date seems invalid."
            done()

          message = "hubot sdt sessions create Sep 35 2015"
          @robot.adapter.receive newTestMessage(@robot, message, "admin")

      context "and session already exists", ->
        beforeEach ->
          @robot.brain.data.sdt.sessions.push {
            date: "09/15/2015"
          }

        it "does not allow session creation", (done) ->
          @robot.adapter.on "reply", (envelope, strings) ->
            expect(strings).to
              .include("Excuse me master, that session already exists.")
            done()

          message = "hubot sdt sessions create Sep 15 2015"
          @robot.adapter.receive newTestMessage(@robot, message, "admin")

      it "registers a new session", (done) ->
        @robot.adapter.on "reply", (envelope, strings) ->
          expect(strings).to.include "Sure master, consider it done."
          done()

        message = "hubot sdt sessions create Sep 15 2015"
        @robot.adapter.receive newTestMessage(@robot, message, "admin")

  describe "sessions list", ->
    context "when there are not sesions scheduled", ->

      it "says there are not sessions", (done) ->
        @robot.adapter.on "send", (envelope, strings) ->
          expect(strings).to
            .include "Sorry, there aren't sessions scheduled yet."
          done()

        message = "hubot sdt sessions"
        @robot.adapter.receive newTestMessage(@robot, message)

    context "when there is a session scheduled", ->
      beforeEach ->
        @date = moment().format('L')
        @talks = [
          {
            title: "Hello world!",
            speakers: [{ name: "john", real_name: "John Doe" }]
          },
          {
            title: "Ruby programming",
            speakers: [
              { name: "john", real_name: "John Doe" },
              { name: "jane", real_name: "Jane Doe" }
            ]
          }
        ]
        @session = { date: @date, talks: @talks }
        @robot.brain.data.sdt.sessions = [@session]


      it "shows last session details", (done) ->
        @robot.adapter.on "send", (envelope, strings) ->
          expect(strings).to
            .include "These are the last (1) session details:\n11/05/2015:\n" +
                     "- *Hello world!* _by John Doe (john)_\n" +
                     "- *Ruby programming* _by Jane Doe (jane) " +
                     "& John Doe (john)_"
          done()

        message = "hubot sdt sessions"
        @robot.adapter.receive newTestMessage(@robot, message)

  describe "submit", ->
    context "when there are not sesions scheduled", ->

      it "says there are not sessions", (done) ->
        @robot.adapter.on "send", (envelope, strings) ->
          expect(strings).to
            .include "Sorry, there aren't sessions scheduled yet."
          done()

        message = "hubot sdt submit x"
        @robot.adapter.receive newTestMessage(@robot, message)

    context "when the curren session schedule has a free slot", ->
      beforeEach ->
        @date = moment().format('L')
        @session = { date: @date, talks: [{}] }
        @robot.brain.data.sdt.sessions = [@session]

      it "registers submission", (done) ->
        @robot.adapter.on "reply", (envelope, strings) =>
          expect(strings).to
            .include "Sure, your talk _x_ has been scheduled for session on " +
              "#{@date}."
          done()

        message = "hubot sdt submit x"
        @robot.adapter.receive newTestMessage(@robot, message)


    context "when the current session schedule is full", ->
      beforeEach ->
        @date = moment().format('L')
        @session = { date: @date, talks: [{}, {}] }
        @robot.brain.data.sdt.sessions = [@session]

      it "does not accept submission", (done) ->
        @robot.adapter.on "reply", (envelope, strings) =>
          expect(strings).to
            .include "Sorry, we reached the limit of talks " +
                     "for session on #{@date}."
          done()

        message = "hubot sdt submit x"
        @robot.adapter.receive newTestMessage(@robot, message)
