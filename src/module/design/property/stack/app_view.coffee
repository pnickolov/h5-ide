#############################
#  View(UI logic) for design/property/stack(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars',
         'UI.notification',
         'UI.secondarypanel' ], ( ide_event, MC ) ->

    InstanceAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        app_template    : Handlebars.compile $( '#property-app-tmpl' ).html()
        acl_template    : Handlebars.compile $( '#property-stack-acl-tmpl' ).html()

        events :
            'click #sg-info-list .sg-edit-icon'     : 'openSecurityGroup'
            'click .stack-property-acl-list .edit'  : 'openEditAclPanel'

        render     : () ->
            me = this

            console.log 'instance app render'

            #
            this.undelegateEvents()
            #
            $( '.property-details' ).html this.app_template this.model.attributes

            this.refreshACLList()
            #
            this.delegateEvents this.events

        openSecurityGroup : (event) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            accordion = $( '.property-stack' )
            cur_expanded_id = accordion.find('.accordion-group').index accordion.find('.expanded')

            ide_event.trigger ide_event.OPEN_SG, target.data('secondarypanel-data'), cur_expanded_id

        deleteNetworkAcl : (event) ->
            aclUID = $(event.target).attr('acl-uid')
            delete MC.canvas_data.component[aclUID]
            this.refreshACLList()

        refreshACLList : () ->
            this.model.getNetworkACL()
            $('.stack-property-acl-list').html this.acl_template this.model.attributes

        openCreateAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            accordion = $( '#instance-accordion' )
            cur_expanded_id = accordion.find('.accordion-group').index accordion.find('.expanded')

            aclUID = MC.guid()
            aclObj = $.extend(true, {}, MC.canvas.ACL_JSON.data)
            aclObj.name = MC.aws.acl.getNewName()
            aclObj.uid = aclUID

            MC.canvas_data.component[aclUID] = aclObj

            ide_event.trigger(ide_event.OPEN_ACL, target.data('secondarypanel-data'), cur_expanded_id, aclUID)

        openEditAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            accordion = $( '#instance-accordion' )
            cur_expanded_id = accordion.find('.accordion-group').index accordion.find('.expanded')

            aclUID = source.attr('acl-uid')

            ide_event.trigger(ide_event.OPEN_ACL, target.data('secondarypanel-data'), cur_expanded_id, aclUID)

    }

    view = new InstanceAppView()

    return view