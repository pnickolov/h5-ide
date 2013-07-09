#############################
#  View Mode for design
#############################

define [ 'MC', 'event', 'backbone' ], ( MC, ide_event ) ->

    #private
    DesignModel = Backbone.Model.extend {

        defaults :
            snapshot : null

        saveTab : ( tab_id, snapshot, data, property ) ->
            console.log 'saveTab'
            MC.tab[ tab_id ] = { 'snapshot' : snapshot, 'data' : data, 'property' : property }
            null

        readTab : ( type, tab_id ) ->
            console.log 'readTab'
            #set snapshot|data vo
            if MC.tab[ tab_id ].snapshot is this.get 'snapshot' then this.set 'snapshot', null
            this.set 'snapshot', MC.tab[ tab_id ].snapshot
            #set MC.canvas_data
            this.setCanvasData MC.tab[ tab_id ].data
            #set MC.canvas_property
            this.setCanvasProperty MC.tab[ tab_id ].property
            null

        setCanvasData : ( data ) ->
            console.log 'setCanvasData'
            MC.canvas_data = data
            null

        getCanvasData : () ->
            console.log 'getCanvasData'
            MC.canvas_data

        setCanvasProperty : ( property ) ->
            console.log 'setCanvasProperty'
            MC.canvas_property = property
            null

        getCanvasProperty : () ->
            console.log 'getCanvasProperty'
            MC.canvas_property

    }

    model = new DesignModel()

    return model