module.exports = (robot) ->
  robot.respond /proxy (\w+) (.+)$/, (msg) ->
    channel = msg.match[1].trim()
    message = msg.match[2].trim()

    robot.messageRoom(channel, message)
