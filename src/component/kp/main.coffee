define [ './component/kp/view', './component/kp/model' ], ( View, Model ) ->


    # Private
    loadModule = ( resModel ) ->

        model = new Model resModel: resModel
        view  = new View model: model

        view.render()


    unLoadModule = ->

        view.remove()
        model.destroy()



    # Public
    loadModule   : loadModule
    unLoadModule : unLoadModule
