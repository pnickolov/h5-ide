#############################
#  View(UI logic) for design/property/vpc
#############################

define [ '../base/view',
         './template/stack'
         'i18n!nls/lang.js'
], ( PropertyView, template, lang ) ->

    # Helpers
    mapFilterInput = ( selector ) ->
        $inputs = $( selector )
        result  = []

        for ipt in $inputs
            if ipt.value
                result.push ipt.value

        result

    updateAmazonCB = () ->
        rowLength = $( "#property-domain-server" ).children().length
        if rowLength > 3
            $( '#property-amazon-dns' ).attr( "disabled", true )
        else
            $( '#property-amazon-dns' ).removeAttr( "disabled" )


    VPCView = PropertyView.extend {

        events   :
            'change #property-vpc-name'       : 'onChangeName'
            'change #property-cidr-block'     : 'onChangeCidr'
            'change #property-dns-resolution' : 'onChangeDnsSupport'
            'change #property-dns-hostname'   : 'onChangeDnsHostname'
            'OPTION_CHANGE #property-tenancy' : 'onChangeTenancy'

            'click #property-dhcp-none'    : 'onRemoveDhcp'
            'click #property-dhcp-default' : 'onRemoveDhcp'
            'click #property-dhcp-spec'    : 'onUseDHCP'
            'click #property-amazon-dns'   : 'onChangeAmazonDns'

            'change .property-control-group-sub .input' : 'onChangeDhcpOptions'
            'OPTION_CHANGE #property-netbios-type'      : 'onChangeDhcpOptions'
            'REMOVE_ROW #property-dhcp-options'         : 'onChangeDhcpOptions'
            'ADD_ROW .multi-input'                      : 'processParsley'

        render   : () ->

            data = @model.attributes

            selectedType = data.dhcp.netbiosType || 0
            data.dhcp.netbiosTypes = [
                  { id : "default" , value : lang.ide.PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED, selected : selectedType == 0 }
                , { id : 1 , value : 1, selected : selectedType == 1 }
                , { id : 2 , value : 2, selected : selectedType == 2 }
                , { id : 4 , value : 4, selected : selectedType == 4 }
                , { id : 8 , value : 8, selected : selectedType == 8 }
            ]

            @$el.html( template( data ) )
            $( '#property-domain-server' ).on( 'ADD_ROW REMOVE_ROW', updateAmazonCB )
            updateAmazonCB()
            multiinputbox.update( $("#property-domain-server") )

            data.name

        processParsley: ( event ) ->
            $( event.currentTarget )
                .find( 'input' )
                .last()
                .removeClass( 'parsley-validated' )
                .removeClass( 'parsley-error' )
                .next( '.parsley-error-list' )
                .remove()

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkResName( target, "Route Table" )
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

        onRemoveDhcp : ( event ) ->

            isDefault = $( event.currentTarget ).closest("section").find("input").attr("id") is "property-dhcp-default"

            $("#property-dhcp-desc").show()
            $("#property-dhcp-options").hide()

            @model.removeDhcp isDefault
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

            if event and not $( event.currentTarget )
                            .closest( '[data-bind=true]' )
                            .parsley( 'validate' )
                return

            # Gather all the infomation to submit
            data =
                domainName     : $("#property-dhcp-domain").val()
                domainServers  : mapFilterInput "#property-domain-server .input"
                ntpServers     : mapFilterInput "#property-ntp-server .input"
                netbiosServers : mapFilterInput "#property-netbios-server .input"
                netbiosType    : parseInt( $("#property-netbios-type .selection").html(), 10 ) || 0

            console.log "DHCP Options Changed", data

            @model.setDHCPOptions data
            null
    }

    new VPCView()
