#############################
#  View(UI logic) for reset
#############################

define [ 'event',
         'text!./template.html', 'text!./password.html', 'text!./loading.html', 'text!./email.html', 'text!./expire.html', 'text!./success.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, password_tmpl, loading_tmpl, email_tmpl, expire_tmpl, success_tmpl ) ->

    ResetView = Backbone.View.extend {

        el       :  '#container'

        template      : Handlebars.compile tmpl
        password_tmpl : Handlebars.compile password_tmpl
        loading_tmpl  : Handlebars.compile loading_tmpl
        email_tmpl    : Handlebars.compile email_tmpl
        expire_tmpl   : Handlebars.compile expire_tmpl
        success_tmpl  : Handlebars.compile success_tmpl

        events   :
            'click #reset-btn'      : 'resetButtonEvent'
            'click #reset-password' : 'resetPasswordEvent'
            'keyup #reset-pw'       : 'verificationPassword'

        initialize : ->
            #

        render   : ( type, key ) ->
            console.log 'reset render'
            console.log type, key

            switch type
                when 'normal'
                    @$el.html @template()
                when 'password'
                    @$el.html @loading_tmpl()
                    #this.trigger 'CHECK_VALIDATION'
                when 'email'
                    @$el.html @email_tmpl()
                when 'expire'
                    @$el.html @expire_tmpl()
                when 'success'
                    @$el.html @success_tmpl()
                else
                    @$el.html @template()

        passwordRender : ->
            console.log 'passwordRender'
            $el.html @password_tmpl()

        resetButtonEvent : ->
            console.log 'resetButtonEvent'
            $('#email-verification-status').hide()
            $( '#reset-btn' ).attr( 'disabled', true )
            this.trigger 'RESET_EMAIL', $( '#reset-pw-email' ).val()
            false

        resetPasswordEvent : ->
            console.log 'resetPasswordEvent'
            $( '#reset-password' ).attr( 'disabled', true )
            this.trigger 'RESET_PASSWORD', $( '#reset-pw' ).val()
            false

        verificationPassword : ->
            value = $('#reset-pw').val().trim()
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

        showErrorMessage : ->
            console.log 'showErrorMessage'
            $( '#reset-btn' ).attr( 'disabled', false )
            status = $('#email-verification-status')
            status.addClass( 'error-status' ).show().text 'The username or email address is not registered with MadeiraCloud.'
            false

        #showPassowordErrorMessage : ->
        #    console.log 'showPassowordErrorMessage'
        #    $( '#reset-password' ).attr( 'disabled', false )
        #    status = $('#password-verification-status')
        #    status.addClass( 'error-status' ).show().text 'Password set error.'
        #    false

    }

    return ResetView
