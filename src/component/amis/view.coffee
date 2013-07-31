#############################
#  View(UI logic) for component/amis
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event ) ->

    AMIsView = Backbone.View.extend {

        events   :
            'closed'                 : 'closedAMIsPopup'

        render     : ( template ) ->
            console.log 'pop-up:amis run render'
            #
            modal template, true
            #
            this.setElement $( '#modal-browse-community-ami' ).closest '#modal-wrap'

        closedAMIsPopup : ->
            console.log 'closedAMIsPopup'
            this.trigger 'CLOSE_POPUP'

    }

    return AMIsView