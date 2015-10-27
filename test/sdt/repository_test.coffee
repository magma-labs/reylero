subject = require "../../scripts/sdt/repository"

describe "sdt.Repository", ->

  describe ".new", ->

    context "when sdt database namespace is undefined", ->

      before ->
        @db = { data: { sdt: undefined } }

      it "initializes sessions list", ->
        expect(new subject(@db).db.data.sdt.sessions)
          .that.is.an('array').and.is.empty

    context "when sdt database namespace is already defined", ->

      before ->
        @session =
          data: "10/08/2015"
          talks: [
            {
              title: "Unit testing with mocha.js",
              speakers: [ { name: "jane", real_name: "Jane Doe" } ]
            }
          ]

        @db = { data: { sdt: { sessions: [@session] } } }

      it "keeps existing sessions list", ->
        expect(new subject(@db).db.data.sdt.sessions).to.include @session

  describe "#addSession", ->
    before ->
      @session =
          data: "10/08/2015"
          talks: [
            {
              title: "Test assertions with chai.js",
              speakers: [ { name: "jane", real_name: "Jane Doe" } ]
            }
          ]
      @db = { data: { sdt: { sessions: [] } }}

     it "adds the session to the database", ->
       repository = new subject(@db)
       expect(repository.db.data.sdt.sessions).to.not.include @session
       repository.addSession(@session)
       expect(repository.db.data.sdt.sessions).to.include @session

  describe "#currentSession", ->

    context "when there aren't any sessions", ->
      before ->
        @db = { data: { sdt: { sessions: [] } } }

      it "does not return any session", ->
        expect(new subject(@db).currentSession()).to.not.exist

    context "when there are a few past sessions", ->

      before ->
        sessions = [
          { date: moment().subtract(1, "day").format("L")  },
          { date: moment().subtract(1, "week").format("L") }
        ]
        @db = { data: { sdt: { sessions: sessions } } }

      it "does not return any session", ->
        expect(new subject(@db).currentSession()).to.not.exist

     context "when there is a future session", ->
       before ->
         @session =
           date: moment().add(1, 'day').format("L")

         @db = { data: { sdt: { sessions: [@session] } } }

       it "returns the session", ->
         expect(new subject(@db).currentSession()).to.equal @session

      context "when there are more than one future session", ->
        before ->
          @one_day_from_now_session =
           date: moment().add(1, 'day').format("L")

          @one_week_from_now_session =
            date: moment().add(1, 'week').format("L")

          @db = { data: { sdt: { sessions: [
            @one_day_from_now_session,
            @one_week_from_now_session
          ]}}}

        it "returns the lastest", ->
          expect(new subject(@db).currentSession())
            .to.equal @one_week_from_now_session

       context "when there's a session on the current day", ->
         before ->
           @session =
             date: moment().format("L")

           @db = { data: { sdt: { sessions: [@session] } } }

         it "returns it", ->
           expect(new subject(@db).currentSession()).to.equal @session

  describe "#findUser", ->
    before ->
      @db = { usersForFuzzyName: sinon.spy(), data: { sdt: undefined }}

    it "relies on hubot brain's usersForFuzzyName user finder", ->
      repository = new subject(@db)
      repository.findUser("john")
      expect(@db.usersForFuzzyName).to.have.been.calledWith("john")

  describe "#sessions", ->

    before ->
      @oldest = { date: "08/21/2015"}
      @older = { date: "09/10/2015" }
      @newest = { date: "09/15/2015" }

      @db = { data: { sdt: { sessions: [@oldest, @older, @newest] } } }

    it "returns a lists of sessions sorted by date", ->
       repository = new subject(@db)
       expect(repository.sessions()[0]).to.equal(@newest)
       expect(repository.sessions()[1]).to.equal(@older)
       expect(repository.sessions()[2]).to.equal(@oldest)
