# Description:
#   Keeps track of wordle scores
#
# Commands:
#   hubot wordle stats
#   hubot wordle import (wordle|lewdle) num1s num2s num3s num4s num5s num6s

attempts = {
  'wordle': 6,
  'lewdle': 6,
  'dordle': 7
}
module.exports = (robot) ->
  allstats = () -> robot.brain.data.wordle ?= {}

  robot.hear /.*(Wordle|Lewdle|Dordle)\s\W?\d+\s(.+)\/\d/, (msg) ->
    user = msg.envelope.user.name

    game = msg.match[1].trim().toLowerCase()
    score = msg.match[2].trim()
    if game == 'dordle'
      scores = score.split('&')
      for i of scores
        if scores[i] == 'X'
          scores[i] = attempts[game] + 1
      score = (((scores[0] * 1) + (scores[1] * 1)) / 2).toPrecision(2)
    if score == 'X'
      score = attempts[game] + 1
    else
      score = score * 1

    userstats = allstats()[user] or {}
    gamestats = userstats[game] or {score: 0, games: 0}
    gamestats.score += score
    gamestats.games++
    userstats[game] = gamestats
    allstats()[user] = userstats
    console.log(allstats())
  
  robot.respond /wordle stats/, (msg) ->
    user = msg.envelope.user.name
    gamestats = allstats()[user]
    if gamestats == undefined
      msg.send "No stats yet"
    else
      scores = []
      for game of gamestats
        totalgames = gamestats[game].games
        avg = (gamestats[game].score / totalgames).toPrecision(3)
        attempt = attempts[game]
        scores.push("#{game}:#{avg}/#{attempt} [#{totalgames} games]")
      output = "Averages for #{user} - " + scores.join(' | ')
      msg.send output
  
  robot.respond /wordle import (Wordle|lewdle) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+)/i, (msg) ->
    user = msg.envelope.user.name

    game = msg.match[1].trim().toLowerCase()
    score1 = msg.match[2].trim() * 1
    score2 = msg.match[3].trim() * 1
    score3 = msg.match[4].trim() * 1
    score4 = msg.match[5].trim() * 1
    score5 = msg.match[6].trim() * 1
    score6 = msg.match[7].trim() * 1

    userstats = allstats()[user] or {}
    gamestats = userstats[game] or {score: 0, games:0}
    gamestats.games = score1 + score2 + score3 + score4 + score5 + score6
    gamestats.score = score1 + (score2 * 2) + (score3 * 3) + (score4 * 4) + (score5 * 5) + (score6 * 6)
  
    userstats[game] = gamestats
    allstats()[user] = userstats
    msg.send "Imported scores for #{game} - #{gamestats.games} games"

  robot.hear /wordle clear all stats/, (msg) ->
    for key of allstats()
      delete allstats()[key]