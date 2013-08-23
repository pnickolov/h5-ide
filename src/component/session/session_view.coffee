#############################
#  View(UI logic) for component/session
#############################

define [ 'event',
         'text!/component/session/session_template.html'
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event, session_template ) ->

    SessionView = Backbone.View.extend {

        events             :
            'click #cidr-remove'     : 'closeSession'
            'click #cidr-return'     : 'reConnectSession'
            'closed'                 : 'closedSessionPopup'

        render     : ->
            console.log 'pop-up:session render'
            #
            modal session_template, false
            #
            this.setElement $( '.invalid-session' ).closest '#modal-wrap'

        closeSession       : ->
            console.log 'closeSession'
            this.trigger 'OPEN_RECONNECT'

        reConnectSession   : ->
            console.log 'reConnectSession'
            ide_event.trigger ide_event.LOGOUT_IDE

        closedSessionPopup : ->
            console.log 'closedSessionPopup'
            this.trigger 'CLOSE_POPUP'

    }

    return SessionView