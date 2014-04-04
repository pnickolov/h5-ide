#############################
#  View(UI logic) for component/tutorial
#############################

define [ 'event', "./template"
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'bootstrap-carousel'
], ( ide_event, template ) ->

    TutorialView = Backbone.View.extend {

        events   :
            'closed'                 : 'closedPopup'

        render     : ( template ) ->
            console.log 'pop-up:stack run render'
            #
            modal template(), true
            #
            this.setElement $( '#guide-carousel-modal' ).closest '#modal-wrap'
            #
            $('#guide-carousel').carousel { 'interval': false, 'wrap': false }
            youtube_player = []
            onYouTubePlayerAPIReady()
            #
            setTimeout () ->
                modal.position()
            , 500

        closedPopup : ->
            console.log 'closedPopup'
            this.trigger 'CLOSE_POPUP'

    }

    return TutorialView
