define [ '../base/view'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( PropertyView, Tpl, lang, constant ) ->

    view = PropertyView.extend

        events:

            'change #property-mesos-stack-name': 'changeName'

        initialize: ( options ) ->

        render: () ->

            @$el.html Tpl(@model.toJSON())
            @model.get('name')

        changeName: (event) ->

            value = $(event.currentTarget).val()
            @model.set('name', value)
            @setTitle(value)

    new view()
