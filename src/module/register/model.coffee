#############################
#  View Mode for register
#############################

define [ 'MC', 'event', 'account_model', 'forge_handle' ], ( MC, ide_event, account_model, forge_handle ) ->

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
                    result = forge_result.resolved_data

                    #set cookies
                    forge_handle.cookie.setCookie result

                    #set madeiracloud_ide_session_id
                    forge_handle.cookie.setIDECookie result
                    #
                    #$.cookie 'new_account', 0, { expires:1, path: '/'  }
                    #
                    window.location.href = 'register.html#success'
                else
                    #
                null

    }

    return new RegisterModel()