#./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus", "ApiRequestR", "backbone"
define ['backbone', "../template/TplBilling", 'i18n!/nls/lang.js', "ApiRequest",
        "ApiRequestR"], (Backbone, template, lang, ApiRequest, ApiRequestR) ->
  Backbone.View.extend {
    events:
      'click #PaymentBody a.payment-receipt': "viewPaymentReceipt"
      'click button.update-payment'         : "showUpdatePayment"
      "click .update-payment-done"          : "updatePaymentDone"
      "click .update-payment-cancel"        : "updatePaymentCancel"
      "click .editEmailBtn"                 : "updatePaymentEmail"
      "click .editEmailDone"                : "updateEmailDone"
      "click .editEmailCancel"              : "updateEmailCancel"

    className: "billing-view"

    initialize: ->
      @


    render    : ()->
      @$el.html template.billingLoadingFrame()
      @$el.find("#billing-status").append MC.template.loadingSpinner()
      that = @
      @$el.find("#PaymentBody").remove()
      paymentState = App.user.get("paymentState")
      @model.getPaymentState().then ()->
        paymentUpdate = that.model.get("payment")
        billingTemplate = template.billingTemplate {paymentUpdate}
        that.$el.find("#billing-status").html billingTemplate
        that.$el.find(".table-head-fix").replaceWith MC.template.loadingSpinner()
        if paymentUpdate.cardNumber and paymentUpdate.currentQuota < paymentUpdate.maxQuota and paymentUpdate.paymentState is "active" or "pastdue"
          that.getPaymentHistory().then (paymentHistory)->
            hasPaymentHistory = (_.keys paymentHistory).length
            paymentUpdate = that.model.get("payment")
            billingTemplate = template.billingTemplate {paymentUpdate, paymentHistory, hasPaymentHistory}
            that.$el.find(".billing-history").html $(billingTemplate).find(".billing-history").html()
          , ()->
            that.renderCache()
        else
          that.$el.find(".loading-spinner").remove()
          that.$el.find("#billing-status").append template.billingTemplate {needUpdatePayment: true}
      , (err)->
        if err.error is -404
          noSubscription = true 
          billingTemplate = template.billingTemplate {noSubscription}
          that.$el.find("#billing-status").html billingTemplate
        else
          notification 'error', "Error while getting user payment info, please try again later."
      @


    renderCache: ()->
      that = @
      paymentHistory = @model.get("paymentHistory") || []
      paymentUpdate = @model.get("payment")
      billingTemplate = template.billingTemplate {paymentUpdate, paymentHistory}
      that.$el.find("#billing-status").html billingTemplate
      if not paymentHistory.length
        that.$el.find(".table-head-fix").replaceWith MC.template.loadingSpinner()
        @getPaymentHistory().then ()->
          paymentHistory = that.model.get("paymentHistory")
          billingTemplate = template.billingTemplate {paymentUpdate, paymentHistory}
          that.$el.find("#billing-status").empty().append billingTemplate
      @

    getPaymentHistory: ()->
      projectId = @model.get("id")
      historyDefer = new Q.defer()
      that = @
      ApiRequestR("payment_statement", {projectId}).then (paymentHistory)->
        tempArray = []
        _.each paymentHistory, (e)->
          e.ending_balance = e.ending_balance_in_cents / 100
          e.total_balance = e.total_in_cents / 100
          e.start_balance = e.starting_balance_in_cents / 100
          tempArray.push e
        tempArray.reverse()
        paymentHistory = tempArray
        that.model.set("paymentHistory", paymentHistory)
        historyDefer.resolve(paymentHistory)
      , (err)->
        historyDefer.reject(err)
      historyDefer.promise


    showUpdatePayment: (evt)->
      $(".update-payment-ctrl").show()
      @$el.find(".billing-history").replaceWith template.updatePayment()
      $(evt.currentTarget).hide()


    updatePaymentDone: ()->
      that = @
      $wrap = @$el.find(".update-payment-wrap")
      attributes = {
        first_name      : $wrap.find(".first-name").val()
        last_name       : $wrap.find(".last-name").val()
        full_number     : $wrap.find("input.card-number").val()
        expiration_month: $wrap.find("input.expiration").val().slice(0, 2)
        expiration_year : $wrap.find("input.expiration").val().slice(2, 4)
        cvv             : $wrap.find("input.cvv").val()
      }
      @$el.find(".update-payment-wrap").html MC.template.loadingSpinner()
      @$el.find(".update-payment-done").text(lang.IDE.LBL_SAVING)
      @$el.find(".update-payment-ctrl button").attr("disabled", "disabled")
      project_id = @model.get("id")
      ApiRequest "project_update_payment", {project_id, attributes}
      .then ()->
        that.model.set("payment", null)
        that.model.set("paymentHistory", null)
        that.render()
      , (err)->
        console.warn err
        notification "error", "Error while updating user payment info, please try again later."
        that.renderCache()


    updatePaymentCancel: ()->
      @renderCache()


    updatePaymentEmail: ()->
      @$el.find(".billing-email-text>p,.editEmailBtn").hide()
      @$el.find(".editEmailControl,.billing-email-text>input").show()
      @$el.find(".billing-email-text>input").val(@model.get("payment").email)

    updateEmailCancel: ()->
      @renderCache()

    updateEmailDone: ()->
      project_id = @model.get "id"
      that = @
      @$el.find(".editEmailControl button").attr("disabled", "disabled")
      @$el.find(".billing-email-text>input").attr("disabled", "disabled")
      @$el.find(".editEmailControl .editEmailDone").text(lang.IDE.LBL_SAVING)
      @$el.find(".editEmailControl .editEmailCancel").hide()
      email = @$el.find(".billing-email-text input").val()
      attributes = {email}
      ApiRequest "project_update_payment", {project_id, attributes}
      .then ()->
        that.model.set("payment", null)
        that.model.set("paymentHistory", null)
        that.render()
      , (err)->
        console.warn err
        notification "error", "Error while updating user payment info, please try again later."
        that.renderCache()


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