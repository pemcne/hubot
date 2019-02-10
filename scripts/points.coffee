# Commands
#  hubot +/-X to/for <name> - Adds/removes points for <name>
#  hubot score for <name> - Returns points for <name>
#  hubot leaderboard - Shows the top 3 points
#  hubot clear all scores - Clears all points

module.exports = (robot) ->
  allpoints = () -> robot.brain.data.points ?= {}
  sortpoints = () ->
    output = []
    points = allpoints()
    for key, value of points
      if points.hasOwnProperty(key)
        output.push([key, value])
      output.sort (a, b) -> b[1] - a[1]
    return output

  robot.respond /(\+|-)\s*(\d+) (to|for) (.+)/, (msg) ->
    symbol = msg.match[1].trim()
    amount = msg.match[2].trim() * 1
    key = msg.match[4].trim()
    points = allpoints()[key] * 1 or 0
    if (symbol == "+")
      points += amount
    else
      points -= amount
    allpoints()[key] = points
    msg.send "#{symbol}#{amount} to #{key} = #{points}"

  robot.respond /score for (.+)/, (msg) ->
    key = msg.match[1].trim()
    points = allpoints()[key] * 1 or 0
    msg.send "#{msg.message.user.name}: #{key} has #{points} points right now"

  robot.respond /leaderboard/, (msg) ->
    points = sortpoints()
    counter = 0
    output = ""
    for p in points
      name = p[0]
      point = p[1]
      output += "#{name}: #{point}\n"
      counter++
      if counter >= 3
        break
    if output == ""
      output = "No scores yet!"
    msg.send "#{output}"

  robot.respond /clear all scores/, (msg) ->
    for key of allpoints()
      delete allpoints()[key]
    msg.send "Cleared the board!"
