#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars',
        'UI.fixedaccordion',
        'UI.selectbox',
        'UI.secondarypanel',
        'UI.tooltip',
        'UI.notification',
        'UI.modal'
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

            'click #sg-info-list li' : 'openSgPanel'
            'click #show-newsg-panel' : 'openSgPanel'

            'click #property-ami' : 'openAmiPanel'
            'click .icon-add-sg' : 'securityGroupAddSelect'

            'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select' : "tenancySelect"
            'EDIT_EMPTY #keypair-select' : "addEmptyKP"
            'OPTION_CHANGE #keypair-select' : "addtoKPList"
            'EDIT_UPDATE #keypair-select' : "createtoKPList"
            'click #security-group-select li' : "removeSGfromSelectbox"
            'OPTION_CHANGE #security-group-select' : "addSGtoList"
            'TOGGLE_ICON #sg-info-list' : "toggleSGfromList"
            'click .sg-remove-item-icon' : "removeSGfromList"
            'click #instance-ip-add' : "addIPtoList"
            'click #property-network-list .network-remove-icon' : "removeIPfromList"



        render     : ( attributes ) ->
            console.log 'property:instance render'
            $( '.property-details' ).html this.template attributes
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
            if(!source.hasClass('sg-toggle-show-icon') || !source.hasClass('sg-remove-item-icon'))
                if(source.hasClass('secondary-panel'))
                    target = source
                else
                    target = source.parents('.secondary-panel').first()

                ide_event.trigger ide_event.OPEN_SG, target.data('secondarypanel-data')
                #secondarypanel.open target, MC.template.sgSecondaryPanel target.data('secondarypanel-data')
                #$(document.body).on 'click', '.back', secondarypanel.close
                #fixedaccordion.resize()
                #selectbox.init()

        openAmiPanel : ( event ) ->
            target = $('#property-ami')
            secondarypanel.open target, MC.template.aimSecondaryPanel target.data('secondarypanel-data')
            $(document.body).on 'click', '.back', secondarypanel.close

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
            target.remove()
            notification 'info', sg_id + ' SG is deleted', false

        toggleSGfromList: (event, id) ->
            notification 'info', id, false
    }

    view = new InstanceView()

    return view