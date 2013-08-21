####################################
#  Controller for header module
####################################

define [ 'jquery', 'text!/module/header/template.html', 'event', 'i18n!/nls/lang.js' ], ( $, template, ide_event, lang ) ->

    view = null

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="header-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#header'

        #load remote module1.js
        require [ './module/header/view', './module/header/model' ], ( View, model ) ->

            #console.log 'asdfasdfasdf = ' + lang.header

            #view
            view       = new View()
            view.model = model
            view.render()

            ide_event.onListen ide_event.WS_COLLECTION_READY_REQUEST, (result) ->
                model.getInfoList()
                view.render()

            ide_event.onLongListen ide_event.UPDATE_HEADER, (req) ->
            #model.on 'HEADER_UPDATE', () ->
                console.log 'HEADER_UPDATE'

                if req
                    console.log 'request:' + req
                    
                    model.updateHeader(req)
                    view.render()

                #view.resetAlert()

            ide_event.onLongListen ide_event.SWITCH_DASHBOARD, () ->
                console.log 'SWITCH_DASHBOARD'
                model.setFlag(true)
                view.render()

            ide_event.onLongListen ide_event.SWITCH_TAB, () ->
                #temp
                setTimeout () ->
                    console.log 'SWITCH_TAB header id:' + MC.canvas_data.id
                    model.setFlag(false)
                    view.render()
                , 500

            ide_event.onListen ide_event.RELOAD_RESOURCE, ( region_name, type, current_paltform, item_name ) ->
                console.log 'RELOAD_RESOURCE'
                model.setFlag(false)
                view.render()

            view.on 'DROPDOWN_MENU_CLOSED', () ->
                console.log 'DROPDOWN_MENU_CLOSED'
                model.resetInfoList()
                view.render()

            view.on 'DROPDOWN_APP_NAME_CLICK', (req_id) ->
                console.log 'design_header:DROPDOWN_APP_NAME_CLICK'
                model.openApp(req_id)

            #event
            view.on 'BUTTON_LOGOUT_CLICK', () ->
                model.logout()

            view.on 'AWSCREDENTIAL_CLICK', () ->
                console.log 'AWSCREDENTIAL_CLICK'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule