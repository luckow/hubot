# Description:
#   Preview URLs using embed.ly data
# Commands:
#   

module.exports = (robot) ->

  embedlyUrl = "http://api.embed.ly/1/oembed?url="

  # ([A-Za-z]{3,9})://([-;:&=\+\$,\w]+@{1})?([-A-Za-z0-9\.]+)+:?(\d+)?((/[-\+~%/\.\w]+)?\??([-\+=&;%@\.\w]+)?#?([\w]+)?)?
  urlPattern = "/([A-Za-z]{3,9}):\\/\\/([-;:&=\\+\\$,\\w]+@{1})?([-A-Za-z0-9\\.]+)+:?(\\d+)?((\\/[-\\+~%\\/\\.\\w]+)?\\??([-\\+=&;%@\\.\\w]+)?#?([\\w]+)?)?/gi"
  ignorePattern = "youtube\\.com"
  
  robot.hear eval(urlPattern), (msg) ->
    for i in msg.match
      url = i

      if url.match(new RegExp(ignorePattern, "gi")) 
        continue

      now = new Date().getTime()
      robot.http(embedlyUrl + url)
        .get() (err, res, body) ->
          if res.statusCode >= 300
            #console.log "Cannot retrieve url [code: " + res.statusCode + "]"
            #console.log body
            return

          try
            json = JSON.parse(body)
            linktype = json.type
            thumbnail = json.thumbnail_url
            title = json.title
            description = json.description

            #console.log body

            if(linktype != "photo" && linktype != "rich")
              message = '"' + title + '"' if title?
              message += ' ' + thumbnail if thumbnail?
              message += ' ' + description if description?
              message += " [" + json.url + "]" if json.url? && message?
              msg.send message if message?

          catch error
            try
              msg.send "[*ERROR*] " + json.errorMessages[0]
            catch reallyError
              msg.send "[*ERROR*] " + reallyError


