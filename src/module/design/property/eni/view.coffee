#############################
#  View(UI logic) for design/property/eni
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'i18n!nls/lang.js'
], ( PropertyView, template, lang ) ->

    template = Handlebars.compile template

    ENIView = PropertyView.extend {

        events   :
            "change #property-eni-desc"             : "setEniDesc"
            "change #property-eni-source-check"     : "setEniSourceDestCheck"

            'click .toggle-eip'                     : 'setEIP'
            'click #property-eni-ip-add'            : "addIP"
            'click #property-eni-list .icon-remove' : "removeIP"
            'blur .input-ip'                        : 'syncIPList'

        render     : () ->
            @$el.html( template( @model.attributes ) )

            @refreshIPList()

            @model.attributes.name

        setEniDesc : ( event ) ->
            @model.setEniDesc event.target.value
            null

        setEniSourceDestCheck : ( event ) ->
            @model.setSourceDestCheck event.target.checked
            null

        addIP : () ->
            if $("#property-eni-ip-add").hasClass("disabled")
                return

            data = @model.addIP()
            $('#property-eni-list').append MC.template.propertyIpListItem( data )
            @updateIPAddBtnState()
            null

        setEIP : ( event ) ->
            $target = $(event.currentTarget)
            index   = $target.closest("li").index()
            attach  = not $target.hasClass("associated")

            @model.attachEIP index, attach
            null

        removeIP : (event) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            @model.removeIP index
            @updateIPAddBtnState()
            null


        syncIPList : (event) ->
            currentAvailableIPAry = _.map $('#property-eni-list li'), (ipInputItem) ->
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

        refreshIPList : ( event ) ->
            html = ""
            for ip in @model.attributes.ips
                html += MC.template.propertyIpListItem ip

            $( '#property-eni-list' ).html( html )
            @updateIPAddBtnState()
            null
# =======
#             else
#                 $parent.find(".input-ip").attr "disabled", "disabled"
#                 $parent.find(".name").data "tooltip", "Automatically assigned IP."

#         updateEIPList: (event) ->

#             currentAvailableIPAry = []
#             ipInuptListItem = $('#property-eni-list li.input-ip-item')
#             validSuccess = true
#             that = this
#             eniUID = that.model.get 'uid'

#             instanceUID = ''
#             currentENIComp = MC.canvas_data.component[eniUID]
#             instanceUIDRef = currentENIComp.resource.Attachment.InstanceId
#             if instanceUIDRef
#                 instanceUID = instanceUIDRef.split('.')[0].slice(1)

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
#             eniUID = this.model.get 'uid'
#             currentENIComp = MC.canvas_data.component[eniUID]
#             instanceUIDRef = currentENIComp.resource.Attachment.InstanceId
#             if instanceUIDRef
#                 instanceUID = instanceUIDRef.split('.')[0].slice(1)
#                 countNum = MC.canvas_data.component[instanceUID].number
#                 if countNum is 1
#                     @setEditableIP true
#                 else
#                     @setEditableIP false
# >>>>>>> origin/develop

        updateIPAddBtnState : () ->
            enabled = @model.canAddIP()

            if enabled is true
                tooltip = "Add IP Address"
            else
                if _.isString enabled
                    tooltip = enabled
                else
                    tooltip = "Cannot add IP address"
                enabled = false

            $("#property-eni-ip-add").toggleClass("disabled", !enabled).data("tooltip", tooltip)
            null

    }

    new ENIView()
