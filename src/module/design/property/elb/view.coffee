#############################
#  View(UI logic) for design/property/elb
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars',
        'UI.fixedaccordion',
        'UI.secondarypanel',
        'UI.selectbox',
        'UI.tooltip',
        'UI.notification',
        'UI.toggleicon',
        'UI.slider' ], ( ide_event, MC ) ->

    ElbView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-elb-tmpl' ).html()

        #events   :
            # 'change .instance-name' : 'instanceNameChange'
            # 'change .instance-type-select' : 'instanceTypeSelect'
            # 'change #property-instance-ebs-optimized' : 'ebsOptimizedSelect'
            # 'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            # 'change #property-instance-user-data' : 'userdataChange'
            # 'change #property-instance-base64' : 'base64Change'
            # 'change #property-instance-ni-description' : 'eniDescriptionChange'
            # 'change #property-instance-source-check' : 'sourceCheckChange'
            
            # 'click #sg-info-list li' : 'openSgPanel'

            # 'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"
            # 'OPTION_CHANGE #tenancy-select' : "tenancySelect"
            # 'EDIT_EMPTY #keypair-select' : "addEmptyKP"
            # 'OPTION_CHANGE #keypair-select' : "addtoKPList"
            # 'EDIT_UPDATE #keypair-select' : "createtoKPList"
            # 'OPTION_CHANGE #security-group-select' : "addSGtoList"
            # 'click #sg-info-list .sg-remove-item-icon' : "removeSGfromList"
            # 'click #instance-ip-add' : "addIPtoList"
            # 'click #property-network-list .network-remove-icon' : "removeIPfromList"

        render     : ( attributes ) ->
            console.log 'property:elb render'
            $( '.property-details' ).html this.template attributes
            #fixedaccordion.resize()

        # instanceNameChange : ( event ) ->
        #     console.log 'instanceNameChange'
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setHost cid, event.target.value

        # instanceTypeSelect : ( event, value )->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setInstanceType cid, value

        # ebsOptimizedSelect : ( event ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setEbsOptimized cid, event.target.checked

        # tenancySelect : ( event, value ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setTenancy cid, value


        # cloudwatchSelect : ( event ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setCloudWatch cid, event.target.checked

        # userdataChange : ( event ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setUserData cid, event.target.value
        #     #console.log event.target.value

        # base64Change : ( event ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setBase64Encoded cid, event.target.checked


        # eniDescriptionChange : ( event ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setEniDescription cid, event.target.value

        # sourceCheckChange : ( event ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setSourceCheck cid, event.target.checked

        # addEmptyKP : ( event ) ->
        #     notification('error', 'KeyPair Empty', false)

        # addtoKPList : ( event, id ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.setKP cid, id
        #     notification('info', (id + ' added'), false)

        # createtoKPList : ( event, id ) ->
        #     cid = $( '#instance-property-detail' ).attr 'component'
        #     this.model.addKP cid, id
        #     notification('info', (id + ' created'), false)

        # securityGroupAddSelect: (event) ->
        #     event.stopPropagation()
        #     fixedaccordion.show.call $(this).parent().find '.fixedaccordion-head'

        # addSGtoList: (event, id) ->
        #     if(id.length != 0)
        #         $('#sg-info-list').append MC.template.sgListItem({name: id})

        # addIPtoList: (event) ->
        #     $('#property-network-list').append MC.template.networkListItem()
        #     false

        # removeSGfromList: (event, id) ->
        #     event.stopPropagation()
        #     $(this).parent().remove()
        #     notification 'info', 'SG is deleted', false

        # removeIPfromList: (event, id) ->
        #     event.stopPropagation()
        #     $(this).parent().remove()

    }

    view = new ElbView()

    return view