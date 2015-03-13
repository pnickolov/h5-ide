
browser = require('./env/Browser')
window = browser.window

#b(){var w = window; w.alert= function(d){console.log(d)}; a.apply(w, arguments)}

loadfile = (path)->
  temp = null
  define = (obj)->
    temp  = obj
  g = global
  g.define = define
  require.apply(g, arguments)
  temp

describe "Lang file generated format", ()->
  it "should not contains Chinese char in English lang file", (done)->
    english = loadfile("../src/nls/en-us/lang")


    for key, value of english
      for sub, subvalue of value
        if subvalue.match(/[\u4e00-\u9fa5]/)
          console.log key, sub, subvalue
          done new Error("Chinese chars shouldn't appear here.")
          return

    console.log "----------------========Chinese Chars Check Passed========-------------------"
    done()

     