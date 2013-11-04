####################################
#  Controller for register module
####################################

define [ 'jquery', 'event', 'base_main' ], ( $, ide_event, base_main ) ->

    #private
    initialize = ->
        #extend parent
        _.extend this, base_main

    initialize()

    #private
    loadModule = ( type ) ->

        #load
        require [ 'reg_view', 'reg_model' ], ( View, model ) ->

            view = loadSuperModule loadModule, 'register', View, null
            return if !view
            view.model = model

            view.on 'CHECK_REPEAT', ( username, email, password ) ->
                model.checkRepeatService username, email, password
            view.on 'AUTO_LOGIN',       () -> model.loginService()

            model.on 'USERNAME_REPEAT', () -> view.showUsernameError()
            model.on 'EMAIL_REPEAT',    () -> view.showEmailError()
            model.on 'USERNAME_EMAIL_REPEAT', () -> view.showUsernameEmailError()
            model.on 'USERNAME_EMAIL_VALID', () -> view.showUsernameEmailValid()
            model.on 'USERNAME_VALID', () -> view.showUsernameValid()
            model.on 'EMAIL_VALID', () -> view.showEmailValid()
            model.on 'RESET_CREATE_ACCOUNT', () -> view.resetCreateAccount()

            #render
            view.render type

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
