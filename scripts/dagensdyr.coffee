# Description:
#   This is very essential knowledge
# Commands:
#   hubot dyr/dagensdyr - Shows you the animal of the day
#   hubot vis dyr/dagensdyr - Shows you the animated animal of the day
#

# Set url
feedUrl = 'http://feeds.feedburner.com/animals'

# Include libraries
request = require('request')
parseString = require('xml2js').parseString

# Function for parsing XML
getAnimal = (xml, callable) ->
  # make request
  request.get { uri:xml, xml: true }, (err, r, body) -> 
    # parse xml into js object
    parseString body, (err, result) ->
      # loop thru results and create oject
      items = item.item for item in result.rss.channel

      # select the latest item
      callable String(items[0].title)

# hubot interaction
module.exports = (robot) ->
  # event listener for regular images
  robot.respond /(dagensdyr|dyr)/i, (msg) ->
    getAnimal feedUrl, (animal) ->
      animal = animal.split("-")[0].replace(/^\s+|\s+$/g, '')
      todaysAnimal msg, animal, false, (url) ->
        msg.send animal + " - " + url

  # event listener for animated (hopefully) gifs
  robot.respond /vis (?:dagensdyr|dyr)/i, (msg) ->
    getAnimal feedUrl, (animal) ->
      animal = animal.split("-")[0].replace(/^\s+|\s+$/g, '')
      todaysAnimal msg, animal, true, (url) ->
        msg.send animal + " - " + url

# google search api url parsing (voodoo)
todaysAnimal = (msg, query, animated, cb) ->
  cb = animated if typeof animated == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.as_filetype = 'gif' if typeof animated is 'boolean' and animated is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData.results
      if images.length > 0
        image  = msg.random images
        cb "#{image.unescapedUrl}#.png"