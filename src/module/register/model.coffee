#############################
#  View Mode for register
#############################

define [ 'MC', 'event', 'account_model', 'forge_handle' ], ( MC, ide_event, account_model, forge_handle ) ->

    #private
    RegisterModel = Backbone.Model.extend {

        #defaults   :

        initialize : ->
            #

        checkRepeatService : ( username, email, password ) ->
            console.log 'checkRepeatService, username = ' + username + ', email = ' + email + ', password = ' + password
            #
            account_model.check_repeat { sender : this }, username, email
            this.once 'ACCOUNT_CHECK__REPEAT_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_CHECK__REPEAT_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    @registerService username, email, password
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
                    window.location.href = 'register.html#success'
                else
                    #
                null

    }

    return new RegisterModel()