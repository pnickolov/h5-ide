#############################
#  View(UI logic) for component/trustedadvisor
#############################

define [ 'event',
         'text!./template.html', 'text!./modal_template.html',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template, modal_template ) ->

    TrustedAdvisorView = Backbone.View.extend {

        el         : '#status-bar-modal'

        events     :
            'click .modal-close'   : 'closedPopup'

        render     : ( type ) ->
            console.log 'pop-up:trusted advisor run render'
            #
            if type is 'stack'
                $( '#modal-wrap' ).find( '#modal-run-stack' ).find( 'summary' ).after template
                @closedPopup() if $.trim( @$el.html() )
            else if type is 'statusbar'
                @$el.html modal_template
                @$el.find( '#modal-run-stack' ).html template

        closedPopup : ->
            console.log 'closedPopup'
            @$el.empty()
            this.trigger 'CLOSE_POPUP'

    }

    return TrustedAdvisorView