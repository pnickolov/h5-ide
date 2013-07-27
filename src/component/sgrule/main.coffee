####################################
#  pop-up for component/sgrule module
####################################

define [ 'jquery', 'event' ], ( $, ide_event ) ->

    #private
    loadModule = ( line_id, delete_module ) ->

        #
        require [ './component/sgrule/view', './component/sgrule/model' ], ( View, Model ) ->

            #
            view  = new View()
            model = new Model()

            #view
            view.model    = model

            model.getSgRuleDetail line_id
            #
            view.on 'CLOSE_POPUP', () ->

                model.checkRuleExisting()

                unLoadModule view, model

            view.on 'ADD_SG_RULE', ( rule_data ) ->

                model.addSGRule rule_data

                ide_event.trigger ide_event.REDRAW_SG_LINE

            model.on 'DELETE_LINE', ( line_id ) ->

                ide_event.trigger ide_event.DELETE_LINE_TO_CANVAS, line_id

            view.on 'DELETE_SG_LINE', () ->

                this.model.deleteSGLine()
                
            #render
            if delete_module
                model.getDeleteSGList()
                view.renderDeleteModule()
            else
                view.render()

    unLoadModule = ( view, model ) ->
        console.log 'sgrule unLoadModule'
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
