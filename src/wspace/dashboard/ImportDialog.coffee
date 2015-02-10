
define [
  './ImportDialogTpl'
  "UI.modalplus"
  "constant"
  "i18n!/nls/lang.js"
  "CloudResources"
  "ApiRequest"
  "JsonExporter"
  "backbone"
  "UI.select2"
  "UI.nanoscroller"
], ( tplPartials, Modal, constant, lang, CloudResources, ApiRequest, JsonExporter )->

  Backbone.View.extend {

    events :
      "change #modal-import-json-file"        : "onSelectFile"
      "drop #modal-import-json-dropzone"      : "onSelectFile"
      "dragenter #modal-import-json-dropzone" : "onDragenter"
      "dragleave #modal-import-json-dropzone" : "onDragleave"
      "dragover  #modal-import-json-dropzone" : "onDragover"
      "click #import-cf-cancel" : "cancelImport"
      "click #import-cf-import" : "doImport"

      "keypress .cf-input" : "onFocusInput"

      "OPTION_CHANGE #import-cf-region" : "onRegionChange"

    initialize : ( attr )->
      self = @

      this.type    = attr.type
      this.project = attr.project

      @modal = new Modal {
        title         : if @type is "stack" then lang.IDE.POP_IMPORT_JSON_TIT else lang.IDE.POP_IMPORT_CF_TIT
        template      : if @type is "stack" then tplPartials.importJSON() else tplPartials.importCF()
        width         : "470"
        disableFooter : true
        onClose       : ()-> self.onModalClose()
      }

      @setElement @modal.tpl

      @regionForceFetchMap = {}

      @reader = new FileReader()
      @reader.onload  = ( evt )-> self.onReaderLoader( evt )
      @reader.onerror = @onReaderError
      return

    onDragenter : ()-> @$el.find("#modal-import-json-dropzone").toggleClass("dragover", true)
    onDragleave : ()-> @$el.find("#modal-import-json-dropzone").toggleClass("dragover", false)
    onDragover  : ( evt )->
      dt = evt.originalEvent.dataTransfer
      if dt then dt.dropEffect = "copy"
      evt.stopPropagation()
      evt.preventDefault()
      return

    onSelectFile : ( evt )->
      evt.stopPropagation()
      evt.preventDefault()

      $("#modal-import-json-dropzone").removeClass("dragover")
      $("#import-json-error").html("")

      evt = evt.originalEvent
      files = (evt.dataTransfer || evt.target).files
      if not files or not files.length then return
      @filename = (files[0].name || "").split(".")[0]
      @reader.readAsText( files[0] )
      null

    onReaderLoader : ( evt )->
      result = JsonExporter.importJson @reader.result
      if _.isString result
        $("#import-json-error").html result
        return

      if @type is "stack" and result.AWSTemplateFormatVersion
        error = lang.IDE.POP_IMPORT_FORMAT_ERROR
      else if @type is "cf" and not result.AWSTemplateFormatVersion
        error = lang.IDE.POP_IMPORT_FORMAT_ERROR

      if not error
        if result.AWSTemplateFormatVersion
          @handleCFTemplate( result )
          return

      opsModel = @project.createStackByJson( result )
      App.loadUrl( opsModel.url() )

      @modal.close()
      @model = @project = @reader = null
      null

    onReaderError : ()-> $("#import-json-error").html lang.IDE.POP_IMPORT_ERROR

    handleCFTemplate : ( cfJson )->

      parameters = []
      for key, value of cfJson.Parameters
        value.Name   = key
        value.NoEcho = value.NoEcho is true
        if value.AllowedValues and not _.isArray( value.AllowedValues )
          value.AllowedValues = undefined

        if value.Type is "AWS::EC2::KeyPair::KeyName"
          @hasKpParam = true

        value.__Constraint = ""
        if value.AllowedValues
          value.__Constraint = "AllowedPattern: " + value.AllowedValues.join(",") + " "

        if value.Type is "Number"
          if value.MinValue
            value.__Constraint += "MinValue: " + value.MinValue + " "
          if value.MaxValue
            value.__Constraint += "MaxValue: " + value.MaxValue + " "

        else if value.Type is "String"
          if value.MinLength
            value.__Constraint += "MinLength: " + value.MinLength + " "
          if value.MaxLength
            value.__Constraint += "MaxLength: " + value.MaxLength + " "

        parameters.push value

      @parameters = parameters
      @cfJson     = cfJson

      data = {
        regions    : constant.REGION_KEYS.slice(0)
        parameters : parameters
      }

      @modal.setContent tplPartials.importCFConfirm(data)
      @modal.setWidth "570"
      @modal.setTitle lang.IDE.POP_IMPORT_CF_TIT

      @modal.tpl.find(".cf-params-wrap").nanoScroller()

      @initInputs()
      @onRegionChange()
      return

    onModalClose : ()->
      for ipt in @modal.tpl.find("#import-cf-params").children().find("input.cf-input")
        select2 = $( ipt ).data( "select2" )
        if select2
          $( ipt ).select2( "destroy" )

      return

    initInputs : ()->

      self = @
      kpQuery = ( options )->
        kps = []
        term = options.term.toLowerCase()
        for kp in self.currentRegionKps
          if kp.toLowerCase().indexOf( term ) >= 0
            kps.push { id:kp, text:kp }

        options.callback {
          more    : false
          results : kps
        }

      kpInitSelection = ( element, callback )->
        def = element.select2("val")
        callback( { id : def, text : def } )

      numberCreateSC = ( term )->
        if isNaN( Number(term) ) then return
        { id : term, text : term }

      formatNoMatches = ( term )->
        if not term
          "Input value..."
        else
          "Invalid input"

      $inputs = $("#import-cf-params").children()
      for param in @parameters

        # NoEcho ( Do nothing for NoEcho type )
        if param.NoEcho then continue

        select2 = false

        ipt = $inputs.filter("[data-name='#{param.Name}']").find("input")

        select2Option =
          allowClear : true
          data : []
          formatNoMatches : formatNoMatches

        if param.Type is "CommaDelimitedList" or param.Type is "List<Number>"
          select2 = true
          select2Option.multiple = true
          select2Option.allowDuplicate = true

          if not param.AllowedValues
            select2Option.tags = []
            select2Option.data = undefined
            select2Option.tokenSeparators = [","]

        if param.Type is "List<Number>"
          select2Option.createSearchChoice = numberCreateSC

        if param.Type is "AWS::EC2::KeyPair::KeyName"
          select2 = true
          select2Option.query = kpQuery
          select2Option.initSelection = kpInitSelection

        if param.AllowedValues
          select2 = true
          avs = []
          for av in param.AllowedValues
            avs.push { id : "" + av, text : "" + av }
          select2Option.data = avs
          select2Option.selectOnComma = true

        if select2 then ipt.select2( select2Option )

      return

    onRegionChange : ()->
      if not @hasKpParam then return

      # Always do a thourough fetch for one region. If the user wants to refresh keypair
      # of one region serverial time, he needs to close and reopen import dialog
      currentRegion = $("#import-cf-region").find(".selected").attr("data-id")
      if not @regionForceFetchMap[ currentRegion ]
        @regionForceFetchMap[ currentRegion ] = true
        CloudResources( constant.RESTYPE.KP, currentRegion ).fetchForce()

      self = @
      $("#import-cf-form .loader").show()
      CloudResources( constant.RESTYPE.KP, currentRegion ).fetch().then ()->
        $("#import-cf-form .loader").hide()
        self.currentRegionKps = CloudResources( constant.RESTYPE.KP, currentRegion ).pluck("id")

        $inputs = $("#import-cf-params").children()
        for param in self.parameters
          if param.Type is "AWS::EC2::KeyPair::KeyName"
            $ipt = $inputs.filter("[data-name='#{param.Name}']").find("input.cf-input")
            $ipt.select2 "val", ( $ipt.select2("val") or param.Default )

        return

      return

    extractUserInput : ( $li )->
      type  = $li.attr("data-type")
      $input = $li.find("input.cf-input")
      if $input.siblings(".select2-container").length
        value = $input.select2("val")
      else
        value = $li.find("input.cf-input").val()
      name  = $li.attr("data-name")
      param = @cfJson.Parameters[ name ]

      if not value
        return {
          name  : name
          value : ""
        }

      # The string might contain ",", so we need to treat string differently.
      if type is "Number" or type is "String"
        valueArray = [ value ]
      else
        if _.isArray( value )
          valueArray = value
        else
          valueArray = value.split(",")

      if type is "Number" or type is "List<Number>"
        for v, idx in valueArray
          v = Number( v )
          if isNaN( v ) then return false
          if param.MinValue and Number( param.MinValue ) > v then return false
          if param.MaxValue and Number( param.MaxValue ) < v then return false
          valueArray[ idx ] = v

      else if type is "String" or type is "CommaDelimitedList"
        if param.AllowedPattern
          AllowedPattern = new RegExp(param.AllowedPattern)
        for v, idx in valueArray
          if param.MinLength and Number( param.MinLength ) > v.length then return false
          if param.MaxLength and Number( param.MaxLength ) < v.length then return false
          if AllowedPattern and not AllowedPattern.test( v ) then return false

      # Check AllowedValues
      if param.AllowedValues
        for v in valueArray
          for av in param.AllowedValues || []
            if "" + av is "" + v
              allowed = true
              break
          if not allowed then return false

      if param.Type is "AWS::EC2::KeyPair::KeyName"
        if @currentRegionKps.indexOf( value ) < 0
          return false

      if type is "String" or type is "Number"
        value = valueArray[0]
      else if type is "List<Number>" or type is "CommaDelimitedList"
        value = valueArray.join(",")

      {
        name  : name
        value : value
      }

    checkCFParameter : ()->
      $entries = @modal.tpl.find(".cf-params").children()
      error    = false
      hasEmpty = false

      for li in $entries
        $li = $(li)
        result = @extractUserInput( $li )
        if not result
          error = true
          $li.toggleClass("error", true)
        else
          if not result.value
            hasEmpty = true

          @cfJson.Parameters[ result.name ].Default = result.value
          $li.toggleClass("error", false)

      @modal.tpl.find(".param-error").hide()
      @modal.tpl.find(".param-empty").hide()

      if error
        @modal.tpl.find(".param-error").show()
        @emptyParamConfirm = false
      else if hasEmpty
        @modal.tpl.find(".param-empty").show()

        if not @emptyParamConfirm
          error = @emptyParamConfirm = true

      return not error

    doImport : ()->

      if not @checkCFParameter()
        return

      self = @

      @modal.tpl.find(".loading-spinner").show()
      @modal.tpl.closest(".modal-box").find(".modal-close").hide()
      $("#import-cf-form").hide()
      @modal.resize()

      region = $("#import-cf-region").find(".selected").attr("data-id")

      CloudResources( constant.RESTYPE.AZ, region ).fetch().then ()->

        ApiRequest("stack_import_cloudformation", {
          region_name : $("#import-cf-region").find(".selected").attr("data-id")
          cf_template : self.cfJson
          parameters  : {
            az : _.pluck CloudResources( constant.RESTYPE.AZ, region ).where({category:region}), "id"
          }
        }).then ( data )->
          self.modal.close()
          data.provider = "aws::global"
          if self.filename
            data.name = self.filename
          App.importJson( data, true )
        , ()->
          self.modal.close()
          notification 'error', sprintf lang.IDE.POP_IMPORT_CFM_ERROR
          return

    cancelImport : ()-> @modal.close()

    onFocusInput : ( evt )-> $( evt.currentTarget ).closest("li").removeClass("error")
  }
