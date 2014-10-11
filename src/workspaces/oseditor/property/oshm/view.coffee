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

        toggleUrlAndCodes: ( visible ) ->
            @$('[data-id="hm-urlpath"]').closest('section').toggle visible
            @$('[data-id="hm-expectedcodes"]').closest('section').toggle visible

        updateAttribute: ( e ) ->
            $target = $ e.currentTarget

            target = $target.data('target')
            val = $target.val()

            @toggleUrlAndCodes if ( target is 'type' ) and ( val in [ 'PING', 'TCP' ] ) then false else true
            OsPropertyView.call @, e

        render: ->
            if @isApp
                @$el.html TplApp @modelData
            else
                bindSelection(@$el, @selectTpl)
                @$el.html TplStack @getRenderData()

            @


    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
        handleModes: [ 'stack', 'appedit' ]
    }
