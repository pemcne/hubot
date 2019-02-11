# Description
#   Trivia
# Commands:
#   hubot trivia question
#   hubot trivia answer

fuzzy = require('fuzzy-matching')
continuous = true

module.exports = (robot) ->
  all_questions = () -> robot.brain.data.questions ?= {}

  askQuestion = (msg) ->
    # This random IP is from http://www.randomtriviagenerator.com/#/
    robot.http('http://159.203.60.127/questions?limit=1').get() (err, res, body) ->
      d = JSON.parse(body)
      question = d.question
      answer = d.answer
      fuzzy_answer = [answer]
      prune_answer = answer.replace(/^(a|the)\s*/i, '')
      if prune_answer != answer
        fuzzy_answer.push(prune_answer)
      strip_abbre = answer.replace(/\./g, '')
      if strip_abbre != answer
        fuzzy_answer.push(prune_answer)
      answer_match = new fuzzy(fuzzy_answer)
      categories = d['categories'].join(', ')
      all_questions[msg.envelope.room] = {
        question: question
        answer: answer
        match: answer_match
      }
      msg.send "[#{categories}] #{question}"

  robot.respond /trivia question/, (msg) ->
    askQuestion(msg)

  robot.respond /trivia answer/, (msg) ->
    room_question = all_questions[msg.envelope.room]
    if room_question == undefined || room_question.answer == null
      msg.send "Ask a question first"
    else
      msg.send "#{room_question.question} -- #{room_question.answer}"
      delete all_questions[msg.envelope.room]
    if continuous
      askQuestion(msg)

  robot.hear /(.+)/, (msg) ->
    room_question = all_questions[msg.envelope.room]
    if room_question != undefined
      s = msg.match[1].trim()
      r = room_question.match.get(s)
      if r.distance > 0.85
        msg.send "Correct!! #{room_question.question} -- #{room_question.answer}"
        delete all_questions[msg.envelope.room]

  robot.respond /fuck.+question/, (msg) ->
    msg.send "Sorry :("
    askQuestion(msg)
