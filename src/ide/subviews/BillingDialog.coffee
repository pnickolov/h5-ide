#############################
#  View(UI logic) for dialog
#############################

define [ "./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus" ,"backbone" ], ( BillingDialogTpl, lang, ApiRequest, Modal ) ->

    BillingDialog = Backbone.View.extend {

      events :
        "click #SettingsNav span"         : "switchTab"

      initialize : ()->
        paymentState = App.user.get("paymentState")
        if  paymentState is "unpay"
          App.user.getPaymentInfo().then (result)->
            @modal = new Modal
              title: lang.ide.PAYMENT_SETTING_TITLE
              width: "600px"
              template: BillingDialogTpl.noPaymentCard result
              compact:  true
              confirm: hide: true
          , ()->
            notification 'error', "Error while getting user payment info, please try again later."
        else
          App.user.getPaymentUpdate().then (result)->
            @modal = new Modal
              title: lang.ide.PAYMENT_SETTING_TITLE
              width: "650px"
              template: BillingDialogTpl.billingTemplate result
              compact: true
              confirm: hide: true
          , ()->
            notification 'error', "Error while getting user payment info, please try again later."
    }


    BillingDialog
