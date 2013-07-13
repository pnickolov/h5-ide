####################################
#  Controller for design/property module
####################################

define [ 'jquery',
         'text!/module/design/property/template.html',
         'event',
         'constant',
         'MC'
], ( $, template, ide_event, constant, MC ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#property-panel'

        #compile partial template
        #MC.IDEcompile 'design-property', template_data, { '.accordion-item-data' : 'accordion-item-tmpl' }

        #
        require [ './module/design/property/view',
                  './module/design/property/model',
                  './module/design/property/instance/main',
                  './module/design/property/sg/main',
                  './module/design/property/stack/main',
                  './module/design/property/volume/main',
                  './module/design/property/elb/main'
        ], ( View, model, instance_main, sg_main, stack_main, volume_main, elb_main ) ->

            uid  = null
            type = null

            #view
            view  = new View { 'model' : model }
            view.render template

            #show stack property
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, () ->
                console.log 'property:RELOAD_RESOURCE'
                #check re-render
                view.reRender template
                #
                stack_main.loadModule()

            #listen OPEN_PROPERTY
            ide_event.onLongListen ide_event.OPEN_PROPERTY, ( uid ) ->
                console.log 'OPEN_PROPERTY, uid = ' + uid

                uid  = uid
                type = type

                #show stack property
                if uid is ''
                    stack_main.loadModule()

                #show instance property
                if MC.canvas_data.component[uid] and (MC.canvas_data.component[uid].type == constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance)
                    instance_main.loadModule uid

                #show vloume/snapshot property
                #volume_main.loadModule()

                #show elb property
                #elb_main.loadModule()

                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            #listen OPEN_SG
            ide_event.onLongListen ide_event.OPEN_SG, ( uid_parent ) ->
                console.log 'OPEN_SG'
                sg_main.loadModule( uid_parent )
                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            #listen OPEN_INSTANCE
            ide_event.onLongListen ide_event.OPEN_INSTANCE, () ->
                console.log 'OPEN_INSTANCE'
                #
                instance_main.loadModule uid, type
                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            ide_event.onLongListen ide_event.RELOAD_PROPERTY, () ->

                view.refresh()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule