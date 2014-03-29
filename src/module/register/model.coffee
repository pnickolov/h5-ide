#############################
#  View Mode for register
#############################

define [ 'MC', 'event', 'account_model', 'session_model', 'common_handle', 'crypto' ], ( MC, ide_event, account_model, session_model, common_handle ) ->

    #private
    RegisterModel = Backbone.Model.extend {

        defaults   :
            password : null

        initialize : ->
            this.on 'ACCOUNT_CHECK__REPEAT_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_CHECK__REPEAT_RETURN'
                console.log forge_result

                # test
                #if not _.isEmpty( forge_result.param[1] ) and not _.isEmpty( forge_result.param[2] )
                #    forge_result.is_error = true
                #    forge_result.error_message = 'sdfsfsdfadaddaadfs'
                #    forge_result.return_code = 12

                if !forge_result.is_error
                    if forge_result.param[1] and forge_result.param[2]
                        #this.trigger 'USERNAME_EMAIL_VALID'
                        @registerService forge_result.param[1], forge_result.param[2], @get( 'password' )

                    else
                        if forge_result.param[1] and !forge_result.param[2]
                            #only check username
                            this.trigger 'USERNAME_VALID'
                        else if !forge_result.param[1] and forge_result.param[2]
                            #only check email
                            this.trigger 'EMAIL_VALID'

                else
                    switch forge_result.error_message
                        when 'username'
                            this.trigger 'USERNAME_REPEAT'
                        when  'email'
                            this.trigger 'EMAIL_REPEAT'
                        when 'username,email'
                            this.trigger 'USERNAME_EMAIL_REPEAT'
                        else
                            console.log 'other error'
                            if not _.isEmpty( forge_result.param[1] ) and not _.isEmpty( forge_result.param[2] )
                                this.trigger 'RESET_CREATE_ACCOUNT', forge_result.return_code
                            else
                                this.trigger 'OTHER_ERROR'
                null

        checkRepeatService : ( username, email, password ) ->
            console.log 'checkRepeatService, username = ' + username + ', email = ' + email + ', password = ' + password
            @set 'password', password
            #
            account_model.check_repeat { sender : this }, username, email

        registerService : ( username, email, password ) ->
            console.log 'registerService, username = ' + username + ', email = ' + email + ', password = ' + password
            #
            account_model.register { sender : this }, username, password, email
            this.once 'ACCOUNT_REGISTER_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_REGISTER_RETURN'
                console.log forge_result
                if !forge_result.is_error

                    sessionStorage.setItem 'username', forge_result.param[ 1 ]
                    sessionStorage.setItem 'password', forge_result.param[ 2 ]

                    window.location.href = "/register/#success"
                else
                    #login failed
                    this.trigger 'RESET_CREATE_ACCOUNT', forge_result.return_code

                null

        loginService : ->
            console.log 'loginService'

            return if !sessionStorage.getItem( 'username' ) or !sessionStorage.getItem( 'password' )

            #invoke session.login api
            session_model.login { sender : this }, sessionStorage.getItem( 'username' ), sessionStorage.getItem( 'password' )

            #
            sessionStorage.clear()

            #login return handler (dispatch from service/session/session_model)
            this.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

                if !forge_result.is_error
                    #login succeed

                    result = forge_result.resolved_data

                    #clear old cookie
                    common_handle.cookie.deleteCookie()

                    #set cookies
                    common_handle.cookie.setCookie result

                    #set madeiracloud_ide_session_id
                    common_handle.cookie.setIDECookie result

                    #set email
                    localStorage.setItem 'email',     MC.base64Decode( common_handle.cookie.getCookieByName( 'email' ))
                    localStorage.setItem 'user_name', common_handle.cookie.getCookieByName( 'username' )
                    intercom_sercure_mode_hash = () ->
                        intercom_api_secret = '4tGsMJzq_2gJmwGDQgtP2En1rFlZEvBhWQWEOTKE'
                        hash = CryptoJS.HmacSHA256( MC.base64Decode($.cookie('email')), intercom_api_secret )
                        return hash.toString CryptoJS.enc.Hex
                    localStorage.setItem 'user_hash', intercom_sercure_mode_hash()

                    window.location.href = "/"

                    null

    }

    return new RegisterModel()
