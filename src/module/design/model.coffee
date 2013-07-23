#############################
#  View Mode for design
#############################

define [ 'MC', 'event', 'backbone' ], ( MC, ide_event ) ->

    #private
    DesignModel = Backbone.Model.extend {

        defaults :
            snapshot : null

        saveTab : ( tab_id, snapshot, data, property, property_panel, last_open_property ) ->
            console.log 'saveTab'
            MC.tab[ tab_id ] = { 'snapshot' : snapshot, 'data' : data, 'property' : property, 'property_panel' : property_panel, 'last_open_property' : last_open_property }
            null

        readTab : ( type, tab_id ) ->
            console.log 'readTab'
            #set snapshot|data vo
            if MC.tab[ tab_id ].snapshot is this.get 'snapshot' then this.set 'snapshot', null
            #
            this.set 'snapshot',      MC.tab[ tab_id ].snapshot
            #
            this.setCanvasData        MC.tab[ tab_id ].data
            #
            this.setCanvasProperty    MC.tab[ tab_id ].property
            #
            this.setPropertyPanel     MC.tab[ tab_id ].property_panel
            #
            this.setLastOpenProperty  MC.tab[ tab_id ].last_open_property
            null

        updateTab : ( old_tab_id, tab_id ) ->
            console.log 'updateTab'
            if MC.tab[ old_tab_id ] is undefined then return
            #
            MC.tab[ tab_id ] = { 'snapshot' : MC.tab[ old_tab_id ].snapshot, 'data' : MC.tab[ old_tab_id ].data, 'property' : MC.tab[ old_tab_id ].property }
            #
            this.deleteTab old_tab_id

        deleteTab    : ( tab_id ) ->
            console.log 'deleteTab'
            delete MC.tab[ tab_id ]
            console.log MC.tab
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

        setPropertyPanel : ( property_panel ) ->
            console.log 'setPropertyPanel'
            MC.data.current_sub_main = property_panel
            null

        getPropertyPanel : () ->
            console.log 'getPropertyPanel'
            #temp
            MC.data.current_sub_main.unLoadModule()
            #
            MC.data.current_sub_main

        setLastOpenProperty : ( last_open_property ) ->
            console.log 'setLastOpenProperty'
            #
            MC.data.last_open_property = last_open_property
            #temp
            if !MC.data.last_open_property
                MC.data.last_open_property = { 'type' : 'component', 'uid' : '', 'instance_expended_id' : '' }
            #
            ide_event.trigger ide_event.OPEN_PROPERTY, MC.data.last_open_property.type, MC.data.last_open_property.uid, MC.data.last_open_property.instance_expended_id
            null

        getLastOpenProperty : () ->
            console.log 'getLastOpenProperty'
            MC.data.last_open_property
    }

    model = new DesignModel()

    return model