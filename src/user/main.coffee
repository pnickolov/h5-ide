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
                checkPassKey (result)->
                    if result
                        console.log 'Right Verify Code!'
                        render "#password-template"
                        $('#reset-form').on 'submit' , ->
                            if checkPassword()
                                $("#reset-password").attr('disabled',true).val langsrc.reset.reset_waiting
                                #window.location.hash = "#success"
                                ajaxChangePassword()
                                console.log('jump...')
                            false
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
                    # todo: send request to send email
                    sendEmail()
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

# verify  key with callback
# todo
checkPassKey = (fn)->
    result = false
    fn(result)

# send Email with callback
# todo
sendEmail = (fn)->
    if false
        fn?()
    else
        showErrorMessage()

# error Message
showErrorMessage = ->
    console.log 'showErrorMessage'
    $('#reset-pw-email').attr('disabled',false)
    $("#reset-btn").attr('disabled',false).val(window.langsrc.reset.reset_btn)
    $("#email-verification-status").addClass("error-status").show().text(langsrc.reset.reset_error_state)
    false

# todo
ajaxChangePassword = ->
    console.log "resetting password..."

