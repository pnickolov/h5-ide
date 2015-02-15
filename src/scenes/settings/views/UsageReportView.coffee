define [ 'backbone', "../template/TplBilling", "ApiRequestR", 'i18n!/nls/lang.js' ], (Backbone, template, ApiRequestR, lang) ->
    Backbone.View.extend {

        events:
            "click .usage-pagination .nav-left": "prevUsage"
            "click .usage-pagination .nav-right": "nextUsage"

        className: "usage-report-view"

        initialize: ->
            @$el.html template.billingLoadingFrame()
            @$el.find("#billing-status").html MC.template.loadingSpinner()
            @

        render : ()->
            self = @
            self.model.getPaymentState().then ->
                payment = self.model.get("payment")
                self.$el.find("#billing-status").html(template.usage {payment})
                self.renderUsageData()
            @

        getUsage: (date)->
            date ||= new Date()
            [startDate, endDate] = @getStartAndEnd(date)
            projectId = @model.get("id")
            startDate = @formatDate new Date(startDate)
            endDate = @formatDate new Date(endDate)
            ApiRequestR("payment_usage", {projectId, startDate, endDate})

        getStartAndEnd: (date)->
            date = new Date(date)
            month = date.getMonth()
            year = date.getFullYear()
            firstDay = new Date(year, month, 1)
            lastDay = new Date(year, month+1, -1)
            console.log firstDay.toLocaleString(), lastDay.toLocaleString()
            [firstDay, lastDay]

        renderUsageData: (dateString)->
            self = @
            dateString ||= now = new Date()
            self.$el.find(".table-head-fix").html $(MC.template.loadingSpinner()).css({"margin": "80px auto"})
            self.$el.find(".usage-pagination button").prop("disabled", true)
            @getUsage(dateString).then (result)->
                payment = self.model.get("payment")
                if not _.isEmpty result?.history_usage
                  project_id = self.model.get("id")
                  _.each result.history_usage, (value, key)->
                    delete result.history_usage[key]
                    key = key.replace("-"+project_id, "").replace("RDS-", "")
                    result.history_usage[key] = value
                  elem = template.usageTable {result}
                else
                  elem = "<div class='full-space'>#{lang.IDE.NO_USAGE_REPORT}</div>"
                self.$el.find(".table-head-fix").html elem
                date = self.formatDate2(dateString)
                self.$el.find(".usage-date").text(date.string).data("date", dateString)
                isDisabled = self.getNewDate(1) > new Date()
                self.$el.find(".nav-left").prop("disabled", false)
                self.$el.find(".nav-right").prop('disabled', isDisabled)
            ,()->
                notification 'error', "Error while getting user payment info, please try again later."
            @

        formatDate: (date)->
            year = date.getFullYear()
            month = date.getMonth() + 1
            if month < 10 then month = "0"+month
            day = date.getDate()
            if day < 10 then day = "0"+day
            hour = date.getHours()
            if hour < 10 then hour = "0"+hour
            "" + year + month + day + hour


        formatDate2: (date)->
            date = new Date(date)
            months = ["January"	,"February"	,"March" ,"April"	,"May" ,"June" ,"July" ,"August" ,"September" ,"October" ,"November" ,"December"]
            month = months[date.getMonth()%12]
            year = date.getFullYear()
            console.log(month, year)
            string = "#{month}, #{year}"
            return {string, date}

        getNewDate: (offset)->
            oldDate = new Date($(".usage-date").data("date"))
            year = oldDate.getFullYear()
            month = oldDate.getMonth() + offset
            new Date(year, month)

        nextUsage: ()->
            newDate = @getNewDate(1)
            @renderUsageData newDate

        prevUsage: ()->
            newDate = @getNewDate(-1)
            @renderUsageData newDate

    }
