API_HOST = 'https://api.mc3.io'

# base64Encode and base64Decode copied from MC.core.js
base64Encode = (string)->
    window.btoa unescape encodeURIComponent string
base64Decode = (string)->
    decodeURIComponent escape window.atob string

# constant option, used in cookie lib
constant =
    COOKIE_OPTION:
        expires:1
        path: '/'
        domain: '.mc3.io'

    LOCAL_COOKIE_OPTION:
        expires:1
        path: '/'

# cookie lib for jQuery

`
/*!
 * jQuery Cookie Plugin v1.3.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2013 Klaus Hartl
 * Released under the MIT license
 */
(function(e){function m(a){return a}function n(a){return decodeURIComponent(a.replace(j," "))}function k(a){0===a.indexOf('"')&&(a=a.slice(1,-1).replace(/\\"/g,'"').replace(/\\\\/g,"\\"));try{return d.json?JSON.parse(a):a}catch(c){}}var j=/\+/g,d=e.cookie=function(a,c,b){if(void 0!==c){b=e.extend({},d.defaults,b);if("number"===typeof b.expires){var g=b.expires,f=b.expires=new Date;f.setDate(f.getDate()+g)}c=d.json?JSON.stringify(c):String(c);return document.cookie=[d.raw?a:encodeURIComponent(a),"=",d.raw?c:encodeURIComponent(c),b.expires?"; expires="+b.expires.toUTCString():"",b.path?"; path="+b.path:"",b.domain?"; domain="+b.domain:"",b.secure?"; secure":""].join("")}c=d.raw?m:n;b=document.cookie.split("; ");for(var g=a?void 0:{},f=0,j=b.length;f<j;f++){var h=b[f].split("="),l=c(h.shift()),h=c(h.join("="));if(a&&a===l){g=k(h);break}a||(g[l]=k(h))}return g};d.defaults={};e.removeCookie=function(a,c){return void 0!==e.cookie(a)?(e.cookie(a,"",e.extend({},c,{expires:-1})),!0):!1}})(jQuery);

`

# CryptoJS Lib in /vender/crypto-js/hmac-sha256.js

`
/*
CryptoJS v3.1.2
code.google.com/p/crypto-js
(c) 2009-2013 by Jeff Mott. All rights reserved.
code.google.com/p/crypto-js/wiki/License
*/
var CryptoJS=CryptoJS||function(h,s){var f={},g=f.lib={},q=function(){},m=g.Base={extend:function(a){q.prototype=this;var c=new q;a&&c.mixIn(a);c.hasOwnProperty("init")||(c.init=function(){c.$super.init.apply(this,arguments)});c.init.prototype=c;c.$super=this;return c},create:function(){var a=this.extend();a.init.apply(a,arguments);return a},init:function(){},mixIn:function(a){for(var c in a)a.hasOwnProperty(c)&&(this[c]=a[c]);a.hasOwnProperty("toString")&&(this.toString=a.toString)},clone:function(){return this.init.prototype.extend(this)}},
r=g.WordArray=m.extend({init:function(a,c){a=this.words=a||[];this.sigBytes=c!=s?c:4*a.length},toString:function(a){return(a||k).stringify(this)},concat:function(a){var c=this.words,d=a.words,b=this.sigBytes;a=a.sigBytes;this.clamp();if(b%4)for(var e=0;e<a;e++)c[b+e>>>2]|=(d[e>>>2]>>>24-8*(e%4)&255)<<24-8*((b+e)%4);else if(65535<d.length)for(e=0;e<a;e+=4)c[b+e>>>2]=d[e>>>2];else c.push.apply(c,d);this.sigBytes+=a;return this},clamp:function(){var a=this.words,c=this.sigBytes;a[c>>>2]&=4294967295<<
32-8*(c%4);a.length=h.ceil(c/4)},clone:function(){var a=m.clone.call(this);a.words=this.words.slice(0);return a},random:function(a){for(var c=[],d=0;d<a;d+=4)c.push(4294967296*h.random()|0);return new r.init(c,a)}}),l=f.enc={},k=l.Hex={stringify:function(a){var c=a.words;a=a.sigBytes;for(var d=[],b=0;b<a;b++){var e=c[b>>>2]>>>24-8*(b%4)&255;d.push((e>>>4).toString(16));d.push((e&15).toString(16))}return d.join("")},parse:function(a){for(var c=a.length,d=[],b=0;b<c;b+=2)d[b>>>3]|=parseInt(a.substr(b,
2),16)<<24-4*(b%8);return new r.init(d,c/2)}},n=l.Latin1={stringify:function(a){var c=a.words;a=a.sigBytes;for(var d=[],b=0;b<a;b++)d.push(String.fromCharCode(c[b>>>2]>>>24-8*(b%4)&255));return d.join("")},parse:function(a){for(var c=a.length,d=[],b=0;b<c;b++)d[b>>>2]|=(a.charCodeAt(b)&255)<<24-8*(b%4);return new r.init(d,c)}},j=l.Utf8={stringify:function(a){try{return decodeURIComponent(escape(n.stringify(a)))}catch(c){throw Error("Malformed UTF-8 data");}},parse:function(a){return n.parse(unescape(encodeURIComponent(a)))}},
u=g.BufferedBlockAlgorithm=m.extend({reset:function(){this._data=new r.init;this._nDataBytes=0},_append:function(a){"string"==typeof a&&(a=j.parse(a));this._data.concat(a);this._nDataBytes+=a.sigBytes},_process:function(a){var c=this._data,d=c.words,b=c.sigBytes,e=this.blockSize,f=b/(4*e),f=a?h.ceil(f):h.max((f|0)-this._minBufferSize,0);a=f*e;b=h.min(4*a,b);if(a){for(var g=0;g<a;g+=e)this._doProcessBlock(d,g);g=d.splice(0,a);c.sigBytes-=b}return new r.init(g,b)},clone:function(){var a=m.clone.call(this);
a._data=this._data.clone();return a},_minBufferSize:0});g.Hasher=u.extend({cfg:m.extend(),init:function(a){this.cfg=this.cfg.extend(a);this.reset()},reset:function(){u.reset.call(this);this._doReset()},update:function(a){this._append(a);this._process();return this},finalize:function(a){a&&this._append(a);return this._doFinalize()},blockSize:16,_createHelper:function(a){return function(c,d){return(new a.init(d)).finalize(c)}},_createHmacHelper:function(a){return function(c,d){return(new t.HMAC.init(a,
d)).finalize(c)}}});var t=f.algo={};return f}(Math);
(function(h){for(var s=CryptoJS,f=s.lib,g=f.WordArray,q=f.Hasher,f=s.algo,m=[],r=[],l=function(a){return 4294967296*(a-(a|0))|0},k=2,n=0;64>n;){var j;a:{j=k;for(var u=h.sqrt(j),t=2;t<=u;t++)if(!(j%t)){j=!1;break a}j=!0}j&&(8>n&&(m[n]=l(h.pow(k,0.5))),r[n]=l(h.pow(k,1/3)),n++);k++}var a=[],f=f.SHA256=q.extend({_doReset:function(){this._hash=new g.init(m.slice(0))},_doProcessBlock:function(c,d){for(var b=this._hash.words,e=b[0],f=b[1],g=b[2],j=b[3],h=b[4],m=b[5],n=b[6],q=b[7],p=0;64>p;p++){if(16>p)a[p]=
c[d+p]|0;else{var k=a[p-15],l=a[p-2];a[p]=((k<<25|k>>>7)^(k<<14|k>>>18)^k>>>3)+a[p-7]+((l<<15|l>>>17)^(l<<13|l>>>19)^l>>>10)+a[p-16]}k=q+((h<<26|h>>>6)^(h<<21|h>>>11)^(h<<7|h>>>25))+(h&m^~h&n)+r[p]+a[p];l=((e<<30|e>>>2)^(e<<19|e>>>13)^(e<<10|e>>>22))+(e&f^e&g^f&g);q=n;n=m;m=h;h=j+k|0;j=g;g=f;f=e;e=k+l|0}b[0]=b[0]+e|0;b[1]=b[1]+f|0;b[2]=b[2]+g|0;b[3]=b[3]+j|0;b[4]=b[4]+h|0;b[5]=b[5]+m|0;b[6]=b[6]+n|0;b[7]=b[7]+q|0},_doFinalize:function(){var a=this._data,d=a.words,b=8*this._nDataBytes,e=8*a.sigBytes;
d[e>>>5]|=128<<24-e%32;d[(e+64>>>9<<4)+14]=h.floor(b/4294967296);d[(e+64>>>9<<4)+15]=b;a.sigBytes=4*d.length;this._process();return this._hash},clone:function(){var a=q.clone.call(this);a._hash=this._hash.clone();return a}});s.SHA256=q._createHelper(f);s.HmacSHA256=q._createHmacHelper(f)})(Math);
(function(){var h=CryptoJS,s=h.enc.Utf8;h.algo.HMAC=h.lib.Base.extend({init:function(f,g){f=this._hasher=new f.init;"string"==typeof g&&(g=s.parse(g));var h=f.blockSize,m=4*h;g.sigBytes>m&&(g=f.finalize(g));g.clamp();for(var r=this._oKey=g.clone(),l=this._iKey=g.clone(),k=r.words,n=l.words,j=0;j<h;j++)k[j]^=1549556828,n[j]^=909522486;r.sigBytes=l.sigBytes=m;this.reset()},reset:function(){var f=this._hasher;f.reset();f.update(this._iKey)},update:function(f){this._hasher.update(f);return this},finalize:function(f){var g=
this._hasher;f=g.finalize(f);g.reset();return g.finalize(this._oKey.clone().concat(f))}})})();

`


# Cookie lib, copied from  /src/lib/common/cookie.coffee
setCookie = ( result ) ->


    if document.domain.indexOf('visualops.io') != -1
        #domain is *.visualops.io
        option = constant.COOKIE_OPTION
    else
        #domain is not *.visualops.io, maybe localhost
        option = constant.LOCAL_COOKIE_OPTION

    #set cookies
    #$.cookie 'userid',      result.userid,      option
    #$.cookie 'region_name', result.region_name, option

    $.cookie 'usercode',    result.usercode,    option
    $.cookie 'username',    base64Decode( result.usercode ), option
    $.cookie 'email',       result.email,       option
    $.cookie 'session_id',  result.session_id,  option
    $.cookie 'account_id',  result.account_id,  option
    $.cookie 'mod_repo',    result.mod_repo,    option
    $.cookie 'mod_tag',     result.mod_tag,     option
    $.cookie 'state',       result.state,       option
    $.cookie 'has_cred',    result.has_cred,    option
    $.cookie 'is_invitated',result.is_invitated,option

deleteCookie = ->

    if document.domain.indexOf('visualops.io') != -1
        #domain is *.visualops.io
        option = constant.COOKIE_OPTION
    else
        #domain is not *.visualops.io, maybe localhost
        option = constant.LOCAL_COOKIE_OPTION

    #delete cookies
    #$.cookie 'region_name', '', option
    #$.cookie 'userid',      '', option

    $.cookie 'usercode',    '', option
    $.cookie 'username',    '', option
    $.cookie 'email',       '', option
    $.cookie 'session_id',  '', option
    $.cookie 'account_id',	'', option
    $.cookie 'mod_repo',    '', option
    $.cookie 'mod_tag',     '', option
    $.cookie 'state',       '', option
    $.cookie 'has_cred',    '', option
    $.cookie 'is_invitated','', option

#$.cookie 'madeiracloud_ide_session_id', '', option

setCred = ( result ) ->

    if document.domain.indexOf('visualops.io') != -1
        #domain is *.visualops.io
        option = constant.COOKIE_OPTION
    else
        #domain is not *.visualops.io, maybe localhost
        option = constant.LOCAL_COOKIE_OPTION


    $.cookie 'has_cred', result, option

setIDECookie = ( result ) ->

    if document.domain.indexOf('visualops.io') != -1
        #domain is *.visualops.io
        option = constant.COOKIE_OPTION
    else
        #domain is not *.visualops.io, maybe localhost
        option = constant.LOCAL_COOKIE_OPTION


    madeiracloud_ide_session_id = [
        result.usercode,
        result.email,
        result.session_id,
        result.account_id,
        result.mod_repo,
        result.mod_tag,
        result.state,
        result.has_cred,
        result.is_invitated
    ]

    #$.cookie 'madeiracloud_ide_session_id', MC.base64Encode( JSON.stringify madeiracloud_ide_session_id ), option
    null


checkAllCookie = ->

    if $.cookie('usercode') and $.cookie('username') and $.cookie('session_id') and $.cookie('account_id') and $.cookie('mod_repo') and $.cookie('mod_tag') and $.cookie('state') and $.cookie('has_cred') and $.cookie('is_invitated')
        true
    else
        false

clearV2Cookie = ( path ) ->
    #for patch
    option = { path: path }


    $.each $.cookie(), ( key, cookie_name ) ->
        $.removeCookie cookie_name	, option
        null


getCookieByName = ( cookie_name ) ->

    $.cookie cookie_name


setCookieByName = ( cookie_name, value ) ->

    if document.domain.indexOf('visualops.io') != -1
        #domain is *.visualops.io
        option = constant.COOKIE_OPTION
    else
        #domain is not *.visualops.io, maybe localhost
        option = constant.LOCAL_COOKIE_OPTION
    $.cookie cookie_name, value, option


# language detect
langu = ->
    document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + "lang\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1") || "en-us"
deepth = 'reset'
# route function
userRoute = (routes)->
    hashArray = window.location.hash.split('#').pop().split('/')
    pathArray = window.location.pathname.split('/')
    pathArray.shift()
    console.log pathArray , hashArray
    # run routes func
    routes[pathArray[0]]?(pathArray, hashArray);

# guid
guid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c)->
        r = Math.random() * 16 | 0
        v = if c == 'x' then r else (r&0x3|0x8)
        v.toString(16)
    ).toUpperCase()
# api
console.log guid()
window.xhr = null
api = (option)->
    window.xhr = $.ajax(
        url: API_HOST + option.url
        dataType: 'json'
        type: 'POST'
        data: JSON.stringify(
            jsonrpc: '2.0',
            id: guid(),
            method: option.method || '',
            params: option.data || {}
        )
        success: (res)->
            option.success(res.result[1], res.result[0])
        error: (xhr,status,error)->
            console.log error
            option.error(status, -1)
    )

# register i18n handlebars helper
Handlebars.registerHelper 'i18n', (str)->
    i18n?(str) || str

# init the page . load i18n source file
loadLang = (cb)->
    $.ajax({
        url: './nls/' + langu() + '/lang.js'
        jsonp: false
        dataType: "jsonp"
        jsonpCallback: "define"
        beforeSend: ->
            template = Handlebars.compile $("#loading-template").html()
            $("#main-body").html template()
        success: (data)->
            window.langsrc = data
            console.log 'Success', data
        error: (error)->
            console.log error, "error"
            window.location = "/500"
    }).done ->
        console.log('Loaded!', langsrc)
        cb()
window.onhashchange = ->
    init()

# temp i18n function
i18n = (str) ->
    langsrc[deepth][str]

# render template
render = (tempName)->
    template = Handlebars.compile $(tempName).html()
    $("#main-body").html template()

# init function
init = ->
    userRoute(
        "reset": (pathArray, hashArray)->
            deepth = 'reset'
            hashTarget = hashArray[0]
            if hashTarget == 'password'
                # check if reset link is valid
                checkPassKey hashArray[1],(result)->
                    if result
                        console.log 'Right Verify Code!'
                        render "#password-template"
                        $('form.box-body').find('input').eq(0).focus()
                        $('#reset-form').on 'submit' , (e)->
                            e.preventDefault();
                            if validPassword()
                                $("#reset-password").attr('disabled',true).val langsrc.reset.reset_waiting
                                #window.location.hash = "#success"
                                ajaxChangePassword(hashArray, $("#reset-pw").val())
                                console.log('jump...')
                            return false
                    else
                        console.log "Error Verify Code!"
                        window.location.hash = "expire"
            else if hashTarget == "expire"
                render '#expire-template'
            else if hashTarget == "email"
                render "#email-template"
                $('form.box-body').find('input').eq(0).focus()
            else if hashTarget == "success"
                render "#success-template"
            else
                render '#default-template'
                $("#reset-pw-email").focus()
                $('#reset-pw-email').keyup ->
                    if @value
                        $('#reset-btn').removeAttr('disabled')
                    else
                        $("#reset-btn").attr('disabled',true)
                $('#reset-form').on 'submit', ->
                    console.log 'sendding....'
                    $('#reset-pw-email').off 'keyup'
                    $("#reset-btn").attr('disabled',true)
                    $("#reset-pw-email").attr('disabled',true)
                    $('#reset-btn').val window.langsrc.reset.reset_waiting
                    sendEmail($("#reset-pw-email").val())
                    false
        'login': (pathArray, hashArray)->
            if checkAllCookie() then window.location = '/'
            deepth = 'login'
            console.log pathArray, hashArray
            render "#login-template"
            $user = $("#login-user")
            $password = $("#login-password")
            submitBtn = $("#login-btn").attr('disabled',false)
            $("#login-form input").eq(0).focus()
            checkValid = ->
                if $(@).val().trim() then $(@).parent().removeClass('error')
            $user.on 'keyup', checkValid
            $password.on 'keyup', checkValid
            $("#login-form").on 'submit', (e)->
                e.preventDefault()
                if $user.val()&&$password.val()
                    $(".error-msg").hide()
                    $(".control-group").removeClass('error')
                    submitBtn.attr('disabled',true).val langsrc.reset.reset_waiting
                    ajaxLogin [$user.val(),$password.val()] , (statusCode)->
                        $('#error-msg-1').show()
                        submitBtn.attr('disabled',false).val langsrc.login['login-btn']
                else
                    $("#error-msg-2").show()
                    if !$user.val().trim() then $user.parent().addClass('error') else $user.parent().removeClass('error')
                    if !$password.val().trim() then $password.parent().addClass('error') else $password.parent().removeClass('error')
                    return false

        'register': (pathArray, hashArray)->
            if checkAllCookie() then window.location = '/'
            deepth = 'register'
            console.log pathArray, hashArray
            if hashArray[0] == 'success'
                render "#success-template"
                $('#register-get-start').click ->
                    window.location = "/"
                return false
            render '#register-template'
            $form = $("#register-form")
            $form.find('input').eq(0).focus()
            $username = $('#register-username')
            $email = $('#register-email')
            $password = $('#register-password')
            timeOutToClear = undefined
            $('#register-btn').attr('disabled',false)

            # username validation
            checkUsername = (e,cb,weak)->
                username = $username.val()
                status = $('#username-verification-status')
                if username.trim() isnt ""
                    if /[^A-Za-z0-9\_]{1}/.test(username) isnt true
                        if username.length > 40
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.username_maxlength
                            if cb then cb(0) else return false
                        else
                            status.hasClass('error-status') && status.removeClass('verification-status').removeClass('error-status').text ""
                            if cb
                                ajaxCheckUsername username, status, cb
                            else
                                return true
                    else
                        status.removeClass('verification-status').addClass('error-status').text langsrc.register.username_not_matched
                        if cb then cb(0) else return false
                else
                    status.removeClass('verification-status').addClass('error-status').text langsrc.register.username_required
                    if cb then cb(0) else return false

            # user Email validation
            checkEmail = (e,cb,weak)->
                email = $email.val()
                status = $("#email-verification-status")
                reg_str = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
                if email.trim() isnt ""
                    if reg_str.test(email)
                        status.hasClass('error-status') && status.removeClass('verification-status').removeClass('error-status').text ""
                        if cb
                            ajaxCheckEmail email, status, cb
                        else
                            return true
                    else
                        status.removeClass('verification-status').addClass('error-status').text langsrc.register.email_not_valid
                        if cb then cb(0) else return false
                else
                    status.removeClass('verification-status').addClass('error-status').text langsrc.register.email_required
                    if cb then cb(0) else return false

            # password validation
            checkPassword = (e,cb)->
                password = $password.val()
                status = $("#password-verification-status")
                if password.trim() isnt ""
                    if password.length > 5
                        status.removeClass('verification-status').removeClass('error-status').text ""
                        if cb then cb(1) else return true
                    else
                        status.removeClass('verification-status').addClass('error-status').text langsrc.register.password_shorter
                        if cb then cb(0) else return false
                else
                    status.removeClass('verification-status').addClass('error-status').text langsrc.register.password_required
                    if cb then cb() else return false
            ajaxCheckUsername = (username, status,cb)->
                window.xhr?.abort()
                window.clearTimeout(timeOutToClear)
                console.log('aborted!', timeOutToClear)
                timeOutToClear = window.setTimeout ->
                    checkUserExist([username, null] , (statusCode)->
                        if !statusCode
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.register.username_available
                            cb?(1)
                        else if(statusCode == 'error')
                            console.log 'Net Work Error while'
                        else
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.username_taken
                            cb?(0)
                    )
                ,500
            ajaxCheckEmail = (email, status, cb)->
                window.xhr?.abort()
                window.clearTimeout(timeOutToClear)
                timeOutToClear = window.setTimeout ->
                    checkUserExist([null, email], (statusCode)->
                        if !statusCode
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.register.email_available
                            cb?(1)
                        else if(statusCode == 'error')
                            console.log "NetWork Error"
                        else
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.email_used
                            cb?(0)
                    )
                ,500
            resetRegForm = ->
                $('#register-btn').attr('disabled',false).val(langsrc.register['register-btn'])
            $username.on 'keyup', (e)->
                checkUsername e, (a)->
                    resetRegForm() unless a
                    return a
            $email.on 'keyup', (e)->
                checkEmail e, (a)->
                    resetRegForm() unless a
                    return a
            $password.on 'keyup', (e)->
                checkPassword e, (a)->
                    resetRegForm() unless a
                    return a
            $form.on 'submit', (e)->
                e.preventDefault()
                if $username.next().hasClass('error-status') or $email.next().hasClass('error-status')
                    console.log "Error Message Exist"
                    return false
                userResult = checkUsername()
                emailResult = checkEmail()
                passwordResult = checkPassword()
                if !(userResult && emailResult && passwordResult)
                    return false
                $('#register-btn').attr('disabled',true).val(langsrc.register.reginster_waiting)
                console.log('check user input here.')
                checkUsername(e , (usernameAvl)->
                    if !usernameAvl
                        resetRegForm()
                        return false
                    checkEmail(e, (emailAvl)->
                        if !emailAvl
                            resetRegForm()
                            return false
                        checkPassword(e, (passwordAvl)->
                            if !passwordAvl
                                resetRegForm()
                                return false
                            if (usernameAvl&&emailAvl&&passwordAvl)
                                console.log('Success!!!!!')
                                ajaxRegister([$username.val(), $password.val(), $email.val()],(status)->
                                    resetRegForm()
                                )
                        )
                    )
                )

    )

# handle reset password input
validPassword = ->
    status = $("#password-verification-status")
    value =  $("#reset-pw").val().trim()
    status.removeClass 'error-status'
    if value isnt ""
        if value.length > 5
            status.hide()
            true
        else
            status.addClass("error-status").show().text langsrc.reset.reset_password_shorter
            false
    else
        status.addClass("error-status").show().text langsrc.reset.reset_password_required
        false

# error Message
showErrorMessage = ->
    console.log 'showErrorMessage'
    $('#reset-pw-email').attr('disabled',false)
    $("#reset-btn").attr('disabled',false).val(window.langsrc.reset.reset_btn)
    $("#email-verification-status").removeClass('verification-status').addClass("error-msg").show().text(langsrc.reset.reset_error_state)
    false

#handleErrorCode
handleErrorCode = (statusCode)->
    console.log 'ERROR_CODE_MESSAGE',langsrc.service["ERROR_CODE_#{statusCode}_MESSAGE"]
# handleNetError
handleNetError = (status)->
    console.log status
    window.location = '/500'
# verify  key with callback
checkPassKey = (keyToValid,fn)->
    api(
        url: '/account/'
        method: 'check_validation'
        data: [keyToValid,'reset']
        success: (result, statusCode)->
            if(!statusCode)
                console.log result
                fn(true)
            else
                handleErrorCode(statusCode)
                fn(false)
        error: (status)->
            handleNetError(status)
    )

setCredit = (result)->
    deleteCookie()
    session_info = {}
    #resolve result
    session_info.usercode    = result[0]
    session_info.email       = result[1]
    session_info.session_id  = result[2]
    session_info.account_id  = result[3]
    session_info.mod_repo    = result[4]
    session_info.mod_tag     = result[5]
    session_info.state       = result[6]
    session_info.has_cred    = result[7]
    session_info.is_invitated= result[8]
    setCookie session_info
    setIDECookie session_info

    localStorage.setItem 'email',     base64Decode( getCookieByName( 'email' ))
    localStorage.setItem 'user_name', getCookieByName( 'username' )
    intercom_sercure_mode_hash = () ->
        intercom_api_secret = '4tGsMJzq_2gJmwGDQgtP2En1rFlZEvBhWQWEOTKE'
        hash = CryptoJS.HmacSHA256( base64Decode($.cookie('email')), intercom_api_secret )
        console.log 'hash.toString(CryptoJS.enc.Hex) = ' + hash.toString(CryptoJS.enc.Hex)
        return hash.toString CryptoJS.enc.Hex
    localStorage.setItem 'user_hash', intercom_sercure_mode_hash()

# ajax register
ajaxRegister = (params, errorCB)->
    console.log params
    api(
        url: '/account/'
        method: 'register'
        data: params
        success: (result, statusCode)->
            if !statusCode
                console.log('registered successfully')
                setCredit(result)
                window.location.hash = "success"
            else
                errorCB(statusCode)
        error: (status)->
            handleNetError(status)
    )

# send Email with callback
ajaxLogin = (params, errorCB)->
    api(
        url: '/session/'
        method: 'login'
        data: params
        success: (result, statusCode)->
            if(!statusCode)
                console.log 'Login Now!'
                setCredit(result)
                window.location = '/'
            else
                errorCB(statusCode)
        error: (status)->
            handleNetError(status)
    )
sendEmail = (params)->
    checkUserExist [params,null], (statusCode)->
        if !statusCode
            showErrorMessage()
            return false
        api(
            url: '/account/'
            method: 'reset_password'
            data: [params]
            success: (result, statusCode)->
                if(!statusCode)
                    console.log(result, statusCode)
                    window.location.hash = 'email'
                    true

                else
                    handleErrorCode(statusCode)
                    showErrorMessage()
                    false
            error: (status)->
                handleNetError(status)
        )

# check user exits
checkUserExist = (params,fn)->
    api({
        url: '/account/'
        method: 'check_repeat'
        data: params
        success: (result,statusCode)->
            console.log result , statusCode
            if(statusCode)
                fn(statusCode)
                false
            else
                fn(statusCode)
        error: (status)->
            console.log 'Net Work Error'
            fn('error')
    })

# ajax to reset password
ajaxChangePassword = (hashArray,newPw)->
    api(
        url: "/account/"
        method: "update_password"
        data: [hashArray[1],newPw]
        success: (result, statusCode)->
            console.log result , statusCode
            if(!statusCode)
                window.location.hash = 'success'
            else
                handleErrorCode(statusCode)
        error: (status)->
            handleNetError(status)
    )
    return false

loadLang(init)