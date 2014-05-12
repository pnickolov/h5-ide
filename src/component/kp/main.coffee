define [ './component/kp/view', './component/kp/model', 'constant' ], ( View, Model, constant ) ->


    # Private
    loadModule = ( resModel ) ->

        model = new Model resModel: resModel
        view  = new View model: model

        view.render()


    unLoadModule = ->

        view.remove()
        model.destroy()

    hasResourceWithDefaultKp = ->
        has = false
        Design.instance().eachComponent ( comp ) ->
            if comp.type in [ constant.RESTYPE.INSTANCE, constant.RESTYPE.LC ]
                if comp.isDefaultKey()
                    has = true
                    false

        has



    # Public
    loadModule                  : loadModule
    unLoadModule                : unLoadModule
    hasResourceWithDefaultKp    : hasResourceWithDefaultKp