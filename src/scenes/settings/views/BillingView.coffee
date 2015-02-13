#./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus", "ApiRequestR", "backbone"
define ['backbone', "../template/TplBilling", 'i18n!/nls/lang.js', "ApiRequest","ApiRequestR", "scenes/ProjectTpl", "UI.parsley"], (Backbone, template, lang, ApiRequest, ApiRequestR, projectTpl) ->
  Backbone.View.extend {
    events:
      'click #PaymentBody a.payment-receipt': "viewPaymentReceipt"
      'click button.update-payment'         : "showUpdatePayment"
      "click .update-payment-done"          : "updatePaymentDone"
      "click .update-payment-cancel"        : "updatePaymentCancel"
      "click .editEmailBtn"                 : "updatePaymentEmail"
      "click .editEmailDone"                : "updateEmailDone"
      "click .editEmailCancel"              : "updateEmailCancel"
      "change .billing-email-text>input"    : "emailInputChange"
      "keyup .billing-email-text>input"     : "emailInputChange"

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
        that.getPaymentHistory().then (paymentHistory)->
          hasPaymentHistory = (_.keys paymentHistory).length
          paymentUpdate = that.model.get("payment")
          billingTemplate = template.billingTemplate {paymentUpdate, paymentHistory, hasPaymentHistory}
          that.$el.find(".billing-history").html $(billingTemplate).find(".billing-history").html()
        , ()->
          that.renderCache()
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
      @$el.find(".billing-history").replaceWith projectTpl.updateProject()
      $(evt.currentTarget).hide()

    emailInputChange: ()->
      email = @$el.find(".billing-email-text input").val()
      @isValidEmail(email)

    updatePaymentDone: ()->
      that = @
      wrap = @$el.find(".update-payment-wrap")
      wrap.find(".new-project-err").hide()

      $updateBtn = that.$el.find(".update-payment-done")

      $firstname = wrap.find("#new-project-fn")
      $lastname = wrap.find("#new-project-ln")
      $number = wrap.find("#new-project-card")
      $expire = wrap.find("#new-project-date")
      $cvv = wrap.find("#new-project-cvv")
      valid = true

      # deal expire
      $expire.parsley 'custom', (val) -> null
      expire = $expire.val()
      expireAry = expire.split('/')
      if expire.match(/^\d\d\/\d\d$/g) # MM/YYYY -> MM/20YY
        expire = "#{expireAry[0]}/20#{expireAry[1]}"
      else if expire.match(/^\d\d\d\d$/g) # MM/YY -> MM/20YY
        expire = "#{expire.substr(0,2)}/20#{expire.substr(2,2)}"
      else if expire.match(/^\d\d\/\d\d\d\d$/g) # MM/YYYY -> MM/YYYY
        expire = expire
      else if expire.match(/^\d\d\d\d\d\d$/g) # MMYYYY -> MM/YYYY
        expire = "#{expire.substr(0,2)}/#{expire.substr(2,4)}"
      else if expire.match(/^\d\d\d$/g) # MYY -> 0M/20YY
        expire = "0#{expire.substr(0,1)}/20#{expire.substr(1,2)}"
      else
        $expire.parsley 'custom', (val) ->
          return lang.IDE.SETTINGS_CREATE_PROJECT_EXPIRE_FORMAT if val.indexOf('/') is -1
          return null

      wrap.find("input").each (idx, dom) ->
        # if not $(dom).hasClass('new-project-cvv')
        if not $(dom).parsley('validate')
          valid = false
          return false

      if valid
        $updateBtn.prop 'disabled', true
        wrap.find("input").attr("disabled", "disabled")
        project_id = that.model.get("id")
        attributes = {
          first_name: $firstname.val()
          last_name : $lastname.val()
          full_number: $number.val()
          expiration_month: expire.split("/")[0]
          expiration_year : expire.split("/")[1]
          cvv:              $cvv.val()
        }

        ApiRequest "project_update_payment", {project_id, attributes}
        .then ->
          that.render()
        .fail ( error )->
          wrap.find("input").prop("disabled", false)
          try
            msgObj = JSON.parse(error.result)
            if _.isArray(msgObj.errors)
              wrap.find(".update-payment-err").show().html msgObj.errors.join('<br/>')
          catch err
            notification 'error', error.result
          # modal.tpl.find(".new-project-info").toggleClass("error", true).html( error.msg )
          return
        .done () ->
          $updateBtn.prop 'disabled', false

    updatePaymentCancel: ()->
      $(".parsley-error-list").remove()
      @renderCache()


    updatePaymentEmail: ()->
      @$el.find(".billing-email-text>p,.editEmailBtn").hide()
      @$el.find(".editEmailControl,.billing-email-text>input").show()
      @$el.find(".billing-email-text>input").val(@model.get("payment").email)

    updateEmailCancel: ()->
      @renderCache()

    isValidEmail: (email)->
      regExp = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i
      isValid = regExp.test(email)
      if isValid
        @$el.find("#SettingErrorInfo").empty()
      else
        @$el.find("#SettingErrorInfo").text lang.IDE.SETTING_INVALID_EMAIL
      isValid

    updateEmailDone: ()->
      project_id = @model.get "id"
      that = @
      email = @$el.find(".billing-email-text input").val()
      unless @isValidEmail email
        return false

      @$el.find(".editEmailControl button").attr("disabled", "disabled")
      @$el.find(".billing-email-text>input").attr("disabled", "disabled")
      @$el.find(".editEmailControl .editEmailDone").text(lang.IDE.LBL_SAVING)
      @$el.find(".editEmailControl .editEmailCancel").hide()
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
