
define [
    'backbone'
    'constant'
    'Design'
    '../../property/OsPropertyView'
    '../../property/OsPropertyBundle'
    './template/TplPropertyPanel'
    'selectize'
], ( Backbone, constant, Design, OsPropertyView, OsPropertyBundle, PropertyPanelTpl )->

  Backbone.View.extend

    events:

      "click .option-group-head" : "updateRightPanelOption"

    initialize: ( options ) ->

        @options = options
        @mode = Design.instance().mode()
        @uid  = options.uid
        @type = options.type

        @model      = Design.instance().component @uid
        @viewClass  = OsPropertyView.getClass( @mode, @type ) or OsPropertyView.getClass( @mode, 'default' )


    render: () ->

        that = @

        propertyView = @propertyView = new @viewClass( model: @model )

        @setTitle()
        @$el.append propertyView.render().el
        @restoreAccordion(@model?.type, @uid)
        @$el.find('select.value').each ->
            that.bindSelection($(@), propertyView.selectTpl)

        @

    setTitle: ( title = @propertyView.getTitle() ) ->
        unless title then return

        $title = @$ 'h1'

        if $title.size()
            $title.eq(0).text title
        else
            @$el.html PropertyPanelTpl.title { title: title }


    updateRightPanelOption : ( event ) ->
      $toggle = $(event.currentTarget)

      if $toggle.is("button") or $toggle.is("a") then return

      hide    = $toggle.hasClass("expand")
      $target = $toggle.next()

      if hide
        $target.css("display", "block").slideUp(200)
      else
        $target.slideDown(200)
      $toggle.toggleClass("expand")

      if not $toggle.parents(".panel-body").length then return

      @__optionStates = @__optionStates || {}

      # added by song ######################################
      # record head state
      comp = @uid || "Stack"
      status = _.map @$el.find('.panel-body').find('.option-group-head'), ( el )-> $(el).hasClass("expand")
      @__optionStates[ comp ] = status

      comp = Design.instance().component( comp )
      console.log comp
      if comp then @__optionStates[ comp.type ] = status
      # added by song ######################################

      return false

    restoreAccordion : ( type, uid )->
      console.log type, uid
      if not @__optionStates then return
      states = @__optionStates[ uid ]
      if not states then states = @__optionStates[ type ]
      if states
        for el, idx in @$el.find('.property-first-panel').find('.option-group-head')
          $(el).toggleClass("expand", states[idx])

        for uid, states of @__optionStates
          if not uid or Design.instance().component( uid ) or uid.indexOf("i-") is 0 or uid is "Stack"
            continue
          delete @__optionStates[ uid ]
      return

    bindSelection: ($valueDom, selectTpl) ->

        return if (not $valueDom or not $valueDom.length)

        if not $valueDom.hasClass('selectized')

            mutil = false
            maxItems = undefined
            if $valueDom.hasClass('mutil')
                mutil = true
                maxItems = null

            if $valueDom.hasClass('bool')

                $valueDom.selectize({
                    multi: mutil,
                    maxItems: maxItems,
                    persist: false,
                    valueField: 'value',
                    labelField: 'text',
                    searchField: ['text'],
                    create: false,
                    openOnFocus: false,
                    plugins: ['custom_selection'],
                    onInitialize: () ->
                        value = @$input.attr('value')
                        @setValue(value.split(','), true) if value
                        $valueDom.trigger 'selectized', @
                    options: [
                        {text: 'True', value: 'true'},
                        {text: 'False', value: 'false'}
                    ],
                    render: {
                        option: (item) ->
                            return '<div>O ' + item.text + '</div>'
                        item: (item) ->
                            return '<div>O ' + item.text + '</div>'
                    }
                })

            if $valueDom.hasClass('option')

                $valueDom.selectize({
                    multi: mutil,
                    maxItems: maxItems,
                    persist: false,
                    create: false,
                    openOnFocus: false,
                    plugins: ['custom_selection']
                    onInitialize: () ->
                        value = @$input.attr('value')
                        @setValue(value.split(','), true) if value
                        $valueDom.trigger 'selectized', @
                    render: {
                        option: (item) ->
                            tplName = @$input.data('select-tpl')
                            if tplName and selectTpl and selectTpl[tplName]
                                return selectTpl[tplName](item)
                            else
                                return '<div>' + item.text + '</div>'

                        item: (item) ->
                            tplName = @$input.data('item-tpl')
                            if tplName and selectTpl and selectTpl[tplName]
                                return selectTpl[tplName](item)
                            else
                                return '<div>' + item.text + '</div>'
                        button: () ->
                            tplName = @$input.data('button-tpl')
                            if tplName and selectTpl and selectTpl[tplName]
                                return selectTpl[tplName]()
                            else
                                return null
                    }
                })
