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

                #### added by song, if the stack/app too old, unable to open ###
                # if type in [ 'OPEN_STACK', 'OPEN_APP' ]
                #     if MC.common.other.canvasData.get 'bad'
                #         notification 'error', lang.ide.IDE_MSG_ERR_OPEN_OLD_STACK_APP_TAB, true
                #         ide_event.trigger ide_event.SWITCH_MAIN
                #         ide_event.trigger ide_event.CLOSE_DESIGN_TAB, tab_name if tab_name
                #         return
                #### added by song, if the stack/app too old, unable to open ###

                # new stack
                #if type is 'NEW_STACK'
                #
                #    # create MC.canvas_data
                #    MC.common.other.canvasData.initSet 'id'       , result
                #    MC.common.other.canvasData.initSet 'name'     , tab_name
                #    MC.common.other.canvasData.initSet 'region'   , region_name
                #    MC.common.other.canvasData.initSet 'platform' , current_platform
                #    MC.common.other.canvasData.initSet 'version'  , '2014-02-17'
                #
                #    # platform is classic
                #    if current_platform is Design.TYPE.Classic or current_platform is Design.TYPE.DefaultVpc
                #        component = $.extend true, {}, MC.canvas.DESIGN_INIT_DATA
                #        layout    = MC.canvas.DESIGN_INIT_LAYOUT
                #
                #    # platform is vpc
                #    else
                #        component = $.extend true, {}, MC.canvas.DESIGN_INIT_DATA_VPC
                #        layout    = MC.canvas.DESIGN_INIT_LAYOUT_VPC
                #
                #    MC.common.other.canvasData.initSet 'component', component
                #    MC.common.other.canvasData.initSet 'layout'   , layout

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
