
# Release : https://ide && https://api
# Debug   : http://ide  && https://ide
# Dev     : http://ide  && https://ide
# Public  : http://ide  && http://ide

# Set domain and set http
API_HOST       = "api.visualops.io"
API_PROTO      = "http://"
shouldIdeHttps = false
ideHttps       = true

### env:debug ###
API_HOST = "api.mc3.io"
ideHttps = false
### env:debug:end ###

### env:dev ###
API_HOST = "api.mc3.io"
ideHttps = false
### env:dev:end ###

### AHACKFORRELEASINGPUBLICVERSION ###
# AHACKFORRELEASINGPUBLICVERSION is a hack. The block will be removed in Public Version.
# Only js/ide/config and user/main supports it.
shouldIdeHttps = ideHttps
API_PROTO      = "https://"
### AHACKFORRELEASINGPUBLICVERSION ###

# Redirect
l = window.location
window.language = window.version = ""
if shouldIdeHttps and l.protocol is "http:"
    window.location = l.href.replace("http:","https:")
    return


goto500 = ()->
    hash = window.location.pathname
    if hash.length == 1
        hash = ""
    else
        hash = hash.replace("/", "#")
    window.location = '/500/' + hash
    return

# variable to record $.ajax
xhr = null

# base64Encode and base64Decode copied from MC.core.js
base64Encode = (string)->
    window.btoa unescape encodeURIComponent string
base64Decode = (string)->
    decodeURIComponent escape window.atob string

checkAllCookie = ->

    if $.cookie('usercode') and $.cookie('username') and $.cookie('session_id') and $.cookie('account_id') and $.cookie('mod_repo') and $.cookie('mod_tag') and $.cookie('state') and $.cookie('has_cred')
        true
    else
        false

# language detect
langType = ->
    document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + "lang\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1") || "en-us"
deepth = 'reset'
# route function
userRoute = (routes)->
    hashArray = window.location.hash.split('#').pop().split('/')
    pathArray = window.location.pathname.split('/')
    pathArray.shift()
    #console.log pathArray , hashArray
    # run routes func
    routes[pathArray[0]]?(pathArray, hashArray)

# guid
guid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c)->
        r = Math.random() * 16 | 0
        v = if c == 'x' then r else (r&0x3|0x8)
        v.toString(16)
    ).toUpperCase()
# api
api = (option)->
    xhr = $.ajax
        url: API_PROTO + API_HOST + option.url
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
            #console.log error
            if status!='abort'
                option.error(status, -1)
    #console.log 'Sending Ajax Request'

# register i18n handlebars helper
Handlebars.registerHelper 'i18n', (str)->
    i18n?(str) || str

# init the page . load i18n source file
loadLang = (cb)->
    $.ajax({
        url: './nls/' + langType() + '/lang.js'
        jsonp: false
        dataType: "jsonp"
        jsonpCallback: "define"
        beforeSend: ->
            template = Handlebars.compile $("#loading-template").html()
            $("#main-body").html template()
        success: (data)->
            window.langsrc = data
            #console.log 'Success', data
        error: (error)->
            goto500()
            console.log error, "error"
    }).done ->
        #console.log('Loaded!', langsrc)
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
    ua = navigator.userAgent.toLowerCase()
    browser = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
            /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
            /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
            /(msie) ([\w.]+)/.exec( ua ) ||
            ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) || []

    support =
        chrome  : 10
        webkit  : 6
        msie    : 10
        mozilla : 4
        opera   : 10

    if browser[1] is "webkit"
        safari = /version\/([\d\.]+).*safari/.exec( ua )
        if safari then browser[2] = safari[1]

    if (parseInt(browser[2], 10) || 0) < support[browser[1]]
      $("header").after '<div id="unsupported-browser"><p>MadeiraCloud IDE does not support the browser you are using.</p> <p>For a better experience, we suggest you use the latest version of <a href="https://www.google.com/intl/en/chrome/browser/" target="_blank">Chrome</a>, <a href="http://www.mozilla.org/en-US/firefox/all/" target="_blank">Firefox</a> or <a href="http://windows.microsoft.com/en-us/internet-explorer/download-ie" target="_blank">IE</a>.</p></div>'

    userRoute(
        "reset": (pathArray, hashArray)->
            deepth = 'reset'
            hashTarget = hashArray[0]
            if hashTarget == 'password'
                # check if reset link is valid
                checkPassKey hashArray[1],(statusCode,result)->
                    if !statusCode
                        console.log 'Right Verify Code!'
                        render "#password-template"
                        $('form.box-body').find('input').eq(0).focus()
                        $('#reset-form').on 'submit' , (e)->
                            e.preventDefault()
                            if validPassword()
                                $("#reset-password").attr('disabled',true).val langsrc.reset.reset_waiting
                                #window.location.hash = "#success"
                                ajaxChangePassword(hashArray, $("#reset-pw").val())
                                #console.log('jump...')
                            return false
                    else
                        #console.log 'ERROR_CODE_MESSAGE',langsrc.service["ERROR_CODE_#{statusCode}_MESSAGE"]
                        tempLang = tempLang||langsrc.reset['expired-info']
                        langsrc.reset['expired-info'] = langsrc.service['RESET_PASSWORD_ERROR_'+statusCode] || tempLang
                        window.location.hash = "expire"
                        #console.log "Error Verify Code!"
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
                    #console.log 'sendding....'
                    $('#reset-pw-email').off 'keyup'
                    $("#reset-btn").attr('disabled',true)
                    $("#reset-pw-email").attr('disabled',true)
                    $('#reset-btn').val window.langsrc.reset.reset_waiting
                    sendEmail($("#reset-pw-email").val())
                    false
        'login': (pathArray, hashArray)->
            if checkAllCookie() then window.location = '/'
            deepth = 'login'
            #console.log pathArray, hashArray
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
            deepth = 'register'
            #console.log pathArray, hashArray
            if hashArray[0] == 'success'
                render "#success-template"
                $('#register-get-start').click ->
                    window.location = "/"
                    #console.log('Getting start...')
                return false
            if checkAllCookie() then window.location = '/'
            render '#register-template'
            $form = $("#register-form")
            $form.find('input').eq(0).focus()
            $username = $('#register-username')
            $email = $('#register-email')
            $password = $('#register-password')
            usernameTimeout = undefined
            emailTimeout = undefined
            $('#register-btn').attr('disabled',false)

            # username validation
            checkUsername = (e,cb)->
                username = $username.val()
                status = $('#username-verification-status')
                if username.trim() isnt ""
                    if /[^A-Za-z0-9\_]{1}/.test(username) isnt true
                        if username.length > 40
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.username_maxlength
                            if cb then cb(0) else return false
                        else
                            if status.hasClass('error-status') then status.removeClass('verification-status').removeClass('error-status').text ""
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
                        if status.hasClass('error-status') then status.removeClass('verification-status').removeClass('error-status').text ""
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
                if password isnt ""
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
                xhr?.abort()
                window.clearTimeout(usernameTimeout)
                #console.log('aborted!', usernameTimeout)
                usernameTimeout = window.setTimeout ->
                    checkUserExist([username, null] , (statusCode)->
                        if !statusCode
                            if not checkUsername()
                                return false
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.register.username_available
                            cb?(1)
                        else if(statusCode == 'error')
                            #console.log 'NetWork Error while checking username'
                            $('.error-msg').eq(0).text(langsrc.service['NETWORK_ERROR']).show()
                            $('#register-btn').attr('disabled',false).val(langsrc.register["register-btn"])
                        else
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.username_taken
                            cb?(0)
                    )
                ,500
                #console.log 'Setup a new validation request'
            ajaxCheckEmail = (email, status, cb)->
                xhr?.abort()
                window.clearTimeout(emailTimeout)
                emailTimeout = window.setTimeout ->
                    checkUserExist([null, email], (statusCode)->
                        if !statusCode
                            if not checkEmail()
                                return false
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.register.email_available
                            cb?(1)
                        else if(statusCode == 'error')
                            #console.log 'NetWork Error while checking username'
                            $('.error-msg').eq(0).text(langsrc.service['NETWORK_ERROR']).show()
                            $('#register-btn').attr('disabled',false).val(langsrc.register["register-btn"])
                        else
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.email_used
                            cb?(0)
                    )
                ,500
                #console.log 'Set up a new validation request'
            resetRegForm = (force)->
                if force
                    $(".verification-status").removeAttr('style')
                    $('.error-status').removeClass('error-status')
                $('#register-btn').attr('disabled',false).val(langsrc.register['register-btn'])
            $username.on 'keyup blur change', (e)->
                checkUsername e, (a)->
                    resetRegForm() unless a
                    return a
            $email.on 'keyup blur change', (e)->
                checkEmail e, (a)->
                    resetRegForm() unless a
                    return a
            $password.on 'keyup blur change', (e)->
                checkPassword e, (a)->
                    resetRegForm() unless a
                    return a
            $form.on 'submit', (e)->
                e.preventDefault()
                $('.error-msg').removeAttr('style')
                if $username.next().hasClass('error-status') or $email.next().hasClass('error-status')
                    #console.log "Error Message Exist"
                    return false
                userResult = checkUsername()
                emailResult = checkEmail()
                passwordResult = checkPassword()
                if !(userResult && emailResult && passwordResult)
                    return false
                $('#register-btn').attr('disabled',true).val(langsrc.register.reginster_waiting)
                #console.log('check user input here.')
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
                                #console.log('Success!!!!!')
                                ajaxRegister([$username.val(), $password.val(), $email.val()],(statusCode)->
                                    resetRegForm(true)
                                    $("#register-status").show().text langsrc.service['ERROR_CODE_'+statusCode+'_MESSAGE']
                                    return false
                                )
                        )
                    )
                )

    )

# handle reset password input
validPassword = ->
    status = $("#password-verification-status")
    value =  $("#reset-pw").val()
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
    #console.log 'showErrorMessage'
    $('#reset-pw-email').attr('disabled',false)
    $("#reset-btn").attr('disabled',false).val(window.langsrc.reset.reset_btn)
    $("#reset-status").removeClass('verification-status').addClass("error-msg").show().text(langsrc.reset.reset_error_state)
    false

#handleErrorCode
handleErrorCode = (statusCode)->
    console.error 'ERROR_CODE_MESSAGE',langsrc.service["ERROR_CODE_#{statusCode}_MESSAGE"]
# handleNetError
handleNetError = (status)->
    goto500()
    console.error status, "Net Work Error, Redirecting..."

# verify  key with callback
checkPassKey = (keyToValid,fn)->
    api(
        url: '/account/'
        method: 'check_validation'
        data: [keyToValid,'reset']
        success: (result, statusCode)->
            console.log(statusCode, result)
            fn(statusCode)
        error: (status)->
            handleNetError(status)
            false
    )

setCredit = (result)->
    # Clear any cookie that's not ours
    domain = { "domain" : window.location.hostname.replace("ide", "") }
    for ckey, cValue of $.cookie()
        $.removeCookie ckey, domain

    session_info =
        usercode     : result.username
        username     : base64Decode( result.username )
        email        : result.email
        user_hash    : result.user_hash
        session_id   : result.session_id
        account_id   : result.account_id
        mod_repo     : result.mod_repo
        mod_tag      : result.mod_tag
        state        : result.state
        has_cred     : result.has_cred

    COOKIE_OPTION =
        expires : 30
        path    : '/'

    for key, value of session_info
        $.cookie key, value, COOKIE_OPTION

    # Set a cookie for WWW
    $.cookie "has_session", !!session_info.session_id, {
        domain  : window.location.hostname.replace("ide", "")
        path    : "/"
        expires : 30
    }

# ajax register
ajaxRegister = (params, errorCB)->
    #console.log params
    api(
        url: '/account/'
        method: 'register'
        data: params
        success: (result, statusCode)->
            if !statusCode
                setCredit(result)
                window.location.hash = "success"
                #console.log('registered successfully')
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
                setCredit(result)
                window.location = '/'
                #console.log 'Login Now!'
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
                    #console.log(result, statusCode)
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
            #console.log result , statusCode
            fn(statusCode)
        error: (status)->
            #console.log 'Net Work Error'
            fn('error')
    })

# ajax to reset password
ajaxChangePassword = (hashArray,newPw)->
    api
        url: "/account/"
        method: "update_password"
        data: [hashArray[1],newPw]
        success: (result, statusCode)->
            #console.log result , statusCode
            if(!statusCode)
                window.location.hash = 'success'
                #console.log 'Password Updated Successfully'
            else
                handleErrorCode(statusCode)
        error: (status)->
            handleNetError(status)
    #console.log 'Updating Password...'

loadLang(init)
