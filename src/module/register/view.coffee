#############################
#  View(UI logic) for register
#############################

define [ 'event',
         'text!./module/register/template.html', 'text!./module/register/success.html',
         'i18n!nls/lang.js',
         'UI.notification',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, success_tmpl, lang ) ->

    RegisterView = Backbone.View.extend {

        el           :  '#main-body'

        template     : Handlebars.compile tmpl
        success_tmpl : Handlebars.compile success_tmpl

        is_submit    : false

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

        verificationUser : (event) ->
            console.log 'verificationUser'
            value  = $('#register-username').val()
            status = $('#username-verification-status')

            #
            #@_checkButtonDisabled()
            #
            if value.trim() isnt ''
                if /[^A-Za-z0-9\_]{1}/.test(value) isnt true

                    if value.trim().length > 40
                        status.addClass('error-status').removeClass( 'verification-status' ).show().text lang.register.username_maxlength
                        false
                    else
                        #status.show().text lang.register.username_available
                        #check vaild
                        this.trigger 'CHECK_REPEAT', value, null #if event and event.type is 'blur'
                        #status.text('')
                        true
                else
                    status.addClass('error-status').removeClass( 'verification-status' ).show().text lang.register.username_not_matched
                    false
            else
                status.addClass('error-status').removeClass( 'verification-status' ).show().text lang.register.username_required
                false

        verificationEmail : (event) ->
            console.log 'verificationEmail'
            value   = $('#register-email').val().trim()
            status  = $('#email-verification-status')
            reg_str = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

            if value isnt '' and reg_str.test(value)
                #check vaild
                this.trigger 'CHECK_REPEAT', null, value #if event and event.type is 'blur'
                true
            else if value.trim() == ''
                status.addClass('error-status').removeClass( 'verification-status' ).show().text lang.register.email_required
            else
                status.addClass('error-status').removeClass( 'verification-status' ).show().text lang.register.email_not_valid
                false

        verificationPassword : ->
            console.log 'verificationPassword'
            value = $('#register-password').val().trim()
            status = $('#password-verification-status')

            if value isnt ''
                if value.length > 5 # &&
                    #/[A-Z]{1}/.test(value) &&
                    #/[0-9]{1}/.test(value)
                    status.addClass( 'verification-status' ).removeClass( 'error-status' ).show().text lang.register.password_ok
                    @_checkButtonDisabled()
                    true
                else
                    status.addClass('error-status').removeClass( 'verification-status' ).show().text lang.register.password_shorter
                    $( '#register-btn' ).attr( 'disabled', true )
                    @_checkButtonDisabled()
                    false
            else
                status.addClass('error-status').removeClass( 'verification-status' ).show().text lang.register.password_required
                $( '#register-btn' ).attr( 'disabled', true )
                @_checkButtonDisabled()
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
                @is_submit = true
                #
                this.trigger 'CHECK_REPEAT', username, email, password


                #$('#username-verification-status').hide()
                #$('#email-verification-status').hide()
                #$('#password-verification-status').hide()
            false



        showUsernameEmailError : ->
            console.log 'showUsernameError'

            @showStatusInValid 'username'
            @showStatusInValid 'email'

            null


        showStatusInValid : ( type ) ->
            console.log 'showStatusInValid'

            #type must be username or email
            if type == 'username' or type == 'email'

                switch type
                    when 'username'
                        status = $('#username-verification-status')
                        status.text lang.register.username_taken
                    when 'email'
                        status = $('#email-verification-status')
                        status.text lang.register.email_used

                if status.attr('class') != 'error-status'
                    status.addClass( 'error-status' ).removeClass( 'verification-status' ).show()
                else
                    status.show()


                @is_submit = false

            #if invoke failed, then reset create account button
            if $( '#register-btn' ).val() == lang.register.reginster_waiting
                $( '#register-btn' ).attr( 'disabled', false )
                $( '#register-btn' ).attr( 'value', lang.register['register-btn'] )

            null


        showUsernameEmailValid : ->
            console.log 'showUsernameValid'

            @showStatusValid 'username'
            @showStatusValid 'email'

            null

        showStatusValid : ( type ) ->
            console.log 'showStatusValid ' + type

            #type must be username or email
            if type == 'username' or type == 'email'

                #username valid
                switch type
                    when 'username'
                        status = $( '#username-verification-status' )
                        status.text lang.register.username_available
                    when 'email'
                        status = $( '#email-verification-status' )
                        status.text lang.register.email_available

                if $('#register-'+ type ).val()
                    if status.attr('class') != 'verification-status'
                        status.removeClass( 'error-status' ).addClass( 'verification-status' ).show()
                    else
                        status.show()
                else
                    #username/email is empty
                    status.removeClass( 'error-status' ).removeClass( 'verification-status' ).show().text('')

                @_checkButtonDisabled()

            null


        loginEvent : ->
            console.log 'loginEvent'
            #window.location.href = '/ide.html'
            this.trigger 'AUTO_LOGIN'
            null

        _checkButtonDisabled : (event) ->
            console.log '_checkButtonDisabled'

            if event and event.target
                switch
                    when event.target.id == "register-username" then @verificationUser()
                    when event.target.id == "register-email" then @verificationEmail()
                    when event.target.id == "register-password" then @verificationPassword()

            #
            right_count = 0
            #
            right_count = right_count + 1 if $('#register-username').val().trim()
            right_count = right_count + 1 if $('#register-email').val().trim()
            right_count = right_count + 1 if $('#register-password').val().trim()

            if right_count is 3
                if $( '#register-btn' ).val() != lang.register.reginster_waiting
                    console.log 'enable create account button'
                    $( '#register-btn' ).attr( 'disabled', false )
            else
                $( '#register-btn' ).attr( 'disabled', true )
            null

        otherError : () ->
            console.log 'otherError'
            $( '#username-verification-status' ).removeClass( 'error-status' ).removeClass( 'verification-status' ).show().text('')
            $( '#email-verification-status' ).removeClass( 'error-status' ).removeClass( 'verification-status' ).show().text('')
            #$( '#register-btn' ).attr( 'disabled', true )

        #notifError : ( message ) ->
        #    console.log 'notifError', message
        #    $( '#register-btn' ).attr( 'disabled', false )
        #    $( '#register-btn' ).attr( 'value', lang.register['register-btn'] )
        #
        #    label = 'ERROR_CODE_' + message + '_MESSAGE'
        #    msg   = lang.service[ label ]
        #    notification 'error', msg, false

        resetCreateAccount :( message ) ->
            console.log 'reset account button'

            $( '#username-verification-status' ).removeClass( 'error-status' ).removeClass( 'verification-status' ).show().text('')
            $( '#email-verification-status' ).removeClass( 'error-status' ).removeClass( 'verification-status' ).show().text('')
            $( '#register-btn' ).attr( 'disabled', false )
            $( '#register-btn' ).attr( 'value', lang.register['register-btn'] )

            label = 'ERROR_CODE_' + message + '_MESSAGE'
            msg   = lang.service[ label ]
            notification 'error', msg, false

            null

    }

    return RegisterView
