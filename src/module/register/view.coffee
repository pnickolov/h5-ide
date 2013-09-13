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
            'keyup #register-email'    : 'verificationEmail'
            'keyup #register-password' : 'verificationPassword'
            'submit #register-form'    : 'submit'

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
            if value.trim() isnt ''
                if /[^A-Za-z0-9\_]{1}/.test(value) isnt true
                  status.show().text 'This username is available.'
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
            if value isnt '' and /\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}/.test(value)
                status.show().text 'This email is available.'
                true
            else
                status.addClass('error-status').show().text 'It`s not an email address.'
                false

        verificationPassword : ->
            value = $('#register-password').val().trim()
            status = $('#password-verification-status')
            status.removeClass 'error-status'

            #signup.verification.confirm_password();
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
            username = $( '#register-username' ).val()
            email    = $( '#register-email' ).val()
            password = $( '#register-password' ).val()
            #
            if @verificationUser() and @verificationEmail() and @verificationPassword()
                this.trigger 'CHECK_REPEAT', username, email, password
            else
                #TO DO
            false

        showUsernameError : ->
            console.log 'showUsernameError'
            status = $('#username-verification-status')
            status.addClass( 'error-status' ).show().text 'Username is already taken. Please choose another.'

        showEmailError : ->
            console.log 'showEmailError'
            status = $('#username-verification-status')
            status.addClass( 'error-status' ).show().text 'This email has already been used.'

    }

    return RegisterView
