define [ '../base/view'
         './container'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( PropertyView, Container, Tpl, lang, constant ) ->

    view = PropertyView.extend

        events:
            'click .open-container': 'openContainer'

        initialize: ( options ) ->

        openContainer: ()->
            @container = new Container( model: @model ).render()

        render: () ->
            @$el.html Tpl @model.toJSON()
            @model.get 'name'


    new view()