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
    loadModule = () ->

        #load
        require [ './module/register/reg_view', './module/register/reg_model' ], ( View, model ) ->

            view = loadSuperModule loadModule, 'register', View, null
            return if !view
            view.model = model

            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
