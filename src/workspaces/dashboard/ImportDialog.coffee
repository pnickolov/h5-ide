
define [
  './ImportDialogTpl'
  "UI.modalplus"
  "constant"
  "i18n!/nls/lang.js"
  "CloudResources"
  "ApiRequest"
  "JsonExporter"
  "backbone"
  ""
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

    initialize : ()->
      @modal = new Modal {
        title         : lang.IDE.POP_IMPORT_JSON_TIT
        template      : tplPartials.importJSON()
        width         : "470"
        disableFooter : true
      }

      @setElement @modal.tpl

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

    getCFParameters : ( cfJson )->
      p = []
      for key, value of cfJson.Parameters
        value.Name   = key
        value.NoEcho = value.NoEcho is true
        p.push value

      p

    handleCFTemplate : ( cfJson )->
      @cfJson     = cfJson
      @parameters = @getCFParameters( cfJson )

      data = {
        regions    : constant.REGION_KEYS.slice(0)
        parameters : @parameters
      }

      @modal.setContent tplPartials.importCF(data)
      @modal.setWidth "570"
      @modal.setTitle lang.IDE.POP_IMPORT_CF_TIT
      return

    extractUserInput : ( $li )->
      type  = $li.attr("data-type")
      value = $li.find("input").val()

      if not value then return false
      if type is "Number"
        value = Number( value )
        if isNaN( value ) then return false
      else if type is "List<Number>"
        value = value.split(",")
        for v, idx in value
          v = Number( v )
          if isNaN( v ) then return false
          value[ idx ] = v
        value = value.join(",")

      {
        name  : $li.attr("data-name")
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

      console.log region, @cfJson

      CloudResources( constant.RESTYPE.AZ, region ).fetch().then ()->

        ApiRequest("stack_import_cloudformation", {
          region_name : $("#import-cf-region").val()
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
