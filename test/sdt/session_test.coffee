subject = require "../../scripts/sdt/session"

describe "sdt.Session", ->

  describe ".new", ->

    context "when initalized with a valid date string", ->
      before ->
        @session = new subject("Sep 15 2015")

      it "builds the session with numbered date format", ->
        expect(@session.date).to.equal("09/15/2015")

    context "when intialized without talks", ->
      before ->
        @session = new subject("Sep 15 2015")

      it "assigns an empty array", ->
        expect(@session.talks).to.be.instanceOf(Array).and.be.empty

    context "when intialized with talks", ->
      before ->
        @talks = [
          {
            title: "Tech communities",
            speakers: [
              name: "john",
              real_name: "John Doe"
            ]
          }
        ]
        @session = new subject("Sep 15 2015", @talks)

      it "assigns given talks", ->
        for talk in @talks
          expect(@session.talks).to.include(talk)
