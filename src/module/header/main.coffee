####################################
#  Controller for header module
####################################

define [ 'event',
         'i18n!nls/lang.js',
         'base_main'
], ( ide_event, lang, base_main ) ->

    initialize = ->
        #extend parent
        _.extend this, base_main
        null

    initialize()

    #private
    loadModule = () ->

        console.log 'load header module'

        #load header module
        require [ 'header_view', 'header_model' ], ( View, model ) ->

            view = loadSuperModule loadModule, 'header', View, null
            return if !view

            model.init()
            view.model = model
            view.render()


            updateHeaderTO = null
            updateHeader = ()->
                view.updateNotification()
                null

            ide_event.onLongListen ide_event.UPDATE_HEADER, (req) ->
                console.log 'HEADER_UPDATE, req:', req

                if req
                    model.updateHeader(req)

                    if updateHeaderTO
                        clearTimeout updateHeaderTO
                    updateHeaderTO = setTimeout updateHeader, 200
                null

            # ide_event.onLongListen ide_event.UPDATE_REQUEST_ITEM, (idx, dag) ->
            #     console.log 'header listen UPDATE_REQUEST_ITEM index:' + idx

            #     # fetch request
            #     req_list = MC.data.websocket.collection.request.find({'_id' : idx}).fetch()

            #     if req_list.length > 0
            #         req = req_list[0]

            #         model.updateHeader req

            #         view.render()

            ide_event.onListen ide_event.WS_COLLECTION_READY_REQUEST, () ->
                model.resetInfoList()
                view.updateNotification()
                null

            ide_event.onLongListen ide_event.SWITCH_DASHBOARD, () ->
                console.log 'header:SWITCH_DASHBOARD'
                model.setFlag(true)
                view.updateNotification()

            ide_event.onLongListen ide_event.SWITCH_TAB, () ->
                #temp
                setTimeout () ->
                    #console.log 'SWITCH_TAB header id:' + MC.common.other.canvasData.get 'id'
                    console.log 'SWITCH_TAB header id:' + MC.data.current_tab_id
                    model.setFlag(false)
                    view.updateNotification()
                , 500

            ide_event.onListen ide_event.OPEN_DESIGN, () ->
                console.log 'OPEN_DESIGN'
                model.setFlag(false)
                view.updateNotification()

            ide_event.onLongListen ide_event.UPDATE_AWS_CREDENTIAL, () ->
                console.log 'UPDATE_AWS_CREDENTIAL'

                model.set 'has_cred', (MC.common.cookie.getCookieByName('has_cred') is 'true')
                view.update()

            view.on 'DROPDOWN_MENU_CLOSED', () ->
                model.resetInfoList()

            view.on 'DROPDOWN_APP_NAME_CLICK', (req_id) ->
                model.openApp(req_id)

            # For LogOut
            logout = () ->
                model.logout()
                null

            ide_event.onLongListen ide_event.LOGOUT_IDE, logout
            view.on 'BUTTON_LOGOUT_CLICK', logout

            view.on 'AWSCREDENTIAL_CLICK', () ->
                console.log 'AWSCREDENTIAL_CLICK'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()
            null

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
