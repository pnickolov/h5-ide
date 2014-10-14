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
            @modelData = options.modelData if @isApp

        setTitle: ( title ) -> @$( 'h1' ).text title

        toggleUrlAndCodes: ->
            type = @model?.get( 'type' )
            visible = if type in [ 'PING', 'TCP' ] then false else true

            @$('[data-id="hm-urlpath"]').closest('section').toggle visible
            @$('[data-id="hm-expectedcodes"]').closest('section').toggle visible

        updateAttribute: ( e ) ->
            $target = $ e.currentTarget

            target = $target.data('target')

            OsPropertyView.call @, e
            @toggleUrlAndCodes() if target is 'type'

        render: ->
            if @isApp
                @$el.html TplApp @modelData
            else
                bindSelection(@$el, @selectTpl)
                @$el.html TplStack @getRenderData()

            @toggleUrlAndCodes() unless @isApp
            @


    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
        handleModes: [ 'stack', 'appedit' ]
    }
