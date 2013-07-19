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
            'EDIT_EMPTY #keypair-select' : "addEmptyKP"
            'OPTION_CHANGE #keypair-select' : "addtoKPList"
            'EDIT_UPDATE #keypair-select' : "createtoKPList"
            'click #security-group-select li' : "removeSGfromSelectbox"
            'OPTION_CHANGE #security-group-select' : "addSGtoList"
            'OPTION_SHOW #security-group-select' : 'openSGAccordion'
            'TOGGLE_ICON #sg-info-list' : "toggleSGfromList"
            'click .sg-remove-item-icon' : "removeSGfromList"
            'click #instance-ip-add' : "addIPtoList"
            'click #property-network-list .network-remove-icon' : "removeIPfromList"



        render     : ( attributes, instance_expended_id ) ->
            console.log 'property:instance render'
            $( '.property-details' ).html this.template attributes
            if instance_expended_id isnt undefined
                accordion = $( '#instance-accordion' )
                cur_id = accordion.find('.accordion-group').index accordion.find('.expanded')
                if cur_id != instance_expended_id
                    fixedaccordion.show.call accordion.find('.accordion-group').index instance_expended_id

            fixedaccordion.resize()

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setHost cid, event.target.value
            this.trigger 'RE_RENDER', cid

        instanceTypeSelect : ( event, value )->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setInstanceType cid, value

        ebsOptimizedSelect : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setEbsOptimized cid, event.target.checked

        tenancySelect : ( event, value ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setTenancy cid, value


        cloudwatchSelect : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setCloudWatch cid, event.target.checked

        userdataChange : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setUserData cid, event.target.value
            #console.log event.target.value

        base64Change : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setBase64Encoded cid, event.target.checked

        eniDescriptionChange : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setEniDescription cid, event.target.value

        sourceCheckChange : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setSourceCheck cid, event.target.checked

        addEmptyKP : ( event ) ->
            notification('error', 'KeyPair Empty', false)

        addtoKPList : ( event, id ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setKP cid, id
            notification('info', (id + ' added'), false)

        createtoKPList : ( event, id ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.addKP cid, id
            notification('info', (id + ' created'), false)

        addIPtoList: (event) ->
            $('#property-network-list').append MC.template.networkListItem()
            false

        removeIPfromList: (event, id) ->
            $(event.target).parents('li').first().remove()

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
                instance_uid = $( '#instance-property-detail' ).attr 'component'
                sg_uid = id
                this.model.addSGtoInstance instance_uid, sg_uid

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
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.removeSG cid, sg_id
            target.remove()
            notification 'info', sg_id + ' SG is deleted', false

        toggleSGfromList: (event, id) ->
            notification 'info', id, false
    }

    view = new InstanceView()

    return view