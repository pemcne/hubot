
module.exports = (robot) ->
  robot.hear /hodor/i, (msg) ->
    msg.send "Hodor!"

  robot.hear /^NO U/, (msg) ->
    msg.send "NO U"

  robot.hear /^good bot/i, (msg) ->
    msg.send ":blush: thanks!"

  robot.hear /fuck you hubot/i, (msg) ->
    msg.send ":feelsangercryman:"
  
  robot.hear /^bad bot/i, (msg) ->
    msg.send ":feelsbadman:"
    
  robot.hear /god|jesus/i, (msg) ->
    msg.send "Yes my child?"
