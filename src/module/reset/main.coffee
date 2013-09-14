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
    loadModule = ( type ) ->

        #load
        require [ './module/reset/view', './module/reset/model' ], ( View, model ) ->

            view = loadSuperModule loadModule, 'reset', View, null
            return if !view
            view.model = model

            #render
            view.render type

            view.on 'RESET_EMAIL', ( result ) -> model.resetPasswordServer result

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
