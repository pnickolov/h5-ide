#############################
#  View(UI logic) for design/canvas
#############################

define [ 'text!./template.html', "event", "constant", "canvas_layout", 'stateeditor', 'MC.canvas', 'backbone', 'jquery' ], ( template, ide_event, constant, canvas_layout, stateeditor ) ->

    CanvasView = Backbone.View.extend {

        initialize : ->
            this.template = Handlebars.compile( template )()

            #listen
            this.listenTo ide_event, 'SWITCH_TAB', ()->
                canvas_layout.listen()

            this.listenTo ide_event, 'UPDATE_RESOURCE_STATE', ()->
                canvas_layout.listen()


        render : () ->

            console.log 'canvas render'
            $( '#canvas' ).html this.template
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            
            console.log 're-canvas render'
            if $("#canvas").is(":empty") then $( '#canvas' ).html this.template

            $("#svg_canvas").on( 'STATE_ICON_CLICKED', this.openStateEditor)

            null

        openStateEditor : ( event, uid ) ->

            allCompData = Design.instance().serialize().component
            compData = allCompData[uid]
            if compData and compData.type in [constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration]
                stateeditor.loadModule(allCompData, uid)
    }

    return CanvasView
