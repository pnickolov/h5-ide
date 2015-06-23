#############################
#  View(UI logic) for design/property/stack
#############################

define [ '../base/view',
         './template/stack',
         './template/acl',
         './template/sub',
         'event',
         'UI.modalplus',
         'i18n!/nls/lang.js'
         'constant'
], ( PropertyView, template, acl_template, sub_template, ide_event, modalPlus, lang, constant ) ->

    StackView = PropertyView.extend {
        events   :
            'change #property-stack-name'               : 'stackNameChanged'
            'change #property-stack-description'        : 'stackDescriptionChanged'
            'change #property-app-name'                 : 'changeAppName'
            'change .custom-app-usage'                  : 'changeUsage'
            'click #stack-property-new-acl'             : 'createAcl'
            'click #stack-property-acl-list .edit'      : 'openAcl'
            'click .acl-info-list .sg-list-delete-btn'  : 'deleteAcl'
            'click #property-app-resdiff'               : 'toggleResDiff'
            'click .marathon-switch'                    : 'toggleMarathon'

        render     : () ->
            if @model.isApp or @model.isAppEdit
                title = "App - #{@model.get('name')}"
            else
                title = "Stack - #{@model.get('name')}"

            @$el.html template.main @model.toJSON()

            if title
                @setTitle( title )

            @refreshACLList()
            @bindAppUsage()

            if @model.isAppEdit
                @$( '#property-app-name' ).parsley 'custom', @checkAppName

            @renderMesosData()

            null

        renderMesosData: ( dataModel = Design.instance().opsModel().getMesosData() ) ->
            @$( '#mesos-data-area' ).html template.mesosData _.extend { isAppEdit: @model.isAppEdit }, dataModel.toJSON()

        bindAppUsage: ()->
          $selectbox = @$el.find("#property-app-usage.selectbox")
          if $selectbox.size() < 1
            return false
          $selectbox.on "OPTION_CHANGE", (evt, _, result)->
            $selectbox.toggleClass("custom",
              result.value is "custom").parent().find("input.custom-app-usage").toggleClass("show",
              result.value is "custom")
            if result.value isnt "custom"
              Design.instance().set("usage", result.value)
          usage = Design.instance().get("usage")
          if usage in ["testing", "development", "production", "others"]
            $selectbox.find(".dropdown li.item[data-value='" + usage + "']").click()
          else
            $selectbox.find(".dropdown li.item[data-value='custom']").click()
            $selectbox.parent().find("input.custom-app-usage").val(usage)

        toggleMarathon: ( e ) ->
            $switch = $ e.currentTarget
            $switch.toggleClass( 'on' )

            marathonOn = $switch.hasClass( 'on' )
            @model.setMarathon marathonOn

        checkAppName: ( val )->
            design = Design.instance()
            repeatApp = design.project().apps().findWhere({name:val})
            if repeatApp and repeatApp.id isnt design.get('id')
                return lang.PROP.MSG_WARN_REPEATED_APP_NAME

            null

        changeAppName: ( e ) ->
            $target = $ e.currentTarget
            if $target.parsley 'validate'
                Design.instance().set 'name', $target.val()

        changeUsage: (e)->
            $target = $ e.currentTarget
            if $target.parsley "validate"
              Design.instance().set "usage", $target.val()

        toggleResDiff: ( e ) -> Design.instance().set 'resource_diff', e.currentTarget.checked

        stackDescriptionChanged: () ->
            stackDescTextarea = $ "#property-stack-description"
            stackId = @model.get('id')
            description = stackDescTextarea.val()

            if stackDescTextarea.parsley 'validate'
                @model.updateDescription description

        stackNameChanged : () ->
            stackNameInput = $ '#property-stack-name'
            stackId = @model.get( 'id' )
            name = stackNameInput.val()

            if name is @model.get("name") then return

            stackNameInput.parsley 'custom', ( val ) ->
                if not MC.validate 'awsName',  val
                    return lang.PARSLEY.SHOULD_BE_A_VALID_STACK_NAME

                if val is Design.instance().__opsModel.get("name")
                    # HACK, will remove after we re-write the whole property shit.
                    return

                if not Design.instance().project().stacks().isNameAvailable( val )
                    return sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, 'Stack', name

            if stackNameInput.parsley 'validate'
                @setTitle "Stack - " + name
                @model.updateStackName name
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

                modal = new modalPlus {
                      title: lang.PROP.STACK_DELETE_NETWORK_ACL_TITLE
                      width: 420
                      template: dialog_template
                      confirm: {text: lang.PROP.LBL_DELETE, color: "red"}
                }

                modal.on "confirm", ()->
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
