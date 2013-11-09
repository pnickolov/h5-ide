#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ '../base/view', 'text!./template/app.html' ], ( PropertyView, template ) ->

    template = Handlebars.compile template

    SubnetAppView = PropertyView.extend {

        events    :
            "click .acl-sg-info-list .icon-btn-details" : 'showACLDetail'

        render     : () ->
            @$el.html template @model.attributes
            @setTitle @model.attributes.name
            null

        showACLDetail : ( event ) ->
            @trigger 'OPEN_ACL', $( event.currentTarget ).attr("data-uid")
            null
    }

    new SubnetAppView()
