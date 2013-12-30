####################################
#  pop-up for component/stateeditor module
####################################

define [ 'event', 'text!./component/stateeditor/modal.html', 'component/stateeditor/lib/data'], ( ide_event, template ) ->

    #private
    loadModule = ( data ) ->

        #
        require [ 'stateeditor_view', 'stateeditor_model' ], ( View, Model ) ->

            MC.forge.other.addSEList data

            editorDialogTpl = Handlebars.compile(template)

            modal editorDialogTpl({}), false

            model = new Model()
            view  = new View({
                model: model
            })

            view.model = model

            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            view.render()

    unLoadModule = ( view, model ) ->
        console.log 'state editor unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule