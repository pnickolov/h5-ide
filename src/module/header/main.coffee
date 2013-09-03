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

            #view
            view       = new View()
            view.model = model

            model.on 'change:user_name', () -> view.render()
            model.getUserName()

            logout = -> model.logout()

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

            ide_event.onListen ide_event.OPEN_DESIGN, ( region_name, type, current_paltform, item_name ) ->
                console.log 'OPEN_DESIGN'
                model.setFlag(false)
                view.render()

            ide_event.onLongListen ide_event.UPDATE_AWS_CREDENTIAL, () ->
                console.log 'UPDATE_AWS_CREDENTIAL'

                if $.cookie('has_cred') is 'true'
                    model.set 'has_cred', true
                else
                    model.set 'has_cred', false

                view.render()

            ide_event.onLongListen ide_event.LOGOUT_IDE, () -> logout()

            view.on 'DROPDOWN_MENU_CLOSED', () ->
                console.log 'DROPDOWN_MENU_CLOSED'
                model.resetInfoList()
                view.render()

            view.on 'DROPDOWN_APP_NAME_CLICK', (req_id) ->
                console.log 'design_header:DROPDOWN_APP_NAME_CLICK'
                model.openApp(req_id)

            #event
            view.on 'BUTTON_LOGOUT_CLICK', () -> logout()

            view.on 'AWSCREDENTIAL_CLICK', () ->
                console.log 'AWSCREDENTIAL_CLICK'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            model.on 'change:has_cred', () ->
                console.log 'awscredential change'
                view.render()

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule