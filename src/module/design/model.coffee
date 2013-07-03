#############################
#  View Mode for design
#############################

define [ 'MC', 'event', 'backbone' ], ( MC, ide_event ) ->

    #private
    DesignModel = Backbone.Model.extend {

        defaults :
            snapshot : null
            data     : null

        saveTab : ( tab_id, snapshot, data ) ->
            console.log 'saveTab'
            MC.tab[ tab_id ] = { 'snapshot' : snapshot, 'data' : data }
            null

        readTab : ( type, tab_id ) ->
            console.log 'readTab'
            if MC.tab[ tab_id ].snapshot is this.get 'snapshot' then this.set 'snapshot', null
            this.set 'snapshot', MC.tab[ tab_id ].snapshot
            this.set 'data',     MC.tab[ tab_id ].data
            null

    }

    model = new DesignModel()

    return model