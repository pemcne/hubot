# Description:
#   What happened today?
# Commands:
#   hubot what happened today?

cheerio = require('cheerio')
module.exports = (robot) ->
  robot.respond /what happened today\?/, (msg) ->
    robot.http("https://en.wikipedia.org/w/api.php?format=json&action=parse&page=Wikipedia:On%20this%20day/Today").get() (err, res, body) ->
      d = JSON.parse(body)
      t = d['parse']['text']['*']
      c = cheerio.load(t)
      events = []
      dates = c('ul').map (i, el) ->
        el = cheerio(el).text().trim()
        for str in el.split("\n")
          if str.search(/^\d\d\d\d.+/) != -1
            events.push(str)
      e = events[Math.floor(Math.random() * events.length)]
      msg.send "In #{e}"
