API_HOST = 'https://api.visualops.io'

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
        domain: '.visualops.io'

    LOCAL_COOKIE_OPTION:
        expires:1
        path: '/'

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
    $.cookie 'username',    MC.base64Decode( result.usercode ), option
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

#getIDECookie = ->
#
#	result = null
#
#	madeiracloud_ide_session_id = $.cookie 'madeiracloud_ide_session_id'
#	if madeiracloud_ide_session_id
#		try
#			result = JSON.parse ( MC.base64Decode madeiracloud_ide_session_id )
#		catch err
#			result = null
#
#	if result and $.type result == "array" and result.length == 8
#		{
#			usercode    : result[0] ,
#			email       : result[1] ,
#			session_id  : result[2] ,
#			account_id  : result[3] ,
#			mod_repo    : result[4] ,
#			mod_tag     : result[5] ,
#			state       : result[6] ,
#			has_cred    : result[7] ,
#			is_invitated: result[8] ,
#		}
#	else
#		null

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

#clearInvalidCookie = ( ) ->
#	#for patch
#	option = { domain: 'ide.visualops.io', path: '/' }
#
#	$.each $.cookie(), ( key, cookie_name ) ->
#		$.removeCookie cookie_name	, option
#		null

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
api = (option)->
    $.ajax(
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
        # todo: change error handler
        console.log error, "error"
}).done ->
    console.log('Loaded!', langsrc)
    init()
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
                            if checkPassword()
                                $("#reset-password").attr('disabled',true).val langsrc.reset.reset_waiting
                                #window.location.hash = "#success"
                                ajaxChangePassword(hashArray, $("#reset-pw").val())
                                console.log('jump...')
                            return false
                    else
                        console.log "Error Verify Code!"
                        render "#expire-template"
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
                    console.log @.value
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
        '_login': (pathArray, hashArray)->
            deepth = 'login'
            console.log pathArray, hashArray
            render "#login-template"
            $user = $("#login-user")
            $password = $("#login-password")
            submitBtn = $("#login-btn").attr('disabled',false)
            $("#login-form input").eq(0).focus()
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

            checkValid = ->
                if $(@).val().trim() then $(@).parent().removeClass('error')
            $user.on 'keyup', checkValid
            $password.on 'keyup', checkValid

        'register': (pathArray, hashArray)->
            console.log pathArray, hashArray
    )

# handle reset password input
checkPassword = ->
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
    $("#email-verification-status").addClass("error-status").show().text(langsrc.reset.reset_error_state)
    false

#handleErrorCode
handleErrorCode = (statusCode)->
    console.log langsrc.service["ERROR_CODE_#{statusCode}_MESSAGE"]
# handleNetError
handleNetError = (status)->
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

# send Email with callback
ajaxLogin = (params, errorCB)->
    api(
        url: '/session'
        method: 'login'
        data: params
        success: (result, statusCode)->
            if(!statusCode)
                console.log 'No login Error'
                #todo: setCookie
                setCookie()
                window.location = "/"
            else
                errorCB(statusCode)
        error: (status)->
            handleNetError(status)

    )
sendEmail = (params)->
    checkUserExist params, (statusCode)->
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
checkUserExist = (username,fn)->
    api({
        url: '/account/'
        method: 'check_repeat'
        data: [username,null]
        success: (result,statusCode)->
            console.log result , statusCode
            if(statusCode)
                fn(statusCode)
                false
            else
                fn(statusCode)
                handleErrorCode(statusCode)
        error: (status)->
            handleNetError(status)
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
