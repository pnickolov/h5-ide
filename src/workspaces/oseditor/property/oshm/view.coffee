define [
    'constant'
    '../OsPropertyView'
    './stack'
    './app'
    'CloudResources'
    'UI.selection'
], ( constant, OsPropertyView, TplStack, TplApp, CloudResources, bindSelection ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]": "updateAttribute"

        initialize: ( options ) ->
            @isApp = options.isApp

        setTitle: ( title ) -> @$( 'h1' ).text title

        render: ->
            if @isApp
                @$el.html TplApp @model.toJSON()
            else
                bindSelection(@$el, @selectTpl)
                @$el.html TplStack @model.toJSON()

            @


    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
        handleModes: [ 'stack', 'appedit' ]
    }
