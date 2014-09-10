
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

        null

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
