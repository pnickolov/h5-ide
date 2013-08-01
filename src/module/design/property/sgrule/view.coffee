#############################
#  View(UI logic) for design/property/sgrule
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SGRuleView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-sgrule-tmpl' ).html()
        app_template : Handlebars.compile $( '#property-sgrule-app-tmpl' ).html()

        events   :
            "click #sg-edit-rule-button" : "onEditRule"

        render     : (is_app_view) ->
            console.log 'property:sgrule render'

            this.model.attributes.isAppView = this.isAppView

            data = this.model.attributes
            data.isAppView = this.isAppView

            if is_app_view
                $( '.property-details' ).html this.app_template data
            else
                $( '.property-details' ).html this.template data


        onEditRule : ( event ) ->

            line_id = $("#property-sgrule").data('line')

            this.trigger "EDIT_RULE", line_id

        setAppView : ( isAppView ) ->
            this.isAppView = isAppView
            null

    }

    view = new SGRuleView()

    return view
