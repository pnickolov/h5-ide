####################################
#  pop-up for component/stackrun module
####################################

define [ 'jquery', 'event',
         'text!./template.html'
], ( $, ide_event, template ) ->

    #private
    loadModule = () ->

        #
        require [ './component/stackrun/view', './component/stackrun/model' ], ( View, Model ) ->

            #
            view  = new View()
            model = new Model()

            #view
            view.model    = model
            #
            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            #render
            view.render template

    unLoadModule = ( view, model ) ->
        console.log 'stack run unLoadModule'
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