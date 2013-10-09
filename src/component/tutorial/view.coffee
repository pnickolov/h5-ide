#############################
#  View(UI logic) for component/tutorial
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'bootstrap-carousel'
], ( ide_event ) ->

    TutorialView = Backbone.View.extend {

        events   :
            #'click .stack-run-click' : 'stackRunClickEvent'
            'closed'                 : 'closedPopup'

        render     : ( template ) ->
            console.log 'pop-up:stack run render'
            #
            modal template, true
            #
            this.setElement $( '#guide-carousel' ).closest '#modal-wrap'
            #
            $('#guide-carousel').carousel { 'interval': false, 'wrap': false }

        #stackRunClickEvent : ->
        #    console.log 'stackRunClickEvent'

        closedPopup : ->
            console.log 'closedPopup'
            this.trigger 'CLOSE_POPUP'

    }

    return TutorialView