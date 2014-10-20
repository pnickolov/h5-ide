#############################
#  View(UI logic) for dialog
#############################

define [ "./HeaderTpl", "./SettingsDialog", './BillingDialog', 'i18n!/nls/lang.js', 'backbone', "UI.selectbox" ], ( tmpl, SettingsDialog, BillingDialog, lang ) ->

    HeaderView = Backbone.View.extend {

        events   :
            'click #HeaderLogout'                : 'logout'
            'click #HeaderSettings'              : 'settings'
            'click #HeaderShortcuts'             : 'shortcuts'
            'click #HeaderBilling'               : 'billingSettings'
            'click .voquota'                     : "billingSettings"
            'DROPDOWN_CLOSE #HeaderNotification' : 'dropdownClosed'

        initialize : ()->
            @listenTo App.user,  "change", @update
            @listenTo App.model, "change:notification", @updateNotification

            @setElement $(tmpl( App.user.toJSON() )).prependTo("#wrapper")
            return

        logout : () -> App.logout()

        shortcuts : ()-> modal MC.template.shortkey()

        settings : ()-> new SettingsDialog()

        update : ()->
            user = App.user

            quota_month = user.get("voQuotaPerMonth")
            quota_current = user.get("voQuotaCurrent")
            $("#HeaderUser").data("tooltip", user.get("email")).children("span").text( user.get("username"))
            $quota = $("#header").children(".voquota")
            paymentRenewDays = Math.round((App.user.attributes.billingCircle - new Date()) / (1000 * 3600 * 24))
            if App.user.get('billingCircle')
              $quota.attr("data-tooltip", sprintf(lang.IDE.PAYMENT_HEADER_TOOLTIP, quota_current, quota_month, paymentRenewDays) )
            currentWidth = Math.round(quota_current / quota_month * 100)
            if currentWidth > 100
              currentWidth = Math.round( quota_month / quota_current * 100 )

            $quota.find(".currquota").css({"width":currentWidth + "%"})
            $quota.find(".current").text(quota_current)
            $quota.find(".limit"  ).text(quota_month)
            $quota.find(".percentage").toggleClass("error", user.shouldPay()).toggleClass("full", (quota_current > quota_month) && !user.shouldPay())
            return

        setAlertCount : ( count ) -> $('#NotificationCounter').text( count || "" )

        updateNotification : ()->
            console.log "Notification Updated, Websocket isReady:", App.WS.isReady()

            notification = App.model.get "notification"

            html = ""
            unread_num = 0
            for i in notification
                html += MC.template.headerNotifyItem i
                if not i.readed
                    unread_num++

            @setAlertCount( unread_num )

            $("#notification-panel-wrapper").find(".scroll-content").html html
            $("#notification-panel-wrapper").css( "max-height", Math.ceil( window.innerHeight * 0.8 ) )
            null

        dropdownClosed : () ->
            # Remove All Unread Count
            $("#notification-panel-wrapper").find(".scroll-content").children().removeClass("unread")
            @setAlertCount()

            App.model.markNotificationRead()
            null

        billingSettings: ()-> new BillingDialog()

    }

    HeaderView
