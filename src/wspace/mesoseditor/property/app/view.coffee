define [ '../base/view'
         './container'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( PropertyView, Container, Tpl, lang, constant ) ->

    view = PropertyView.extend

        events:
            '': ''

        initialize: ( options ) ->


        render: () ->
            @$el.html Tpl @model.toJSON()
            new Container( model: @model ).render()
            @model.get 'name'


    new view()