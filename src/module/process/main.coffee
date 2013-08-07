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
            ide_event.onLongListen ide_event.SWITCH_APP_PROCESS, ( type, tab_name ) ->
                console.log 'process:SWITCH_APP_PROCESS, type = ' + type + ', tab_name = ' + tab_name

                model.getProcess(type, tab_name)

            model.on 'UPDATE_PROCESS', () ->
                console.log 'UPDATE_PROCESS'
                view.render()

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule