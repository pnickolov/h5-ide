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

        render     : ( type, template ) ->
            console.log 'pop-up:trusted advisor run render'
            #
            #modal template, true
            #
            #this.setElement $( '#stack-run-modal' ).closest '#modal-wrap'
            #
            if type is 'stack'
                $( '#modal-run-stack' ).find( 'summary' ).after template

        closedPopup : ->
            console.log 'closedPopup'
            this.trigger 'CLOSE_POPUP'

    }

    return TrustedAdvisorView