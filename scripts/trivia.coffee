# Description
#   Trivia
# Commands:
#   hubot trivia question
#   hubot trivia answer

fuzzy = require('fuzzy-matching')
continuous = true

pruneAnswer = (answer) ->
  out = [answer]
  # Remove any a/an/the/or
  article_answer = answer.replace(/(a|an|the)\s+/gi, '')
  if article_answer != answer
    out.push(article_answer)
  # Remove punctuation
  punc_answer = answer.replace(/(\.|,|&|!)/g, '')
  if punc_answer != answer
    out.push(article_answer)
  return out

module.exports = (robot) ->
  all_questions = () -> robot.brain.data.questions ?= {}

  askQuestion = (msg) ->
    # This random IP is from http://www.randomtriviagenerator.com/#/
    robot.http('http://159.203.60.127/questions?limit=1').get() (err, res, body) ->
      d = JSON.parse(body)
      question = d.question
      answer = d.answer
      fuzzy_answer = pruneAnswer(answer)
      answer_match = new fuzzy(fuzzy_answer)
      categories = d['categories'].join(', ')
      all_questions[msg.envelope.room] = {
        question: question
        answer: answer
        match: answer_match
      }
      msg.send "[#{categories}] #{question}"

  answerQuestion = (correct, msg) ->
    room_question = all_questions[msg.envelope.room]
    if room_question == undefined || room_question.answer == null
      msg.send "Ask a question first"
      return
    if correct
      correctStr = "Correct!! "
    else
      correctStr = ""
    msg.send "#{correctStr}#{room_question.question} -- #{room_question.answer}"
    delete all_questions[msg.envelope.room]
    if continuous
      askQuestion(msg)

  robot.respond /trivia question/, (msg) ->
    askQuestion(msg)

  robot.respond /trivia answer/, (msg) ->
    answerQuestion(false, msg)

  robot.hear /(.+)/, (msg) ->
    room_question = all_questions[msg.envelope.room]
    if room_question != undefined
      s = msg.match[1].trim()
      r = room_question.match.get(s)
      if r.distance > 0.85
        answerQuestion(true, msg)

  robot.respond /fuck.+question/, (msg) ->
    msg.send "Sorry :("
    answerQuestion(false, msg)
