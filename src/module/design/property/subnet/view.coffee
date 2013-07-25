#############################
#  View(UI logic) for design/property/subnet
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SubnetView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-subnet-tmpl' ).html()

        acl_template: Handlebars.compile $( '#property-subnet-acl-tmpl' ).html()

        events   :
            'click #networkacl-create': 'openCreateAclPanel'
            'click .networkacl-edit': 'openEditAclPanel'
            "change #property-subnet-name" : 'onChangeName'
            "change #property-cidr-block"  : 'onChangeCIDR'
            "click .item-networkacl input" : 'onChangeACL'
            "change #networkacl-create"    : 'onCreateACL'

        initialize : () ->
            that = this
            ide_event.onLongListen ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL, () ->
                that.refreshACLList()

        render     : () ->
            console.log 'property:subnet render'

            # Should not touch model's data
            data = $.extend true, {}, this.model.attributes

            # Split CIDR into two parts
            CIDR = data.CIDR.split "."
            data.CIDRPrefix = CIDR[0] + "." + CIDR[1] + "."
            data.CIDR = CIDR[2] + "." + CIDR[3]

            $( '.property-details' ).html this.template data

            this.refreshACLList()

        openCreateAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            accordion = $( '#instance-accordion' )
            cur_expanded_id = accordion.find('.accordion-group').index accordion.find('.expanded')

            aclUID = MC.guid()
            aclObj = $.extend(true, {}, MC.canvas.ACL_JSON.data)
            aclObj.name = this.model.getNewACLName()
            aclObj.uid = aclUID

            MC.canvas_data.component[aclUID] = aclObj

            this.trigger 'SET_NEW_ACL', aclUID

            ide_event.trigger(ide_event.OPEN_ACL, target.data('secondarypanel-data'), cur_expanded_id, aclUID)

        openEditAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            accordion = $( '#instance-accordion' )
            cur_expanded_id = accordion.find('.accordion-group').index accordion.find('.expanded')

            aclUID = source.attr('acl-uid')

            ide_event.trigger(ide_event.OPEN_ACL, target.data('secondarypanel-data'), cur_expanded_id, aclUID)

        onChangeName : ( event ) ->
            # TODO : Validate newName

            # Update title
            $( '#property-title' ).html event.target.value

            # Notify changes
            change.value   = event.target.value
            change.event   = "CHANGE_NAME"

            this.trigger "CHANGE_NAME", change


        onChangeCIDR : ( event ) ->

            change.handled = false
            change.value   = $("#property-cidr-prefix").html() + $("#property-cidr-block").val()
            change.event   = "CHANGE_CIDR"

            this.trigger "CHANGE_CIDR", change

        onChangeACL : () ->

            change.value = $( "#networkacl-list :checked" ).attr "data-uid"
            change.event = "CHANGE_ACL"

            this.trigger "CHANGE_ACL", change

            this.refreshACLList()

        onViewACL : () ->
            null

        onCreateACL : () ->
            null

        refreshACLList : () ->
            this.model.setId(this.model.get('uid'))
            $('#networkacl-list').html this.acl_template(this.model.attributes)

    }

    view = new SubnetView()

    eventTgtMap =
        "CHANGE_NAME" : "#property-subnet-name"
        "CHANGE_CIDR" : "#property-cidr-block"

    # When user enters new value, a `change` will trigger
    # When the validation is handle in model, the change can be done with or without error.
    change =
        value   : ""
        event   : ""
        handled : true
        done    : ( error ) ->
            if this.handled
                return

            if error
                # TODO : show error on the input

                # Restore last value
                $ipt = $( eventTgtMap[ this.event ] )
                $ipt.val( $ipt.attr "lastValue" )
            else
                $( eventTgtMap[ this.event ] ).attr "lastValue", this.value

            this.handled = true
            null

    return view
