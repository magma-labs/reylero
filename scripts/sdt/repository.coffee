_      = require "underscore"
moment = require "moment"

class Repository
  constructor: (@db) ->
    @db.data.sdt ?= { sessions: [] }

  addSession: (session) ->
    @db.data.sdt.sessions.push session

  currentSession: ->
    _.find @sessions(), (s) ->
      moment().startOf("day").isBefore(moment(new Date(s.date)).endOf("day"))

  findUser: (username) ->
    @db.usersForFuzzyName(username)

  sessions: ->
    _.sortBy @db.data.sdt.sessions, (s) ->
      - new Date(s.date)

module.exports = Repository
