#############################
#  View Mode for register
#############################

define [ 'MC', 'event', 'account_model', 'session_model', 'forge_handle' ], ( MC, ide_event, account_model, session_model, forge_handle ) ->

    #private
    RegisterModel = Backbone.Model.extend {

        defaults   :
            password : null

        initialize : ->
            this.on 'ACCOUNT_CHECK__REPEAT_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_CHECK__REPEAT_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    if forge_result.param[1] and forge_result.param[2]
                        @registerService forge_result.param[1], forge_result.param[2], @get( 'password' )
                else
                    switch forge_result.error_message
                        when 'username'
                            this.trigger 'USERNAME_REPEAT'
                        when  'email'
                            this.trigger 'EMAIL_REPEAT'
                        when 'username,email'
                            this.trigger 'USERNAME_REPEAT'
                            this.trigger 'EMAIL_REPEAT'
                        else
                            console.log 'other error'
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
                    #
                    #result = forge_result.resolved_data

                    #
                    #forge_handle.cookie.deleteCookie()

                    #set cookies
                    #forge_handle.cookie.setCookie result

                    #set madeiracloud_ide_session_id
                    #result.new_account = true
                    #forge_handle.cookie.setCookie result
                    #forge_handle.cookie.setIDECookie result
                    #
                    sessionStorage.setItem 'username', forge_result.param[ 1 ]
                    sessionStorage.setItem 'password', forge_result.param[ 2 ]
                    window.location.href = 'register.html#success'
                else
                    #
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
                    forge_handle.cookie.deleteCookie()

                    #set cookies
                    forge_handle.cookie.setCookie result

                    #set madeiracloud_ide_session_id
                    forge_handle.cookie.setIDECookie result

                    #redirect to page ide.html
                    window.location.href = 'ide.html'

                    null

    }

    return new RegisterModel()