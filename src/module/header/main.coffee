####################################
#  Controller for header module
####################################

define [ 'jquery', 'text!/module/header/template.html', 'event' ], ( $, template, ide_event ) ->

    view = null

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="header-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#header'

        #load remote module1.js
        require [ './module/header/view', './module/header/model' ], ( View, model ) ->

            #view
            view       = new View()

            #event
            view.on 'BUTTON_LOGOUT_CLICK', () ->

                model.logout()

            view.render()

            ide_event.onListen ide_event.DESIGN_COMPLETE, (result) ->
                model.getInfoList()

            model.on 'change:info_list', () ->
                console.log 'header_change:info_list'
                view.render()

            model.on 'change:unread_num', () ->
                console.log 'header_change:unread_num'
                view.render()

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule