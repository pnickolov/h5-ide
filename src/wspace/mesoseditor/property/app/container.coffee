define [ './template/container'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( Tpl, lang, constant, Modal ) ->

    Backbone.View.extend
        id: 'modal-option-group'
        events:
            '': ''

        initialize: ( options ) ->
            modalOptions =
                template        : @el
                title           : 'Container Settings'
                width           : '855px'
                height          : '473px'
                compact         : true
                mode            : 'panel'
                confirm         :
                    text        : 'Save'

            @modal = new Modal modalOptions

        render: () ->
            @$el.html Tpl @model.toJSON()
            @model.get 'name'



