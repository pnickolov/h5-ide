#############################
#  View(UI logic) for component/session
#############################

define [ 'event',
         'text!/component/session/reconnect_template.html'
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'UI.parsley'
], ( ide_event, reconnect_template ) ->

    ReConnectView = Backbone.View.extend {

        events             :
            'click #reconnect-ok'    : 'reConnectOK'
            'click #reconnect-close' : 'reConnectClose'
            'keyup #input-demo'      : 'keyupPassword'

        render             : ->
            console.log 'pop-up:reconnect render'
            #
            modal reconnect_template, false
            #
            this.setElement $( '.reconnect-session' ).closest '#modal-wrap'

        reConnectOK        : ->
            console.log 'reConnectOK'
            this.trigger 'RE_LOGIN', $( '#input-demo' ).val()

        reConnectClose     : ->
            console.log 'reConnectClose'
            ide_event.trigger ide_event.LOGOUT_IDE

        keyupPassword      : ( event )  ->
            console.log 'changePassword'
            if event.target.value then $( '#reconnect-ok' ).removeAttr 'disabled' else  $( '#reconnect-ok' ).attr 'disabled', true

        invalid            : () ->
            console.log 'invalid'
            $( '#input-demo' ).parsley 'custom',
                validator: () ->
                    return 'Authentication failed.'
                now: true


            $( '#input-demo' ).parsley 'validate'

        close              : ->
            console.log 'closedReConnectPopup'
            modal.close()
            this.trigger 'CLOSE_POPUP'

    }

    return ReConnectView