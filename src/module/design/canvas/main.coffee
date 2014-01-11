####################################
#  Controller for design/canvas module
####################################

define [ 'event', 'MC', 'i18n!nls/lang.js' ], (ide_event, MC, lang ) ->

    #private
    loadModule = () ->

        #
        require [ './module/design/canvas/view',
                  './module/design/canvas/model'
        ], ( View, model ) ->

            #view
            view = new View()
            view.render()

            #listen OPEN_DESIGN
            # when 'NEW_STACK' result is tab_id
            # when Tabbar.current is 'appview' result is result
            ide_event.onLongListen ide_event.OPEN_DESIGN, ( region_name, type, current_platform, tab_name, result ) ->
                console.log 'canvas:OPEN_DESIGN', region_name, type, current_platform, tab_name, result

                try
                    #check re-render
                    view.reRender()

                    #### added by song, if the stack/app too old, unable to open ###
                    if type in [ 'OPEN_STACK', 'OPEN_APP' ]
                        if MC.forge.other.canvasData.get 'bad'
                            notification 'error', lang.ide.IDE_MSG_ERR_OPEN_OLD_STACK_APP_TAB, true
                            ide_event.trigger ide_event.SWITCH_MAIN
                            ide_event.trigger ide_event.CLOSE_DESIGN_TAB, tab_name if tab_name
                            return
                    #### added by song, if the stack/app too old, unable to open ###

                    # new stack
                    if type is 'NEW_STACK'

                        # create MC.canvas_data
                        MC.forge.other.canvasData.set 'id'       , result
                        MC.forge.other.canvasData.set 'name'     , tab_name
                        MC.forge.other.canvasData.set 'region'   , region_name
                        MC.forge.other.canvasData.set 'platform' , current_platform
                        MC.forge.other.canvasData.set 'version'  , '2013-09-04'

                        # platform is classic
                        if current_platform is Design.TYPE.Classic or current_platform is Design.TYPE.DefaultVpc
                            component = $.extend true, {}, MC.canvas.DESIGN_INIT_DATA
                            layout    = MC.canvas.DESIGN_INIT_LAYOUT

                        # platform is vpc
                        else
                            component = $.extend true, {}, MC.canvas.DESIGN_INIT_DATA_VPC
                            layout    = MC.canvas.DESIGN_INIT_LAYOUT_VPC

                        MC.forge.other.canvasData.set 'component', component
                        MC.forge.other.canvasData.set 'layout'   , layout

                    # init options
                    options =
                        mode : if Tabbar.current is 'new' then Design.MODE.Stack else Tabbar.current

                    # resource import
                    if Tabbar.current is 'appview'

                        # set MC.canvas_data
                        MC.forge.other.canvasData.init result.resolved_data[0]

                        # set autoFinish = false
                        options.autoFinish = false

                        # set svg
                        MC.canvas.layout.init()

                        # create Design object
                        dd = new Design MC.forge.other.canvasData.data(true), options

                        # set ami layout
                        MC.aws.ami.setLayout MC.forge.other.canvasData.data(true)

                        # set analysis
                        MC.canvas.analysis()

                        # init Design
                        dd.finishDeserialization()

                    # 'NEW_STACK', 'OPEN_STACK', 'OPEN_APP' without 'appview'
                    else

                        # set svg
                        MC.canvas.layout.init()

                        # create Design object
                        new Design MC.forge.other.canvasData.data(true), options

                        # old design flow
                        MC.forge.other.canvasData.origin MC.forge.other.canvasData.data()

                        # init ta
                        MC.ta.list = []

                catch error
                    console.error error

                null

            #listen RESTORE_CANVAS
            ide_event.onLongListen ide_event.RESTORE_CANVAS, () ->
                console.log 'RESTORE_CANVAS'

                view.render()

                # old design flow +++++++++++++++++++++++++++
                #MC.canvas_data = $.extend( true, {}, MC.data.origin_canvas_data )
                #redraw
                #MC.canvas.layout.init()
                #re set
                #update instance icon of app
                #MC.aws.instance.updateStateIcon MC.canvas_data.id
                #MC.aws.asg.updateASGCount MC.canvas_data.id
                #MC.aws.eni.updateServerGroupState MC.canvas_data.id
                #update deleted resource style
                #MC.forge.app.updateDeletedResourceState MC.canvas_data
                # old design flow +++++++++++++++++++++++++++

                # new design flow +++++++++++++++++++++++++++

                # restore origin_canvas_data to MC.canvas_data
                #MC.forge.other.canvasData.init MC.forge.other.canvasData.origin()

                # set options component layout
                options    =
                    mode   : Tabbar.current

                # create Design
                MC.canvas.layout.init()

                # create Design object
                new Design( MC.forge.other.canvasData.data(), options )

                # new design flow +++++++++++++++++++++++++++

                # old design flow
                #MC.data.origin_canvas_data = $.extend( true, {}, MC.canvas_data )

                # new design flow
                MC.forge.other.canvasData.origin MC.forge.other.canvasData.data()

                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
