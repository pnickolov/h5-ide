
browser = require('./env/Browser')
window = browser.window

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
      console.log "Checking #{key} of English lang file."
      for sub, subvalue of value
        if subvalue.match(/[\u4e00-\u9fa5]/)
          console.log key, sub, subvalue
          done new Error("Chinese chars shouldn't appear here.")
          return

    console.log "----------------========Chinese Chars Check Passed========-------------------"
    done()

describe "should not contains english symbol in Chinese lang.", ()->

  chinese = loadfile("../src/nls/zh-cn/lang")
  it "should", (done)->
    fail = false
    for key, value of chinese
      console.log "Checking #{key} of Chinese file..."
      for sub, subvalue of value
        if subvalue.match(/[\,\!]/)
          if sub not in ['DATE_FORMAT_MONTHS', 'DATE_FORMAT_MON', 'DATE_FORMAT_WEEK', 'DATE_FORMAT_WEK']
            console.log key, sub, subvalue
            fail = true
    if fail
      done new Error("Chinese file check failed.")
    else
      done()

