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
              template: BillingDialogTpl.noPaymentCard result
              confirm: hide: true
          , ()->
            notification 'error', "Error while getting user payment info, please try again later."
        else
          App.user.getPaymentUpdate().then (result)->
            @modal = new Modal
              title: lang.ide.PAYMENT_SETTING_TITLE
              template: BillingDialogTpl.billingTemplate result
              confirm: hide: true
          , ()->
            notification 'error', "Error while getting user payment info, please try again later."
    }


    BillingDialog
