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

            model.on 'change:timeout_obj', () ->
                console.log 'change:timeout_obj'
                view.render type

            ide_event.onLongListen ide_event.SWITCH_PROCESS, ( state, tab_id ) ->
                console.log 'process:SWITCH_PROCESS', state, tab_id

                # get type
                type = MC.common.other.processType tab_id

                # call model method
                switch type
                    when 'appview'
                        obj = MC.common.other.getCacheMap tab_id
                        model.getVpcResourceService obj.region, obj.origin_id, state
                        model.getTimestamp state, tab_id
                    when 'process'
                        model.getProcess tab_id

                # view type
                view.render type

            ide_event.onLongListen ide_event.UPDATE_PROCESS, ( tab_id ) ->
                console.log 'UPDATE_PROCESS', tab_id

                if MC.common.other.isCurrentTab tab_id
                    model.getProcess tab_id

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule