
# This file is used to place handlebar helpers. All handlebar helpers should be placed here.
# Any helper that is not in this file might lead to compile error.

define ["i18n!/nls/lang.js", "handlebars"], ( lang )->

  #i18n
  Handlebars.registerHelper 'i18n', ( text ) ->
    t = lang.ide[ text ]
    ### env:prod ###
    t = t || "undefined"
    ### env:prod:end ###

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

    lang.ide[ "PROP_VOLUME_TYPE_#{text.toUpperCase()}" ]

  Handlebars.registerHelper 'UTC', ( text ) ->
    new Handlebars.SafeString new Date( text ).toUTCString()

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
    return options.fn this if v1 is v2
    return options.inverse this


  Handlebars.registerHelper 'timeStr', ( v1 ) ->
      d = new Date( v1 )

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


  Handlebars.registerHelper 'formatTime', (timeStr, formatStr)->

     `function formatDate (date, format, utc){
        date = new Date(date)
        var MMMM = ["\x00", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var MMM = ["\x01", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var dddd = ["\x02", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        var ddd = ["\x03", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        function ii(i, len) { var s = i + ""; len = len || 2; while (s.length < len) s = "0" + s; return s; }

        var y = utc ? date.getUTCFullYear() : date.getFullYear();
        format = format.replace(/(^|[^\\])yyyy+/g, "$1" + y);
        format = format.replace(/(^|[^\\])yy/g, "$1" + y.toString().substr(2, 2));
        format = format.replace(/(^|[^\\])y/g, "$1" + y);

        var M = (utc ? date.getUTCMonth() : date.getMonth()) + 1;
        format = format.replace(/(^|[^\\])MMMM+/g, "$1" + MMMM[0]);
        format = format.replace(/(^|[^\\])MMM/g, "$1" + MMM[0]);
        format = format.replace(/(^|[^\\])MM/g, "$1" + ii(M));
        format = format.replace(/(^|[^\\])M/g, "$1" + M);

        var d = utc ? date.getUTCDate() : date.getDate();
        format = format.replace(/(^|[^\\])dddd+/g, "$1" + dddd[0]);
        format = format.replace(/(^|[^\\])ddd/g, "$1" + ddd[0]);
        format = format.replace(/(^|[^\\])dd/g, "$1" + ii(d));
        format = format.replace(/(^|[^\\])d/g, "$1" + d);

        var H = utc ? date.getUTCHours() : date.getHours();
        format = format.replace(/(^|[^\\])HH+/g, "$1" + ii(H));
        format = format.replace(/(^|[^\\])H/g, "$1" + H);

        var h = H > 12 ? H - 12 : H == 0 ? 12 : H;
        format = format.replace(/(^|[^\\])hh+/g, "$1" + ii(h));
        format = format.replace(/(^|[^\\])h/g, "$1" + h);

        var m = utc ? date.getUTCMinutes() : date.getMinutes();
        format = format.replace(/(^|[^\\])mm+/g, "$1" + ii(m));
        format = format.replace(/(^|[^\\])m/g, "$1" + m);

        var s = utc ? date.getUTCSeconds() : date.getSeconds();
        format = format.replace(/(^|[^\\])ss+/g, "$1" + ii(s));
        format = format.replace(/(^|[^\\])s/g, "$1" + s);

        var f = utc ? date.getUTCMilliseconds() : date.getMilliseconds();
        format = format.replace(/(^|[^\\])fff+/g, "$1" + ii(f, 3));
        f = Math.round(f / 10);
        format = format.replace(/(^|[^\\])ff/g, "$1" + ii(f));
        f = Math.round(f / 10);
        format = format.replace(/(^|[^\\])f/g, "$1" + f);

        var T = H < 12 ? "AM" : "PM";
        format = format.replace(/(^|[^\\])TT+/g, "$1" + T);
        format = format.replace(/(^|[^\\])T/g, "$1" + T.charAt(0));

        var t = T.toLowerCase();
        format = format.replace(/(^|[^\\])tt+/g, "$1" + t);
        format = format.replace(/(^|[^\\])t/g, "$1" + t.charAt(0));

        var tz = -date.getTimezoneOffset();
        var K = utc || !tz ? "Z" : tz > 0 ? "+" : "-";
        if (!utc)
        {
            tz = Math.abs(tz);
            var tzHrs = Math.floor(tz / 60);
            var tzMin = tz % 60;
            K += ii(tzHrs) + ":" + ii(tzMin);
        }
        format = format.replace(/(^|[^\\])K/g, "$1" + K);

        var day = (utc ? date.getUTCDay() : date.getDay()) + 1;
        format = format.replace(new RegExp(dddd[0], "g"), dddd[day]);
        format = format.replace(new RegExp(ddd[0], "g"), ddd[day]);

        format = format.replace(new RegExp(MMMM[0], "g"), MMMM[M]);
        format = format.replace(new RegExp(MMM[0], "g"), MMM[M]);

        format = format.replace(/\\(.)/g, "$1");

        return format;
     };`
     formatDate(timeStr, formatStr)


  Handlebars.registerHelper "lastChar", ( string )->
    ch = string.charAt( string.length - 1 )
    if (ch >= "A" && ch <= "Z") or (ch >= "a" && ch <= "z" )
      ch
    else
      ""
