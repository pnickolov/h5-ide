#############################
#  View(UI logic) for dialog
#############################

define [ "./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus", "ApiRequestR", "backbone" ], ( BillingDialogTpl, lang, ApiRequest, Modal, ApiRequestR ) ->

    BillingDialog = Backbone.View.extend {

      events :
        "click #PaymentNav span"              : "switchTab"
        'click #PaymentBody a.payment-receipt': "viewPaymentReceipt"
        'click .update-payment'               : "_bindPaymentEvent"

      initialize : (modal)->
        that = @
        paymentState = App.user.get("paymentState")
        if modal
          @modal = modal
          @modal.setWidth "650px"
          .setTitle lang.IDE.PAYMENT_SETTING_TITLE
          .setContent MC.template.loadingSpiner
          .find('.modal-confirm').hide()
        else
          @modal = new Modal
            title: lang.IDE.PAYMENT_SETTING_TITLE
            width: "650px"
            template: MC.template.loadingSpiner
            disableClose: true
            confirm: hide: true
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

          that.modal.find(".modal-body").css 'padding', "0"
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
          that.modal.setContent BillingDialogTpl.billingTemplate {paymentUpdate, paymentHistory, hasPaymentHistory}
          unless App.user.get("creditCard")
            that.modal.find("#PaymentBillingTab").html(MC.template.paymentSubscribe {url: App.user.get("paymentUrl"), freePointsPerMonth: App.user.get("voQuotaPerMonth"), shouldPay: App.user.shouldPay()})
            that.modal.listenTo App.user, "paymentUpdate", ->
              that.initialize(that.modal)
              that.modal.stopListening()
          that.updateUsage()
        , ()->
          notification 'error', "Error while getting user payment info, please try again later."
          that.modal?.close()
        @listenTo App.user, "paymentUpdate", -> that.updateUsage()
        @setElement @modal.tpl

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
        @modal.find("#PaymentNav").find("span").removeClass("selected")
        @modal.find(".tabContent > section").addClass("hide")
        $("#"+ target.addClass("selected").data('target')).removeClass("hide")
        @updateUsage()

      _bindPaymentEvent: (event)->
        that = @
        event.preventDefault()
        window.open $(event.currentTarget).attr("href"), ""
        @modal.listenTo App.user, 'change:paymentState', ->
          paymentState = App.user.get 'paymentState'
          if that.modal.isClosed then return false
          if paymentState is 'active'
            that._renderBillingDialog(that.modal)
        @modal.on 'close', ()->that.modal.stopListening App.user
        return false

      _renderBillingDialog: (modal)->
        new BillingDialog(modal)

      updateUsage: ()->
        if @modal.isClosed
          return false
        shouldPay = App.user.shouldPay()
        @modal.$(".usage-block").toggleClass("error", shouldPay)
        @modal.$(".used-points").toggleClass("error", shouldPay)

        current_quota = App.user.get("voQuotaCurrent")

        @modal.find(".payment-number").text(App.user.get("creditCard") || "No Card")
        @modal.find(".payment-username").text("#{App.user.get("cardFirstName")} #{App.user.get("cardLastName")}")
        @modal.find(".used-points .usage-number").text(current_quota)

        if App.user.shouldPay()
          @modal.find(".warning-red").not(".no-change").show().html sprintf lang.IDE.PAYMENT_PROVIDE_UPDATE_CREDITCARD,  App.user.get("paymentUrl"), (if App.user.get("creditCard") then "Update" else "Provide")
        else if App.user.isUnpaid()
          @modal.find(".warning-red").not(".no-change").show().html sprintf lang.IDE.PAYMENT_UNPAID_BUT_IN_FREE_QUOTA, App.user.get("paymentUrl")
        else
          @modal.find(".warning-red").not(".no-change").hide()


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


    BillingDialog