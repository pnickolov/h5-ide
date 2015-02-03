define [ 'backbone', "../template/TplBilling", "ApiRequestR" ], (Backbone, template, ApiRequestR) ->
    Backbone.View.extend {

        className: "usage-report-view"

        initialize: ->
            @$el.html template.billingLoadingFrame()
            @$el.find("#billing-status").html MC.template.loadingSpinner()
            @

        render : ()->
            self = @
            self.getPaymentState().then ->
                payment = self.model.get("payment")
                self.$el.html(template.usage {payment})
                self.$el.find(".full-space").html $(MC.template.loadingSpinner()).css({"margin": "80px auto"})
                #self.renderUsageData()
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

        getStartAndEnd: (date)->
            date = new Date(date)
            month = date.getMonth()
            year = date.getFullYear()
            firstDay = new Date(year, month, 1)
            lastDay = new Date(year, month+1, -1)
            console.log firstDay.toLocaleString(), lastDay.toLocaleString()
            [firstDay, lastDay]

        formatDate: (date)->
            year = date.getFullYear()
            month = date.getMonth() + 1
            if month < 10 then month = "0"+month
            day = date.getDate()
            if day < 10 then day = "0"+day
            hour = date.getHours()
            if hour < 10 then hour = "0"+hour
            "" + year + month + day + hour


        renderUsageData: ()->
            self = @
            @getUsage().then (result)->
                payment = self.model.get("payment")
                self.$el.find(".full-space").html(template.usageTable {result})
                self.$el.find(".usage-date").text self.formatDate2().string
            ,()->
                notification 'error', "Error while getting user payment info, please try again later."
            @

        formatDate2: (date)->
            date = new Date(date);
            months = ["January"	,"February"	,"March" ,"April"	,"May" ,"June" ,"July" ,"August" ,"September" ,"October" ,"November" ,"December"]
            month = months[date%12]
            year = date.getFullYear()
            console.log(month, year)
            string = "#{month}, #{year}"
            return {string, date}


    }