#############################
#  View(UI logic) for component/trustedadvisor
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event ) ->

    TrustedAdvisorView = Backbone.View.extend {

        events   :
            'closed'                 : 'closedPopup'

        render     : ( template ) ->
            console.log 'pop-up:trusted advisor run render'
            #
            modal template, true
            #
            this.setElement $( '#stack-run-modal' ).closest '#modal-wrap'

        closedPopup : ->
            console.log 'closedPopup'
            this.trigger 'CLOSE_POPUP'

    }

    return TrustedAdvisorView