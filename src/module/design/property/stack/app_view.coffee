#############################
#  View(UI logic) for design/property/stack(app)
#############################

define [ '../base/view',
         'text!./template/app.html',
         'text!./template/acl.html',
         'event'
], ( PropertyView, template, acl_template, ide_event ) ->

    template     = Handlebars.compile template
    acl_template = Handlebars.compile acl_template

    InstanceAppView = PropertyView.extend {

        events :
            'click #stack-property-acl-list .edit' : 'openAcl'

        render     : () ->
            @$el.html template @model.attributes
            @refreshACLList()

            if MC.canvas.getState() isnt 'appview'
                "App - " + @model.attributes.name
            else
                str = '<header class="property-sidebar-title sidebar-title truncate" id="property-title">Visualization - '+@model.attributes.vpcid+'<i class="icon-info tooltip property-header-info" data-tooltip="Currently you can rearrange the layout of visualisation and export it as PNG image file. Future version will include the feature to import VPC resource as an app. "></i></header>'
                $('#property-title').html(str)


        refreshACLList : () ->
            this.model.getNetworkACL()
            $('#stack-property-acl-list').html acl_template this.model.attributes

        openAcl : ( event ) ->
            @trigger "OPEN_ACL", $(event.currentTarget).closest("li").attr("data-uid")
            null
    }

    new InstanceAppView()
