#############################
#  View(UI logic) for design/property/vpc
#############################

define [ '../base/view',
         './template/stack'
         'i18n!/nls/lang.js'
         'dhcp'
         'UI.modalplus'
], ( PropertyView, template, lang, dhcp, modalPlus ) ->

    # Helpers
    mapFilterInput = ( selector ) ->
        $inputs = $( selector )
        result  = []

        for ipt in $inputs
            if ipt.value
                result.push ipt.value

        result


    VPCView = PropertyView.extend {

        events   :
            'change #property-vpc-name'       : 'onChangeName'
            'change #property-cidr-block'     : 'onChangeCidr'
            'change #property-dns-resolution' : 'onChangeDnsSupport'
            'change #property-dns-hostname'   : 'onChangeDnsHostname'
            'OPTION_CHANGE #property-tenancy' : 'onChangeTenancy'

            'change .property-control-group-sub .input' : 'onChangeDhcpOptions'
            'OPTION_CHANGE #property-netbios-type'      : 'onChangeDhcpOptions'
            'REMOVE_ROW #property-dhcp-options'         : 'onChangeDhcpOptions'
            'ADD_ROW .multi-input'                      : 'processParsley'

        render   : () ->

            data = @model.toJSON()

            @$el.html( template( data ) )
            multiinputbox.update( $("#property-domain-server") )
            @dhcp = new dhcp(resModel: @model)
            @dhcp.off 'change'
            @dhcp.on 'change', (e)=>
                @changeDhcp(e)
            @dhcp.on 'manage', =>
                console.log @dhcp.manager
            @$el.find('#dhcp-dropdown').html(@dhcp.dropdown.el)
            @initDhcpSelection()
            data.name
        initDhcpSelection: ->
            currentVal = @model.attributes.dhcp.appId
            if currentVal is ''
                selection = isAuto : true
            else if currentVal is "default"
                selection = isDefault : true
            else
                selection = id: currentVal
            @dhcp.setSelection selection
        changeDhcp: (e)->
            if e.id is 'default'
                @model.removeDhcp true
            else if e.id is ''
                @model.removeDhcp false
            else
                @model.setDhcp(e.id)

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "Route Table" )
                @model.setName name
                @setTitle name
            null

        onChangeCidr : ( event ) ->
            target = $ event.currentTarget
            cidr = target.val()

            if target.parsley 'validate'
                if not @model.setCidr cidr
                    target.val( @model.get("cidr") )
                    notification lang.ide.NOTIFY_MSG_WARN_CANNT_AUTO_ASSIGN_CIDR_FOR_SUBNET
            null

        onChangeTenancy : ( event, newValue ) ->
            @model.setTenancy newValue
            null

        onChangeDnsSupport : ( event ) ->
            @model.setDnsSupport event.target.checked
            null

        onChangeDnsHostname : ( event ) ->
            @model.setDnsHosts event.target.checked
            null

        onChangeAmazonDns : ( event ) ->
            useAmazonDns = $("#property-amazon-dns").is(":checked")
            allowRows    = if useAmazonDns then 3 else 4
            $inputbox    = $("#property-domain-server").attr( "data-max-row", allowRows )
            $rows        = $inputbox.children()
            $inputbox.toggleClass "max", $rows.length >= allowRows

            @model.setAmazonDns useAmazonDns
            null

        onUseDHCP : ( event ) ->
            $("#property-dhcp-desc").hide()
            $("#property-dhcp-options").show()

            @model.useDhcp()
            null

        onChangeDhcpOptions : ( event ) ->
            if event and not $( event.currentTarget ).closest( '[data-bind=true]' ).parsley( 'validate' )
                return

            # Gather all the infomation to submit
            data =
                domainName     : $("#property-dhcp-domain").val()
                domainServers  : mapFilterInput "#property-domain-server .input"
                ntpServers     : mapFilterInput "#property-ntp-server .input"
                netbiosServers : mapFilterInput "#property-netbios-server .input"
                netbiosType    : parseInt( $("#property-netbios-type .selection").html(), 10 ) || 0

            @model.setDHCPOptions data
            null
    }

    new VPCView()
