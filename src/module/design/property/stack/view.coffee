#############################
#  View(UI logic) for design/property/stack
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/acl.html',
         'text!./template/sub.html',
         'event'
], ( PropertyView, template, acl_template, sub_template, ide_event ) ->

    template     = Handlebars.compile template
    acl_template = Handlebars.compile acl_template
    sub_template = Handlebars.compile sub_template

    StackView = PropertyView.extend {
        events   :
            'change #property-stack-name'          : 'stackNameChanged'

            'click #stack-property-new-acl'        : 'createAcl'
            'click #stack-property-acl-list .edit' : 'openAcl'

            'click #property-sub-list .icon-edit' : 'editSNS'
            'click #property-sub-list .icon-del'  : 'delSNS'
            'click #property-create-asg'          : 'openSNSModal'

        render     : () ->

            @$el.html( template( @model.attributes ) )
            @setTitle( "Stack - #{@model.get('name')}" )

            @refreshACLList()

            @updateSNSList @model.get("subscription"), true
            null

        stackNameChanged : () ->
            stackNameInput = $ '#property-stack-name'
            stackId = @model.get( 'id' )
            name = stackNameInput.val()

            stackNameInput.parsley 'custom', ( val ) ->
                if not MC.validate 'awsName',  val
                    return 'This value should be a valid Stack name.'

                if not MC.aws.aws.checkStackName stackId, val
                    return "Stack name \" #{name} \" is already in using. Please use another one."

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

                $clone.data "uid", sub.uid
                $clone.find(".protocol").html sub.protocol
                $clone.find(".endpoint").html sub.endpoint

            $("#property-stack-sns-num").html( snslist_data.length )

            null

        delSNS : ( event ) ->

            $li = $(event.currentTarget).closest("li")
            uid = $li.data("uid")
            $li.remove()

            @updateSNSList $("#property-sub-list").children(":not(.hide)"), true

            @model.deleteSNS uid

        editSNS : ( event ) ->
            $sub_li = $( event.currentTarget ).closest("li")
            data =
                title : "Edit"
                uid   : $sub_li.data("uid")
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
                    protocol : "Email"
                    title    : "Add"

            modal sub_template data

            $modal = $("#property-asg-sns-modal")

            # Setup the protocol
            $modal.find(".dropdown").find(".item").each ()->
                if $(this).text() is data.protocol
                    $(this).addClass("selected")

            # Setup the endpoint
            updateEndpoint = ( protocol ) ->
                $input  = $(".property-asg-ep")#.removeClass("https http")
                switch $modal.find(".selected").data("id")

                    when "sqs"
                        placeholder = "Amazon ARN"
                        type        = 'sqs'
                        errorMsg    = 'Please provide a valid Amazon SQS ARN'

                    when "arn"
                        placeholder = "Amazon ARN"
                        type        = 'arn'
                        errorMsg    = 'Please provide a valid Application ARN'

                    when "email"
                        placeholder = "exmaple@acme.com"
                        type        = 'email'
                        errorMsg    = 'Please provide a valid email address'

                    when "email-json"
                        placeholder = "example@acme.com"
                        type        = 'email'
                        errorMsg    = 'Please provide a valid email address'

                    when "sms"
                        placeholder = "e.g. 1-206-555-6423"
                        type        = 'usPhone'
                        errorMsg    = 'Please provide a valid phone number (currently only support US phone number)'

                    when "http"
                        #$input.addClass "http"
                        placeholder = "http://www.example.com"
                        type        = 'http'
                        errorMsg    = 'Please provide a valid URL'

                    when "https"
                        #$input.addClass "https"
                        placeholder = "https://www.example.com"
                        type        = 'https'
                        errorMsg    = 'Please provide a valid URL'

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
                        uid : $modal.data("uid")
                        protocol : $modal.find(".selected").data("id")
                        endpoint : endPoint.val()

                    modal.close()

                    self.saveSNS data

                null
    }

    new StackView()
