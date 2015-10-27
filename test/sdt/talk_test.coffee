subject = require "../../scripts/sdt/talk"

describe "sdt.Talk", ->

  describe ".new", ->

    context "when multiple speakers", ->

      before ->
        @speakers = [
          { name: "john", real_name: "John Doe" },
          { name: "jane", real_name: "Jane Doe" }
        ]

        @talk = new subject("Mastering Javascript", @speakers[0], @speakers[1])

      it "assigns both as speakers", ->
        for speaker in @speakers
          expect(@talk.speakers).to.include(speaker)

