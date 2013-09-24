#############################
#  View(UI logic) for design/property/stack
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars',
    'UI.notification',
    'UI.secondarypanel' ], ( ide_event ) ->

    StackView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        stack_template  : Handlebars.compile $( '#property-stack-tmpl' ).html()
        acl_template    : Handlebars.compile $( '#property-stack-acl-tmpl' ).html()
        app_template    : Handlebars.compile $( '#property-app-tmpl' ).html()
        sub_template    : Handlebars.compile $( '#property-stack-sns-tmpl' ).html()

        events   :
            # 'change #property-stack-name'           : 'stackNameChanged'
            # 'click #add-sg-btn'                     : 'openSecurityGroup'
            # 'click #sg-info-list .sg-edit-icon'     : 'openSecurityGroup'
            # 'click .deleteSG'                       : 'deleteSecurityGroup'
            # 'click .resetSG'                        : 'resetSecurityGroup'
            # 'click .stack-property-acl-list .delete': 'deleteNetworkAcl'
            # 'click #stack-property-add-new-acl'     : 'openCreateAclPanel'
            # 'click .stack-property-acl-list .edit'  : 'openEditAclPanel'

            'change #property-stack-name'   : 'stackNameChanged'
            # 'click #add-sg-btn'             : 'createSecurityGroup'
            # 'click .deleteSG'               : 'deleteSecurityGroup'
            # 'click .resetSG'                : 'resetSecurityGroup'
            'click .stack-property-acl-list .sg-list-delete-btn' : 'deleteNetworkAcl'
            'click #stack-property-add-new-acl' : 'openCreateAclPanel'
            'click .stack-property-acl-list .edit' : 'openEditAclPanel'

            'click #property-sub-list .icon-edit' : 'editSNS'
            'click #property-sub-list .icon-del'  : 'delSNS'
            'click #property-create-asg' : 'openSNSModal'

        render     : () ->
            me = this

            console.log 'property:stack render'

            #
            this.undelegateEvents()
            #
            $( '.property-details' ).html this.stack_template this.model.attributes

            this.refreshACLList()
            #
            this.delegateEvents this.events

            MC.canvas_data.name = MC.canvas_data.name.replace(/\s+/g, '')
            $( '#property-stack-name' ).val(MC.canvas_data.name)

            this.updateSNSList this.model.attributes.subscription, this.model.attributes.has_asg, true

            null

        stackNameChanged : () ->
            me = this
            stackNameInput = $ '#property-stack-name'
            stackId = @model.get( 'property_detail' ).id
            name = stackNameInput.val()

            stackNameInput.parsley 'custom', ( val ) ->
                if not MC.validate 'awsName',  val
                    return 'This value should be a valid Stack name.'

                if not MC.aws.aws.checkStackName stackId, val
                    return "Stack name \" #{name} \" is already in using. Please use another one."

            if stackNameInput.parsley 'validate'
                me.trigger 'STACK_NAME_CHANGED', name

        openSecurityGroup : (event) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            ide_event.trigger ide_event.OPEN_SG, target.data('secondarypanel-data')

        # deleteSecurityGroup : (event) ->
        #     me = this

        #     target = $(event.target).parents('div:eq(0)')
        #     uid = target.attr('uid')
        #     name = target.children('p.title').text()

        #     console.log "Remove sg:" + uid

        #     me.trigger 'DELETE_STACK_SG', uid

        #     target.remove()

        #     notification 'info', name + ' is deleted.'

        #     null

        # resetSecurityGroup : (event) ->
        #     me = this

        #     target = $(event.target).parents('div:eq(0)')
        #     uid = target.attr('uid')

        #     me.trigger 'RESET_STACK_SG', uid

        #     null

        deleteNetworkAcl : (event) ->

            that = this

            $target = $(event.currentTarget)
            aclUID = $target.attr('acl-uid')
            
            associationNum = Number($target.attr('acl-association'))
            aclName = $target.attr('acl-name')

            # show dialog to confirm that delete acl
            if associationNum
                mainContent = 'Are you sure you want to delete ' + aclName + '?'
                descContent = 'Subnets associated with ' + aclName + ' will use DefaultACL.'
                template = MC.template.modalDeleteSGOrACL {
                    title : 'Delete Network ACL',
                    main_content : mainContent,
                    desc_content : descContent
                }
                modal template, false, () ->
                    $('#modal-confirm-delete').click () ->
                        MC.aws.acl.addRelatedSubnetToDefaultACL(aclUID)
                        delete MC.canvas_data.component[aclUID]
                        that.refreshACLList()
                        modal.close()

            else
                delete MC.canvas_data.component[aclUID]
                that.refreshACLList()

        refreshACLList : () ->
            if MC.aws.vpc.getVPCUID()
                this.model.getNetworkACL()
                $('.stack-property-acl-list').html this.acl_template this.model.attributes

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

            vpcUID = MC.aws.vpc.getVPCUID()
            aclObj.resource.VpcId = '@' + vpcUID + '.resource.VpcId'

            MC.canvas_data.component[aclUID] = aclObj

            ide_event.trigger ide_event.OPEN_ACL, aclUID

        openEditAclPanel : ( event ) ->
            source = $(event.currentTarget)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            aclUID = source.attr('acl-uid')

            ide_event.trigger ide_event.OPEN_ACL, aclUID

        updateSNSList : ( snslist_data, hasASG, textOnly ) ->

            console.log "Morris updateSNSList", this.model.attributes

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

            this.updateSNSList $("#property-sub-list").children(":not(.hide)"), this.model.attributes.has_asg, true

            this.trigger 'DELETE_SUBSCRIPTION', uid


        editSNS : ( event ) ->
            $sub_li = $( event.currentTarget ).closest("li")
            data =
                title : "Edit"
                uid   : $sub_li.data("uid")
                protocol : $sub_li.find(".protocol").text()
                endpoint : $sub_li.find(".endpoint").text()

            this.openSNSModal event, data
            null

        saveSNS : ( data ) ->

            if data.uid
                # We are editing existing Subscription
                # Update the related subscription's dom
                $dom = $("#property-sub-list > li[data-uid='#{data.uid}']")
                $dom.find(".protocol").html( data.protocol )
                $dom.find(".endpoint").html( data.endpoint )

            this.trigger  "SAVE_SUBSCRIPTION", data

            if !data.uid
                # Update the list
                this.updateSNSList this.model.attributes.subscription, this.model.attributes.has_asg

        openSNSModal : ( event, data ) ->
            # data =
            #       uid : "123123-123123-123123"
            #       protocol : "Email"
            #       endpoint : "123@abc.com"
            if !data
                data =
                    protocol : "Email"
                    title    : "Add"

            modal this.sub_template data

            $modal = $("#property-asg-sns-modal")

            # Setup the protocol
            $modal.find(".dropdown").find(".item").each ()->
                if $(this).text() is data.protocol
                    $(this).addClass("selected")

            # Setup the endpoint
            updateEndpoint = ( protocol ) ->
                $input  = $(".property-asg-ep").removeClass("https http")
                switch $modal.find(".selected").data("id")

                    when "sqs"
                        placeholder = "Amazon ARN"
                        type = 'sqs'
                        errorMsg = 'Please provide a valid Amazon SQS ARN'

                    when "arn"
                        placeholder = "Amazon ARN"
                        type = 'arn'
                        errorMsg = 'Please provide a valid Application ARN'
                    when "email"
                        placeholder = "exmaple@acme.com"
                        type = 'email'
                        errorMsg = 'Please provide a valid email address'
                    when "email-json"
                        placeholder = "example@acme.com"
                        type = 'email'
                        errorMsg = 'Please provide a valid email address'
                    when "sms"
                        placeholder = "e.g. 1-206-555-6423"
                        type='usPhone'
                        errorMsg = 'Please provide a valid phone number (currently only support US phone number)'
                    when "http"
                        $input.addClass "http"
                        placeholder = "www.example.com"
                        type = 'http'
                        errorMsg = 'Please provide a valid URL'
                    when "https"
                        $input.addClass "https"
                        placeholder = "www.example.com"
                        type = 'https'
                        errorMsg = 'Please provide a valid URL'

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

    view = new StackView()

    return view
