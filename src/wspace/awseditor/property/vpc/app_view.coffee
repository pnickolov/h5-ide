#############################
#  View(UI logic) for design/property/vpc(app)
#############################

define [ '../base/view', './template/app', "tag_manager" ], ( PropertyView, template, TagManager ) ->

    VPCAppView = PropertyView.extend {
        events:
            "click .open-tag-manager"    : "openTagManager"

        render : () ->
            data = @model.attributes
            if data.dhcpOptionsId is 'default'
                data.defaultDhcp = true
                data.autoDhcp = false
            else if not data.dhcpOptionsId or not data.dhcp
                data.autoDhcp = true
                data.defaultDhcp = false
            else if data.dhcpOptionsId[0] isnt "@"
                data.autoDhcp = false
                data.defaultDhcp = false
            @$el.html template data
            @model.attributes.name

        openTagManager: ()->
            new TagManager(@model)
    }

    new VPCAppView()
