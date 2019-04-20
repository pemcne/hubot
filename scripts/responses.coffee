
module.exports = (robot) ->
  robot.hear /hodor/i, (msg) ->
    msg.send "Hodor!"

  robot.hear /^NO U/, (msg) ->
    msg.send "NO U"