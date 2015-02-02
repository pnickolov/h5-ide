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
                self.getPaymentState().then ->
                  payment = self.model.get("payment")
                  self.$el.find(".loading-spinner").replaceWith(template.usage {result, payment})
            , ()->
                notification 'error', "Error while getting user payment info, please try again later."
            @

        getUsage: (startDate = new Date() - 30*24*3600*1000, endDate = new Date())->
            projectId = @model.get("id")
            startDate = @formatDate new Date(startDate)
            endDate = @formatDate new Date(endDate)
            ApiRequestR("payment_usage", {projectId, startDate, endDate})

        getPaymentState: ()->
            defer = new Q.defer()
            self = @
            payment = @model.get("payment")
            if payment
                defer.resolve(payment)
            else
                @model.getPaymentState().then ()->
                  defer.resolve(self.model.get("payment"))
                , (err)->
                  defer.reject(err)
            defer.promise

        formatDate: (date)->
          year = date.getFullYear()
          month = date.getMonth() + 1
          if month < 10 then month = "0"+month
          day = date.getDate()
          if day < 10 then day = "0"+day
          hour = date.getHours()
          if hour < 10 then hour = "0"+hour
          console.log year, month, day
          "" + year + month + day + hour


    }