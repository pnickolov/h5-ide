#############################
#  View(UI logic) for design/property/sgrule
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SGRuleView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-sgrule-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:sgrule render'

    }

    view = new SGRuleView()

    return view