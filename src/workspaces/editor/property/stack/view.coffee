#############################
#  View(UI logic) for design/property/stack
#############################

define [ '../base/view',
         './template/stack',
         './template/acl',
         './template/sub',
         'event',
         'i18n!/nls/lang.js'
], ( PropertyView, template, acl_template, sub_template, ide_event, lang ) ->

    StackView = PropertyView.extend {
        events   :
            'change #property-stack-name'          : 'stackNameChanged'
            'change #property-stack-description'   : 'stackDescriptionChanged'
            'change #property-app-name'            : 'changeAppName'
            'click #stack-property-new-acl'        : 'createAcl'
            'click #stack-property-acl-list .edit' : 'openAcl'
            'click .acl-info-list .sg-list-delete-btn' : 'deleteAcl'
            'click #property-app-resdiff'          : 'toggleResDiff'

        render     : () ->
            if @model.isApp or @model.isAppEdit
                title = "App - #{@model.get('name')}"
            else
                title = "Stack - #{@model.get('name')}"
            @$el.html( template( @model.attributes ) )

            if title
                @setTitle( title )

            @refreshACLList()

            if @model.isAppEdit
                @$( '#property-app-name' ).parsley 'custom', @checkAppName

            null

        checkAppName: ( val )->
            repeatApp = App.model.appList().findWhere(name: val)
            if repeatApp and repeatApp.id isnt Design.instance().get('id')
                return lang.PROP.MSG_WARN_REPEATED_APP_NAME

            null

        changeAppName: ( e ) ->
            $target = $ e.currentTarget
            if $target.parsley 'validate'
                Design.instance().set 'name', $target.val()

        toggleResDiff: ( e ) -> Design.instance().set 'resource_diff', e.currentTarget.checked

        stackDescriptionChanged: () ->
            stackDescTextarea = $ "#property-stack-description"
            stackId = @model.get('id')
            description = stackDescTextarea.val()

            if stackDescTextarea.parsley 'validate'
                @trigger 'STACK_DESC_CHANGED', description
                #@setDescription description
        stackNameChanged : () ->
            stackNameInput = $ '#property-stack-name'
            stackId = @model.get( 'id' )
            name = stackNameInput.val()

            if name is @model.get("name") then return

            stackNameInput.parsley 'custom', ( val ) ->
                if not MC.validate 'awsName',  val
                    return lang.PARSLEY.SHOULD_BE_A_VALID_STACK_NAME

                if not App.model.stackList().isNameAvailable( val )
                    return sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, 'Stack', name

            if stackNameInput.parsley 'validate'
                @trigger 'STACK_NAME_CHANGED', name
                @setTitle "Stack - " + name
            null

        refreshACLList : () ->
            $(@el).find('.acl-info-list-num').text("(#{@model.get('networkAcls').length})")
            $('#stack-property-acl-list').html acl_template @model.attributes

        createAcl : ()->
            @trigger "OPEN_ACL", @model.createAcl()

        openAcl : ( event ) ->
            @trigger "OPEN_ACL", $(event.currentTarget).closest("li").attr("data-uid")
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
                    title : lang.PROP.STACK_DELETE_NETWORK_ACL_TITLE
                    main_content : sprintf lang.PROP.STACK_DELETE_NETWORK_ACL_CONTENT, aclName
                    desc_content : sprintf lang.PROP.STACK_DELETE_NETWORK_ACL_DESC, aclName
                }
                modal dialog_template, false, () ->
                    $('#modal-confirm-delete').click () ->
                        that.model.removeAcl( aclUID )
                        that.model.getNetworkACL()
                        that.refreshACLList()
                        modal.close()
            else
                @model.removeAcl( aclUID )
                @model.getNetworkACL()
                @refreshACLList()
    }

    new StackView()
