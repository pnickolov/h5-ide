#############################
#  View(UI logic) for component/stateeditor
#############################

define [ 'event',
         'text!./component/stateeditor/template.html',
         'UI.modal'
], ( ide_event, template ) ->

    StateEditorView = Backbone.View.extend {

        events   :
            'closed'                 : 'closedPopup'

        render   : ->
            console.log 'pop-up:state editor render'

            # modal this
            modal Handlebars.compile( template )(), true

            # set root element
            @setElement $( '#state-editor-body' ).closest '#modal-wrap'

            null

        closedPopup : ->
            console.log 'closedPopup'
            @trigger 'CLOSE_POPUP'

    }

    return StateEditorView