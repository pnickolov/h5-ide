####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main', '../base/model', '../base/view', 'constant' ], ( PropertyModule, PropertyModel, PropertyView, constant ) ->

    MissingView = PropertyView.extend {
        render : () ->
            comp = Design.instance().component @model.get 'uid'
            if Design.instance().get('state') in ['Stopped', "Stopping" ] and comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
                @$el.html MC.template.missingAsgWhenStop asgName: comp.get 'name'
                return "#{comp.get 'name'} Deleted"

            else
                @$el.html MC.template.missingPropertyPanel()
                return "Resource Unavailable"
    }

    view  = new MissingView()

    m = PropertyModel.extend {
        init : ( uid ) ->
            @set 'uid', uid
    }

    model = new m()

    MissingModule = PropertyModule.extend {

        handleTypes : "Missing_Resource"

        initApp : () ->
            @model = model
            @view  = view
            null

        initAppEdit : ()->
            @model = model
            @view  = view
            null
    }
    null
