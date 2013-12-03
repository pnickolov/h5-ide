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

                # tab id sample process-cs6dbvrc
                if MC.forge.other.getCacheMap( tab_id ) and MC.forge.other.getCacheMap( tab_id ).type is 'appview'
                    type = 'appview'

                # tab id sample process-us-west-1-untitled-112
                else if tab_id.split('-')[0] is 'process' and tab_id.split('-').length > 2
                    model.getProcess tab_id
                    type = 'process'

                else
                    type = null
                    console.log 'current tab id is ' + tab_id

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