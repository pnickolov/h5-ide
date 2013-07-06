#############################
#  View Mode for design/property
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

    PropertyPanelModel = Backbone.Model.extend {

        defaults :
            'head'    : null
            'content' : null

        addItem  : ->
            this.set 'head',  'Instance Details'
            this.set 'content', null
            this.set 'content', 'loading...'

    }

    model = new PropertyPanelModel()

    return model