####################################
#  Controller for navigation module
####################################

define [ 'jquery',
         'text!./module/navigation/template.html',
         'text!./module/navigation/template_data.html',
         './module/navigation/model.js',
         'event',
         'MC.ide.template'
], ( $, template, template_data, model, ide_event ) ->

    #private
    loadModule = () ->

        #compile partial template
        MC.IDEcompile 'nav', template_data, { '.app-list-data' : 'nav-app-list-tmpl', '.stack-list-data' : 'nav-stack-list-tmpl', '.region-empty-list' : 'nav-region-empty-list-tmpl', '.region-list' : 'nav-region-list-tmpl' }

        #load remote /module/navigation/view.js
        require [ './module/navigation/view', 'UI.tooltip', 'hoverIntent' ], ( View ) ->

            #view
            view       = new View()
            view.model = model
            #refresh view
            view.render template

            #listen vo set change event
            model.on 'change:app_list', () ->
                console.log 'change:app_list'
                #push event
                ide_event.trigger ide_event.RESULT_APP_LIST, model.get 'app_list'
                #refresh view
                view.appListRender()
                #call
                model.stackListService()

            model.on 'change:stack_list', () ->
                console.log 'change:stack_list'
                #push event
                ide_event.trigger ide_event.RESULT_STACK_LIST, model.get 'stack_list'
                #refresh view
                view.stackListRender()
                #call
                model.regionEmptyList()

            model.on 'change:region_empty_list', () ->
                console.log 'change:region_empty_list'
                #push event
                ide_event.trigger ide_event.RESULT_EMPTY_REGION_LIST, null
                #refresh view
                view.regionEmtpyListRender()
                #call
                model.describeRegionsService()

            model.on 'change:region_list', () ->
                console.log 'change:region_list'
                #refresh view
                view.regionListRender()

            #model
            model.appListService()

            ide_event.onLongListen ide_event.UPDATE_APP_LIST, () ->
                console.log 'UPDATE_APP_LIST'
                #call
                model.appListService()

            ide_event.onLongListen ide_event.UPDATE_STACK_LIST, () ->
                console.log 'UPDATE_STACK_LIST'
                #call
                model.stackListService()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
