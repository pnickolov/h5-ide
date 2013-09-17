#############################
#  View(UI logic) for register
#############################

define [ 'event',
         'text!./template.html', 'text!./success.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, success_tmpl ) ->

    RegisterView = Backbone.View.extend {

        el           :  '#container'

        template     : Handlebars.compile tmpl
        success_tmpl : Handlebars.compile success_tmpl

        events       :
            'keyup #register-username' : 'verificationUser'
            'blur  #register-username' : 'verificationUser'
            'keyup #register-email'    : 'verificationEmail'
            'blur  #register-email'    : 'verificationEmail'
            'keyup #register-password' : 'verificationPassword'
            'submit #register-form'    : 'submit'
            'click #register-get-start': 'loginEvent'

        initialize   : ->
            #

        render   : ( type ) ->
            console.log 'register render'
            console.log type

            switch type
                when 'normal'
                    @$el.html @template @model
                when 'success'
                    @$el.html @success_tmpl()
                else
                    @$el.html @template @model

        verificationUser : ->
            value  = $('#register-username').val()
            status = $('#username-verification-status')
            status.removeClass 'error-status'
            #
            if value.trim() isnt ''
                if /[^A-Za-z0-9\_]{1}/.test(value) isnt true
                    status.show().text 'This username is available.'
                    #check vaild
                    this.trigger 'CHECK_REPEAT', value if event.type is 'blur'
                    true
                else
                    status.addClass('error-status').show().text 'User name not matched.'
                    false
            else
                status.addClass('error-status').show().text 'User name is required.'
                false

        verificationEmail : ->
            value  = $('#register-email').val().trim()
            status = $('#email-verification-status')
            status.removeClass 'error-status'
            #
            if value isnt '' and /\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}/.test(value)
                status.show().text 'This email is available.'
                #check vaild
                this.trigger 'CHECK_REPEAT', value if event.type is 'blur'
                true
            else
                status.addClass('error-status').show().text 'It`s not an email address.'
                false

        verificationPassword : ->
            value = $('#register-password').val().trim()
            status = $('#password-verification-status')
            status.removeClass 'error-status'
            #
            if value isnt ''
                if value.length > 6 # &&
                    #/[A-Z]{1}/.test(value) &&
                    #/[0-9]{1}/.test(value)
                    status.show().text 'This password is OK.'
                    true
                else
                    status.addClass('error-status').show().text 'This password is too weak.'
                    false
            else
                status.addClass('error-status').show().text 'Password is required.'
                false

        submit : ->
            console.log 'submit'
            #
            username    = $( '#register-username' ).val()
            email       = $( '#register-email' ).val()
            password    = $( '#register-password' ).val()
            #
            right_count = 0
            #
            right_count = right_count + 1 if @verificationUser()
            right_count = right_count + 1 if @verificationEmail()
            right_count = right_count + 1 if @verificationPassword()

            if right_count is 3
                $( '#register-btn' ).attr( 'disabled', true )
                this.trigger 'CHECK_REPEAT', username, email, password
            false

        showUsernameError : ->
            console.log 'showUsernameError'
            $( '#register-btn' ).attr( 'disabled', false )
            status = $('#username-verification-status')
            status.addClass( 'error-status' ).show().text 'Username is already taken. Please choose another.'

        showEmailError : ->
            console.log 'showEmailError'
            $( '#register-btn' ).attr( 'disabled', false )
            status = $('#email-verification-status')
            status.addClass( 'error-status' ).show().text 'This email has already been used.'

        loginEvent : ->
            console.log 'loginEvent'
            window.location.href = 'ide.html'
            null

    }

    return RegisterView
