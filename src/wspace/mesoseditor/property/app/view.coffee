#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( PropertyView, Tpl, lang, constant ) ->

    view = PropertyView.extend

        events:
            '': ''

        initialize: ( options ) ->


        render: () ->
            @$el.html Tpl @model.toJSON()
            @model.get 'name'


    new view()