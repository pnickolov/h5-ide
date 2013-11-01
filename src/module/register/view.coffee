#############################
#  View(UI logic) for register
#############################

define [ 'event',
         'text!./module/register/template.html', 'text!./module/register/success.html',
         'i18n!nls/lang.js',
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
            status.text('')
            status.removeClass( 'error-status' ).removeClass( 'verification-status' )
            status.show()
            #
            #@_checkButtonDisabled()
            #
            if value.trim() isnt ''
                if /[^A-Za-z0-9\_]{1}/.test(value) isnt true
                    #status.show().text lang.register.username_available
                    #check vaild
                    if event and event.type is "blur"
                        this.trigger 'CHECK_REPEAT', value, null
                    true
                else
                    status.addClass('error-status').show().text lang.register.username_not_matched
                    false
            else
                status.addClass('error-status').show().text lang.register.username_required
                false

        verificationEmail : (event)->
            console.log 'verificationEmail'
            value  = $('#register-email').val().trim()
            status = $('#email-verification-status')
            status.text('')
            status.removeClass( 'error-status' ).removeClass( 'verification-status' )
            status.show()
            #
            #@_checkButtonDisabled()
            #
            if value isnt '' and /^\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}$/.test(value)
                #status.show().text lang.register.email_available
                #check vaild
                if event and event.type is "blur"
                    this.trigger 'CHECK_REPEAT', null, value
                true
            else
                status.addClass('error-status').show().text lang.register.email_not_valid
                false

        verificationPassword : ()->
            console.log 'verificationPassword'
            value = $('#register-password').val().trim()
            status = $('#password-verification-status')
            status.text('')
            status.removeClass( 'error-status' ).removeClass( 'verification-status' )
            status.show()
            #
            #@_checkButtonDisabled()
            #
            if value isnt ''
                if value.length > 5 # &&
                    #/[A-Z]{1}/.test(value) &&
                    #/[0-9]{1}/.test(value)
                    status.show().text lang.register.password_ok
                    status.addClass( 'verification-status' )
                    status.show()
                    @_checkButtonDisabled()
                    true
                else
                    status.addClass('error-status').show().text lang.register.password_shorter
                    $( '#register-btn' ).attr( 'disabled', true )
                    @_checkButtonDisabled()
                    false
            else
                status.addClass('error-status').show().text lang.register.password_required
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
                #
                $('#username-verification-status').hide()
                $('#email-verification-status').hide()
                $('#password-verification-status').hide()
            false

        showUsernameError : ->
            console.log 'showUsernameError'

            #username invalid
            status = $('#username-verification-status')
            status.addClass( 'error-status' ).show().text lang.register.username_taken

            @is_submit = false

            $( '#register-btn' ).attr( 'disabled', true )

            null

        showEmailError : ->
            console.log 'showEmailError'

            #email invalid
            status = $('#email-verification-status')
            status.addClass( 'error-status' ).show().text lang.register.email_used

            @is_submit = false

            $( '#register-btn' ).attr( 'disabled', true )

            null

        showUsernameEmailError : ->
            console.log 'showUsernameError'
            #username invalid
            status = $('#username-verification-status')
            status.removeClass( 'verification-status' )
            status.addClass( 'error-status' ).show().text lang.register.username_taken

            #email invalid
            console.log 'showEmailError'
            status = $('#email-verification-status')
            status.removeClass( 'verification-status' )
            status.addClass( 'error-status' ).show().text lang.register.email_used
            @is_submit = false

            $( '#register-btn' ).attr( 'disabled', true )

            null

        showUsernameEmailValid : ->
            console.log 'showUsernameValid'
            #username valid
            status = $('#username-verification-status')
            status.text('')
            if $('#register-username').val()
                status.removeClass( 'error-status' )
                status.addClass( 'verification-status' )
                status.text lang.register.username_available
            else
                #username is empty
                status.removeClass( 'error-status' ).removeClass( 'verification-status' )
            status.show()
            
            #email valid
            status = $('#email-verification-status')
            status.text('')
            if $('#register-email').val()
                status.removeClass( 'error-status' )
                status.addClass( 'verification-status' )
                status.show().text lang.register.email_available
            else
                #email is empty
                status.removeClass( 'error-status' ).removeClass( 'verification-status' )
            status.show()

            @_checkButtonDisabled()


            null

        showUsernameValid : ->
            console.log 'showUsername'
            #username valid
            status = $('#username-verification-status')
            status.text('')
            if $('#register-username').val()
                status.removeClass( 'error-status' )
                status.addClass( 'verification-status' )
                status.text lang.register.username_available
            else
                #username is empty
                status.removeClass( 'error-status' ).removeClass( 'verification-status' )
            status.show()
            
            @_checkButtonDisabled()

            null

        showEmailValid : ->
            console.log 'showEmailValid'
            
            #email valid
            status = $('#email-verification-status')
            status.text('')
            if $('#register-email').val()
                status.removeClass( 'error-status' )
                status.addClass( 'verification-status' )
                status.show().text lang.register.email_available
            else
                #email is empty
                status.removeClass( 'error-status' ).removeClass( 'verification-status' )
            status.show()

            @_checkButtonDisabled()

            null

        loginEvent : ->
            console.log 'loginEvent'
            #window.location.href = '/ide.html'
            this.trigger 'AUTO_LOGIN'
            null

        _checkButtonDisabled : ->
            console.log '_checkButtonDisabled'
            #
            right_count = 0
            #
            right_count = right_count + 1 if $('#register-username').val().trim() and $("#username-verification-status").hasClass('verification-status')
            right_count = right_count + 1 if $('#register-email').val().trim() and $("#email-verification-status").hasClass('verification-status')
            right_count = right_count + 1 if $('#register-password').val().trim() and $('#password-verification-status').hasClass('verification-status')

            if right_count is 3
                $( '#register-btn' ).attr( 'disabled', false )
            else
                $( '#register-btn' ).attr( 'disabled', true )
            null

    }

    return RegisterView
