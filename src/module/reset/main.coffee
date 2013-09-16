####################################
#  Controller for reset module
####################################

define [ 'jquery', 'event', 'base_main' ], ( $, ide_event, base_main ) ->

    #private
    initialize = ->
        #extend parent
        _.extend this, base_main

    initialize()

    #private
    loadModule = ( type, key ) ->

        #load
        require [ './module/reset/view', './module/reset/model' ], ( View, model ) ->

            view = loadSuperModule loadModule, 'reset', View, null
            return if !view
            view.model = model
            model.set 'key', key if key

            #render
            view.render type, key

            view.on 'RESET_EMAIL',    ( result ) -> model.resetPasswordServer result
            view.on 'RESET_PASSWORD', ( result ) -> model.updatePasswordServer result
            model.on 'NO_EMAIL',              () -> view.showErrorMessage()
            model.on 'PASSWORD_INVAILD',      () -> view.showPassowordErrorMessage()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
