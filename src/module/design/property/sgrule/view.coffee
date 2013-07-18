#############################
#  View(UI logic) for design/property/sgrule
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SGRuleView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-sgrule-tmpl' ).html()

        #events   :

        render     : ( attributes ) ->
            console.log 'property:sgrule render'
            $( '.property-details' ).html this.template attributes

    }

    view = new SGRuleView()

    return view