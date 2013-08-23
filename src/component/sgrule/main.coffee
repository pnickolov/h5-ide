####################################
#  pop-up for component/sgrule module
####################################

define [ 'event', './view', './model' ], ( ide_event, View, Model ) ->

    #private
    loadModule = ( line_id, delete_module ) ->

        view  = new View()
        model = new Model()

        #view
        view.model = model

        model.getSgRuleDetail line_id
        #

        view.on 'CLOSE_POPUP', () ->

            model.checkRuleExisting()

            line = model.getCurrentLineId()

            MC.canvas.select(line)

            unLoadModule view, model

        view.on 'ADD_RULE', ( rule_data ) ->

            model.addSGRule rule_data

            ide_event.trigger ide_event.REDRAW_SG_LINE

        model.on 'DELETE_LINE', ( line_id ) ->

            ide_event.trigger ide_event.DELETE_LINE_TO_CANVAS, line_id

        view.on 'DELETE_SG_LINE', () ->

            this.model.deleteSGLine()

            ide_event.trigger ide_event.REDRAW_SG_LINE

            $('#svg_canvas').trigger('CANVAS_NODE_SELECTED', '')

        view.on 'DELETE_RULE', ( rule_id ) ->

            this.model.deleteSGRule(rule_id)

            ide_event.trigger ide_event.REDRAW_SG_LINE


        view.on 'UPDATE_SLIDE_BAR', () ->

            model.getDispSGList line_id

            view.updateSidebar()

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
