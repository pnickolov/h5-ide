#############################
#  View(UI logic) for design/property/subnet
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/acl.html',
         'event',
         "Design"
], ( PropertyView, template, acl_template, ide_event, Design ) ->

    template     = Handlebars.compile template
    acl_template = Handlebars.compile acl_template

    SubnetView = PropertyView.extend {

        events   :
            "change #property-subnet-name"  : 'onChangeName'

            "focus #property-cidr-block"    : 'onFocusCIDR'
            "keypress #property-cidr-block" : 'onPressCIDR'
            "blur #property-cidr-block"     : 'onBlurCIDR'

            'click #networkacl-create'  : 'createAcl'
            'click .icon-btn-details'   : 'openAcl'
            "click .ppty-acl-cb"        : 'changeAcl'
            'click .sg-list-delete-btn' : 'deleteAcl'

        render : () ->
            # Should not touch model's data
            data = $.extend true, {}, this.model.attributes

            subnetUID  = data.uid
            subnetName = data.name

            if subnetUID

                vpcComp = MC.aws.subnet.getVPC(subnetUID)
                vpcCIDR = vpcComp.resource.CidrBlock

                focusCIDR = false
                isInVPCCIDR = MC.aws.subnet.isInVPCCIDR(vpcCIDR, data.CIDR)
                if MC.aws.subnet.isSubnetConflictInVPC(subnetUID) or !isInVPCCIDR
                    focusCIDR = true
                    if !isInVPCCIDR
                        data.CIDR = vpcCIDR

                # Split CIDR into two parts
                cidrDivAry = MC.aws.subnet.genCIDRDivAry(vpcCIDR, data.CIDR)
                data.CIDRPrefix = cidrDivAry[0]
                data.CIDR = cidrDivAry[1]

                @$el.html template data
                this.refreshACLList()

                if focusCIDR
                    MC.canvas.update subnetUID, 'text', 'label', subnetName + ' ()'
                    @forceShow()
                    $('#property-cidr-block').val('').focus()
            else
                @$el.html template data

            data.name

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkDupName( target, "Subnet" )
                @model.setName name
                @setTitle name

        onPressCIDR : ( event ) ->
            if (event.keyCode is 13)
                $('#property-cidr-block').blur()
            null

        onFocusCIDR : ( event ) ->

            MC.aws.aws.disabledAllOperabilityArea(true)

            null


        onBlurCIDR : ( event ) ->

            that = this

            mainContent = ''
            descContent = ''

            subnetUID = that.model.get('uid')
            vpcComp = MC.aws.subnet.getVPC(subnetUID)
            vpcCIDR = vpcComp.resource.CidrBlock

            # if blank
            cidrPrefix = $("#property-cidr-prefix").html()
            cidrSuffix = $("#property-cidr-block").val()
            subnetCIDR = cidrPrefix + cidrSuffix

            removeInfo = 'Remove Subnet'
            haveError = true
            if !cidrSuffix
                mainContent = 'CIDR block is required.'
                descContent = 'Please provide a subset of IP ranges of this VPC.'
            else if !MC.validate 'cidr', subnetCIDR
                mainContent = subnetCIDR + ' is not a valid form of CIDR block.'
                descContent = 'Please provide a valid IP range. For example, 10.0.0.1/24.'
            else if !MC.aws.subnet.isInVPCCIDR(vpcCIDR, subnetCIDR)
                mainContent = subnetCIDR + ' conflicts with VPC CIDR.'
                descContent = 'Subnet CIDR block should be a subset of VPC\'s.'
            else if MC.aws.subnet.isSubnetConflictInVPC(subnetUID, subnetCIDR)
                mainContent = subnetCIDR + ' conflicts with other subnet.'
                descContent = 'Please choose a CIDR block not conflicting with existing subnet.'
            else if MC.aws.subnet.isConnectToELB subnetUID
                cidrNum = Number(cidrSuffix.split('/')[1])
                if cidrNum > 27
                    mainContent = 'The subnet is attached with a load balancer. The CIDR mask must be smaller than /27.'
                    descContent = ''
                    removeInfo = ''
                else
                    haveError = false
            else
                haveError = false

            if haveError
                dialog_template = MC.template.setupCIDRConfirm {
                    main_content : mainContent,
                    desc_content : descContent
                    remove_content : removeInfo
                }

                modal dialog_template, false, () ->

                    $('.modal-close').click () ->
                        $('#property-cidr-block').focus()

                    $('#cidr-remove').click () ->
                        $canvas.clearSelected()
                        Design.instance().component( subnetUID ).remove()

                        MC.aws.aws.disabledAllOperabilityArea(false)
                        modal.close()
            else
                @model.setCIDR subnetCIDR

                MC.aws.aws.disabledAllOperabilityArea(false)

        createAcl : ()->
            @trigger "OPEN_ACL", @model.createAcl()

        openAcl : ( event ) ->
            id = $(event.currentTarget).closest("li").attr("data-uid")
            @trigger "OPEN_ACL", id
            null

        deleteAcl : (event) ->

            $target  = $( event.currentTarget )
            assoCont = parseInt $target.attr('data-count'), 10
            aclUID   = $target.closest("li").attr('data-uid')

            # show dialog to confirm that delete acl
            if assoCont
                that    = this
                aclName = $target.attr('data-name')

                dialog_template = MC.template.modalDeleteSGOrACL {
                    title : 'Delete Network ACL'
                    main_content : "Are you sure you want to delete #{aclName}?"
                    desc_content : "Subnets associated with #{aclName} will use DefaultACL."
                }
                modal dialog_template, false, () ->
                    $('#modal-confirm-delete').click () ->
                        that.model.removeAcl( aclUID )
                        that.refreshACLList()
                        modal.close()
            else
                @model.removeAcl( aclUID )
                @refreshACLList()

        changeAcl : ( event ) ->
            @model.setACL $( event.currentTarget ).closest("li").attr "data-uid"
            @refreshACLList()

        refreshACLList : () ->
            @model.init( @model.get('uid') )
            $('#networkacl-list').html acl_template(@model.attributes)

    }

    new SubnetView()
