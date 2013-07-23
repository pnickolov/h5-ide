#############################
#  View(UI logic) for design/property/sglist
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SGListView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '#sg-secondary-panel-wrap'

        template : Handlebars.compile $( '#property-sg-list-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:sg list render'
            $( '.sg-group' ).html this.template this.model.attributes

    }

    view = new SGListView()

    return view