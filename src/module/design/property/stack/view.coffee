#############################
#  View(UI logic) for design/property/stack
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars',
    'UI.notification',
    'UI.secondarypanel' ], ( ide_event ) ->

    StackView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-stack-tmpl' ).html()
        acl_template : Handlebars.compile $( '#property-stack-acl-tmpl' ).html()

        events   :
            'change #property-stack-name'   : 'stackNameChanged'
            'click #add-sg-btn'             : 'createSecurityGroup'
            'click .deleteSG'               : 'deleteSecurityGroup'
            'click .resetSG'                : 'resetSecurityGroup'
            'click .stack-property-acl-list .delete' : 'deleteNetworkAcl'
            
        render     : () ->
            console.log 'property:stack render'
            $( '.property-details' ).html this.template this.model.attributes
            this.refreshACLList()

        stackNameChanged : () ->
            me = this

            name = $( '#property-stack-name' ).val()
            #check stack name
            if name.slice(0,1) == '-'
                notification 'error', 'Stack name cannot start with dash.'
            else if name.slice(0, 8) == 'untitled'
                notification 'error', 'Please modify the initial stack name.'
            else if not name
                $( '#property-stack-name' ).val me.model.attributes.stack_detail.name
            else if name in MC.data.stack_list[MC.canvas_data.region]
                notification 'error', 'Stack name \"' + name + '\" is already in using. Please use another one.'
            else
                me.trigger 'STACK_NAME_CHANGED', name
                ide_event.trigger ide_event.UPDATE_TABBAR, MC.canvas_data.id, name + ' - stack'

        createSecurityGroup : (event) ->

            ide_event.trigger ide_event.OPEN_SG

        deleteSecurityGroup : (event) ->
            me = this

            target = $(event.target).parents('div:eq(0)')
            uid = target.attr('uid')
            name = target.children('p.title').text()

            console.log "Remove sg:" + uid

            me.trigger 'DELETE_STACK_SG', uid

            target.remove()

            notification 'info', name + ' is deleted.'

            null

        resetSecurityGroup : (event) ->
            me = this

            target = $(event.target).parents('div:eq(0)')
            uid = target.attr('uid')
            
            me.trigger 'RESET_STACK_SG', uid

            null

        deleteNetworkAcl : (event) ->
            aclUID = $(event.target).attr('acl-uid')
            delete MC.canvas_data.component[aclUID]
            this.refreshACLList()

        refreshACLList : () ->
            this.model.getNetworkACL()
            $('.stack-property-acl-list').html this.acl_template this.model.attributes
    }

    view = new StackView()

    return view