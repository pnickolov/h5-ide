#./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus", "ApiRequestR", "backbone"
define [ 'backbone', "../template/TplBilling", 'i18n!/nls/lang.js', "ApiRequest", "ApiRequestR" ], (Backbone, template, lang, ApiRequest, ApiRequestR ) ->
    Backbone.View.extend {
        events :
            'click #PaymentBody a.payment-receipt': "viewPaymentReceipt"
            'click button.update-payment'         : "showUpdatePayment"
            "click .update-payment-done"          : "updatePaymentDone"
            "click .update-payment-cancel"        : "updatePaymentCancel"

        className: "billing-view"

        initialize: ->
            @$el.html template.billingLoadingFrame()
            @$el.find("#billing-status").append MC.template.loadingSpinner()
            @
        render : ()->
            projectId = @model.get "id"
            that = @
            @$el.find("#PaymentBody").remove()
            paymentState = App.user.get("paymentState")
            ApiRequestR "payment_self", {projectId}
            .then (result)->
                formattedResult = {
                    cardNumber  :result.card
                    lastName :result.last_name
                    firstName  :result.first_name
                    periodEnd  :result.current_period_ends_at
                    periodStart  :result.current_period_started_at
                    maxQuota :result.max_quota
                    currentQuota :result.current_quota
                    nextPeriod :result.next_assessment_at
                    paymentState :result.state
                }
                that.model.set("payment", formattedResult)
                paymentUpdate = that.model.get("payment")
                billingTemplate = template.billingTemplate {paymentUpdate}

                that.$el.find(".loading-spinner").remove()
                that.$el.find("#billing-status").append billingTemplate
                that.$el.find(".table-head-fix").replaceWith MC.template.loadingSpinner()
                if result.card and result.current_quota < result.max_quota and state is "active" or "pastdue"
                    that.getPaymentHistory().then (paymentHistory)->
                        console.log paymentHistory
                        hasPaymentHistory = (_.keys paymentHistory).length
                        tempArray = []
                        _.each paymentHistory, (e)->
                            e.total_balance = e.total_balance_in_cents / 100
                            e.start_balance = e.starting_balance_in_cents / 100
                            tempArray.push e
                        tempArray.reverse()
                        paymentHistory = tempArray
                        that.model.set("paymentHistory", paymentHistory)
                        paymentUpdate = that.model.get("payment")
                        billingTemplate = template.billingTemplate {paymentUpdate, paymentHistory, hasPaymentHistory}
                        that.$el.find("#PaymentBody").remove()
                        that.$el.find("#billing-status").append billingTemplate
                else
                  that.$el.find(".loading-spinner").remove()
                  that.$el.find("#billing-status").append template.billingTemplate {needUpdatePayment: true}
                  @updateUsage()
                  return @
            , ()->
                notification 'error', "Error while getting user payment info, please try again later."
            @

        getPaymentHistory: ()->
            projectId = @model.get("id")
            historyDefer = new Q.defer()
            ApiRequestR("payment_statement", {projectId}).then (paymentHistory)->
                historyDefer.resolve(paymentHistory)
            , (err)->
                historyDefer.reject(err)
            historyDefer.promise

        showUpdatePayment: (evt)->
            @$el.find("#PaymentBillingTab").append template.updatePayment()
            $(evt.currentTarget).hide()
            $(".update-payment-ctrl").show()

        updatePaymentDone: ()->
            that = @
            @$el.find(".update-payment-wrap").html MC.template.loadingSpinner()
            @$el.find(".update-payment-done").text(lang.IDE.LBL_SAVING)
            @$el.find(".update-payment-ctrl button").attr("disabled", "disabled")
            _.delay ->
                that.render()
            , 500

        updatePaymentCancel: ()->
            @render()

        viewPaymentReceipt: (event)->
            $target = $(event.currentTarget)
            id = $target.parent().parent().data("id")
            paymentHistory = @model.get("paymentHistory")[id]
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