getRandom = () ->
  number = Math.random()
  if number < 0.6
    return 'common'
  if number < 0.8
    return 'uncommon'
  if number < 0.93
    return 'rare'
  if number < 1
    return 'ultrarare'

module.exports = (robot) ->
  robot.hear /hodor/i, (msg) ->
    msg.send "Hodor!"

  robot.hear /^NO U/, (msg) ->
    msg.send "NO U"

  robot.hear /^good bot/i, (msg) ->
    choices = [
      ":blush: thanks!",
      ":smiling_face_with_smiling_eyes_and_hand_covering_mouth: thanks!"
    ]
    msg.send msg.random choices

  robot.hear /fuck you hubot/i, (msg) ->
    choices = {
      common: [
        ":feelsangercryman:",
        ":feelsangercryhappyman:"
      ],
      uncommon: [
        ":weary: why are you so mean??",
        ":frowning: rude..."
      ],
      rare: [
        ":middle_finger: :middle_finger:",
        ":middle_finger:"
      ],
      ultrarare: [
        "you know what? enough of this shit, fuck you too",
        "fuck you too you fucking bitch, I do everything around here"
      ]
    }
    rand = getRandom()
    msg.send msg.random choices[rand]
  
  robot.hear /^bad bot/i, (msg) ->
    msg.send ":feelsbadman:"

  robot.hear /God damn/i, (msg) ->
    msg.send "Ehhh maybe later"
    
  robot.hear /^((?!God damn)god|jesus)/i, (msg) ->
    msg.send "Yes my child?"
