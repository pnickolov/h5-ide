#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    SubnetAppView = PropertyView.extend {

        events    :
            "click .acl-sg-info-list .icon-btn-details" : 'showACLDetail'

        render     : () ->
            @$el.html template @model.toJSON()
            @setTitle @model.get 'name'
            null

        showACLDetail : ( event ) ->
            @trigger 'OPEN_ACL', $( event.currentTarget ).data 'uid'
            null
    }

    new SubnetAppView()
