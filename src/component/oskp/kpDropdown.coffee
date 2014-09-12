define ['Design', "CloudResources", "backbone", "component/oskp/template", 'underscore', 'jquery'], (Design, CloudResources, Backbone, template, _, $)->
  Backbone.View.extend {
    render: ->
      console.log "Initializing...."
      dropdown = $(template.selection())
      dropdownSelect = dropdown.find("select.selection.dropdown")
      console.log dropdownSelect
      selectize=dropdownSelect.selectize({
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
              return '<div>xxx-' + item.text + '</div>'

          item: (item) ->
            tplName = @$input.data('item-tpl')
            if tplName and selectTpl and selectTpl[tplName]
              return selectTpl[tplName](item)
            else
              return '<div>xxx-' + item.text + '</div>'
          button: () ->
            tplName = @$input.data('button-tpl')
            if tplName and selectTpl and selectTpl[tplName]
              return selectTpl[tplName]()
            else
              return null
        }
      })
      console.log selectize[0].selectize.$wrapper
      console.log dropdown
      dropdown = selectize[0].selectize.$wrapper
      @setElement(dropdown)
      @
  }


