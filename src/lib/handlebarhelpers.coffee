
# This file is used to place handlebar helpers. All handlebar helpers should be placed here.
# Any helper that is not in this file might lead to compile error.

define ["i18n!/nls/lang.js", "handlebars"], ( lang )->

  #i18n
  Handlebars.registerHelper 'i18n', ( text ) ->
    members = text.split '.'
    if members.length is 1 then members.unshift 'IDE'

    t = lang[ members[0] ][ members[1] ] or lang.PROP[ members[1] ]
    ### env:dev ###
    t = t || text
    ### env:dev:end ###

    ### env:prod ###
    t = t || text || "undefined"
    ### env:prod:end ###

    # Support sprint
    if arguments.length > 2
      args = [].slice.call arguments, 1, -1
      args.unshift t
      t = sprintf.apply null, args

    new Handlebars.SafeString t

  Handlebars.registerHelper 'tolower', ( result ) ->
    return new Handlebars.SafeString result.toLowerCase()

  Handlebars.registerHelper 'emptyStr', ( v1 ) ->
    if v1 in [ '', undefined, null ]
        '-'
    else
        new Handlebars.SafeString v1

  Handlebars.registerHelper 'readableVt', ( text ) ->
    if text in [ '', undefined, null ]
      return '-'

    lang.IDE[ "PROP.VOLUME_TYPE_#{text.toUpperCase()}" ]

  Handlebars.registerHelper 'UTC', ( text ) ->
    new Handlebars.SafeString new Date( +text ).toUTCString()

  Handlebars.registerHelper 'breaklines', (text) ->
    text = Handlebars.Utils.escapeExpression(text)
    text = text.replace(/(\r\n|\n|\r)/gm, '<br>')
    return new Handlebars.SafeString(text)

  # nl2br
  Handlebars.registerHelper 'nl2br', (text) ->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    return new Handlebars.SafeString(nl2br)

  # if equal
  Handlebars.registerHelper 'ifCond', ( v1, v2, options ) ->
    if (v1 is v2) or (v1 and v2 and v1.valueOf?() is v2.valueOf?())
      return options.fn(this)
    return options.inverse this



  Handlebars.registerHelper 'timeStr', ( v1 ) ->
      d = new Date( +v1 )

      if not isNaN(parseFloat(v1)) and isFinite(v1) and v1 > 0
        return d.toLocaleDateString() + " "+ d.toTimeString()
      if isNaN( Date.parse( v1 ) ) or not d.toLocaleDateString or not d.toTimeString
          if v1
              return new Handlebars.SafeString v1
          else
              return '-'

      d = new Date( v1 )
      d.toLocaleDateString() + " " + d.toTimeString()

  Handlebars.registerHelper "plusone", ( v1 ) ->
      v1 = parseInt( v1, 10 )
      if isNaN( v1 )
          return v1
      else
          return '' + (v1 + 1)

  Handlebars.registerHelper "getInvalidKey", ( v1, v2 ) -> return v1[v2]

  Handlebars.registerHelper "doubleIf", ( v1, v2, options ) ->
    return options.fn this if v1 and v2
    return options.inverse this

  Handlebars.registerHelper "or", ( v1, v2 ) -> v1 || v2

  # Handlebars.registerHelper "eachObj", ( obj, fn )->
  #   buffer = ""
  #   data = { key : "", value : "" }

  #   for key, value of obj
  #     if obj.hasOwnProperty key
  #       data.key   = key
  #       data.value = value
  #       buffer += fn(data)
  #   buffer

  Handlebars.registerHelper "simpleTime", ( time ) -> MC.dateFormat(new Date(time), "yyyy-MM-dd hh:mm:ss")

  Handlebars.registerHelper "firstOfSplit", ( content, splitter )-> content.split("-")[0]


  Handlebars.registerHelper 'formatTime', (dateStr, format)->
    utc = false
    date = new Date(dateStr)
    MMMM = lang.IDE.DATE_FORMAT_MONTHS.split(', ')
    MMM = lang.IDE.DATE_FORMAT_MON.split(', ')
    dddd = lang.IDE.DATE_FORMAT_WEEK.split(', ')
    ddd = lang.IDE.DATE_FORMAT_WEK.split(', ')
    daySuffix = lang.IDE.DATE_FORMAT_DAY
    yearSuffix = lang.IDE.DATE_FORMAT_YEAR
    monthSuffix = lang.IDE.DATE_FORMAT_MONTH
    y = if utc then date.getUTCFullYear() else date.getFullYear()

    ii = (i, len) ->
      s = i + ''
      len = len or 2
      while s.length < len
        s = '0' + s
      s

    format = format.replace(/(^|[^\\])yyyy+/g, '$1' + y + yearSuffix)
    format = format.replace(/(^|[^\\])yy/g, '$1' + y.toString().substr(2, 2))
    format = format.replace(/(^|[^\\])y/g, '$1' + y + yearSuffix)
    M = (if utc then date.getUTCMonth() else date.getMonth()) + 1
    format = format.replace(/(^|[^\\])MMMM+/g, '$1' + MMMM[0])
    format = format.replace(/(^|[^\\])MMM/g, '$1' + MMM[0])
    format = format.replace(/(^|[^\\])MM/g, '$1' + ii(M) + monthSuffix)
    format = format.replace(/(^|[^\\])M/g, '$1' + M + monthSuffix)
    d = if utc then date.getUTCDate() else date.getDate()
    format = format.replace(/(^|[^\\])dddd+/g, '$1' + dddd[0])
    format = format.replace(/(^|[^\\])ddd/g, '$1' + ddd[0])
    format = format.replace(/(^|[^\\])dd/g, '$1' + ii(d) + daySuffix)
    format = format.replace(/(^|[^\\])d/g, '$1' + d + daySuffix)
    H = if utc then date.getUTCHours() else date.getHours()
    format = format.replace(/(^|[^\\])HH+/g, '$1' + ii(H))
    format = format.replace(/(^|[^\\])H/g, '$1' + H)
    h = if H > 12 then H - 12 else if H == 0 then 12 else H
    format = format.replace(/(^|[^\\])hh+/g, '$1' + ii(h))
    format = format.replace(/(^|[^\\])h/g, '$1' + h)
    m = if utc then date.getUTCMinutes() else date.getMinutes()
    format = format.replace(/(^|[^\\])mm+/g, '$1' + ii(m))
    format = format.replace(/(^|[^\\])m/g, '$1' + m)
    s = if utc then date.getUTCSeconds() else date.getSeconds()
    format = format.replace(/(^|[^\\])ss+/g, '$1' + ii(s))
    format = format.replace(/(^|[^\\])s/g, '$1' + s)
    f = if utc then date.getUTCMilliseconds() else date.getMilliseconds()
    format = format.replace(/(^|[^\\])fff+/g, '$1' + ii(f, 3))
    f = Math.round(f / 10)
    format = format.replace(/(^|[^\\])ff/g, '$1' + ii(f))
    f = Math.round(f / 10)
    format = format.replace(/(^|[^\\])f/g, '$1' + f)
    T = if H < 12 then lang.IDE.DATE_FORMAT_AM else lang.IDE.DATE_FORMAT_PM
    format = format.replace(/(^|[^\\])TT+/g, '$1' + T)
    format = format.replace(/(^|[^\\])T/g, '$1' + T.charAt(0))
    t = T.toLowerCase()
    format = format.replace(/(^|[^\\])tt+/g, '$1' + t)
    format = format.replace(/(^|[^\\])t/g, '$1' + t.charAt(0))
    tz = -date.getTimezoneOffset()
    K = if utc or !tz then 'Z' else if tz > 0 then '+' else '-'
    if !utc
      tz = Math.abs(tz)
      tzHrs = Math.floor(tz / 60)
      tzMin = tz % 60
      K += ii(tzHrs) + ':' + ii(tzMin)
    format = format.replace(/(^|[^\\])K/g, '$1' + K)
    day = (if utc then date.getUTCDay() else date.getDay()) + 1
    format = format.replace(new RegExp(dddd[0], 'g'), dddd[day])
    format = format.replace(new RegExp(ddd[0], 'g'), ddd[day])
    format = format.replace(new RegExp(MMMM[0], 'g'), MMMM[M])
    format = format.replace(new RegExp(MMM[0], 'g'), MMM[M])
    format = format.replace(/\\(.)/g, '$1')
    format





  Handlebars.registerHelper "lastChar", ( string )->
    ch = string.charAt( string.length - 1 )
    if (ch >= "A" && ch <= "Z") or (ch >= "a" && ch <= "z" )
      ch
    else
      ""

  Handlebars.registerHelper "awsAmiIcon", ( amiId, region )->
    # This is a placeholder.
    # The actually implementation is in DashboardView

  Handlebars.registerHelper "awsIsEip", ( ip, region )->
    # This is a placeholder.
    # The actually implementation is in DashboardView

  Handlebars.registerHelper 'ifLogic', (v1, operator, v2, options) ->

      r
      switch operator
          when 'is'
              r = if (v1 is v2) then options.fn(this) else options.inverse(this)
          when '<'
              r = if (v1 < v2) then options.fn(this) else options.inverse(this)
          when '<='
              r = if (v1 <= v2) then options.fn(this) else options.inverse(this)
          when '>'
              r = if (v1 > v2) then options.fn(this) else options.inverse(this)
          when '>='
              r = if (v1 >= v2) then options.fn(this) else options.inverse(this)
          when 'and'
              r = if (v1 and v2) then options.fn(this) else options.inverse(this)
          when 'or'
              r = if (v1 or v2) then options.fn(this) else options.inverse(this)
          else
              r = options.inverse(this)
      r
