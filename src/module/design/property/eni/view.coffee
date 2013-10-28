#############################
#  View(UI logic) for design/property/eni
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/ip_list.html',
         'i18n!nls/lang.js'
], ( PropertyView, template, ip_list_template, lang ) ->

    template = Handlebars.compile template
    ip_list_template = Handlebars.compile ip_list_template

    ENIView = PropertyView.extend {

        events   :
            "change #property-eni-desc"             : "setEniDesc"
            "change #property-eni-source-check"     : "setEniSourceDestCheck"
            'click #property-eni-ip-add'            : "addIPtoList"
            'click #property-eni-list .icon-remove' : "removeIPfromList"
            'click .toggle-eip'                     : 'addEIP'
            'blur .input-ip'                        : 'updateEIPList'

        render     : () ->
            console.log 'property:eni render'
            @$el.html( template( @model.attributes ) )

            $( '#property-eni-list' ).html( ip_list_template( @model.attributes ) )

            @changeIPAddBtnState()

            @model.attributes.eni_display.name

        setEniDesc : ( event ) ->

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger "SET_ENI_DESC", uid, event.target.value

        setEniSourceDestCheck : ( event ) ->

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger "SET_ENI_SOURCE_DEST_CHECK", uid, event.target.checked

        addIPtoList : ( event ) ->

            subnetCIDR = ''
            eniUID = this.model.get 'uid'

            # validate max ip num
            maxIPNum = MC.aws.eni.getENIMaxIPNum(eniUID)
            currentENIComp = MC.canvas_data.component[eniUID]
            if !currentENIComp then return
            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                return false
            # validate max ip num

            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(eniUID)
                subnetCIDR = subnetObj.cidrBlock
            else
                subnetUID = MC.canvas_data.component[eniUID].resource.SubnetId.split('.')[0][1...]
                subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

            ipPrefixSuffix = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)
            tmpl = $(MC.template.networkListItem({
                ipPrefix: ipPrefixSuffix[0],
                ipSuffix: ipPrefixSuffix[1]
            }))

            $('#property-eni-list').append tmpl

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger 'ADD_NEW_IP', uid

            this.updateEIPList()

        addEIP : ( event ) ->

            # todo, need a index of eip
            index = $(event.currentTarget).closest("li").index()

            if event.target.className.indexOf('associated') >= 0 then attach = true else attach = false

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger 'ATTACH_EIP', uid, index, attach

            this.updateEIPList()

        removeIPfromList: (event) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger 'REMOVE_IP', uid, index

            this.updateEIPList()

        setEditableIP : ( enable ) ->
            $parent = $("#property-eni-list")

            if enable
                $parent.find(".input-ip").removeAttr "disabled"
                $parent.find(".name").data "tooltip", "Specify an IP address or leave it as .x to automatically assign an IP."

            else
                $parent.find(".input-ip").attr "disabled", "disabled"
                $parent.find(".name").data "tooltip", "Automatically assigned IP."

        updateEIPList: (event) ->

            currentAvailableIPAry = []
            ipInuptListItem = $('#property-eni-list li')

            _.each ipInuptListItem, (ipInputItem) ->
                inputValuePrefix = $(ipInputItem).find('.input-ip-prefix').text()
                inputValue = $(ipInputItem).find('.input-ip').val()
                inputHaveEIP = $(ipInputItem).find('.input-ip-eip-btn').hasClass('associated')
                currentAvailableIPAry.push({
                    ip: inputValuePrefix + inputValue,
                    eip: inputHaveEIP
                })
                null

            this.trigger 'SET_IP_LIST', currentAvailableIPAry

            # if is Server Group, disabled ip inputbox
            eniUID = this.model.get 'uid'
            currentENIComp = MC.canvas_data.component[eniUID]
            instanceUIDRef = currentENIComp.resource.Attachment.InstanceId
            if instanceUIDRef
                instanceUID = instanceUIDRef.split('.')[0].slice(1)
                countNum = MC.canvas_data.component[instanceUID].number
                if countNum is 1
                    @setEditableIP true
                else
                    @setEditableIP false

            this.changeIPAddBtnState()

        refreshIPList : ( event ) ->
            eniUID = this.model.get 'uid'
            this.model.getENIDisplay(eniUID)
            $( '#property-eni-list' ).html( ip_list_template( @model.attributes))

        changeIPAddBtnState : () ->

            disabledBtn = false
            eniUID = this.model.get 'uid'

            maxIPNum = MC.aws.eni.getENIMaxIPNum(eniUID)

            currentENIComp = MC.canvas_data.component[eniUID]
            if !currentENIComp then return
            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                disabledBtn = true

            instanceUIDRef = currentENIComp.resource.Attachment.InstanceId
            if instanceUIDRef
                instanceUID = instanceUIDRef.split('.')[0].slice(1)
                instanceType = MC.canvas_data.component[instanceUID].resource.InstanceType
                if disabledBtn
                    tooltipStr = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
                    $('#property-eni-ip-add').addClass('disabled').attr('data-tooltip', tooltipStr).data('tooltip', tooltipStr)
                else
                    $('#property-eni-ip-add').removeClass('disabled').attr('data-tooltip', 'Add IP Address').data('tooltip', 'Add IP Address')

            null

    }

    new ENIView()
