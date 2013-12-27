#############################
#  View(UI logic) for component/stateeditor
#############################

define [ 'event',
         'text!./component/stateeditor/template1.html',
         'UI.modal'
], ( ide_event, template ) ->

    StateEditorView = Backbone.View.extend {

        events   :
            'closed'                 : 'closedPopup'

        render   : ->
            console.log 'pop-up:state editor render'

            tplRegex = '(<!-- (.*) -->)(\n|\r|.)*?(?=<!-- (.*) -->)'
            alert(template)
            # modal this
            modal Handlebars.compile( template )(), false

            # set root element
            @setElement $( '#state-editor-body' ).closest '#modal-wrap'

            null

        closedPopup : ->
            console.log 'closedPopup'
            @trigger 'CLOSE_POPUP'

    }

    return StateEditorView