# Description:
#   Slack version of wordle
# Commands:
#   hubot huwordle new - generates a new word and gives up the previous attempt
#   hubot huwordle toggle strict mode - toggles strict mode which restricts guesses to the dictionary
#   hubot huwordle current state - current state of the guesses

fs = require 'fs'
path = require 'path'

dict_path = path.resolve(__dirname, "..", "misc/dictionary.json")
ans_path = path.resolve(__dirname, '..', 'misc/answers.json')
dict = JSON.parse(fs.readFileSync dict_path, 'utf8')
answers = JSON.parse(fs.readFileSync ans_path, 'utf8')

CORRECT = ':large_green_square:'
PRESENT = ':large_yellow_square:'
ABSENT = ':black_large_square:'
ALPHABET = "abcdefghijklmnopqrstuvwxyz"

module.exports = (robot) ->
  huwordle = () -> robot.brain.data.huwordle ?= {}
  array_remove = (arr, element) ->
    if element in arr
      arr.splice(arr.indexOf(element), 1)

  print_state = (won, first) ->
    state = huwordle().state
    len = huwordle().word.length
    output = ""
    if !won
      if first
        output += "New word is "
      output += "#{len} letters: #{state.state.join('')}"
      if !first
        output += "\n#{PRESENT}: #{state.letters.present}"
        output += "\n#{ABSENT}: #{state.letters.absent}"
    if won
      output += "#{state.guesses} total guesses"
    return output

  new_word = (msg) ->
    word = msg.random answers
    huwordle().word = word
    huwordle().state = {
      guesses: 0,
      state: Array(word.length).fill(ABSENT),
      letters: {
        present: [],
        absent: [],
        unknown: word.split('')
      }
    }
    console.log "Secret word is #{word}"
    msg.send print_state(false, true)
  
  process_guess = (guess, word) ->
    wordchars = word.split('')
    guesschars = guess.split('')
    output = Array(word.length)
    letters = huwordle().state.letters
    huwordle().state.guesses += 1
    # First pass for corrects
    for i of wordchars
      l = guesschars[i]
      if l == wordchars[i]
        output[i] = CORRECT
        guesschars[i] = null
        wordchars[i] = null
        # Update letter state
        letters.unknown[i] = null
        huwordle().state.state[i] = emoji(l)
        if !(l in letters.unknown)
          array_remove(letters.present, l)
    for i of wordchars
      c = guesschars[i]
      if c != null
        # Check for presents
        index = wordchars.indexOf(c)
        if index == -1
          output[i] = ABSENT
          if !(c in letters.absent)
            letters.absent.push(c)
        else
          output[i] = PRESENT
          wordchars[index] = null
          if !(c in letters.present)
            letters.present.push(c)
    letters.present.sort()
    letters.absent.sort()
    huwordle().state.letters = letters
    return output
  
  emoji = (str) ->
    output = []
    for c in str
      output.push(":alphabet-yellow-#{c}:")
    return output

  robot.respond /huwordle new/, (msg) ->
    if msg.message.room != 'C033N9SPX33'
      return
    if huwordle().word != undefined
      msg.send "Previous word was '#{huwordle().word}'"
    if huwordle().strict_mode == undefined
      huwordle().strict_mode = true
    new_word(msg)
    console.log(huwordle())
  
  robot.respond /huwordle toggle strict mode/, (msg) ->
    huwordle().strict_mode = !(huwordle().strict_mode)
    msg.send "Strict mode is now: #{huwordle().strict_mode}"
  
  robot.hear /^(\w+)$/, (msg) ->
    if msg.message.room != 'C033N9SPX33'
      return
    word = huwordle().word
    if word == undefined
      return
    guess = msg.match[1].trim().toLowerCase()
    won = (guess == word)
    if guess.length != word.length
      return
    if huwordle().strict_mode && !(guess in dict)
      msg.send "'#{guess}' isn't in my dictionary"
      return
    results = process_guess(guess, word)
    emoji_guess = emoji(guess)
    output = "#{emoji_guess.join('')}\n#{results.join('')}\n"
    output += print_state(won, false)
    msg.send output
    if won
      new_word(msg)
  
  robot.respond /huwordle current state/, (msg) ->
    state = huwordle().state
    msg.send print_state(false, false)