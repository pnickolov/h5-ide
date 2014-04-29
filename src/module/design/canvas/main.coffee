####################################
#  Controller for design/canvas module
####################################

define [ 'event', 'i18n!nls/lang.js', 'constant' ], ( ide_event, lang, constant ) ->

    #private
    loadModule = () ->

        #
        require [ './module/design/canvas/view' ], ( View ) ->

            #view
            view = new View()
            view.render()

            #listen CREATE_DESIGN_OBJ
            # when 'NEW_STACK' result is tab_id
            # when Tabbar.current is 'appview' result is result
            ide_event.onLongListen ide_event.CREATE_DESIGN_OBJ, ( region_name, type, current_platform, tab_name, result ) ->
                console.log 'canvas:CREATE_DESIGN_OBJ', region_name, type, current_platform, tab_name, result

                #check re-render
                view.reRender()

                # init options
                options =
                    mode : if Tabbar.current is 'new' then Design.MODE.Stack else Tabbar.current

                # resource import
                if Tabbar.current is 'appview'

                    # set MC.canvas_data
                    MC.common.other.canvasData.init result.resolved_data[0]

                    # set autoFinish = false
                    options.autoFinish = false

                    # set svg
                    MC.canvas.layout.init()

                    # create Design object
                    dd = new Design MC.common.other.canvasData.data(true), options
                    console.log 'new Design Create Complete'

                    # set analysis
                    MC.canvas.analysis()

                    # init Design
                    dd.finishDeserialization()

                # 'NEW_STACK', 'OPEN_STACK', 'OPEN_APP' without 'appview'
                else

                    # set svg
                    MC.canvas.layout.init()

                    # create Design object
                    new Design MC.common.other.canvasData.data(true), options
                    console.log 'new Design Create Complete'

                    if type is 'NEW_STACK'
                        MC.aws.aws.enableStackAgent(true)

                    # old design flow
                    MC.common.other.canvasData.origin MC.common.other.canvasData.data()

                    # init ta
                    MC.ta.list = []

                # open sub design
                ide_event.trigger ide_event.OPEN_SUB_DESIGN, region_name, type, current_platform, tab_name, result

                null

            #listen RESTORE_CANVAS
            ide_event.onLongListen ide_event.RESTORE_CANVAS, () ->
                console.log 'RESTORE_CANVAS'

                # re render
                view.render()

                # set options component layout
                options    =
                    mode   : Tabbar.current

                # create Design
                MC.canvas.layout.init()

                # create Design object
                new Design( MC.common.other.canvasData.origin(), options )
                console.log 'new Design Create Complete'

                # new design flow
                MC.common.other.canvasData.origin MC.common.other.canvasData.data()

                null

            ide_event.onLongListen ide_event.UPDATE_APP_STATE, ( type, id ) ->
                console.log 'canvas:UPDATE_APP_STATE', type, id

                # include XXXING
                if type in [ constant.APP_STATE.APP_STATE_STARTING, constant.APP_STATE.APP_STATE_STOPPING, constant.APP_STATE.APP_STATE_TERMINATING, constant.APP_STATE.APP_STATE_UPDATING ]

                    if MC.common.other.isCurrentTab id
                        MC.common.other.canvasData.set 'state', type
                    else
                        # TO DO

                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
