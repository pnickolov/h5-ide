#############################
#  View(UI logic) for component/stackrun
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event ) ->

    StackRunView = Backbone.View.extend {

        events   :
            'click .stack-run-click' : 'stackRunClickEvent'
            'closed'                 : 'closedStackRunPopup'

        render     : ( template ) ->
            console.log 'pop-up:stack run render'
            #
            modal template, true
            #
            this.setElement $( '#stack-run-modal' ).closest '#modal-wrap'

        stackRunClickEvent : ->
            console.log 'stackRunClickEvent'

        closedStackRunPopup : ->
            console.log 'closedStackRunPopup'
            this.trigger 'CLOSE_POPUP'

    }

    return StackRunView