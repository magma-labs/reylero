_ = require "underscore"

class ListDecorator
  @speakers: (speakers) ->
    _.sortBy speakers, (s) -> s.real_name
      .map (s) -> "#{s.real_name} (#{s.name})"
      .join " & "

  @talks: (talks) ->
    details = talks.map (t) => "- *#{t.title}* _by #{@speakers(t.speakers)}_"

    if talks.length > 0
      details.join "\n"
    else
      "- No talks"

module.exports = ListDecorator
