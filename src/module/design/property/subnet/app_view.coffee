#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ '../base/view', 'text!./template/app.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    SubnetAppView = Backbone.View.extend {

        events    :
            "click #property-app-subnet-acl" : 'showACLDetail'

        render     : () ->
            @$el.html template @model.attributes
            @setTitle @model.attributes.name
            null

        showACLDetail : () ->
            @trigger 'OPEN_ACL', $("#property-app-subnet-acl").attr("data-uid")
            null
    }

    new SubnetAppView()
