#############################
#  View(UI logic) for design/property/subnet
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/acl.html',
         'event'
], ( PropertyView, template, acl_template, ide_event ) ->

    template     = Handlebars.compile template
    acl_template = Handlebars.compile acl_template

    SubnetView = PropertyView.extend {

        events   :
            'click #networkacl-create': 'openCreateAclPanel'
            'click .networkacl-edit': 'openEditAclPanel'
            "change #property-subnet-name" : 'onChangeName'
            "focus #property-cidr-block"  : 'onFocusCIDR'
            "keypress #property-cidr-block"  : 'onPressCIDR'
            "blur #property-cidr-block"  : 'onBlurCIDR'
            "click .item-networkacl input" : 'onChangeACL'
            "click .item-networkacl" : 'onClickACL'
            "change #networkacl-create"    : 'onCreateACL'
            'click .stack-property-acl-list .sg-list-delete-btn' : 'deleteNetworkAcl'

        render     : () ->
            console.log 'property:subnet render'

            # Should not touch model's data
            data = $.extend true, {}, this.model.attributes

            subnetUID = this.model.get('uid')
            subnetName = this.model.get('name')

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

            @model.attributes.name


        openCreateAclPanel : ( event ) ->
            aclUID = MC.guid()
            aclObj = $.extend(true, {}, MC.canvas.ACL_JSON.data)
            aclObj.name = MC.aws.acl.getNewName()
            aclObj.uid = aclUID

            vpcUID = MC.aws.vpc.getVPCUID()
            aclObj.resource.VpcId = '@' + vpcUID + '.resource.VpcId'

            MC.canvas_data.component[aclUID] = aclObj

            @trigger 'SET_NEW_ACL', aclUID
            @trigger "OPEN_ACL", aclUID

        openEditAclPanel : ( event ) ->
            @trigger "OPEN_ACL", $(event.currentTarget).attr('acl-uid')

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()
            id = @model.get 'uid'

            MC.validate.preventDupname target, id, name, 'Subnet'

            # Notify changes

            if target.parsley 'validate'
                this.trigger "CHANGE_NAME", name
                @setTitle name

        onPressCIDR : ( event ) ->
            if (event.keyCode is 13)
                $('#property-cidr-block').blur()
            null

        onFocusCIDR : ( event ) ->

            MC.aws.aws.disabledAllOperabilityArea(true)

            null

        deleteNetworkAcl : (event) ->

            subnetUID = @model.get 'uid'

            that = this

            $target = $(event.currentTarget)
            aclUID = $target.attr('acl-uid')

            associationNum = Number($target.attr('acl-association'))
            aclName = $target.attr('acl-name')

            # show dialog to confirm that delete acl
            if associationNum
                mainContent = 'Are you sure you want to delete ' + aclName + '?'
                descContent = 'Subnets associated with ' + aclName + ' will use DefaultACL.'
                dialog_template = MC.template.modalDeleteSGOrACL {
                    title : 'Delete Network ACL',
                    main_content : mainContent,
                    desc_content : descContent
                }
                modal dialog_template, false, () ->
                    $('#modal-confirm-delete').click () ->
                        MC.aws.acl.addAssociationToDefaultACL(subnetUID)
                        delete MC.canvas_data.component[aclUID]
                        that.refreshACLList()
                        modal.close()

            else
                delete MC.canvas_data.component[aclUID]
                that.refreshACLList()

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
                    mainContent = 'The subnet is attached with a load balancer. The CIDR must be smaller than /27.'
                    descContent = ''
                    noRemove = true
                else
                    haveError = false
            else
                haveError = false

            if haveError
                dialog_template = MC.template.setupCIDRConfirm {
                    main_content : mainContent,
                    desc_content : descContent
                }
                if not noRemove
                    dialog_template.remove_content = 'Remove Subnet'

                modal dialog_template, false, () ->

                    $('.modal-close').click () ->
                        $('#property-cidr-block').focus()

                    $('#cidr-remove').click () ->
                        $('#svg_canvas').trigger('CANVAS_NODE_SELECTED', '')
                        ide_event.trigger ide_event.DELETE_COMPONENT, subnetUID, 'group'
                        MC.aws.aws.disabledAllOperabilityArea(false)
                        modal.close()
            else
                this.trigger "CHANGE_CIDR", subnetCIDR

                MC.aws.aws.disabledAllOperabilityArea(false)
                # $('#property-cidr-block').blur()

        onChangeACL : () ->

            this.trigger "CHANGE_ACL", $( "#networkacl-list :checked" ).attr "data-uid"

            this.refreshACLList()

        onClickACL : (event) ->

            inputElem = $(event.currentTarget).find('input')
            inputElem.select()

        refreshACLList : () ->
            this.model.init( this.model.get('uid') )
            $('#networkacl-list').html acl_template(this.model.attributes)

    }

    new SubnetView()
