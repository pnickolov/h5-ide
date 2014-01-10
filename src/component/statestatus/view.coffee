#############################
#  View(UI logic) for component/statestatus
#############################

define [ 'event',
         'text!./template.html', 'text!./modal_template.html',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template, modal_template ) ->

    StateStatusView = Backbone.View.extend {

        el         : '#status-bar-modal'

        events     :
            'click .modal-close'   : 'closedPopup'

        render     : ( type, status ) ->

            @$el.html modal_template
            @$el.find( '#modal-state-statusbar' ).html Handlebars.compile( template )( @model.attributes )
            $('#status-bar-modal').show()

            null

        closedPopup : ->
            if @$el.html()
                @$el.empty()
                this.trigger 'CLOSE_POPUP'
                $( '#status-bar-modal' ).hide()
    }

    return StateStatusView