#############################
#  View(UI logic) for design/property/subnet
#############################

define [ '../base/view',
         './template/stack',
         './template/acl',
         'event',
         "Design"
         'i18n!/nls/lang.js'
], ( PropertyView, template, acl_template, ide_event, Design, lang ) ->

    SubnetView = PropertyView.extend {

        events   :
            "change #property-subnet-name"  : 'onChangeName'
            "change #property-res-desc"     : 'onChangeDesc'
            "focus #property-cidr-block"    : 'onFocusCIDR'
            "keypress #property-cidr-block" : 'onPressCIDR'
            "blur #property-cidr-block"     : 'onBlurCIDR'

            'click #networkacl-create'  : 'createAcl'
            'click .icon-btn-details'   : 'openAcl'
            "click .ppty-acl-cb"        : 'changeAcl'
            'click .sg-list-delete-btn' : 'deleteAcl'

        render : () ->
            @$el.html template @model.attributes
            @refreshACLList()

            @model.attributes.name

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "Subnet" )
                @model.setName name
                @setTitle name

        onChangeDesc : (event) ->

            @model.setDesc $(event.currentTarget).val()

        onPressCIDR : ( event ) ->
            if (event.keyCode is 13)
                $('#property-cidr-block').blur()
            null

        onFocusCIDR : ( event ) ->
            @disabledAllOperabilityArea( true )
            null

        onBlurCIDR : ( event ) ->
            # if blank
            cidrPrefix = $("#property-cidr-prefix").html()
            cidrSuffix = $("#property-cidr-block").val()
            subnetCIDR = cidrPrefix + cidrSuffix

            removeInfo = 'Remove Subnet'

            if !cidrSuffix
                mainContent = lang.PROP.SUBNET_CIDR_VALIDATION_REQUIRED
                descContent = lang.PROP.SUBNET_CIDR_VALIDATION_REQUIRED_DESC
            else if !MC.validate 'cidr', subnetCIDR
                mainContent = sprintf lang.PROP.SUBNET_CIDR_VALIDATION_INVALID, subnetCIDR
                descContent = sprintf lang.PROP.SUBNET_CIDR_VALIDATION_INVALID_DESC
            else
                error = @model.isValidCidr( subnetCIDR )
                if error isnt true
                    mainContent = error.error
                    descContent = error.detail
                    if error.shouldRemove is false
                        removeInfo = ""

            if mainContent
                that = this

                modal MC.template.setupCIDRConfirm({
                    main_content   : mainContent
                    desc_content   : descContent
                    remove_content : removeInfo
                }), false, null, {
                    $source: $(event.target)
                }

                $('.modal-close').click () -> $('#property-cidr-block').focus()
                $('#cidr-remove').click () ->
                    Design.instance().component( that.model.get("uid") ).remove()
                    that.disabledAllOperabilityArea(false)
                    modal.close()
            else
                @model.setCidr subnetCIDR
                @disabledAllOperabilityArea(false)


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
                    title : lang.IDE.TITLE_DELETE_NETWORK_ACL
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