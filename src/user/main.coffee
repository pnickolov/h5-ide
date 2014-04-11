API_HOST = 'https://api.visualops.io'
# language detect
langu = ->
    document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + "lang\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1") || "en-us"

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
    langsrc['reset'][str]

# render template
render = (tempName)->
    template = Handlebars.compile $(tempName).html()
    $("#main-body").html template()

# init function
init = ->
    userRoute(
        "reset": (pathArray, hashArray)->
            hashTarget = hashArray[0]
            if hashTarget == 'password'
                # check if reset link is valid
                checkPassKey hashArray[1],(result)->
                    if result
                        console.log 'Right Verify Code!'
                        render "#password-template"
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
            else if hashTarget == "success"
                render "#success-template"
            else
                render '#default-template'
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
    console.log(status)
# verify  key with callback
# todo
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
# todo
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

# todo
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
