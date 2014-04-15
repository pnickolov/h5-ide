#############################
#  View(UI logic) for reset
#############################

define [ 'event',
         './template', './email',
         './password', './loading',
         './expire',   './success',
         'i18n!nls/lang.js',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, email_tmpl, password_tmpl, loading_tmpl, expire_tmpl, success_tmpl, lang ) ->

    ResetView = Backbone.View.extend {

        el       :  '#main-body'

        template      : tmpl
        email_tmpl    : email_tmpl
        password_tmpl : password_tmpl
        loading_tmpl  : loading_tmpl
        expire_tmpl   : expire_tmpl
        success_tmpl  : success_tmpl

        is_submit     : false

        events        :
            'keyup #reset-pw-email' : 'changeSendButtonState'
            'click #reset-btn'      : 'resetPasswordButtonEvent'
            'click #reset-password' : 'resetPasswordEvent'
            'blur #reset-pw'        : 'verificationPassword'

        initialize : ->
            #

        render   : ( type, key ) ->
            console.log 'reset render'
            console.log type, key

            switch type
                when 'normal'
                    @$el.html @template()
                when 'email'
                    @$el.html @email_tmpl()
                when 'password'
                    @$el.html @loading_tmpl()
                when 'expire'
                    @$el.html @expire_tmpl()
                when 'success'
                    @$el.html @success_tmpl()
                else
                    @$el.html @template()

        passwordRender : ->
            console.log 'passwordRender'
            @$el.html @password_tmpl()

        changeSendButtonState : ( event ) ->
            console.log 'changeSendButtonState'
            $('#email-verification-status').hide()
            return if @is_submit
            if event.target.value then $( '#reset-btn' ).removeAttr 'disabled' else  $( '#reset-btn' ).attr 'disabled', true

        resetPasswordButtonEvent : ->
            console.log 'resetPasswordButtonEvent'
            $('#email-verification-status').hide()
            $( '#reset-btn' ).attr( 'disabled', true )
            $( '#reset-btn' ).attr( 'value', lang.reset.reset_waiting )
            @is_submit = true
            this.trigger 'RESET_EMAIL', $( '#reset-pw-email' ).val()
            false

        resetPasswordEvent : ->
            console.log 'resetPasswordEvent'
            if @verificationPassword()
                $( '#reset-password' ).attr( 'value', lang.reset.reset_waiting )
                $( '#reset-password' ).attr( 'disabled', true )
                this.trigger 'RESET_PASSWORD', $( '#reset-pw' ).val()
            false

        verificationPassword : ->
            value = $('#reset-pw').val().trim()
            status = $('#password-verification-status')
            status.removeClass 'error-status'

            #signup.verification.confirm_password()
            if value isnt ''
                if value.length > 5 # &&
                  #/[A-Z]{1}/.test(value) &&
                  #/[0-9]{1}/.test(value)
                  # status.show().text 'This password is OK.'
                  status.hide()
                  true
                else
                  status.addClass('error-status').show().text lang.reset.reset_password_shorter
                  false
            else
                status.addClass('error-status').show().text lang.reset.reset_password_required
                false

        showErrorMessage : ->
            console.log 'showErrorMessage'
            @is_submit = false
            $( '#reset-btn' ).attr( 'disabled', false )
            $( '#reset-btn' ).attr( 'value', lang.reset.reset_btn )
            status = $('#email-verification-status')
            status.addClass( 'error-status' ).show().text lang.reset.reset_error_state
            false

        #showPassowordErrorMessage : ->
        #    console.log 'showPassowordErrorMessage'
        #    $( '#reset-password' ).attr( 'disabled', false )
        #    status = $('#password-verification-status')
        #    status.addClass( 'error-status' ).show().text 'Password set error.'
        #    false

    }

    return ResetView
