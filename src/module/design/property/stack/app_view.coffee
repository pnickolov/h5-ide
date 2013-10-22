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

        # events :
            # 'click #sg-info-list .sg-edit-icon'     : 'openSecurityGroup'
            # 'click .stack-property-acl-list .edit'  : 'openEditAclPanel'

        render     : () ->
            @$el.html template @model.attributes
            @refreshACLList()

            "App - " + @model.attributes.property_detail.name

        # openSecurityGroup : (event) ->
        #     source = $(event.target)
        #     if(source.hasClass('secondary-panel'))
        #         target = source
        #     else
        #         target = source.parents('.secondary-panel').first()

        #     @trigger "OPEN_SG", target.data('secondarypanel-data')

        # deleteNetworkAcl : (event) ->
        #     aclUID = $(event.target).attr('acl-uid')
        #     delete MC.canvas_data.component[aclUID]
        #     this.refreshACLList()

        refreshACLList : () ->
            if MC.aws.vpc.getVPCUID() or MC.aws.aws.checkDefaultVPC()
                this.model.getNetworkACL()
                $('.stack-property-acl-list').html acl_template this.model.attributes

        # openCreateAclPanel : ( event ) ->
        #     source = $(event.target)
        #     if(source.hasClass('secondary-panel'))
        #         target = source
        #     else
        #         target = source.parents('.secondary-panel').first()

        #     aclUID = MC.guid()
        #     aclObj = $.extend(true, {}, MC.canvas.ACL_JSON.data)
        #     aclObj.name = MC.aws.acl.getNewName()
        #     aclObj.uid = aclUID

        #     MC.canvas_data.component[aclUID] = aclObj

        #     @trigger "OPEN_ACL", aclUID

        # openEditAclPanel : ( event ) ->
        #     source = $(event.target)
        #     if(source.hasClass('secondary-panel'))
        #         target = source
        #     else
        #         target = source.parents('.secondary-panel').first()

        #     @trigger "OPEN_ACL", source.attr('acl-uid')
    }

    new InstanceAppView()
