#############################
#  View(UI logic) for design/property/stack
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/acl.html',
         'text!./template/sub.html',
         'event',
         'i18n!nls/lang.js'
], ( PropertyView, template, acl_template, sub_template, ide_event, lang ) ->

    template     = Handlebars.compile template
    acl_template = Handlebars.compile acl_template
    sub_template = Handlebars.compile sub_template

    StackView = PropertyView.extend {
        events   :
            'change #property-stack-name'          : 'stackNameChanged'

            'click #stack-property-new-acl'        : 'createAcl'
            'click #stack-property-acl-list .edit' : 'openAcl'
            'click .sg-list-delete-btn'            : 'deleteAcl'

            'click #property-sub-list .icon-edit' : 'editSNS'
            'click #property-sub-list .icon-del'  : 'delSNS'
            'click #property-create-asg'          : 'openSNSModal'

        render     : () ->

            t = template
            if @model.isApp or @model.isAppEdit
                if @model.attributes.isImport
                    str = '<header class="property-sidebar-title sidebar-title truncate" id="property-title">Visualization - '+@model.attributes.vpcid+'<i class="icon-info tooltip property-header-info" data-tooltip="Currently you can rearrange the layout of visualisation and export it as PNG image file. Future version will include the feature to import VPC resource as an app. "></i></header>'
                    $('#property-title').html(str)
                else
                    title = "App - #{@model.get('name')}"
            else
                title = "Stack - #{@model.get('name')}"

            @$el.html( template( @model.attributes ) )

            if title
                @setTitle( title )

            @refreshACLList()

            if not @model.isApp
                @updateSNSList @model.get("subscription"), true

            null

        stackNameChanged : () ->
            stackNameInput = $ '#property-stack-name'
            stackId = @model.get( 'id' )
            name = stackNameInput.val()

            stackNameInput.parsley 'custom', ( val ) ->
                if not MC.validate 'awsName',  val
                    return lang.ide.PARSLEY_SHOULD_BE_A_VALID_STACK_NAME

                if not MC.aws.aws.checkStackName stackId, val
                    return sprintf lang.ide.PARSLEY_TYPE_NAME_CONFLICT, 'Stack', name

            if stackNameInput.parsley 'validate'
                @trigger 'STACK_NAME_CHANGED', name
                @setTitle "Stack - " + name
            null

        refreshACLList : () ->
            $('#stack-property-acl-list').html acl_template @model.attributes

        createAcl : ()->
            @trigger "OPEN_ACL", @model.createAcl()

        openAcl : ( event ) ->
            @trigger "OPEN_ACL", $(event.currentTarget).closest("li").attr("data-uid")
            null

        updateSNSList : ( snslist_data, textOnly ) ->

            hasASG = @model.get("has_asg")

            # Hide all message
            $(".property-sns-info").children().hide()

            if not snslist_data or not snslist_data.length
                if hasASG
                    $("#property-sns-no-sub").show()
                else
                    $("#property-sns-no-sub-no-asg").show()
            else if not hasASG
                $("#property-sns-no-asg").show()

            if textOnly
                return

            # Remove Old Stuff
            $list = $("#property-sub-list")
            $list.find("li:not(.hide)").remove()

            # Insert New List
            $template = $list.find(".hide")
            for sub in snslist_data
                $clone = $template.clone().removeClass("hide").appendTo $list

                $clone.attr "data-uid", sub.id
                $clone.find(".protocol").html sub.protocol
                $clone.find(".endpoint").html sub.endpoint
                if sub.confirmed isnt null and sub.confirmed is false
                #not confirmed subscription
                    $clone.find(".sns-action").html( '<i class="icon-pending tooltip" data-tooltip="pendingConfirm" ></i>' )
                else
                #new or confirmed subscription
                    $clone.find(".sns-action").html( '<i class="icon-del icon-remove"></i>' )

            $("#property-stack-sns-num").html( snslist_data.length )

            null

        delSNS : ( event ) ->

            $li = $(event.currentTarget).closest("li")
            uid = $li.attr("data-uid")
            $li.remove()

            @updateSNSList $("#property-sub-list").children(":not(.hide)"), true

            @model.deleteSNS uid

        editSNS : ( event ) ->
            $sub_li = $( event.currentTarget ).closest("li")
            data =
                title    : "Edit"
                uid      : $sub_li.attr("data-uid")
                protocol : $sub_li.find(".protocol").text()
                endpoint : $sub_li.find(".endpoint").text()

            @openSNSModal event, data
            null

        saveSNS : ( data ) ->

            if data.uid
                # We are editing existing Subscription
                # Update the related subscription's dom
                $dom = $("#property-sub-list").children("li[data-uid='#{data.uid}']")
                $dom.find(".protocol").html( data.protocol )
                $dom.find(".endpoint").html( data.endpoint )
                if data.confirmed isnt null and data.confirmed is false
                #not confirmed subscription
                    $dom.find(".sns-action").html( '<i class="icon-pending tooltip" data-tooltip="pendingConfirm" ></i>' )
                else
                #new or confirmed subscription
                    $dom.find(".sns-action").html( '<i class="icon-del icon-remove"></i>' )

            @model.addSubscription data

            if !data.uid
                # Update the list
                @updateSNSList @model.get("subscription")

        openSNSModal : ( event, data ) ->
            # data =
            #       uid : "123123-123123-123123"
            #       protocol : "Email"
            #       endpoint : "123@abc.com"
            if !data
                data =
                    protocol : "email"
                    title    : "Add"

            modal sub_template data

            $modal = $("#property-asg-sns-modal")

            # Setup the protocol
            $modal.find(".dropdown").find(".item").each ()->
                if $(this).data("id") is data.protocol
                    $(this).addClass("selected").parent().siblings().text( $(this).text() )

            # Setup the endpoint
            updateEndpoint = ( protocol ) ->
                $input  = $(".property-asg-ep")#.removeClass("https http")
                switch $modal.find(".selected").data("id")

                    when "sqs"
                        placeholder = lang.ide.PROP_STACK_AMAZON_ARN
                        type        = lang.ide.PROP_STACK_SQS
                        errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_AMAZON_SQS_ARN

                    when "arn"
                        placeholder = lang.ide.PROP_STACK_AMAZON_ARN
                        type        = lang.ide.PROP_STACK_ARN
                        errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_APPLICATION_ARN

                    when "email"
                        placeholder = lang.ide.PROP_STACK_EXAMPLE_EMAIL
                        type        = lang.ide.PROP_STACK_EMAIL
                        errorMsg    = lang.ide.HEAD_MSG_ERR_UPDATE_EMAIL3

                    when "email-json"
                        placeholder = lang.ide.PROP_STACK_EXAMPLE_EMAIL
                        type        = lang.ide.PROP_STACK_EMAIL
                        errorMsg    = lang.ide.HEAD_MSG_ERR_UPDATE_EMAIL3

                    when "sms"
                        placeholder = lang.ide.PROP_STACK_E_G_1_206_555_6423
                        type        = lang.ide.PROP_STACK_USPHONE
                        errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_PHONE_NUMBER

                    when "http"
                        #$input.addClass "http"
                        placeholder = lang.ide.PROP_STACK_HTTP_WWW_EXAMPLE_COM
                        type        = lang.ide.PROP_STACK_HTTP
                        errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_URL

                    when "https"
                        #$input.addClass "https"
                        placeholder = lang.ide.PROP_STACK_HTTPS_WWW_EXAMPLE_COM
                        type        = lang.ide.PROP_STACK_HTTPS
                        errorMsg    = lang.ide.PARSLEY_PLEASE_PROVIDE_A_VALID_URL

                endPoint = $ '#property-asg-endpoint'
                endPoint.attr "placeholder", placeholder

                endPoint.parsley 'custom', ( value ) ->
                    if type and value and ( not MC.validate type, value )
                        return errorMsg

                if endPoint.val().length
                    endPoint.parsley 'validate'
                null

            updateEndpoint()

            $modal.on "OPTION_CHANGE", updateEndpoint


            # Bind Events
            self = this
            $("#property-asg-sns-done").on "click", ()->
                endPoint = $("#property-asg-endpoint")

                if endPoint.parsley 'validate'
                    data =
                        uid      : $modal.attr("data-uid")
                        protocol : $modal.find(".selected").data("id")
                        endpoint : endPoint.val()

                    modal.close()

                    self.saveSNS data

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
    }

    new StackView()
