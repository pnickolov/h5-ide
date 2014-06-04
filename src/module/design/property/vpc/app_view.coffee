#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    VPCAppView = PropertyView.extend {

        render : () ->
            data = @model.attributes
            if data.dhcpOptionsId is 'default'
                data.defaultDhcp = true
            else if not data.dhcpOptionsId
                data.autoDhcp = true
            else if data.dhcpOptionsId[0] isnt "@"
                data.autoDhcp = false
            @$el.html template data
            @model.attributes.name
    }

    new VPCAppView()
