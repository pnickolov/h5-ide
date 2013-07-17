#############################
#  View(UI logic) for design/property/vpc
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars',
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

        render   : ( attributes ) ->
            $( '.property-details' ).html this.template attributes
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

        setName : ( name ) ->
            $("#property-vpc-name").val( name )

        setCIDR : ( cidr ) ->
            $("#property-cidr-block").val( cidr )
    }

    view = new VPCView()

    return view
