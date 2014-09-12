define ['Design', "CloudResources", "backbone", "component/oskp/template", 'underscore', 'jquery'], (Design, CloudResources, Backbone, template, _, $)->
  Backbone.View.extend {
    render: (collection,selectTpl)->
      console.log "Initializing...."
      dropdown = $("<div/>")
      dropdown.append template.selection()
      dropdownSelect = dropdown.find("select.selection.dropdown")

      @selectize = dropdownSelect.selectize({
        multi: false,
        maxItems: undefined,
        persist: false,
        create: false,
        openOnFocus: false,
        plugins: ['custom_selection']
        onInitialize: () ->
          value = @$input.attr('value')
          @setValue(value.split(','), true) if value
        render: {
          option: (item) ->
            tplName = @$input.data('select-tpl')
            if tplName and selectTpl and selectTpl[tplName]
              return selectTpl[tplName](item)
            else
              return '<div>' + item.text + '</div>'
        }
      })[0].selectize

      @selectize.addOption([{value: "www", text:"xxxxx"}, {value: "eee", text: "rrrrr"}])
      dropdown.find(".selectize-dropdown-content").after($(template.manageBtn()))
      @setElement(dropdown)
      @$el.find('.dropdown-list-btn').click =>
        @.trigger 'manage'
      @.$input = @selectize.$input
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


