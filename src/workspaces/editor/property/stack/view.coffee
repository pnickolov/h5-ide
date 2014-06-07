#############################
#  View(UI logic) for design/property/stack
#############################

define [ '../base/view',
         './template/stack',
         './template/acl',
         './template/sub',
         'event',
         'i18n!nls/lang.js'
], ( PropertyView, template, acl_template, sub_template, ide_event, lang ) ->

    StackView = PropertyView.extend {
        events   :
            'change #property-stack-name'          : 'stackNameChanged'
            'change #property-stack-description'   : 'stackDescriptionChanged'
            'click #stack-property-new-acl'        : 'createAcl'
            'click #stack-property-acl-list .edit' : 'openAcl'
            'click .sg-list-delete-btn'            : 'deleteAcl'

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
            console.log @model.attributes
            @$el.html( template( @model.attributes ) )

            if title
                @setTitle( title )

            @refreshACLList()

            null

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
                    return lang.ide.PARSLEY_SHOULD_BE_A_VALID_STACK_NAME

                if not App.model.stackList().isNameAvailable( val )
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
