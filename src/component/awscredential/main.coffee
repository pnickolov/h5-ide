####################################
#  pop-up for component/awscredential module
####################################

define [ 'jquery', 'event',
         'text!/component/awscredential/template.html'
], ( $, ide_event, template ) ->

    #private
    loadModule = () ->

        #
        require [ './component/awscredential/view', './component/awscredential/model' ], ( View, Model ) ->

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
        console.log 'awscredential unLoadModule'
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