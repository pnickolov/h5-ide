#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/ip_list.html',
         'event',
         'i18n!nls/lang.js' ], ( PropertyView, template, ip_list_template, ide_event, lang ) ->

    template =  Handlebars.compile template
    ip_list_template = Handlebars.compile ip_list_template

    InstanceView = PropertyView.extend {

        events   :
            'change .instance-name'                       : 'instanceNameChange'
            'change #property-instance-count'             : 'countChange'
            'change .instance-type-select'                : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-ni-description'    : 'eniDescriptionChange'
            'change #property-instance-source-check'      : 'sourceCheckChange'
            'change #property-instance-public-ip'         : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select'               : "tenancySelect"
            'OPTION_CHANGE #keypair-select'               : "setKP"
            'EDIT_UPDATE #keypair-select'                 : "addKP"
            'click #instance-ip-add'                      : "addIPtoList"
            'click #property-network-list .icon-remove'   : "removeIPfromList"
            "EDIT_FINISHED #keypair-select"               : "updateKPSelect"

            'change .input-ip'    : 'updateEIPList'
            'click .toggle-eip'   : 'addEIP'
            'click #property-ami' : 'openAmiPanel'

        render : () ->

            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                this.model.attributes.component.resource.VpcId = defaultVPCId

            @$el.html template @model.attributes

            @refreshIPList()

            $( "#keypair-select" ).on("click", ".icon-remove", _.bind(this.deleteKP, this) )

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

            target.parsley 'custom', ( val ) ->
                if isNaN( val ) or val > 99 or val < 1
                    return 'This value must be >= 1 and <= 99'

            if target.parsley 'validate'
                val = +target.val()
                @model.setCount val
                $(".property-instance-name-wrap").toggleClass("single", val == 1)
                $("#property-instance-name-count").text val
                @setEditableIP val == 1

        setEditableIP : ( enable ) ->
            $parent = $("#property-network-list")

            if enable
                $parent.find(".input-ip").removeAttr "disabled"
                $parent.find(".name").data "tooltip", "Specify an IP address or leave it as .x to automatically assign an IP."

            else
                $parent.find(".input-ip").attr "disabled", "disabled"
                $parent.find(".name").data "tooltip", "Automatically assigned IP."

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

            instanceUID = this.model.get 'uid'
            MC.aws.eni.reduceAllENIIPList(instanceUID)
            this.refreshIPList()

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


        addIPtoList: (event) ->

            subnetCIDR = ''
            instanceUID = this.model.get 'uid'

            # validate max ip num
            maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
            currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            if !currentENIComp then return false

            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                return false
            # validate max ip num

            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
                subnetCIDR = subnetObj.cidrBlock
            else
                subnetUID = MC.canvas_data.component[instanceUID].resource.SubnetId.split('.')[0][1...]
                subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

            ipPrefixSuffix = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)
            tmpl = $(MC.template.networkListItem({
                ipPrefix: ipPrefixSuffix[0],
                ipSuffix: ipPrefixSuffix[1]
            }))

            $('#property-network-list').append tmpl
            @model.addNewIP()
            @updateEIPList()
            false

        removeIPfromList: (event, id) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            @model.removeIP index
            @updateEIPList()

        openAmiPanel : ( event ) ->
            @trigger "OPEN_AMI", $("#property-ami").attr("data-uid")
            null

        addEIP : ( event ) ->

            # todo, need a index of eip
            index = $(event.currentTarget).closest("li").index()
            if event.target.className.indexOf('associated') >= 0 then attach = true else attach = false

            @model.attachEIP index, attach
            @updateEIPList()

        updateEIPList: (event) ->

            currentAvailableIPAry = []
            ipInuptListItem = $('#property-network-list li')

            _.each ipInuptListItem, (ipInputItem) ->
                inputValuePrefix = $(ipInputItem).find('.input-ip-prefix').text()
                inputValue = $(ipInputItem).find('.input-ip').val()
                inputHaveEIP = $(ipInputItem).find('.input-ip-eip-btn').hasClass('associated')
                currentAvailableIPAry.push({
                    ip: inputValuePrefix + inputValue,
                    eip: inputHaveEIP
                })
                null

            @model.setIPList currentAvailableIPAry

            this.changeIPAddBtnState()
            null

        changeIPAddBtnState : () ->

            disabledBtn = false
            instanceUID = this.model.get 'uid'

            maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
            currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            if !currentENIComp
                disabledBtn = true
                return

            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                disabledBtn = true

            instanceType = MC.canvas_data.component[instanceUID].resource.InstanceType
            if disabledBtn
                tooltipStr = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
                $('#instance-ip-add').addClass('disabled').attr('data-tooltip', tooltipStr).data('tooltip', tooltipStr)
            else
                $('#instance-ip-add').removeClass('disabled').attr('data-tooltip', 'Add IP Address').data('tooltip', 'Add IP Address')

            null

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

        refreshIPList : ( event ) ->
            @model.getEni()
            $( '#property-network-list' ).html( ip_list_template( @model.attributes ) )
            this.changeIPAddBtnState()
    }

    new InstanceView()
