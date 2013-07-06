#############################
#  View Mode for design/property
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

    PropertyPanelModel = Backbone.Model.extend {

        defaults :
            'head'    : null
            'content' : null

        addItem  : ( head, content ) ->
            console.log 'addItem'
            this.set 'head', head
            if this.get( 'content' ) is content then this.set 'content', null
            this.set 'content', content

    }

    model = new PropertyPanelModel()

    return model