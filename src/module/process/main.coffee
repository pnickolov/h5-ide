####################################
#  Controller for process module
####################################

define [ 'event' ], ( ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="process-tmpl">' + template + '</script>'

        #load remote html template
        #$( template ).appendTo '#header'

        #
        require [ 'process_view', 'process_model' ], ( view, model ) ->
            #
            view.model = model
            view.render()

            #test
            MC.ide_event = ide_event

            #listen
            ide_event.onLongListen ide_event.SWITCH_PROCESS, ( tab_id ) ->
                console.log 'process:SWITCH_PROCESS', tab_id

                type = tab_id.split '-'

                if type is 'process'
                    model.getProcess tab_id
                else if type is 'appview'
                    # TO DO
                else
                    console.log 'current tab id is ' + tab_id

                view.render type

            ide_event.onLongListen ide_event.UPDATE_PROCESS, ( tab_name ) ->
                console.log 'UPDATE_PROCESS'

                if MC.data.current_tab_id is tab_name
                    model.getProcess tab_name

            model.on 'change:flag_list', () ->
                console.log 'change:flag_list'
                view.render()

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule