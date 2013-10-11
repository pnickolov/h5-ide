#############################
#  View(UI logic) for register
#############################

define [ 'event',
         'text!./module/register/template.html', 'text!./module/register/success.html',
         'i18n!nls/lang.js',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, success_tmpl, lang ) ->

    RegisterView = Backbone.View.extend {

        el           :  '#container'

        template     : Handlebars.compile tmpl
        success_tmpl : Handlebars.compile success_tmpl

        events       :
            'blur  #register-username'  : 'verificationUser'
            'keyup #register-username'  : '_checkButtonDisabled'

            'blur  #register-email'     : 'verificationEmail'
            'keyup #register-email'     : '_checkButtonDisabled'

            'blur #register-password'   : 'verificationPassword'
            'keyup #register-password'  : '_checkButtonDisabled'

            'submit #register-form'     : 'submit'
            'click #register-get-start' : 'loginEvent'

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
            console.log 'verificationUser'
            value  = $('#register-username').val()
            status = $('#username-verification-status')
            status.removeClass 'error-status'
            status.show()
            #
            #@_checkButtonDisabled()
            #
            if value.trim() isnt ''
                if /[^A-Za-z0-9\_]{1}/.test(value) isnt true
                    status.show().text lang.register.username_available
                    #check vaild
                    this.trigger 'CHECK_REPEAT', value, null if event.type is 'blur'
                    true
                else
                    status.addClass('error-status').show().text lang.register.username_not_matched
                    false
            else
                status.addClass('error-status').show().text lang.register.username_required
                false

        verificationEmail : ->
            console.log 'verificationEmail'
            value  = $('#register-email').val().trim()
            status = $('#email-verification-status')
            status.removeClass 'error-status'
            status.show()
            #
            #@_checkButtonDisabled()
            #
            if value isnt '' and /\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}/.test(value)
                status.show().text lang.register.email_available
                #check vaild
                this.trigger 'CHECK_REPEAT', null, value if event.type is 'blur'
                true
            else
                status.addClass('error-status').show().text lang.register.email_not_valid
                false

        verificationPassword : ->
            console.log 'verificationPassword'
            value = $('#register-password').val().trim()
            status = $('#password-verification-status')
            status.removeClass 'error-status'
            status.show()
            #
            #@_checkButtonDisabled()
            #
            if value isnt ''
                if value.length > 5 # &&
                    #/[A-Z]{1}/.test(value) &&
                    #/[0-9]{1}/.test(value)
                    status.show().text lang.register.password_ok
                    true
                else
                    status.addClass('error-status').show().text lang.register.password_shorter
                    false
            else
                status.addClass('error-status').show().text lang.register.password_required
                false

        submit : ->
            console.log 'submit'
            #
            username    = $( '#register-username' ).val()
            email       = $( '#register-email' ).val()
            password    = $( '#register-password' ).val()
            #
            right_count = 0
            right_count = right_count + 1 if @verificationUser()
            right_count = right_count + 1 if @verificationEmail()
            right_count = right_count + 1 if @verificationPassword()

            if right_count is 3
                #
                $( '#register-btn' ).attr( 'value', lang.register.reginster_waiting )
                $( '#register-btn' ).attr( 'disabled', true )
                #
                this.trigger 'CHECK_REPEAT', username, email, password
                #
                $('#username-verification-status').hide()
                $('#email-verification-status').hide()
                $('#password-verification-status').hide()
            false

        showUsernameError : ->
            console.log 'showUsernameError'
            status = $('#username-verification-status')
            status.addClass( 'error-status' ).show().text lang.ide.username_taken

        showEmailError : ->
            console.log 'showEmailError'
            status = $('#email-verification-status')
            status.addClass( 'error-status' ).show().text lang.ide.email_used

        loginEvent : ->
            console.log 'loginEvent'
            window.location.href = 'ide.html'
            null

        _checkButtonDisabled : ->
            console.log '_checkButtonDisabled'
            #
            right_count = 0
            #
            right_count = right_count + 1 if $('#register-username').val().trim()
            right_count = right_count + 1 if $('#register-email').val().trim()
            right_count = right_count + 1 if $('#register-password').val().trim()

            if right_count is 3
                $( '#register-btn' ).attr( 'disabled', false )
            else
                $( '#register-btn' ).attr( 'disabled', true )
            null

    }

    return RegisterView
