#############################
#  View(UI logic) for design/property/sgrule
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SGRuleView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-sgrule-tmpl' ).html()

        events   :
            "click #sg-edit-rule-button" : "onEditRule"

        render     : () ->
            console.log 'property:sgrule render'

            ###
            attributes =
                sg_group : []
            ###

            $( '.property-details' ).html this.template this.model.attributes

        onEditRule : ( event ) ->
            this.trigger "EDIT_RULE"


    }

    view = new SGRuleView()

    return view
