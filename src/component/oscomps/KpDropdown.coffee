define ['Design', "CloudResources", 'constant', 'toolbar_modal', 'UI.modalplus', 'component/oscomps/KpDialogTpl', 'kp_upload', 'i18n!/nls/lang.js', 'JsonExporter', 'UI.selection'],
( Design, CloudResources, constant, toolbar_modal, modalplus, template, upload, lang, JsonExporter, bindSelection )->
  download = JsonExporter.download
  Backbone.View.extend {
    __needDownload: false
    __upload: null
    __import: ''
    __mode: 'normal'

    initialize: (resModel, selectTemplate)->
      @template = selectTemplate
      @resModel = resModel

      @collection = CloudResources(constant.RESTYPE.OSKP, Design.instance().region())
      @listenTo @collection, 'update', @updateOption.bind(@)

      @
    render: (name)->
      dropdown = $("<div/>")
      @template ||= $("<select class='selection option' name='kpDropdown' data-button-tpl='kpButton'></select>")
      $(@template).attr('placeholder', lang.IDE.COMPONENT_SELECT_KEYPAIR)
      dropdown.append @template
      dropdownSelect = dropdown.find("select.selection.option")
      bindSelection(dropdown, @selectionTemplate)
      dropdownSelect.on 'select_initialize', =>
        @selectize = dropdownSelect[0].selectize
        @updateOption()
        if name then @setValue(name)
      @$input = dropdownSelect
      if @resModel then @$input.change => @resModel.set('keypair', @$input.val())
      dropdownSelect.on 'select_dropdown_button_click', =>
        console.log 'manage'
        @trigger 'manage'
        @manage()
      @setElement(dropdown)
      @

    hasResourceWithDefaultKp: ()->
      has = false
      Design.instance().eachComponent ( comp ) ->
        if comp.type is constant.RESTYPE.OSSERVER
          if comp.get('keypair') is "$DefaultKeyPair" and comp.get('credential') is 'keypair'
            has = true
            return
      has

    defaultKpNotSet: ()->
      KeypairModel = Design.modelClassForType(constant.RESTYPE.OSKP)
      defaultKp = _.find KeypairModel.allObjects(), ( obj )-> obj.get("name") is "DefaultKP"
      not (defaultKp.get('keyName') and defaultKp.get("fingerprint"))

    setDefaultKeyPair: ()->
      that = @
      Design.instance().eachComponent ( comp ) ->
        if comp.type is constant.RESTYPE.OSSERVER
          if comp.get('keypair') is "$DefaultKeyPair" and  comp.get('credential') is 'keypair'
            console.log comp
            targetKeypair = that.collection.get(that.$input.val())
            KeypairModel = Design.modelClassForType(constant.RESTYPE.OSKP)
            defaultKp = _.find KeypairModel.allObjects(), ( obj )-> obj.get("name") is "DefaultKP"
            defaultKp.set('keyName', targetKeypair.get('name'))
            defaultKp.set('fingerprint', targetKeypair.get('fingerprint'))

    updateOption: ->
      optionList = _.map @collection.toJSON(), (e)->
        {text: e.name, value: e.name}
      defaultKp = if @resModel then [{text: "$DefaultKeyPair", value: "$DefaultKeyPair"}] else []
      optionList = defaultKp.concat(optionList)
      if not @selectize then return false
      @selectize.clearOptions()
      @selectize.addOption optionList
      if @resModel then @selectize.setValue(@resModel.get('keypair')||optionList[0].value)

    setValue: (value)->
      if not @selectize
        console.error "Not Rendered Yet...."
        return false
      @selectize.setValue(value)

    getValue: ()->
      if not @selectize
        console.error "Not Rendered Yet...."
        return false
      @selectize.getValue()

    needDownload: () ->
      if arguments.length is 1
        @__needDownload = arguments[ 0 ]
        if arguments[ 0 ] is false
          @M$( '.cancel' ).prop 'disabled', false
      else
        if @__needDownload then notification 'warning', lang.NOTIFY.YOU_MUST_DOWNLOAD_THE_KEYPAIR

      @__needDownload

    denySlide: () ->
      not @needDownload()

    selectionTemplate:
      kpButton: ()->
        template.kpButton()

    getModalOptions: ->
      that = @
      region = Design.instance().get('region')
      regionName = constant.REGION_SHORT_LABEL[ region ] || region

      title: "Manage Key Pairs in #{regionName}"
      slideable: _.bind that.denySlide, that
      context: that
      buttons: [
        {
          icon: 'new-stack'
          type: 'create'
          name: lang.IDE.COMPONENT_CREATE_KEYPAIR
        }
        {
          icon: 'import'
          type: 'import'
          name: lang.IDE.COMPONENT_IMPORT_KEY_PAIR
        }
        {
          icon: 'del'
          type: 'delete'
          disabled: true
          name: lang.IDE.COMPONENT_DELETE_KEY_PAIR
        }
        {
          icon: 'refresh'
          type: 'refresh'
          name: ''
        }
      ]
      columns: [
        {
          sortable: true
          width: "40%" # or 40%
          name: lang.IDE.COMPONENT_KEY_PAIR_COL_NAME
        }
        {
          sortable: false
          name: lang.IDE.COMPONENT_KEY_PAIR_COL_FINGERPRINT
        }
      ]

    initModal: () ->
      new toolbar_modal @getModalOptions()
      @modal.on 'slidedown', @renderSlides, @
      @modal.on 'action', @doAction, @
      @modal.on 'refresh', @refresh, @


    manage: ( options ) ->
      options = {} if not options
      @initModal()
      @modal.render()
      if App.user.hasCredential()
        that = @
        @collection.fetch().then ->
          that.renderKeys()
      else
        @modal.render 'nocredential'

      @collection.on 'update', @renderKeys, @

    renderKeys: () ->
      if not @collection.isReady()
        return false
      data = keys : @collection.toJSON()
      @modal.setContent template.keys data
      @

    __events:

    # actions
      'click #kp-create': 'renderCreate'
      'click #kp-import': 'renderImport'
      'click #kp-delete': 'renderDelete'
      'click #kp-refresh': 'refresh'

    # do action
    #'click .do-action': 'doAction'
      'click .cancel': 'cancel'

    downloadKp: ->
      @__downloadKp and @__downloadKp()

    doAction: ( action, checked ) ->
      @[action] and @[action](@validate(action), checked)

    validate: ( action ) ->
      switch action
        when 'create'
          return not @M$( '#create-kp-name' ).parsley 'validate'
        when 'import'
          return not @M$( '#import-kp-name' ).parsley 'validate'


    switchAction: ( state ) ->
      if not state
        state = 'init'

      @M$( '.slidebox .action' ).each () ->
        if $(@).hasClass state
          $(@).show()
        else
          $(@).hide()

    genDownload: ( name, str ) ->
      @__downloadKp = ->
        if $("body").hasClass("safari")
          blob = null
        else
          blob = new Blob [str]

        if not blob
          options =
            template        : template.safari_download keypair: str
            title           : 'Keypair Content'
            disableFooter   : true
            disableClose    : true
            width           : '855px'
            height          : '473px'
            compact         : true

          new modalplus options
          $('.safari-download-textarea').select()

          return

        download( blob, name )


      @__downloadKp

    genDeleteFinish: ( times ) ->
      success = []
      error = []
      that = @

      finHandler = _.after times, ->
        that.cancel()
        if success.length is 1
          console.debug success
          notification 'info', sprintf lang.NOTIFY.XXX_IS_DELETED, success[0].attributes.name
        else if success.length > 1
          notification 'info', sprintf lang.NOTIFY.SELECTED_KEYPAIRS_ARE_DELETED, success.length

        if not that.collection.toJSON().length
          that.M$( '#t-m-select-all' )
          .get( 0 )
          .checked = false

        _.each error, ( s ) ->
          console.log(s)

      ( res ) ->
        console.debug res
        if not (res.reason|| res.msg)
          success.push res
        else
          error.push res

        finHandler()

    create: ( invalid ) ->
      that = @
      if not invalid
        keyName = @M$( '#create-kp-name' ).val()
        @switchAction 'processing'
        @collection.create( {name: keyName} ).save()
        .then (res) ->
          that.needDownload true
          that.genDownload "#{res.attributes.name}.pem", res.attributes.private_key
          that.switchAction 'download'
          that.M$( '.before-create' ).hide()
          that.M$( '.after-create' ).find( 'span' ).text( res.attributes.keyName ).end().show()

        ,( err ) ->
          that.modal.error err.awsResult or err.reason or err.msg
          that.switchAction()

    download: () ->
      @needDownload false
      @__downloadKp and @__downloadKp()
      null

    delete: ( invalid, checked ) ->
      count = checked.length

      onDeleteFinish = @genDeleteFinish count
      @switchAction 'processing'
      that = @
      _.each checked, ( c ) =>
        @collection.findWhere(name: c.data.name.toString()).destroy().then onDeleteFinish, onDeleteFinish
    import: ( invalid ) ->
      that = @
      if not invalid
        keyName = @M$( '#import-kp-name' ).val()
        @switchAction 'processing'
        try
          keyContent = that.__upload.getData()
        catch
          @modal.error 'Key is not in valid OpenSSH public key format'
          that.switchAction 'init'
          return


        @collection.create( {name:keyName, public_key: keyContent}).save()
        .then (res) ->
          notification 'info', sprintf lang.NOTIFY.XXX_IS_IMPORTED, keyName
          that.cancel()
        ,( err ) ->
          if err.awsResult and err.awsResult.indexOf( 'Length exceeds maximum of 2048' ) >= 0
            msg = 'Length exceeds maximum of 2048'
          else
            msg = err.awsResult or err.error_message or err.reason or err.msg

          that.modal.error msg
          that.switchAction 'ready'

    cancel: ->
      @modal.cancel()

    refresh: ->
      @collection.fetchForce().then =>
        @renderKeys()

    renderSlides: ( which, checked ) ->
      tpl = template[ "slide_#{which}" ]
      slides = @getSlides()
      slides[ which ]?.call @, tpl, checked


    getSlides: ->
      that = @
      modal = @modal

      create: ( tpl, checked ) ->
        modal.setSlide tpl

      "delete": ( tpl, checked ) ->
        checkedAmount = checked.length

        if not checkedAmount
          return

        data = {}

        if checkedAmount is 1
          data.selecteKeyName = checked[ 0 ].data.name
        else
          data.selectedCount = checkedAmount

        modal.setSlide tpl data

      import: ( tpl, checked ) ->
        modal.setSlide tpl
        that.__upload and that.__upload.remove()
        that.__upload = new upload()
        that.__upload.on 'load', that.afterImport, @
        that.M$( '.import-zone' ).html that.__upload.render().el


    afterImport: ( result ) ->
      @switchAction 'ready'

  }


