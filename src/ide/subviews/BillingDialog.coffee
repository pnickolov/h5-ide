#############################
#  View(UI logic) for dialog
#############################

define [ "./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus" ,"backbone" ], ( BillingDialogTpl, lang, ApiRequest, Modal ) ->

    BillingDialog = Backbone.View.extend {

      events :
        "click #SettingsNav span"         : "switchTab"

      initialize : ()->
        that = @
        paymentState = App.user.get("paymentState")
        @modal = new Modal
          title: lang.ide.PAYMENT_SETTING_TITLE
          width: "650px"
          template: MC.template.loadingSpiner
          confirm: hide: true
        if  paymentState is "unpay"
          App.user.getPaymentInfo().then (result)=>
            @modal.setContent BillingDialogTpl.noPaymentCard result
          , ()->
            notification 'error', "Error while getting user payment info, please try again later."
        else
          Q.all([App.user.getPaymentUpdate(),App.user.getPaymentStatement(), App.user.getPaymentUsage()]).spread (paymentUpdate, paymentHistory, paymentUsage)->
            that.modal.find(".modal-body").css 'padding', "0"
            hasPaymentHistory = (_.keys paymentHistory).length
            that.modal.setContent BillingDialogTpl.billingTemplate {paymentUpdate, paymentHistory, paymentUsage, hasPaymentHistory}
          , ()->
            notification 'error', "Error while getting user payment info, please try again later."
    }


    BillingDialog
