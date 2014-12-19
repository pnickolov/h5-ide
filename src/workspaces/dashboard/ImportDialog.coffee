
define [
  './ImportDialogTpl'
  "UI.modalplus"
  "constant"
  "i18n!/nls/lang.js"
  "CloudResources"
  "ApiRequest"
  "JsonExporter"
  "backbone"
  "UI.typeahead"
  "UI.tokenfield"
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
      typeaheadOption =
        hint      : false
        minLength : 0

      typeaheadKpDataset =
        name   : 'importcf'
        source : (q, cb)-> self.typeaheadMatch(q, cb, self.currentRegionKps )

      $inputs = $("#import-cf-params").children()
      for param in @parameters

        # NoEcho ( Do nothing for NoEcho type )
        if param.NoEcho then continue

        ipt = $inputs.filter("[data-name='#{param.Name}']").find("input")

        if param.Type is "AWS::EC2::KeyPair::KeyName"
          ipt.typeahead( typeaheadOption, typeaheadKpDataset )
          continue

        if param.AllowedValues
          if param.Type is "CommaDelimitedList" or param.Type is "List<Number>"
            ipt.tokenfield({
              typeahead : [ typeaheadOption, {
                name   : "importcf"
                source : @createTypeaheadMatch( param.AllowedValues )
              }]
            })
            continue

          else if param.Type is "String" or param.Type is "Number"
            continue
        else
          if param.Type is "CommaDelimitedList" or param.Type is "List<Number>"
            ipt.tokenfield()

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
        self.currentRegionKps = CloudResources( constant.RESTYPE.KP, currentRegion ).pluck( "id" )
        return

      return

    typeaheadMatch : ( query, cb, source )->
      matches  = []
      queryReg = new RegExp( query, "i" )

      for i in source
        if queryReg.test( i )
          matches.push { value : "" + i }

      if matches.length is 0
        for i in source
          matches.push { value : "" + i }

      cb( matches )

    createTypeaheadMatch : ( source )->
      self = @
      ( query, cb )-> self.typeaheadMatch( query, cb, source )

    extractUserInput : ( $li )->
      type  = $li.attr("data-type")
      value = $li.find("input").val()
      name  = $li.attr("data-name")
      param = @cfJson.Parameters[ name ]

      if not value then return false

      # The string might contain ",", so we need to treat string differently.
      if type is "Number" or type is "String"
        valueArray = [ value ]
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
          if param.MinLength and Number( param.MinLength ) > value.length then return false
          if param.MaxLength and Number( param.MaxLength ) < value.length then return false
          if AllowedPattern and not AllowedPattern.test( value ) then return false

      # Check AllowedValues
      if param.AllowedValues
        for v in valueArray
          if param.AllowedValues.indexOf( v ) < 0
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
      error = false
      for li in $entries
        $li = $(li)
        result = @extractUserInput( $li )
        if not result
          error = true
          $li.toggleClass("error", true)
        else
          @cfJson.Parameters[ result.name ].Default = result.value

      return not error

    doImport : ()->

      if not @checkCFParameter()
        @modal.tpl.find(".param-error").show()
        return

      self = @

      @modal.tpl.find(".loading-spinner").show()
      @modal.tpl.closest(".modal-box").find(".modal-close").hide()
      $("#import-cf-form").hide()

      region = $("#import-cf-region").val()

      CloudResources( constant.RESTYPE.AZ, region ).fetch().then ()->

        ApiRequest("stack_import_cloudformation", {
          region_name : $("#import-cf-region").find(".selected").attr("data-id")
          cf_template : JSON.stringify( @cfJson )
          parameters  : {
            az : _.pluck CloudResources( constant.RESTYPE.AZ, region ).where({category:region}), id
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
