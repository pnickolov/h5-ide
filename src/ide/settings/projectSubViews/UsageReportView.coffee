define [ 'backbone', "../template/TplBilling" ], (Backbone, template) ->
    Backbone.View.extend {

        className: "usage-report-view"

        initialize: ->
            @$el.html template.billingLoadingFrame()
            @$el.find("#billing-status").html MC.template.loadingSpinner()
            @

        render : ()->
            self = @
            _.delay ->
                self.$el.find(".loading-spinner").replaceWith(template.usage())
            , 500
            @
    }