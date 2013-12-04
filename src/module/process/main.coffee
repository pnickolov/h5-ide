####################################
#  Controller for process module
####################################

define [ 'event' ], ( ide_event ) ->

    #private
    loadModule = () ->

        require [ 'process_view', 'process_model' ], ( view, model ) ->

            # set current type, include 'process' and 'appview'
            type = null

            # set model
            view.model = model

            model.on 'change:flag_list', () ->
                console.log 'change:flag_list'
                view.render type

            ide_event.onLongListen ide_event.SWITCH_PROCESS, ( state, tab_id ) ->
                console.log 'process:SWITCH_PROCESS', state, tab_id

                # get type
                type = MC.forge.other.processType tab_id

                # call model method
                switch type
                    when 'appview'
                        obj = MC.forge.other.getCacheMap tab_id
                        model.getVpcResourceService obj.region, obj.origin_tab_id
                    when 'process'
                        model.getProcess tab_id

                # view type
                view.render type

            ide_event.onLongListen ide_event.UPDATE_PROCESS, ( tab_name ) ->
                console.log 'UPDATE_PROCESS'

                if MC.data.current_tab_id is tab_name
                    model.getProcess tab_name

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule