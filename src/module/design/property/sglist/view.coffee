#############################
#  View(UI logic) for design/property/sglist
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.tablist' ], ( ide_event ) ->

    SGListView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '#sg-secondary-panel-wrap'

        template : Handlebars.compile $( '#property-sg-list-tmpl' ).html()

        #events   :

        render     : ( isStackView ) ->
            console.log 'property:sg list render'

            data = this.model.attributes
            data.isStackView = isStackView

            $( '.sg-group' ).html this.template data

    }

    view = new SGListView()

    return view
