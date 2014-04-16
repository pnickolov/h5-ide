API_HOST = 'https://api.mc3.io'


# constant option, used in cookie lib
constant =
    COOKIE_OPTION:
        expires:1
        path: '/'
        domain: '.visualops.io'

    LOCAL_COOKIE_OPTION:
        expires:1
        path: '/'

# variable to record $.ajax
xhr = null

# base64Encode and base64Decode copied from MC.core.js
base64Encode = (string)->
    window.btoa unescape encodeURIComponent string
base64Decode = (string)->
    decodeURIComponent escape window.atob string

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
langType = ->
    document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + "lang\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1") || "en-us"
deepth = 'reset'
# route function
userRoute = (routes)->
    hashArray = window.location.hash.split('#').pop().split('/')
    pathArray = window.location.pathname.split('/')
    pathArray.shift()
    console.log pathArray , hashArray
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
    console.log 'Sending Ajax Request'

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
            console.log 'Success', data
        error: (error)->
            window.location = "/500"
            console.log error, "error"
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
                            e.preventDefault()
                            if validPassword()
                                $("#reset-password").attr('disabled',true).val langsrc.reset.reset_waiting
                                #window.location.hash = "#success"
                                ajaxChangePassword(hashArray, $("#reset-pw").val())
                                console.log('jump...')
                            return false
                    else
                        window.location.hash = "expire"
                        console.log "Error Verify Code!"
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
                    console.log('Getting start...')
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
                window.clearTimeout(timeOutToClear)
                console.log('aborted!', timeOutToClear)
                timeOutToClear = window.setTimeout ->
                    checkUserExist([username, null] , (statusCode)->
                        if !statusCode
                            if not checkUsername()
                                return false
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.register.username_available
                            cb?(1)
                        else if(statusCode == 'error')
                            console.log 'Net Work Error while'
                        else
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.username_taken
                            cb?(0)
                    )
                ,500
                console.log 'Setup a new validation request'
            ajaxCheckEmail = (email, status, cb)->
                xhr?.abort()
                window.clearTimeout(timeOutToClear)
                timeOutToClear = window.setTimeout ->
                    checkUserExist([null, email], (statusCode)->
                        if !statusCode
                            if not checkEmail()
                                return false
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.register.email_available
                            cb?(1)
                        else if(statusCode == 'error')
                            console.log "NetWork Error"
                        else
                            status.removeClass('verification-status').addClass('error-status').text langsrc.register.email_used
                            cb?(0)
                    )
                ,500
                console.log 'Set up a new validation request'
            resetRegForm = (force)->
                if force
                    $(".verification-status").removeAttr('style')
                    $('.error-status').removeClass('error-status')
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
                $('.error-msg').removeAttr('style')
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
    window.location = '/500'
    console.log status, "Net Work Error, Redirecting..."
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
                setCredit(result)
                window.location.hash = "success"
                console.log('registered successfully')
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
                console.log 'Login Now!'
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
                console.log 'Password Updated Successfully'
            else
                handleErrorCode(statusCode)
        error: (status)->
            handleNetError(status)
    )
    return false

loadLang(init)