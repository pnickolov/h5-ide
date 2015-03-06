define [ '../base/view'
         './template'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( PropertyView, Tpl, lang, constant ) ->

    view = PropertyView.extend

        events:

            'change #property-mesos-stack-name': 'changeName'

        initialize: ( options ) ->

        render: () ->

            if @mode is 'stack'
                @$el.html Tpl.stack(@model.toJSON())
            else
                @$el.html Tpl.app()
            @model.get('name')

        changeName: (event) ->

            value = $(event.currentTarget).val()
            @model.set('name', value)
            @setTitle(value)

    new view()
