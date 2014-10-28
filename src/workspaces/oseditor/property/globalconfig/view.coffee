define [
    'constant'
    '../OsPropertyView'
    './stack'
    './app'

], ( constant, OsPropertyView, TplStack, TplApp ) ->

    OsPropertyView.extend {
        events:
            'change [data-target]': 'updateAttribute'

        render: ->
            template = switch
                when @mode() is 'app' then TplApp
                else TplStack

            @$el.html template @getRenderData()
            @

        mode: ->
            mod = Design.instance().mode()
            mod

        getTitle: ->
            if @mode() in [ 'app', 'appedit' ]
                'App Property'
            else
                'Stack Property'

    }, {
        handleTypes: [ 'globalconfig' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }
