require "./test_helper"

describe "sdt", ->

  describe "callbacks", ->

    context "on brain load", ->
      before ->
        @robot = newTestRobot()
        require("../scripts/sdt")(@robot)

      it "initializes a repository with the sdt namespace", ->
        expect(@robot.brain.data.sdt).to.be.empty
        @robot.brain.emit("loaded")
        expect(@robot.brain.data.sdt).not.to.be.empty
