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
            view.model = model
            view.render()

            #event
            view.on 'BUTTON_LOGOUT_CLICK', () ->
                model.logout()

            ide_event.onListen ide_event.DESIGN_COMPLETE, (result) ->
                model.getInfoList()
                view.render()

            model.once 'UPDATE_HEADER', () ->
                console.log 'UPDATE_HEADER'
                view.render()

            ide_event.onListen ide_event.SWITCH_DASHBOARD, () ->
                console.log 'SWITCH_DASHBOARD'
                model.setFlag(true)

            ide_event.onListen ide_event.SWITCH_TAB, () ->
                console.log 'SWITCH_TAB'
                model.setFlag(false)

            view.once 'DROPDOWN_APP_NAME_CLICK', (req_id) ->
                console.log 'design_header:DROPDOWN_APP_NAME_CLICK'
                model.openApp(req_id)


    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule