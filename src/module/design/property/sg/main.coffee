####################################
#  Controller for design/property/sg module
####################################

define [ '../base/main', './model', './view' ], ( PropertyModule, model, view ) ->

    SgModule = PropertyModule.extend {

        subPanelID : "SG"

        setupStack : () ->
            me = this
            @view.on 'SET_SG_NAME', ( value ) ->
                me.model.setSGName value

            @view.on 'REMOVE_SG_RULE', ( rule )->
                me.model.removeSGRule  rule

            @view.on 'SET_SG_RULE', ( rule ) ->
                me.model.setSGRule rule

            @view.on 'SET_SG_DESC', ( value ) ->
                me.model.setSGDescription value

        initStack : () ->
            @model = model
            @model.isApp = false
            @view  = view
            null

        initApp : ()->
            @model = model
            @model.isApp = true
            @view  = view
            null
    }
    null
