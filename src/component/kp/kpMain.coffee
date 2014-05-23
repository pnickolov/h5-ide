define [ './component/kp/kpView', './component/kp/kpModel', 'constant' ], ( View, Model, constant ) ->


    # Private
    load = ( resModel ) ->

        model = new Model resModel: resModel
        view  = new View model: model

        view.render()


    unload = ->

        view.remove()
        model.destroy()

    hasResourceWithDefaultKp = ->
        has = false
        Design.instance().eachComponent ( comp ) ->
            if comp.type in [ constant.RESTYPE.INSTANCE, constant.RESTYPE.LC ]
                if comp.isDefaultKey() and not comp.get( 'appId' )
                    has = true
                    false

        has



    # Public
    load                        : load
    unload                      : unload
    hasResourceWithDefaultKp    : hasResourceWithDefaultKp