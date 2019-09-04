posTagger = require( 'wink-pos-tagger' )
tagger = posTagger()

module.exports = (robot) ->
  getSynonym = (word, word_type, i) -> new Promise (resolve) ->

    if word_type in ['JJ', 'JJR', 'JJS'] 
      this_word_type = "adjective"
    else if word_type in ['RB', 'RBR', 'RBS']
      this_word_type = "adverb"
    else if word_type in ['NN', 'NNP', 'NNS', 'NNPS'] 
      this_word_type = "noun"
    else if word_type in ['VB','VBD','VBG','VBN','VBP','VBZ'] 
      this_word_type = "verb"
    else
      return resolve {'word': word, 'index': i}

    robot.http('http://words.bighugelabs.com/api/2/a182cf1301cc4408e65536812d869767/'+word+'/json').get() (err, res, body) ->
      if err
        console.log "ERROR"
        console.log err
        return resolve {'word': word, 'index': i}

      try
        d = JSON.parse(body)
      catch error
        return resolve {'word': word, 'index': i}

      for key, value of d
        if key.toLowerCase() == this_word_type
          # Sort the array by length
          if 'syn' of value
            # Grab one of the longest word from the list of synonyms
            value.syn.sort (a,b) ->
              return if a.length < b.length then 1 else -1
            index_to_return = Math.floor(Math.random()*(value.syn.length * 0.3))
            return resolve {'word': value.syn[index_to_return], 'index': i}
          else if 'sim' of value
            # Grab one of the longest word from the list of similar words
            value.sim.sort (a,b) ->
              return if a.length < b.length then 1 else -1
            index_to_return = Math.floor(Math.random()*(value.sim.length * 0.3))
            return resolve {'word': value.sim[index_to_return], 'index': i}

      # Fallback to returning the original word.
      return resolve {'word': word, 'index': i}

  robot.respond /fancyspeak (.*)/i, (msg) ->
    response = []
    i = 0
    join_counter = 0
    for part in tagger.tagSentence(msg.match[1])
      if part.tag == "word"
          response.push("")
          getSynonym(part.value, part.pos, i).then (res) ->
            # Special case for apostrophes, because tagSentence() separates "that's" into "that" and "'s"
            if res.word.charAt(0) == "'"
              # No leading space
              word = res.word
            else  
              word = " " + res.word

            response.splice(res.index, 1, word);
            # Not the safest async code, but should work fine
            # If join_counter reaches i, then we have processed all elements
            join_counter++
            if join_counter == i
              #msg.send msg.message.user.name + "." + response.join("")
              msg.send ">" + response.join("")
      else
          response.push(part.value)
          join_counter++
      i++

