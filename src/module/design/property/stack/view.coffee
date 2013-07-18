#############################
#  View(UI logic) for design/property/stack
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.notification' ], ( ide_event ) ->

    StackView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-stack-tmpl' ).html()

        events   :
            'change #property-stack-name'   : 'stackNameChanged'
            'click #show-newsg-panel'       : 'createSecurityGroup'
            'OPTION_CHANGE #security-group-select' : "addSGtoList"

        render     : () ->
            console.log 'property:stack render'
            $( '.property-details' ).html this.template this.model.attributes

        stackNameChanged : () ->
            me = this

            name = $( '#property-stack-name' ).val()
            #check stack name
            if name.slice(0,1) == '-'
                notification 'error', 'Stack name cannot start with dash'
            else if not name
                $( '#property-stack-name' ).val me.model.attributes.stack_detail.name
            else if name in MC.data.stack_list[MC.canvas_data.region]
                notification 'error', 'Stack name \"' + name + '\" is already in user. Please use another one.'
            else
                me.trigger 'STACK_NAME_CHANGED', name
                ide_event.trigger ide_event.UPDATE_TABBAR, MC.canvas_data.id, name + ' - stack'

        createSecurityGroup : (event) ->

            cid = $( '#property-stack' ).attr 'component'

            ide_event.trigger ide_event.OPEN_SG, {parent: cid}

            source = $(event.target)
            if(!source.hasClass('sg-toggle-show-icon') && !source.hasClass('sg-remove-item-icon'))
                if(source.hasClass('secondary-panel'))
                    target = source
                else
                    target = source.parents('.secondary-panel').first()

                ide_event.trigger ide_event.OPEN_SG, target.data('secondarypanel-data')

        addSGtoList: (event, id) ->
            if(id.length != 0)
                $('#sg-info-list').append MC.template.sgListItem({name: id})
                sg_uid = id
                #this.model.addSGtoInstance instance_uid, sg_uid
            else
                ide_event.trigger ide_event.OPEN_SG, {parent: MC.canvas_data.id}

    }

    view = new StackView()

    return view