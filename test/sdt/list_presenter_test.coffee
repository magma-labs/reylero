subject = require "../../scripts/sdt/list_presenter"

describe "sdt.ListPresenter", ->

  describe ".speakers", ->

    context "when called with only one speaker", ->
      before ->
        @speakers = [
          { name: "john_doe", real_name: "John Doe" }
        ]

      it "returns its real name and username surrounded by parentheses", ->
        expect(subject.speakers(@speakers)).to.equal "John Doe (john_doe)"

    context "when called with more than one speaker", ->
      before ->
        @speakers = [
          { name: "jane", real_name: "Jane" }
          { name: "john", real_name: "John" }
        ]

      it "returns a sorted list of their names and usernames joined by an &", ->
        expect(subject.speakers(@speakers)).to.equal "Jane (jane) & John (john)"

  describe ".talks", ->

    context "when called with an empty talk list", ->

      it "returns a message explaining it",->
        expect(subject.talks([])).to.equal "- No talks"

    context "when called with only one talk", ->

      before ->
        @talks = [
          {
            title: "Writing CoffeeScript",
            speakers: [
              { name: "jane", real_name: "Jane"  }
            ]
          }
        ]

      it "returns a formatted talk description with speaker details", ->
        expect(subject.talks(@talks)).to
          .equal "- *Writing CoffeeScript* _by Jane (jane)_"

    context "when called with more than one talk", ->
      before ->
        @talks = [
          {
            title: "Learning NodeJS",
            speakers: [
              { name: "jane", real_name: "Jane"  }
            ]
          },
          {
            title: "Hubot scripting",
            speakers: [
              { name: "jane", real_name: "Jane Doe" }
              { name: "john", real_name: "John Doe" }
            ]
          }
        ]


      it "returns a formatted talk description list with speaker details", ->
        expect(subject.talks(@talks)).to
          .equal "- *Learning NodeJS* _by Jane (jane)_\n" +
                 "- *Hubot scripting* _by Jane Doe (jane) & John Doe (john)_"
