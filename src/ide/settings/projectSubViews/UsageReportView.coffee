define [ 'backbone', "../template/TplBilling", "ApiRequestR" ], (Backbone, template, ApiRequestR) ->
    Backbone.View.extend {

        className: "usage-report-view"

        initialize: ->
            @$el.html template.billingLoadingFrame()
            @$el.find("#billing-status").html MC.template.loadingSpinner()
            @

        render : ()->
            self = @
            @getUsage().then (result)->
                console.log result
                self.$el.find(".loading-spinner").replaceWith(template.usage())
            , ()->
                notification 'error', "Error while getting user payment info, please try again later."
            @

        getUsage: ()->
            projectId = @model.get("id")
            ApiRequestR("payment_usage", {projectId})

    }