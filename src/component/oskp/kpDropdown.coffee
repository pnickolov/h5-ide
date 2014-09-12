define ['Design', "CloudResources", "backbone", "component/oskp/template", 'underscore', 'jquery'], (Design, CloudResources, Backbone, template, _, $)->
  Backbone.View.extend {
    render: (collection,selectTpl)->
      console.log "Initializing...."
      dropdown = $("<div/>")
      dropdown.append template.selection()
      dropdownSelect = dropdown.find("select.selection.option")
      dropdownSelect.on 'select_initialize', =>
        @selectize = dropdownSelect[0].selectize
        @selectize.addOption([{value: "www", text:"xxxxx"}, {value: "eee", text: "rrrrr"}])

      @.$input = dropdownSelect
      dropdownSelect.on 'select_dropdown_button_click', =>
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


