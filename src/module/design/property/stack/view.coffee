#############################
#  View(UI logic) for design/property/stack
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars',
    'UI.notification',
    'UI.secondarypanel', 'UI.parsley' ], ( ide_event ) ->

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
            'click .stack-property-acl-list .delete' : 'deleteNetworkAcl'
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

            stackNameInput.parsley 'custom', () ->
                if not MC.aws.aws.checkStackName stackId, name
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
            aclUID = $(event.target).attr('acl-uid')
            delete MC.canvas_data.component[aclUID]
            this.refreshACLList()

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

            MC.canvas_data.component[aclUID] = aclObj

            ide_event.trigger ide_event.OPEN_ACL, aclUID

        openEditAclPanel : ( event ) ->
            source = $(event.target)
            if(source.hasClass('secondary-panel'))
                target = source
            else
                target = source.parents('.secondary-panel').first()

            aclUID = source.attr('acl-uid')

            ide_event.trigger ide_event.OPEN_ACL, aclUID

        updateSNSList : ( snslist_data, hasASG, textOnly ) ->

            console.log "Morris updateSNSList", this.model.attributes

            # Hide all message
            $(".property-sns-info > div").hide()

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

            $li = $(this).closest("li")
            uid = $li.data("uid")
            $li.remove()

            this.trigger "DEL_SUBSCRIPTION", uid

            this.trigger 'DELETE_SUBSCRIPTION', uid


        editSNS : ( event ) ->
            $sub_li = $( event.currentTarget ).parent()
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

                    when "sqa"
                        placeholder = "e.g. Amazon ARN"
                    when "email"
                        placeholder = "e.g. exmaple@acme.com"
                    when "email-json"
                        placeholder = "e.g. example@acme.com"
                    when "sms"
                        placeholder = "e.g. 1-343-21-323"
                    when "http"
                        $input.addClass "http"
                        placeholder = "e.g. www.example.com"
                    when "https"
                        $input.addClass "https"
                        placeholder = "e.g. www.example.com"
                $("#property-asg-endpoint").attr "placeholder", placeholder
                null

            updateEndpoint()

            $modal.on "OPTION_CHANGE", updateEndpoint


            # Bind Events
            self = this
            $("#property-asg-sns-done").on "click", ()->
                data =
                    uid : $modal.data("uid")
                    protocol : $modal.find(".selected").data("id")
                    endpoint : $("#property-asg-endpoint").val()

                console.log "Save Subscription", data

                modal.close()

                self.saveSNS data
                null
            null


    }

    view = new StackView()

    return view
