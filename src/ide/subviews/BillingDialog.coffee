#############################
#  View(UI logic) for dialog
#############################

define [ "./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus" ,"backbone" ], ( BillingDialogTpl, lang, ApiRequest, Modal ) ->

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
        @modal.find('.modal-body').css({background: "#252525"})
        #Q.all([App.user.getPaymentUpdate(),App.user.getPaymentStatement(), App.user.getPaymentUsage()]).spread (paymentUpdate, paymentHistory, paymentUsage)->
        App.user.getPaymentStatement().then (paymentHistory)->
          console.log paymentHistory
          paymentUpdate = {
            paymentState: App.user.get("paymentState")
            first_name: App.user.get("firstName")
            last_name: App.user.get("lastName")
            url: App.user.get("paymentUrl")
            card: App.user.get("creditCard")
            billingCircle: App.user.get("billingCircle")
          }
          paymentUsage = {
            current_quota: App.user.get("voQuotaCurrent")
            max_quota:  App.user.get("voQuotaPerMonth")
          }
          that.modal.find(".modal-body").css 'padding', "0"
          hasPaymentHistory = (_.keys paymentHistory).length
          tempArray = []
          _.each paymentHistory, (e)->
            e.ending_balance = e.ending_balance_in_cents/100
            tempArray.push(e)
          tempArray.reverse()
          paymentHistory = tempArray
          that.paymentHistory = tempArray
          that.paymentUsage = _.clone paymentUsage
          that.modal.setContent BillingDialogTpl.billingTemplate {paymentUpdate, paymentHistory, paymentUsage, hasPaymentHistory}
        , ()->
          notification 'error', "Error while getting user payment info, please try again later."
        @setElement @modal.tpl

      switchTab: (event)->
        target = $(event.currentTarget)
        console.log "Switching Tabs"
        @modal.find("#PaymentNav").find("span").removeClass("selected")
        @modal.find(".tabContent > section").addClass("hide")
        $("#"+ target.addClass("selected").data('target')).removeClass("hide")
        @animateUsage()


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

      animateUsage: ()->

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
