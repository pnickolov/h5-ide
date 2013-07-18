#############################
#  View(UI logic) for design/property/vpc
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'underscore'
        'UI.fixedaccordion' ], ( ide_event ) ->

    VPCView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vpc-tmpl' ).html()

        events   :
            'change #property-vpc-name'       : 'onChangeName'
            'change #property-cidr-block'     : 'onChangeCidr'
            'change #property-dns-resolution' : 'onChangeDnsSupport'
            'change #property-dns-hostname'   : 'onChangeDnsHostname'
            'OPTION_CHANGE #property-tenancy' : 'onChangeTenancy'

            'click .property-dhcp input'      : 'onChangeDhcp'
            'click #property-amazon-dns'      : 'onChangeAmazonDns'

            'change .property-control-group-sub .input' : 'onChangeDhcpOptions'
            'OPTION_CHANGE #property-netbios-type'      : 'onChangeDhcpOptions'

        render   : ( attributes ) ->

            updateAmazonCB = ( evt ) ->
                rowLength = $( evt.target ).children().length
                if rowLength > 3
                    $( '#property-amazon-dns' ).attr( "disabled", true )
                else
                    $( '#property-amazon-dns' ).removeAttr( "disabled" )

            $( '.property-details' ).html this.template attributes
            $( '#property-domain-server' ).on( 'ADD_ROW REMOVE_ROW', updateAmazonCB )

            fixedaccordion.resize()

        onChangeName : ( event ) ->
            console.log "Name Cahanged"
            this.trigger "CHANGE_NAME", event.target.value
            null

        onChangeCidr : ( event ) ->
            this.trigger "CHANGE_CIDR", event.target.value
            null

        onChangeTenancy : ( event, newValue ) ->
            $("#desc-dedicated").toggle( newValue == "dedicated" )

            uid = $("#vpc-property-detail").attr("component")
            this.model.setTenancy uid, newValue
            null

        onChangeDnsSupport : ( event ) ->
            uid = $("#vpc-property-detail").attr("component")
            this.model.setDnsSupport uid, event.target.checked
            null

        onChangeDnsHostname : ( event ) ->
            uid = $("#vpc-property-detail").attr("component")
            this.model.setDnsHosts uid, event.target.checked
            null

        onChangeDhcp : ( event ) ->

            uid = $("#vpc-property-detail").attr("component")
            $selectOption = $(".property-dhcp input:checked")

            noDhcp = $selectOption.attr("id") == "property-dhcp-none"

            $("#property-dhcp-desc").toggle    noDhcp
            $("#property-dhcp-options").toggle !noDhcp

            this.model.setDhcp uid, !noDhcp
            null

        onChangeAmazonDns : ( event ) ->
            useAmazonDns = $("#property-amazon-dns").is(":checked")
            allowRows    = if useAmazonDns then 3 else 4
            $inputbox    = $("#property-domain-server").attr( "data-max-row", allowRows )
            $rows        = $inputbox.children()
            $inputbox.toggleClass "max", $rows.length >= allowRows
            null

        onChangeDhcpOptions : ( event ) ->

            # Gather all the infomation to submit
            uid  = $("#vpc-property-detail").attr("component")
            data =
                domainName     : $("#property-dhcp-domain").val()
                useAmazonDns   : $("#property-amazon-dns").is(":checked")
                domainServers  : _.map( $("#property-domain-server .input"),  (ipt)->ipt.value )
                ntpServers     : _.map( $("#property-ntp-server .input"),     (ipt)->ipt.value )
                netbiosServers : _.map( $("#property-netbios-server .input"), (ipt)->ipt.value )
                netbiosType    : parseInt( $("#property-netbios-type .cur-value"), 10 ) || 0

            console.log "DHCP Options Changed", data

            this.model.setDHCPOptions uid, data
            null


        setName : ( name ) ->
            $("#property-vpc-name").val( name )

        setCIDR : ( cidr ) ->
            $("#property-cidr-block").val( cidr )
    }

    view = new VPCView()

    return view
