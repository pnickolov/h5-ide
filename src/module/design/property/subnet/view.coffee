#############################
#  View(UI logic) for design/property/subnet
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SubnetView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-subnet-tmpl' ).html()

        events   :
            "change #property-subnet-name" : 'onChangeName'
            "change #property-cidr-block"  : 'onChangeCIDR'
            "click .item-networkacl input" : 'onChangeACL'
            "change #networkacl-create"    : 'onCreateACL'

        render     : ( data ) ->
            console.log 'property:subnet render', data

            this.uid = data.uid

            CIDR = data.CIDR.split "."
            data.CIDRPrefix = CIDR[0] + "." + CIDR[1] + "."
            data.CIDR = CIDR[2] + "." + CIDR[3]

            $( '.property-details' ).html this.template data


        onChangeCIDR : ( event ) ->
            change.value = $("#property-cidr-prefix").html() + $("#property-cidr-block").val()
            change.event = "CHANGE_CIDR"
            this.trigger "CHANGE_CIDR", this.uid, change

        onChangeName : ( event ) ->
            change.value = event.target.value
            change.event = "CHANGE_NAME"
            this.trigger "CHANGE_NAME", this.uid, change

        onChangeACL : () ->
            change.value = $( "#networkacl-list :checked" ).attr "data-uid"
            change.event = "CHANGE_ACL"
            this.trigger "CHANGE_ACL", this.uid, change

        onViewACL : () ->
            null

        onCreateACL : () ->
            null

    }

    view = new SubnetView()

    eventTgtMap =
        "CHANGE_NAME" : "#property-subnet-name"
        "CHANGE_CIDR" : "#property-cidr-block"

    change =
        value   : ""
        event   : ""
        context : view
        accept  : () ->
            $( eventTgtMap[ this.event ] ).attr "lastValue", this.value

            if this.event == "CHANGE_NAME"
                $( '#property-title' ).html this.value

        reject  : ( reason ) ->
            # TODO : show error on the input

            # Restore last value
            $ipt = $( eventTgtMap[ this.event ] )
            $ipt.val( $ipt.attr "lastValue" )

    return view
