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
            'click .stack-property-acl-list .edit'  : 'openEditAclPanel'

        render     : () ->
            @$el.html template @model.attributes
            @refreshACLList()

            "App - " + @model.attributes.property_detail.name


        refreshACLList : () ->
            if MC.aws.vpc.getVPCUID() or MC.aws.aws.checkDefaultVPC()
                this.model.getNetworkACL()
                $('.stack-property-acl-list').html acl_template this.model.attributes

        openEditAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            @trigger "OPEN_ACL", source.attr('acl-uid')
    }

    new InstanceAppView()
