moment = require "moment"

class Session
  constructor: (date, @talks = []) ->
    @date = moment(new Date(date)).format("L")

module.exports = Session
