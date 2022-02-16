# Description:
#   Slack version of wordle
# Commands:
#   hubot huwordle new - generates a new word and gives up the previous attempt
#   hubot huwordle toggle strict mode - toggles strict mode which restricts guesses to the dictionary

fs = require 'fs'
path = require 'path'

dict_path = path.resolve(__dirname, "..", "misc/dictionary.json")
dict = JSON.parse(fs.readFileSync dict_path, 'utf8')

CORRECT = ':large_green_square:'
PRESENT = ':large_yellow_square:'
ABSENT = ':black_large_square:'

module.exports = (robot) ->
  huwordle = () -> robot.brain.data.huwordle ?= {}

  new_word = (msg) ->
    word = msg.random dict
    huwordle().word = word
    console.log "Secret word is #{word}"
    msg.send "Word is #{word.length} letters"
  
  process_guess = (guess, word) ->
    wordchars = word.split('')
    guesschars = guess.split('')
    output = Array(word.length)
    # First pass for corrects
    for i of wordchars
      if guesschars[i] == wordchars[i]
        output[i] = CORRECT
        guesschars[i] = null
        wordchars[i] = null
    for i of wordchars
      c = guesschars[i]
      if c != null
        # Check for presents
        index = wordchars.indexOf(c)
        if index == -1
          output[i] = ABSENT
        else
          output[i] = PRESENT
          wordchars[index] = null
    return output
  
  emoji = (str) ->
    output = []
    for c in str
      output.push(":alphabet-yellow-#{c}:")
    return output

  robot.respond /huwordle new/, (msg) ->
    if msg.message.room != 'C033N9SPX33'
      return
    console.log(huwordle())
    if huwordle().word != undefined
      msg.send "Previous word was '#{huwordle().word}'"
    if huwordle().strict_mode == undefined
      huwordle().strict_mode = true
    new_word(msg)
  
  robot.respond /huwordle toggle strict mode/, (msg) ->
    huwordle().strict_mode = !(huwordle().strict_mode)
    msg.send "Strict mode is now: #{huwordle().strict_mode}"
  
  robot.hear /(.+)/, (msg) ->
    if msg.message.room != 'C033N9SPX33'
      return
    word = huwordle().word
    if word == undefined
      return
    guess = msg.match[1].trim().toLowerCase()
    if guess == word
      msg.send "Correct! Secret word was '#{word}'"
      return new_word(msg)
    if guess.length != word.length
      return
    if huwordle().strict_mode && !(guess in dict)
      return
    results = process_guess(guess, word)
    emoji_guess = emoji(guess)
    output = "#{emoji_guess.join('')}\n#{results.join('')}"
    msg.send output