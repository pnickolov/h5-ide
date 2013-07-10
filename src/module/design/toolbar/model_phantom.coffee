#############################
#  View Mode for design/toolbar
#############################

define [ 'MC', 'event', 'backbone' ], ( MC, ide_event ) ->

    #private
    ToolbarModel = Backbone.Model.extend {

        savePNG : ( tab_id, region_name ) ->
            console.log 'savePNG'
            #
            $.ajax {
                url  : 'http://localhost:3001/savepng',
                type : 'post',
                data : {
                    'usercode'   : $.cookie( 'usercode' ),
                    'session_id' : $.cookie( 'session_id' ),
                    'region'     : 'region_name',
                    'name'       : 'tab_id',
                    'thumbnail'  : true,
                    'screenshot' : 'http://localhost:3000/screenshot.html'
                },
                success : ( result ) ->
                    console.log 'phantom callback'
                    console.log result
                    if result.status is 'success'
                        #
                    else
                        #
            }

    }

    model = new ToolbarModel()

    return model