# Description
#   Trivia
# Commands:
#   hubot trivia question
#   hubot trivia answer

fuzzy = require('fuzzy-matching')
numtowords = require('number-to-words')
wordstonum = require('words-to-numbers')
continuous = true

pruneAnswer = (answer) ->
  out = [answer]
  # Remove any a/an/the/or
  article_answer = answer.replace(/\b(a|an|the)\b\s+/gi, '')
  if article_answer != answer
    out.push(article_answer)
  # Remove punctuation
  punc_answer = answer.replace(/(\.|,|&|!)/g, '')
  if punc_answer != answer
    out.push(article_answer)
  # Convert any numbers to word form
  if answer.match(/^\d+$/)
    out.push(numtowords.toWords(answer))
  # Convert any word numbers into actual numbers
  numword_answer = wordstonum.wordsToNumbers(answer)
  if numword_answer != answer
    out.push(numword_answer)
  decade_answer = answer.match(/^19(\d{2})s?$/)
  if decade_answer != null
    d = decade_answer[1]
    out.push("#{d}")
    out.push("#{d}s")
  return out

processOpentdbQuestion = (body) ->
  d = JSON.parse(body).results[0]
  question = decodeURIComponent(d.question)
  category = decodeURIComponent(d.category)
  answer = decodeURIComponent(d.correct_answer)
  choices = d.incorrect_answers
  choices.push(answer)
  choices.sort(() -> Math.random() - 0.5)
  for i in [0...choices.length]
    s = choices.shift()
    choices.push(decodeURIComponent(s))
  return {
    question: question
    category: category
    answer: answer
    choices: choices
  }

processTriviaGeneratorQuestion = (body) ->
  d = JSON.parse(body)
  question = d.question
  answer = d.answer
  category = d['categories'].join(', ')
  category = category.charAt(0).toUpperCase() + category.slice(1)
  return {
    question: question
    category: category
    answer: answer
    choices: null
  }

module.exports = (robot) ->
  all_questions = () -> robot.brain.data.questions ?= {}

  askQuestion = (msg) ->
    room = getCurrentRoom(msg)
    sources = [{
      name: 'OpenTDB'
      url: 'https://opentdb.com/api.php?amount=1&type=multiple&encode=url3986'
      callback: processOpentdbQuestion
    }, {
      name: 'TriviaGenerator'
      url: 'http://159.203.60.127/questions?limit=1'
      callback: processTriviaGeneratorQuestion
    }]
    source = msg.random sources
    robot.logger.info("Pulling question from #{source.name}")
    robot.http(source.url).get() (err, res, body) ->
      question = source.callback(body)
      robot.logger.info('question', question)
      question.possible = pruneAnswer(question.answer)
      question.match = new fuzzy(question.possible)
      all_questions()[room] = question
      robot.logger.info('Possible answers:', question.possible.join(', '))
      msg.send "[#{question.category}] #{question.question}"

  answerQuestion = (correct, msg) ->
    room = getCurrentRoom(msg)
    room_question = all_questions()[room]
    if room_question == undefined || room_question.answer == null
      msg.send "Ask a question first"
      return
    if correct
      correctStr = "Correct!! "
    else
      correctStr = ""
    msg.send "#{correctStr}#{room_question.question} -- #{room_question.answer}"
    delete all_questions()[room]
    if continuous
      askQuestion(msg)

  getCurrentRoom = (msg) ->
    return msg.envelope.room || 'shell'

  robot.respond /trivia question/, (msg) ->
    askQuestion(msg)

  robot.respond /trivia answer/, (msg) ->
    answerQuestion(false, msg)
  
  robot.respond /trivia hint/, (msg) ->
    room = getCurrentRoom(msg)
    room_question = all_questions()[room]
    if room_question.choices == null
      msg.send 'No hint for this question, sorry.'
    else
      hint = room_question.choices.join('\n')
      msg.send hint

  robot.hear /(.+)/, (msg) ->
    room = getCurrentRoom(msg)
    room_question = all_questions()[room]
    if room_question != undefined
      s = msg.match[1].trim()
      r = room_question.match.get(s)
      robot.logger.info(room_question.answer, s, r)
      if r.distance > 0.85
        answerQuestion(true, msg)

  robot.respond /fuck.+question/, (msg) ->
    msg.send "Sorry :("
    answerQuestion(false, msg)
