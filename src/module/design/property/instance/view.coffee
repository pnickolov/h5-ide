#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars',
        'UI.fixedaccordion',
        'UI.selectbox',
        'UI.secondarypanel',
        'UI.tooltip',
        'UI.notification',
        'UI.modal',
        'UI.tablist',
        'UI.toggleicon' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-instance-tmpl' ).html()

        events   :
            'change .instance-name' : 'instanceNameChange'
            'change .instance-type-select' : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized' : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data' : 'userdataChange'
            'change #property-instance-base64' : 'base64Change'
            'change #property-instance-ni-description' : 'eniDescriptionChange'
            'change #property-instance-source-check' : 'sourceCheckChange'

            'click #sg-info-list .sg-edit-icon' : 'openSgPanel'
            'click #add-sg-btn' : 'openSgPanel'

            'click #property-ami' : 'openAmiPanel'
            'click .icon-add-sg' : 'securityGroupAddSelect'

            'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select' : "tenancySelect"
            'OPTION_CHANGE #keypair-select' : "addtoKPList"
            'EDIT_UPDATE #keypair-select' : "createtoKPList"
            'click #security-group-select li' : "removeSGfromSelectbox"
            'OPTION_CHANGE #security-group-select' : "addSGtoList"
            'OPTION_SHOW #security-group-select' : 'openSGAccordion'
            'TOGGLE_ICON #sg-info-list' : "toggleSGfromList"
            'click .sg-remove-item-icon' : "removeSGfromList"
            'click #instance-ip-add' : "addIPtoList"
            'click #property-network-list .network-remove-icon' : "removeIPfromList"

            'click .toggle-eip' : 'addEIP'

        render     : ( attributes, instance_expended_id ) ->
            console.log 'property:instance render'
            #
            this.undelegateEvents()

            $( '.property-details' ).html this.template this.model.attributes
            #
            if instance_expended_id isnt undefined
                accordion = $( '#instance-accordion' )
                cur_id = accordion.find('.accordion-group').index accordion.find('.expanded')
                if cur_id != instance_expended_id
                    fixedaccordion.show.call accordion.find('.accordion-group').index instance_expended_id

            fixedaccordion.resize()
            #
            this.delegateEvents this.events

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'
            this.model.set 'name', event.target.value
            null

        instanceTypeSelect : ( event, value )->
            this.model.set 'instance_type', value

        ebsOptimizedSelect : ( event ) ->
            this.model.set 'ebs_optimized', event.target.checked

        tenancySelect : ( event, value ) ->
            this.model.set 'tenacy', value


        cloudwatchSelect : ( event ) ->
            this.model.set 'cloudwatch', event.target.checked

        userdataChange : ( event ) ->
            this.model.set 'user_data', event.target.value

        base64Change : ( event ) ->
            this.model.set 'base64', event.target.checked

        eniDescriptionChange : ( event ) ->
            this.model.set 'eni_description', event.target.value

        sourceCheckChange : ( event ) ->
            this.model.set 'source_check', event.target.checked

        addEmptyKP : ( event ) ->
            notification('error', 'KeyPair Empty', false)

        addtoKPList : ( event, id ) ->
            this.model.set 'set_kp', id
            notification('info', (id + ' added'), false)

        createtoKPList : ( event, id ) ->
            this.model.set 'add_kp', id
            notification('info', (id + ' created'), false)

        addIPtoList: (event) ->

            tmpl = $(MC.template.networkListItem())

            index = $('#property-network-list').children().length

            tmpl.children()[1] = $(tmpl.children()[1]).data("index", index).attr('data-index', index)[0]

            $('#property-network-list').append tmpl
            this.trigger 'ADD_NEW_IP'
            false

        removeIPfromList: (event, id) ->

            index = $($(event.target).parents('li').first().children()[1]).data().index

            $(event.target).parents('li').first().remove()

            $.each $("#property-network-list").children(), (idx, val) ->

                $($(val).children()[1]).data('index', idx)

                $($(val).children()[1]).attr('data-index', idx)

            this.trigger 'REMOVE_IP', index

        openSgPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            accordion = $( '#instance-accordion' )
            cur_expanded_id = accordion.find('.accordion-group').index accordion.find('.expanded')

            ide_event.trigger ide_event.OPEN_SG, target.data('secondarypanel-data'), cur_expanded_id

        openAmiPanel : ( event ) ->
            target = $('#property-ami')
            secondarypanel.open target, MC.template.aimSecondaryPanel target.data('secondarypanel-data')
            $(document.body).on 'click', '.back', secondarypanel.close
            fixedaccordion.resize()

        openSGAccordion : ( event ) ->
            fixedaccordion.show.call $('#sg-head')

        addSGtoList: (event, id) ->
            if(id.length != 0)
                $('#sg-info-list').append MC.template.sgListItem({name: id})
                this.model.set 'add_sg', id

            else

                cid = $( '#instance-property-detail' ).attr 'component'

                ide_event.trigger ide_event.OPEN_SG, {parent: cid}

        removeSGfromSelectbox : ( event ) ->
            target = $(event.target)
            if(target.data('id').length != 0)
                console.log target
                target.remove()


        removeSGfromList: (event) ->
            target = $(event.target).parents('li').first()
            sg_id = target.data('sgid')
            this.model.set 'remove_sg', sg_id
            target.remove()
            notification 'info', sg_id + ' SG is deleted', false

        toggleSGfromList: (event, id) ->
            notification 'info', id, false

        addEIP : ( event ) ->

            # todo, need a index of eip
            index = parseInt event.target.dataset.index, 10
            if event.target.className.indexOf('associated') >= 0 then attach = true else attach = false
            this.trigger 'ATTACH_EIP', index, attach
    }

    view = new InstanceView()

    return view
