
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

    initialize : ()->
      @modal = new Modal {
        title         : lang.IDE.POP_IMPORT_JSON_TIT
        template      : tplPartials.importJSON()
        width         : "470"
        disableFooter : true
      }

      @setElement @modal.tpl

      @regionForceFetchMap = {}

      self = @
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
      @reader.readAsText( files[0] )
      null

    onReaderLoader : ( evt )->
      result = JsonExporter.importJson @reader.result
      if _.isString result
        $("#import-json-error").html result
        return

      if result.AWSTemplateFormatVersion
        @handleCFTemplate( result )
        return

      error = App.importJson( @reader.result )
      if _.isString error
        $("#import-json-error").html error
      else
        @modal.close()
        @reader = null
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

      @modal.setContent tplPartials.importCF(data)
      @modal.setWidth "570"
      @modal.setTitle lang.IDE.POP_IMPORT_CF_TIT

      @initInputs()
      @onRegionChange()
      return

    initInputs : ()->

      self = @
      kpQuery = ( options )->
        options.callback {
          more    : false
          results : self.currentRegionKps
        }

      kpInitSelection = ( element, callback )->
        def = element.select2("val")
        callback( { id : def, text : def } )

      numberCreateSC = ( term )->
        if isNaN( Number(term) ) then return
        { id : term, text : term }

      $inputs = $("#import-cf-params").children()
      for param in @parameters

        # NoEcho ( Do nothing for NoEcho type )
        if param.NoEcho then continue

        select2 = false

        ipt = $inputs.filter("[data-name='#{param.Name}']").find("input")

        select2Option =
          allowClear : true
          data : []

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
        self.currentRegionKps = []
        for kp in CloudResources( constant.RESTYPE.KP, currentRegion ).models
          self.currentRegionKps.push { id : kp.id, text : kp.id }

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

      if not value then return false

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
        for kp in @currentRegionKps
          if kp.id is value
            allowed = true

        if not allowed then return false

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
      error = false
      for li in $entries
        $li = $(li)
        result = @extractUserInput( $li )
        if not result
          error = true
          $li.toggleClass("error", true)
        else
          @cfJson.Parameters[ result.name ].Default = result.value
          $li.toggleClass("error", false)

      return not error

    doImport : ()->

      if not @checkCFParameter()
        @modal.tpl.find(".param-error").show()
        return

      self = @

      @modal.tpl.find(".loading-spinner").show()
      @modal.tpl.closest(".modal-box").find(".modal-close").hide()
      $("#import-cf-form").hide()

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
          data.provider = "aws::china"
          App.importJson( data, true )
        , ()->
          self.modal.close()
          notification 'error', sprintf lang.IDE.POP_IMPORT_CFM_ERROR
          return

    cancelImport : ()-> @modal.close()

    onFocusInput : ( evt )-> $( evt.currentTarget ).closest("li").removeClass("error")
  }
