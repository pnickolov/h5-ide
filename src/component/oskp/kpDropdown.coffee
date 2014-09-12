define ['Design', "CloudResources", "backbone", 'underscore', 'jquery', 'constant'], (Design, CloudResources, Backbone, _, $, constant)->
  Backbone.View.extend {
    initialize: (resModel, template)->
      @template = template
      @resModel = resModel
    render: ->
      console.log "Initializing...."
      dropdown = $("<div/>")
      dropdown.append @template
      dropdownSelect = dropdown.find("select.selection.option")
      dropdownSelect.on 'select_initialize', =>
        @collection = CloudResources(constant.RESTYPE.OSKP, Design.instance().region())
        optionList = _.map @collection.toJSON(), (e)->
          {text: e.name, value: e.name}
        optionList = [{text: "$DefaultKeyPair", value: "$DefaultKeyPair"}].concat(optionList)
        @selectize = dropdownSelect[0].selectize
        @selectize.addOption optionList
        @selectize.setValue(@resModel.get('keypair')||optionList[0].value)
      @$input = dropdownSelect
      dropdownSelect.on 'select_dropdown_button_click', =>
        console.log 'manage'
        @trigger 'manage'
      @setElement(dropdown)
      @

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

  }


