#############################
#  View(UI logic) for dialog
#############################

define [ "./BillingDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus" ,"backbone" ], ( BillingDialogTpl, lang, ApiRequest, Modal ) ->

    BillingDialog = Backbone.View.extend {

      events :
        "click #PaymentNav span"              : "switchTab"
        'click #PaymentBody a.payment-receipt': "viewPaymentReceipt"
        "click .btn.btn-xlarge"               : "_bindPaymentEvent"

      initialize : ()->
        that = @
        paymentState = App.user.get("paymentState")
        @modal = new Modal
          title: lang.ide.PAYMENT_SETTING_TITLE
          width: "650px"
          template: MC.template.loadingSpiner
          confirm: hide: true
          delay: 1
        if  paymentState is "unpay"
          App.user.getPaymentInfo().then (result)=>
            @modal.setContent BillingDialogTpl.noPaymentCard result
          , ()->
            notification 'error', "Error while getting user payment info, please try again later."
        else
          Q.all([App.user.getPaymentUpdate(),App.user.getPaymentStatement(), App.user.getPaymentUsage()]).spread (paymentUpdate, paymentHistory, paymentUsage)->
            that.modal.find(".modal-body").css 'padding', "0"
            hasPaymentHistory = (_.keys paymentHistory).length
            _.each paymentHistory, (e)->
              e.ending_balance = e.ending_balance_in_cents/100
              e
            that.paymentHistory = _.clone paymentHistory
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

      viewPaymentReceipt: (event)->
        $target = $(event.currentTarget)
        id = $target.parent().parent().data("id")
        console.log id
        paymentHistory = @paymentHistory[id]
        console.log paymentHistory
        makeNewWindow = ()->
          newWindow = window.open("", "")
          newWindow.focus()
          content = paymentHistory.html
          newWindow.document.write(content)
          newWindow.document.close()
        makeNewWindow()

      _bindPaymentEvent: (event)->
        that = @
        event.preventDefault()
        window.open $(event.currentTarget).attr("href"), ""
        @modal.setTitle lang.ide.PAYMENT_LOADING_BILLING
        @modal.setContent MC.template.loadingSpiner()
        App.WS.once 'userStateChange', (idx, dag)->
          paymentState = dag.payment_state
          App.user.set('paymentState', paymentState)
          console.log paymentState
          if paymentState is 'active'
            that.modal.close()
            window.setTimeout ()->
              that._renderBillingDialog()
            , 2

      _renderBillingDialog: ->
        new BillingDialog()

      animateUsage: ()->
        that = @
        seconds = 3
        loaderBg = document.getElementById('usage_all')
        loader = document.getElementById('usage_free')
        numElem = document.getElementById('usage_num')
        a = 0
        pi = Math.PI
        t = (seconds / 360 * 1000)
        num = 0
        freeNum = that.paymentUsage.free_credit
        numMax = that.paymentUsage.charge_credit
        totalNum = (freeNum + that.paymentUsage.charge_credit)
        @modal.find(".usage-num-free span.num").text(freeNum)
        @modal.find(".usage-num-total span.num").text(totalNum)
        tempElement = null
        tempAngle = 270
        if that.chartTimeOut then window.clearTimeout(that.chartTimeOut)
        that.chartTimeOut = null
        draw = (element,angle,direct)->
          if element then a = 0
          a = if direct then angle else a
          a++
          num += ((numMax) / tempAngle)
          r = a * pi / 180
          x = Math.sin(r) * 125
          y = Math.cos(r) * - 125
          mid = if (a > 180) then 1 else 0
          anim = "M 0 0 v -125 A 125 125 1 #{mid} 1 #{x} #{y} z" #Magic, don't touch.
          tempElement = element || tempElement
          tempAngle = angle || tempAngle
          tempElement.setAttribute( 'd' , anim)
          console.log num, a
          if not direct then numElem.innerText = Math.round(if num > numMax then numMax else num)
          if(a < tempAngle and not direct)
            that.chartTimeOut = window.setTimeout draw, t
        if freeNum
          console.log freeNum, totalNum
          loaderBg.setAttribute( 'fill' , "#4b4f8c")
          loader.setAttribute( 'fill' , "#30bc00")
          draw(loaderBg, 270, true)
          draw(loader, (freeNum/totalNum) * 270)
          return false
        loaderBg.setAttribute( 'fill' , "#5f5f5f")
        draw(loaderBg, 270, true)
        console.log @paymentUsage
        return
  }


    BillingDialog
