
###
----------------------------
  App Action Method
----------------------------
###

define [
  "backbone"
  "component/AppAction/template"
  'i18n!/nls/lang.js'
  'CloudResources'
  'constant'
  'UI.modalplus'
], ( Backbone, AppTpl, lang, CloudResources, constant, modalPlus )->
  AppAction = Backbone.View.extend
    deleteStack : ( id, name ) ->
      name = name || App.model.stackList().get( id ).get( "name" )

      modal AppTpl.removeStackConfirm {
        msg : sprintf lang.ide.TOOL_POP_BODY_DELETE_STACK, name
      }

      $("#confirmRmStack").on "click", ()->
        opsModel = App.model.stackList().get( id )
        p = opsModel.remove()
        if opsModel.isPersisted()
          p.then ()->
            notification "info", sprintf(lang.ide.TOOL_MSG_ERR_DEL_STACK_SUCCESS, name)
          , ()->
            notification "error", sprintf(lang.ide.TOOL_MSG_ERR_DEL_STACK_FAILED, name)
      return

    duplicateStack : (id) ->
      opsModel = App.model.stackList().get(id)
      if not opsModel then return
      opsModel.fetchJsonData().then ()->
        App.openOps( App.model.createStackByJson opsModel.getJsonData() )
      , ()->
        notification "error", "Cannot duplicate the stack, please retry."
      return

    startApp : ( id )->
      name = App.model.appList().get( id ).get("name")
      comp = Design.instance().serialize().component
      hasEC2Instance =( _.filter comp, (e)->
        e.type is constant.RESTYPE.INSTANCE).length
      hasDBInstance = (_.filter comp, (e)->
        e.type is constant.RESTYPE.DBINSTANCE).length
      hasASG = (_.filter comp, (e)->
        e.type is constant.RESTYPE.ASG).length

      startAppModal = new modalPlus {
        template: AppTpl.loading()
        title: lang.ide.TOOL_TIP_START_APP
        confirm:
          text: lang.ide.TOOL_POP_BTN_START_APP
          color: 'blue'
          disabled: false
        disableClose: true
      }
      startAppModal.tpl.find('.modal-footer').hide()

      dbInstance = _.filter comp, (e)->
        e.type is constant.RESTYPE.DBINSTANCE
      snapshots = CloudResources(constant.RESTYPE.DBSNAP, Design.instance().region())
      snapshots.fetchForce().then ->
        lostDBSnapshot = _.filter dbInstance, (e)->
          e.resource.DBSnapshotIdentifier and not snapshots.findWhere({id: e.resource.DBSnapshotIdentifier})

        startAppModal.tpl.find('.modal-footer').show()
        startAppModal.tpl.find('.modal-body').html AppTpl.startAppConfirm {hasEC2Instance, hasDBInstance, hasASG, lostDBSnapshot}

        startAppModal.on 'confirm', ->
          startAppModal.close()
          App.model.appList().get( id ).start().fail ( err )->
            error = if err.awsError then err.error + "." + err.awsError else err.error
            notification "Fail to start your app \"#{name}\". (ErrorCode: #{error})"
            return
          return
        return

    stopApp : ( id )->
      app  = App.model.appList().get( id )
      name = app.get("name")
      that = this

      AppTpl.cantStop {}
      isProduction = app.get('usage') is "production"
      appName = app.get('name')
      canStop = new modalPlus {
        template: AppTpl.loading()
        title:  if isProduction then lang.ide.TOOL_POP_TIT_STOP_PRD_APP else lang.ide.TOOL_POP_TIT_STOP_APP
        confirm:
          text: lang.ide.TOOL_POP_BTN_STOP_APP
          color: 'red'
          disabled: isProduction
        disableClose: true
      }
      canStop.tpl.find(".modal-footer").hide()
      resourceList = CloudResources(constant.RESTYPE.DBINSTANCE, app.get("region"))

      Q.all(
        resourceList.fetchForce()
        app.fetchJsonData()
      ).then ()->
        comp = app.getJsonData().component
        toFetch = {}
        for uid, com of comp
          if com.type is constant.RESTYPE.INSTANCE or com.type is constant.RESTYPE.LC
            imageId = com.resource.ImageId
            if imageId then toFetch[ imageId ] = true
        toFetchArray  = _.keys toFetch
        amiRes = CloudResources( constant.RESTYPE.AMI, app.get("region") )
        amiRes.fetchAmis( _.keys toFetch ).then ->
          hasInstanceStore = false
          amiRes.each (e)->
            if e.id in toFetchArray and e.get("rootDeviceType") is 'instance-store'
              return hasInstanceStore = true

          hasEC2Instance = (_.filter comp, (e)->
            e.type == constant.RESTYPE.INSTANCE)?.length

          hasDBInstance = _.filter comp, (e)->
            e.type == constant.RESTYPE.DBINSTANCE

          dbInstanceName = _.map hasDBInstance, (e)->
            return e.resource.DBInstanceIdentifier
          hasNotReadyDB = resourceList.filter (e)->
            (e.get('DBInstanceIdentifier') in dbInstanceName) and e.get('DBInstanceStatus') isnt 'available'

          hasAsg = (_.filter comp, (e)->
            e.type == constant.RESTYPE.ASG)?.length

          fee = Design.instance()?.getCost() || {}
          totalFee = fee.totalFee
          savingFee = fee.totalFee

          canStop.tpl.find(".modal-footer").show()
          if hasNotReadyDB and hasNotReadyDB.length
            canStop.tpl.find('.modal-body').html AppTpl.cantStop {cantStop : hasNotReadyDB}
            canStop.tpl.find('.modal-confirm').remove()
          else
            hasDBInstance = hasDBInstance?.length
            canStop.tpl.find('.modal-body').css('padding', "0").html AppTpl.stopAppConfirm {isProduction, appName, hasEC2Instance, hasDBInstance, hasAsg, totalFee, savingFee, hasInstanceStore}
          canStop.resize()

          canStop.on "confirm", ()->
            canStop.close()
            app.stop().fail ( err )->
              error = if err.awsError then err.error + "." + err.awsError else err.error
              notification "Fail to stop your app \"#{name}\". (ErrorCode: #{error})"
              return
            return

          $("#appNameConfirmIpt").on "keyup change", ()->
            if $("#appNameConfirmIpt").val() is name
              canStop.tpl.find('.modal-confirm').removeAttr "disabled"
            else
              canStop.tpl.find('.modal-confirm').attr "disabled", "disabled"
            return
          return

    terminateApp : ( id )->
      app  = App.model.appList().get( id )
      name = app.get("name")
      production = app.get("usage") is 'production'
      # renderLoading
      terminateConfirm = new modalPlus(
        title: if production then lang.ide.TOOL_POP_TIT_TERMINATE_PRD_APP else lang.ide.TOOL_POP_TIT_TERMINATE_APP
        template: AppTpl.loading()
        confirm: {
          text: lang.ide.TOOL_POP_BTN_TERMINATE_APP
          color: "red"
          disabled: production
        }
        disableClose: true
      )
      terminateConfirm.tpl.find('.modal-footer').hide()

      # get Resource list
      resourceList = CloudResources(constant.RESTYPE.DBINSTANCE, app.get("region"))
      resourceList.fetchForce().then ()->
        # Render Varies
        app.fetchJsonData().then ->
          comp = app.getJsonData().component
          hasDBInstance = _.filter comp, (e)->
            e.type == constant.RESTYPE.DBINSTANCE
          dbInstanceName = _.map hasDBInstance, (e)->
            return e.resource.DBInstanceIdentifier
          notReadyDB = resourceList.filter (e)->
            (e.get('DBInstanceIdentifier') in dbInstanceName) and e.get('DBInstanceStatus') isnt 'available'

          # Render Terminate Confirm
          terminateConfirm.tpl.find('.modal-body').html AppTpl.terminateAppConfirm {production, name, hasDBInstance, notReadyDB}
          terminateConfirm.tpl.find('.modal-footer').show()
          terminateConfirm.resize()

          if notReadyDB?.length
            terminateConfirm.tpl.find("#take-rds-snapshot").attr("checked", false).change  ->
              terminateConfirm.tpl.find(".modal-confirm").attr 'disabled', $(this).is(":checked")

          $("#appNameConfirmIpt").on "keyup change", ()->
            if $("#appNameConfirmIpt").val() is name
              terminateConfirm.tpl.find('.modal-confirm').removeAttr "disabled"
            else
              terminateConfirm.tpl.find('.modal-confirm').attr "disabled", "disabled"
            return

          terminateConfirm.on "confirm", ()->
            terminateConfirm.close()
            takeSnapshot = terminateConfirm.tpl.find("#take-rds-snapshot").is(':checked')
            app.terminate(null, takeSnapshot).fail ( err )->
              error = if err.awsError then err.error + "." + err.awsError else err.error
              notification "Fail to terminate your app \"#{name}\". (ErrorCode: #{error})"
            return
          return


    _bindPaymentEvent: (modal, checkPaymentDefer, paymentUpdate)->
      modal.find("a.btn.btn-xlarge").click (event)->
        event.preventDefault()
        window.open $(event.currentTarget).attr("href"), ""
        modal.setTitle lang.ide.PAYMENT_LOADING_BILLING
        modal.setContent MC.template.loadingSpiner()
        return false
      App.WS.once 'userStateChange', (idx, dag)->
        paymentState = dag.payment_state
        App.user.set('paymentState', paymentState)
        console.log paymentState
        if paymentState is 'active'
          checkPaymentDefer.resolve {paymentModal: modal, paymentUpdate: paymentUpdate}
      modal.on 'close', ->
        App.WS.off 'userStateChange'

    checkPayment: ()->
      that = @
      checkPaymentDefer = Q.defer()
      stackAgentEnabled = Design.instance().serialize().agent.enabled

      if stackAgentEnabled
        userPaymentState = App.user.get("paymentState")
        if userPaymentState isnt 'active'
          paymentModal = new modalPlus
            title: lang.ide.PAYMENT_LOADING
            template: MC.template.loadingSpiner
            disableClose: true
            confirm:
              text: if App.user.hasCredential() then lang.ide.RUN_STACK_MODAL_CONFIRM_BTN else lang.ide.RUN_STACK_MODAL_NEED_CREDENTIAL
              disabled: true
            #disableFooter: true

          paymentModal.find('.modal-footer').hide()
          App.user.getPaymentUpdate().then (result)->
            if paymentModal.isClosed then return false
            if App.user.get('paymentState') is 'past_due'
              checkPaymentDefer.resolve {paymentUpdate: result,paymentModal: paymentModal}
              return false
            paymentModal.setTitle lang.ide.PAYMENT_INVALID_BILLING
            paymentModal.setContent(MC.template.paymentUpdate result)
            that._bindPaymentEvent(paymentModal, checkPaymentDefer, result)
          , (err)->
            if paymentModal.isClosed then return false
            App.user.getPaymentInfo().then (result)->
              if paymentModal.isClosed then return false
              paymentModal.setTitle lang.ide.PAYMENT_PAYMENT_NEEDED
              paymentModal.setContent(MC.template.paymentSubscribe result)
              that._bindPaymentEvent(paymentModal, checkPaymentDefer, result)
            ,(err)->
              if paymentModal.isClosed then return false
              notification 'error', "Error while getting user payment info. please try again later."
              paymentModal.close()
        else
          checkPaymentDefer.resolve()
      else
        checkPaymentDefer.resolve()

      checkPaymentDefer.promise

  new AppAction()