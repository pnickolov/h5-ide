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
            "focus #property-cidr-block"  : 'onFocusCIDR'
            "blur #property-cidr-block"  : 'onBlurCIDR'
            "click .item-networkacl input" : 'onChangeACL'
            "change #networkacl-create"    : 'onCreateACL'

        initialize : () ->
            that = this
            null

        render     : () ->
            console.log 'property:subnet render'

            # Should not touch model's data
            data = $.extend true, {}, this.model.attributes

            vpcComp = MC.aws.subnet.getVPC(this.model.get('uid'))
            vpcCIDR = vpcComp.resource.CidrBlock

            # Split CIDR into two parts
            cidrDivAry = MC.aws.subnet.genCIDRDivAry(vpcCIDR, data.CIDR)
            data.CIDRPrefix = cidrDivAry[0]
            data.CIDR = cidrDivAry[1]

            $( '.property-details' ).html this.template data

            this.refreshACLList()

            $('#property-cidr-block').focus()

        openCreateAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            aclUID = MC.guid()
            aclObj = $.extend(true, {}, MC.canvas.ACL_JSON.data)
            aclObj.name = MC.aws.acl.getNewName()
            aclObj.uid = aclUID

            MC.canvas_data.component[aclUID] = aclObj

            this.trigger 'SET_NEW_ACL', aclUID

            ide_event.trigger ide_event.OPEN_ACL, aclUID

        openEditAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            ide_event.trigger ide_event.OPEN_ACL, source.attr('acl-uid')

        onChangeName : ( event ) ->
            # TODO : Validate newName

            # Notify changes
            change.value   = event.target.value
            change.event   = "CHANGE_NAME"

            this.trigger "CHANGE_NAME", change


        onChangeCIDR : ( event ) ->

            change.handled = false
            change.value   = $("#property-cidr-prefix").html() + $("#property-cidr-block").val()
            change.event   = "CHANGE_CIDR"

            this.trigger "CHANGE_CIDR", change

        onFocusCIDR : ( event ) ->

            MC.aws.aws.disabledAllOperabilityArea(true)

            null

        onBlurCIDR : ( event ) ->

            that = this

            template = MC.template.setupCIDRConfirm {
                content   : "Message"
            }
            modal template, false, () ->

                $('.modal-close, #cidr-return').click () ->
                    $('#property-cidr-block').focus()

                $('#cidr-remove').click () ->
                    subnetUID = that.model.get('uid')
                    $('#svg_canvas').trigger('CANVAS_NODE_SELECTED', '')
                    MC.canvas.remove($("#" + subnetUID)[0])
                    MC.aws.aws.disabledAllOperabilityArea(false)

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
