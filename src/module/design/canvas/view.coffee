#############################
#  View(UI logic) for design/canvas
#############################

define [ 'text!./template.html', "event", "canvas_layout", 'MC.canvas', 'backbone', 'jquery' ], ( template, ide_event, canvas_layout ) ->
         'lib/forge/app',
         'stateeditor'
         'MC.canvas', 'backbone', 'jquery'
], ( ide_event, canvas_layout, constant, forge_app, stateeditor ) ->

    CanvasView = Backbone.View.extend {

        initialize : ->
            this.template = Handlebars.compile( template )()

            #listen
            this.listenTo ide_event, 'SWITCH_TAB', ()->
                canvas_layout.listen()

            this.listenTo ide_event, 'UPDATE_RESOURCE_STATE', ()->
                canvas_layout.listen()


        render : () ->
                .on( 'STATE_ICON_CLICKED',          '#svg_canvas', this.openStateEditor )
            console.log 'canvas render'
            $( '#canvas' ).html this.template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-canvas render'
            if $("#canvas").is(":empty") then $( '#canvas' ).html this.template
            null

            null

        openStateEditor : ( event, uid ) ->

            compObj = MC.canvas_data.component[uid]
            compType = compObj.type
            if compObj and compType in [constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration]
                stateeditor.loadModule(MC.canvas_data, uid)
    }

    return CanvasView
