#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'event',
         'i18n!nls/lang.js' ], ( PropertyView, template, ide_event, lang ) ->

    template =  Handlebars.compile template

    InstanceView = PropertyView.extend {

        events   :
            'change .instance-name'                       : 'instanceNameChange'
            'change #property-instance-count'             : 'countChange'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-ni-description'    : 'eniDescriptionChange'
            'change #property-instance-source-check'      : 'sourceCheckChange'
            'change #property-instance-public-ip'         : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select'               : "tenancySelect"

            'click #property-ami' : 'openAmiPanel'

            'OPTION_CHANGE #keypair-select'      : "setKP"
            'EDIT_UPDATE #keypair-select'        : "addKP"
            'click #keypair-select .icon-remove' : "deleteKP"
            "EDIT_FINISHED #keypair-select"      : "updateKPSelect"

            'click .toggle-eip'                         : 'setEIP'
            'click #instance-ip-add'                    : "addIP"
            'click #property-network-list .icon-remove' : "removeIP"
            'change .input-ip'                          : 'syncIPList'


        render : () ->

            # TODO : Remove following 3 lines
            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                this.model.attributes.component.resource.VpcId = defaultVPCId

            @$el.html template @model.attributes

            @refreshIPList()

            @model.attributes.name

        instanceNameChange : ( event ) ->

            target = $ event.currentTarget
            name = target.val()
            id = @model.get 'uid'

            MC.validate.preventDupname target, id, name, 'Instance'


            if target.parsley 'validate'
                @model.setName name
                @setTitle name
            null

        countChange : ( event ) ->
            target = $ event.currentTarget

            that = this

            target.parsley 'custom', ( val ) ->
                if isNaN( val ) or val > 99 or val < 1
                    return 'This value must be >= 1 and <= 99'

            if target.parsley 'validate'

                instanceUID = that.model.get 'get_uid'
                MC.aws.eni.updateAllInstanceENIIPToAutoAssign(instanceUID)
                this.refreshIPList()

                val = +target.val()
                @model.setCount val
                $(".property-instance-name-wrap").toggleClass("single", val == 1)
                $("#property-instance-name-count").text val
                @setEditableIP val == 1

        setEditableIP : ( enable ) ->
            $parent = $("#property-network-list")

            if enable
                $parent.find(".input-ip-wrap").removeClass("disabled")
                       .find(".name").data("tooltip", lang.ide.PROP_INSTANCE_IP_MSG_1)
                       .find(".input-ip").removeAttr("disabled")

            else
                $parent.find(".input-ip-wrap").addClass("disabled")
                       .find(".name").data("tooltip", lang.ide.PROP_INSTANCE_IP_MSG_2)
                       .find(".input-ip").attr("disabled", "disabled")
            null

        instanceTypeSelect : ( event, value )->

            canset = @model.canSetInstanceType value
            if canset isnt true
                notification "error", canset
                event.preventDefault()
                return

            has_ebs = @model.setInstanceType value
            $ebs = $("#property-instance-ebs-optimized")
            $ebs.closest(".property-control-group").toggle has_ebs
            if not has_ebs
                $ebs.prop "checked", false

            @refreshIPList()

        ebsOptimizedSelect : ( event ) ->
            @model.setEbsOptimized event.target.checked
            null

        tenancySelect : ( event, value ) ->
            $type = $("#instance-type-select")
            $t1   = $type.find("[data-id='t1.micro']")

            if $t1.length
                show = value isnt "dedicated"
                $t1.toggle( show )

                if $t1.hasClass("selected") and not show
                    $type.find(".item:not([data-id='t1.micro'])").eq(0).click()

            @model.setTenancy value
            null

        cloudwatchSelect : ( event ) ->
            @model.setCloudWatch event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            @model.setUserData event.target.value
            null

        eniDescriptionChange : ( event ) ->
            @model.setEniDescription event.target.value
            null

        sourceCheckChange : ( event ) ->
            @model.setSourceCheck event.target.checked
            null

        publicIpChange : ( event ) ->
            @model.setPublicIp event.target.checked
            null

        setKP : ( event, id ) ->
            @model.setKP id
            null

        addKP : ( event, id ) ->
            result = @model.addKP id
            if not result
                notification "error", "KeyPair with the same name already exists."
                return result

        updateKPSelect : () ->
            # Add remove icon to the newly created item
            $("#keypair-select").find(".item:last-child").append('<span class="icon-remove"></span>')
            null

        openAmiPanel : ( event ) ->
            @trigger "OPEN_AMI", $("#property-ami").attr("data-uid")
            null

# <<<<<<< HEAD
# =======
#         addEIP : ( event ) ->

#             # todo, need a index of eip
#             index = $(event.currentTarget).closest("li").index()
#             if event.target.className.indexOf('associated') >= 0 then attach = true else attach = false
#             this.trigger 'ATTACH_EIP', index, attach

#             this.updateEIPList()

#         updateEIPList: (event) ->

#             currentAvailableIPAry = []
#             ipInuptListItem = $('#property-network-list li.input-ip-item')
#             validSuccess = true
#             that = this
#             instanceUID = that.model.get 'get_uid'
#             eniComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
#             eniUID = eniComp.uid

#             currentInputValue = currentIdx = null
#             if event and event.currentTarget
#                 currentInputValue = $(event.currentTarget).val()
#                 currentIdx = $(event.currentTarget).parents('li.input-ip-item').index()

#             _.each ipInuptListItem, (ipInputItem, idx) ->

#                 if event and event.currentTarget
#                     currentInputValue = $(event.currentTarget).val()

#                 inputValuePrefix = $(ipInputItem).find('.input-ip-prefix').text()
#                 inputValue = $(ipInputItem).find('.input-ip').val()
#                 currentInputIP = inputValuePrefix + currentInputValue

#                 prefixAry = inputValuePrefix.split('.')

#                 ################################### validation
#                 validDOM = $(ipInputItem).find('.input-ip')

#                 validDOM.parsley 'custom', ( val ) ->

#                     ###### validation format
#                     ipIPFormatCorrect = false
#                     # for 10.0.0.
#                     if prefixAry.length is 4
#                         if inputValue is 'x'
#                             ipIPFormatCorrect = true
#                         if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
#                             ipIPFormatCorrect = true
#                     # for 10.0.
#                     else
#                         if inputValue is 'x.x'
#                             ipIPFormatCorrect = true
#                         if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
#                             ipIPFormatCorrect = true
#                     if !ipIPFormatCorrect
#                         return 'Invalid IP address'

#                     ###### validation if in subnet
#                     # ipAddr = inputValuePrefix + inputValue
#                     if currentInputValue.indexOf('x') is -1
#                         ipInSubnet = false
#                         subnetCIDR = ''
#                         defaultVPCId = MC.aws.aws.checkDefaultVPC()
#                         if defaultVPCId
#                             subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
#                             subnetCIDR = subnetObj.cidrBlock
#                         else
#                             subnetUID = MC.canvas_data.component[instanceUID].resource.SubnetId.split('.')[0][1...]
#                             subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

#                         ipInSubnet = MC.aws.subnet.isIPInSubnet(currentInputIP, subnetCIDR)

#                         if !ipInSubnet
#                             return 'This IP address conflicts with subnet’s IP range'

#                     ###### validation if conflict with other eni
#                     if currentInputValue.indexOf('x') is -1
#                         innerRepeat = false
#                         _.each ipInuptListItem, (ipInputItem1, idx1) ->
#                             inputValue1 = $(ipInputItem1).find('.input-ip').val()
#                             if currentIdx isnt idx1 and inputValue1 is currentInputValue
#                                 innerRepeat = true
#                             null
#                         if innerRepeat
#                             return 'This IP address conflicts with other IP'
#                         if MC.aws.eni.haveIPConflictWithOtherENI(currentInputIP, eniUID)
#                             return 'This IP address conflicts with other network interface’s IP'

#                     null

#                 if event and event.currentTarget and currentIdx is idx
#                     if not validDOM.parsley 'validate'
#                         validSuccess = false
#                 ################################### validation

#                 inputHaveEIP = $(ipInputItem).find('.input-ip-eip-btn').hasClass('associated')
#                 currentAvailableIPAry.push({
#                     ip: inputValuePrefix + inputValue,
#                     eip: inputHaveEIP
#                 })
#                 null

#             if !validSuccess
#                 return

#             this.trigger 'SET_IP_LIST', currentAvailableIPAry

#             # if is Server Group, disabled ip inputbox
#             instanceUID = this.model.get 'get_uid'
#             countNum = MC.canvas_data.component[instanceUID].number
#             if countNum is 1
#                 @setEditableIP true
#             else
#                 @setEditableIP false

#             this.changeIPAddBtnState()

#         changeIPAddBtnState : () ->

#             disabledBtn = false
#             instanceUID = this.model.get 'get_uid'

#             maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
#             currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
#             if !currentENIComp
#                 disabledBtn = true
#                 return

#             currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
#             if maxIPNum is currentIPNum
#                 disabledBtn = true

#             instanceType = MC.canvas_data.component[instanceUID].resource.InstanceType
#             if disabledBtn
#                 tooltipStr = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
#                 $('#instance-ip-add').addClass('disabled').attr('data-tooltip', tooltipStr).data('tooltip', tooltipStr)
#             else
#                 $('#instance-ip-add').removeClass('disabled').attr('data-tooltip', 'Add IP Address').data('tooltip', 'Add IP Address')

#             null
# >>>>>>> origin/develop

        deleteKP : ( event ) ->
            me = this
            $li = $(event.currentTarget).closest("li")

            selected = $li.hasClass("selected")
            using = if using is "true" then true else selected

            removeKP = () ->

                $li.remove()
                # If deleting selected kp, select the first one
                if selected
                    $("#keypair-select").find(".item").eq(0).click()

                me.model.deleteKP $li.attr("data-id")

            if using
                data =
                    title   : "Delete Key Pair"
                    confirm : "Delete"
                    color   : "red"
                    body    : "<p class='modal-text-major'>Are you sure you want to delete #{$li.text()}</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
                # Ask for confirm
                modal MC.template.modalApp data
                $("#btn-confirm").one "click", ()->
                    removeKP()
                    modal.close()
            else
                removeKP()

            return false


        addIP : () ->
            if $("#instance-ip-add").hasClass("disabled")
                return

            data = @model.addIP()
            $('#property-network-list').append MC.template.propertyIpListItem( data )
            @updateIPAddBtnState()
            null

        removeIP : ( event ) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            @model.removeIP index
            @updateIPAddBtnState()
            null

        setEIP : ( event ) ->
            $target = $(event.currentTarget)
            index   = $target.closest("li").index()
            attach  = not $target.hasClass("associated")

            @model.attachEIP index, attach
            null

        # This function is used to save IP List to model
        syncIPList: () ->
            currentAvailableIPAry = _.map $('#property-network-list li'), (ipInputItem) ->
                $item   = $(ipInputItem)
                prefix  = $item.find(".input-ip-prefix").text()
                value   = $item.find(".input-ip").val()
                has_eip = $item.find(".input-ip-eip-btn").hasClass("associated")

                {
                    ip     : prefix + value
                    eip    : has_eip
                    suffix : value
                }

            @model.setIPList currentAvailableIPAry
            null

        # This function is used to display IP List
        refreshIPList : ( event ) ->
            if not @model.attributes.eni_ips
                return

            html = ""
            for ip in @model.attributes.eni_ips
                html += MC.template.propertyIpListItem ip

            $( '#property-network-list' ).html( html )
            @updateIPAddBtnState()
            null

        updateIPAddBtnState : ()->
            enabled = @model.canAddIP()

            if enabled is true
                tooltip = "Add IP Address"
            else
                if _.isString enabled
                    tooltip = enabled
                else
                    tooltip = "Cannot add IP address"
                enabled = false

            $("#instance-ip-add").toggleClass("disabled", !enabled).data("tooltip", tooltip)
            null
    }

    new InstanceView()
