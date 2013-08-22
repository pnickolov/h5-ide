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
        require [ './module/process/view', './module/process/model' ], ( view, model ) ->
            #
            view.model = model
            view.render()

            #test
            MC.ide_event = ide_event

            #listen
            ide_event.onLongListen ide_event.SWITCH_APP_PROCESS, ( tab_name ) ->
                console.log 'process:SWITCH_APP_PROCESS tab_name = ' + tab_name

                if tab_name.indexOf('process-') == 0
                    model.getProcess(tab_name)

                view.render()

            ide_event.onLongListen ide_event.UPDATE_PROCESS, ( tab_name ) ->
            #model.on 'UPDATE_PROCESS', () ->
                console.log 'UPDATE_PROCESS'

                if MC.data.current_tab_id is tab_name
                    model.getProcess tab_name

            model.on 'UPDATE_HEADER_AT_ONCE', () ->
                console.log 'UPDATE_HEADER_AT_ONCE'
                view.render()

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule