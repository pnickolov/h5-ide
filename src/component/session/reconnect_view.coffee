#############################
#  View(UI logic) for component/session
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'text!./reconnect_template.html',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event, lang, reconnect_template ) ->

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
            $( '#reconnect-ok' ).prop 'disabled', true

            this.trigger 'RE_LOGIN', $( '#input-demo' ).val()

        reConnectClose     : ->
            console.log 'reConnectClose'
            ide_event.trigger ide_event.LOGOUT_IDE

        keyupPassword      : ( event )  ->
            console.log 'changePassword'

            if event.currentTarget.value.length
                if event.which is 13
                    @reConnectOK()
                else
                    $( '#reconnect-ok' ).removeAttr 'disabled'
            else
                $( '#reconnect-ok' ).prop 'disabled', true


        invalid            : () ->
            console.log 'invalid'
            notification 'error', lang.ide.NOTIFY_MSG_WARN_AUTH_FAILED
            $( '#reconnect-ok' ).prop 'disabled', false

            $( '#input-demo' )
                .addClass( 'parsley-error' )
                .one 'keyup', ()->
                    $( @ ).removeClass 'parsley-error'



        close              : ->
            console.log 'closedReConnectPopup'
            modal.close()
            this.trigger 'CLOSE_POPUP'

    }

    return ReConnectView