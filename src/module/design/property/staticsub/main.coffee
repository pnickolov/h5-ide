####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main',
         './model',
         './view',
         "event",
         "Design"
], ( PropertyModule, model, view, ide_event, Design ) ->

    view.on "AMI_CHANGE", ()->
        component = Design.instance().component( PropertyModule.activeModule().uid )
        ide_event.trigger ide_event.OPEN_PROPERTY, component.type, component.id
        null


    StaticSubModule = PropertyModule.extend {

        subPanelID : "STATIC"

        initStack : ()->
            @model = model
            @view  = view
            @model.isApp = false
            null

        initApp : () ->
            @model = model
            @view  = view
            @model.isApp = true
            null

        initAppEdit : () ->
            @model = model
            @view  = view
            @model.isApp = true
            null
    }
    null
