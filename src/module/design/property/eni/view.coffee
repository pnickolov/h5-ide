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
            ipItems = $('#property-eni-list .input-ip-item')

            if not @validateIPList( event, ipItems )
                return

            currentAvailableIPAry = _.map ipItems, (ipInputItem) ->
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

        validateIPList : ( event, ipInuptListItem ) ->

            eniUID      = @model.get 'uid'
            instanceUID = MC.extractID MC.canvas_data.component[eniUID].resource.Attachment.InstanceId

            ################################### validation
            validDOM         = $(event.currentTarget)
            inputValue       = validDOM.val()
            inputValuePrefix = validDOM.closest(".input-ip-item").find(".input-ip-prefix").text()
            currentInputIP   = inputValuePrefix + inputValue
            prefixAry        = inputValuePrefix.split('.')


            validDOM.parsley 'custom', ( val ) ->

                ###### validation format
                ipIPFormatCorrect = false
                # for 10.0.0.
                if prefixAry.length is 4
                    if inputValue is 'x'
                        ipIPFormatCorrect = true
                    if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                        ipIPFormatCorrect = true
                # for 10.0.
                else
                    if inputValue is 'x.x'
                        ipIPFormatCorrect = true
                    if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                        ipIPFormatCorrect = true
                if !ipIPFormatCorrect
                    return 'Invalid IP address'

                ###### validation if in subnet
                if inputValue.indexOf('x') is -1
                    ipInSubnet = false
                    if MC.aws.aws.checkDefaultVPC()
                        subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(eniUID)
                        subnetCIDR = subnetObj.cidrBlock
                    else
                        subnetUID = MC.extractID MC.canvas_data.component[eniUID].resource.SubnetId
                        subnetObj = MC.canvas_data.component[subnetUID]
                        subnetCIDR = subnetObj.resource.CidrBlock

                    ipInSubnet = MC.aws.subnet.isIPInSubnet(currentInputIP, subnetCIDR)

                    if !ipInSubnet
                        return 'This IP address conflicts with subnet’s IP range'

                ###### validation if conflict with other eni
                if inputValue.indexOf('x') is -1
                    innerRepeat = 0
                    _.each ipInuptListItem, (ipInputItem) ->
                        if $(ipInputItem).find('.input-ip').val() is inputValue
                            ++innerRepeat
                        null
                    if innerRepeat > 1
                        return 'This IP address conflicts with other IP'
                    if MC.aws.eni.haveIPConflictWithOtherENI(currentInputIP, eniUID)
                        return 'This IP address conflicts with other network interface’s IP'

                null

            validDOM.parsley 'validate'


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
