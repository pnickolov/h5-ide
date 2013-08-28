####################################
#  pop-up for component/session module
####################################

define [ 'jquery', 'event',
], ( $, ide_event ) ->

    #private
    loadModule = () ->

        #
        require [ './component/session/session_view' ], ( Session_view ) ->

            #
            return if modal and modal.isPopup()

            #
            session_view   = new Session_view()

            #render
            session_view.render()

            #
            session_view.on 'CLOSE_POPUP',    () -> unLoadModule session_view
            session_view.on 'OPEN_RECONNECT', () -> loadReConnectModule()

    #private
    loadReConnectModule = () ->

        #
        require [ './component/session/reconnect_view', './component/session/model' ], ( Reconnect_view, Model ) ->

            #
            return if modal and modal.isPopup()

            #
            reconnect_view  = new Reconnect_view()
            model           = new Model()
            #
            reconnect_view.render()

            #
            reconnect_view.on 'RE_LOGIN', ( password ) -> model.relogin password
            reconnect_view.on 'CLOSE_POPUP',        () -> unLoadModule reconnect_view, model
            model.on 'RE_LOGIN_SCUCCCESS',          () -> reconnect_view.close()
            model.on 'RE_LOGIN_FAILED',             () -> reconnect_view.invalid()

    unLoadModule = ( view, model ) ->
        console.log 'session unLoadModule'
        view.off()
        view.undelegateEvents()
        view  = null
        #
        return if !model
        model.off()
        model = null
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule