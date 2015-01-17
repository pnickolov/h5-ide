#./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus", "ApiRequestR", "backbone"
define [ 'backbone', "../template/TplBilling", 'i18n!/nls/lang.js', "ApiRequest", "ApiRequestR" ], (Backbone, template, lang, ApiRequest, ApiRequestR ) ->
    Backbone.View.extend {
        events :
            "click #PaymentNav span"              : "switchTab"
            'click #PaymentBody a.payment-receipt': "viewPaymentReceipt"
            'click .update-payment'               : "_bindPaymentEvent"

        className: "billing-view"

        initialize: ->
            @$el.html template.billingLoadingFrame()
            @$el.find("#billing-status").append MC.template.loadingSpiner()
            @
        render : ()->
            that = @
            paymentState = App.user.get("paymentState")
            @getPaymentHistory().then (paymentHistory)->
                console.log paymentHistory
                paymentUpdate = {
                    url: App.user.get("paymentUrl")
                    card: App.user.get("creditCard")
                    billingEnd: App.user.get("billingEnd")
                    current_quota: App.user.get("voQuotaCurrent")
                    max_quota:  App.user.get("voQuotaPerMonth")
                    renewRemainDays: Math.round( (App.user.get("renewDate") - ( new Date() ))/(1000*60*60*24) )
                    last_billing_time: App.user.get("billingStart") || new Date()
                }
                billable_quota = App.user.get("voQuotaCurrent") - App.user.get("voQuotaPerMonth")
                paymentUpdate.billable_quota = if billable_quota > 0 then billable_quota else 0

                hasPaymentHistory = (_.keys paymentHistory).length
                tempArray = []
                _.each paymentHistory, (e)->
                    e.ending_balance = e.ending_balance_in_cents/100
                    e.total_balance = e.total_in_cents / 100
                    e.start_balance = e.starting_balance_in_cents / 100
                    tempArray.push(e)
                tempArray.reverse()
                paymentHistory = tempArray
                that.paymentHistory = tempArray
                that.paymentUpdate = _.clone paymentUpdate
                billingTemplate = template.billingTemplate {paymentUpdate, paymentHistory, hasPaymentHistory}
                that.$el.find(".loading-spinner").remove()
                that.$el.find("#billing-status").append billingTemplate
                unless true # todo: App.user.get("creditCard")
                    that.$el.find("#PaymentBillingTab").html(MC.template.paymentSubscribe {url: App.user.get("paymentUrl"), freePointsPerMonth: App.user.get("voQuotaPerMonth"), shouldPay: false}) #todo: App.user.shouldPay()
                    that.listenTo App.user, "paymentUpdate", ->
                        that.stopListening(App.user)
                        that.updateUsage()
                that.updateUsage()
            , ()->
                notification 'error', "Error while getting user payment info, please try again later."

            @listenTo App.user, "paymentUpdate", -> that.updateUsage()
            @$el

        getPaymentHistory: ()->
            historyDefer = new Q.defer()
            unless App.user.get("creditCard")
                historyDefer.resolve({})
            else
                ApiRequestR("payment_statement").then (paymentHistory)->
                    historyDefer.resolve(paymentHistory)
                , (err)->
                    historyDefer.reject(err)
            historyDefer.promise

        switchTab: (event)->
            target = $(event.currentTarget)
            console.log "Switching Tabs"
            @$el.find("#PaymentNav").find("span").removeClass("selected")
            @$el.find(".tabContent > section").addClass("hide")
            $("#"+ target.addClass("selected").data('target')).removeClass("hide")
            @updateUsage()

        _bindPaymentEvent: (event)->
            that = @
            event.preventDefault()
            window.open $(event.currentTarget).attr("href"), ""
            @listenTo App.user, 'change:paymentState', ->
                paymentState = App.user.get 'paymentState'
                if paymentState is 'active'
                    that._renderBillingDialog()
            return false

        _renderBillingDialog: ()->
            new BillingDialog()

        updateUsage: ()->
            shouldPay = false
            @$el.find(".usage-block").toggleClass("error", shouldPay)
            @$el.find(".used-points").toggleClass("error", shouldPay)

            current_quota = App.user.get("voQuotaCurrent")

            @$el.find(".payment-number").text(App.user.get("creditCard") || "No Card")
            @$el.find(".payment-username").text("#{App.user.get("cardFirstName")} #{App.user.get("cardLastName")}")
            @$el.find(".used-points .usage-number").text(current_quota)

            if false # todo: App.user.shouldPay()
                @$el.find(".warning-red").not(".no-change").show().html sprintf lang.IDE.PAYMENT_PROVIDE_UPDATE_CREDITCARD,  App.user.get("paymentUrl"), (if App.user.get("creditCard") then "Update" else "Provide")
            else if false # todo： App.user.isUnpaid()
                @$el.find(".warning-red").not(".no-change").show().html sprintf lang.IDE.PAYMENT_UNPAID_BUT_IN_FREE_QUOTA, App.user.get("paymentUrl")
            else
                @$el.find(".warning-red").not(".no-change").hide()


        viewPaymentReceipt: (event)->
            $target = $(event.currentTarget)
            id = $target.parent().parent().data("id")
            paymentHistory = @paymentHistory[id]
            cssToInsert = """
                .billing_statement_section {
                    display: block;
                    position: relative;
                }
                .billing_statement_section h2 {
                    display: block;
                    background: #E6E6E6;
                    font-size: 16px;
                    padding: 10px;
                    font-weight: bold;
                    margin-bottom: 0;
                    border-bottom: 1px solid #727272;
                }
                .billing_statement_section_content {
                    display: block;
                    position: relative;
                    padding-top: 10px;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                }
                table, td, th {
                    border: 1px solid #333;
                    padding: 7px;
                    text-align: left;
                    font-size: 14px;
                }
                table thead {
                    background: #dedede;
                }
                table tr.billing_statement_listing_tfoot {
                    font-weight: bold;
                    text-align: right;
                }
                #billing_statement {
                    width: 800px;
                    margin: 20px auto;
                    padding-bottom: 50px;
                }
                .billing_statement_section .billing_statement_section_content h3 {
                    font-size: 14px;
                    position: relative;
                    margin: 10px 0;
                    font-weight: bold;
                    margin-bottom: 14px;
                    background: #F3F3F3;
                    padding: 5px;
                }
                div#billing_statement_account_information_section {
                    width: 49%;
                    float: left;
                }
                div#billing_statement_summary_section {
                    width: 49%;
                    float: right;
                }
                div#billing_statement_detail_section {
                    clear: both;
                    padding-top: 10px;
                }
                .billing_statement_section_content .billing_statement_summary_label {
                    font-weight: bold;
                    font-size: 16px;
                    width: 44%;
                    display: inline-block;
                    text-align: right;
                }
                .billing_statement_section_content> div {
                    margin-bottom: 10px;
                }
                .billing_statement_section_content .billing_statement_summary_value {
                    text-align: right;
                    float: right;
                    color: #666;
                }
                div#billing_statement_summary_balance_paid_stamp.billing_statement_balance_paid_stamp_paid {
                    float: right;
                    font-size: 30px;
                    color: #50B816;
                    margin-top: 10px;
                }
                div#billing_statement_summary_balance_paid_stamp.billing_statement_balance_paid_stamp_unpaid {
                    float: right;
                    font-size: 30px;
                    color: #C70000;
                    margin-top: 10px;
                }
                body {font-family: 'Lato', 'Helvetica Neue', Arial, sans-serif;}
            """
            makeNewWindow = ()->
                newWindow = window.open("", "")
                newWindow.focus()
                content = paymentHistory.html
                newWindow.document.write(content)
                headTag = newWindow.document.head || newWindow.document.getElementsByTagName('head')[0]
                styleTag = document.createElement('style')
                styleTag.type = 'text/css'
                if (styleTag.styleSheet)
                    styleTag.styleSheet.cssText = cssToInsert
                else
                    styleTag.appendChild(document.createTextNode(cssToInsert))
                headTag.appendChild(styleTag)
                newWindow.document.close()
            makeNewWindow()
    }