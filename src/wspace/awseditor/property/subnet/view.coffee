#############################
#  View(UI logic) for design/property/subnet
#############################

define [ '../base/view',
         './template/stack',
         './template/acl',
         'event',
         "Design"
         'i18n!/nls/lang.js'
         "UI.modalplus"
], ( PropertyView, template, acl_template, ide_event, Design, lang, modalPlus ) ->

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
            @validateCidr true

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

        validateCidr: ( init ) ->
            # if blank
            cidrPrefix = $("#property-cidr-prefix").html()
            cidrSuffix = $("#property-cidr-block").val()
            subnetCIDR = cidrPrefix + cidrSuffix

            removeInfo = lang.PROP.REMOVE_SUBNET

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

            unless mainContent then return subnetCIDR

            if init
                @focusCidrFirsttime()
                return false

            if not @modal?.isOpen()

                that = this

                cidrModal = MC.template.setupCIDRConfirm({
                    main_content   : mainContent
                    desc_content   : descContent
                    remove_content : removeInfo
                })

                @modal = new modalPlus {
                    title: lang.IDE.SET_UP_CIDR_BLOCK
                    width: 420
                    template: cidrModal
                    confirm: text: "OK", color: "blue"
                    disableClose: true
                    cancel: hide: true
                }

                modal = @modal

                $("""<a id="cidr-removed" class="link-red left link-modal-danger">#{removeInfo}</a>""")
                .appendTo(modal.find(".modal-footer"))

                modal.on "close", () -> that.$( '#property-cidr-block' ).focus()
                modal.on "closed", () -> that.$( '#property-cidr-block' ).focus()

                modal.on "confirm", ()-> modal.close()
                modal.find("#cidr-removed").on "click", () ->
                    Design.instance().component( that.model.get("uid") ).remove()
                    that.disabledAllOperabilityArea(false)
                    modal.close()

            return false

        focusCidrFirsttime: ->
            _.defer ->
                $cidr = @$( '#property-cidr-block' )
                $cidr.focus()
                len = $cidr.val().length
                $cidr[ 0 ].setSelectionRange len, len

        onBlurCIDR : ( event ) ->
            subnetCidr = @validateCidr()
            unless subnetCidr then return

            @model.setCidr subnetCidr
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
                    main_content : sprintf(lang.PROP.STACK_DELETE_NETWORK_ACL_CONTENT, aclName)
                    desc_content : sprintf lang.PROP.STACK_DELETE_NETWORK_ACL_DESC, aclName
                }
                modal = new modalPlus {
                      title: lang.PROP.TITLE_DELETE_NETWORK_ACL
                      width: 420
                      template: dialog_template
                      confirm: {text: lang.PROP.LBL_DELETE, color: "red"}
                }
                modal.on "confirm", ()->
                    that.model.removeAcl( aclUID )
                    that.refreshACLList()
                    modal.close()
                modal.on "close", ()-> $('#property-cidr-block').focus()
                modal.on "closed", ()-> $('#property-cidr-block').focus()
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
