define [ '../base/view'
         './template'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( PropertyView, Tpl, lang, constant ) ->

    view = PropertyView.extend

        initialize: ( options ) ->

        render: () ->

            beforeComp = @model.port1Comp()
            afterComp = @model.port2Comp()

            @$el.html Tpl.stack({
                before: beforeComp.get('name')
                after: afterComp.get('name')
            })

            return 'Dependency'

    new view()
