#############################
#  View(UI logic) for dialog
#############################

define [ 'event',
         './module/process/template',
         './module/process/appview_template',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template, appview_template ) ->

    ProcessView = Backbone.View.extend {

        el       : '#tab-content-process'

        template         : template
        appview_template : appview_template

        events:
            'click .btn-close-process'      : 'closeProcess'

        render   : ( type ) ->
            console.log 'process render', type
            if type is 'process'
                $( @el ).html @template @model.attributes
            else if type is 'appview'
                $( @el ).html @appview_template @model.attributes.timeout_obj

        closeProcess : ->
            console.log 'closeProcess'

            ide_event.trigger ide_event.CLOSE_DESIGN_TAB, MC.data.current_tab_id

    }

    processView = new ProcessView()

    return processView
