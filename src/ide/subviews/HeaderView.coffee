#############################
#  View(UI logic) for dialog
#############################

define [ "./HeaderTpl", "./SettingsDialog", './BillingDialog', 'backbone', "UI.selectbox" ], ( tmpl, SettingsDialog, BillingDialog ) ->

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

            $("#HeaderUser").data("tooltip", user.get("email")).children("span").text( user.get("username"))
            $quota = $("#header").children(".voquota")
            currentWidth = Math.round(user.get("voQuotaCurrent") / user.get("voQuotaPerMonth") * 100)
            if currentWidth > 100
              currentWidth = Math.round( user.get("voQuotaPerMonth") / user.get("voQuotaCurrent") * 100 )
            $quota.find(".currquota").css({"width":currentWidth + "%"})
            $quota.find(".current").text(user.get("voQuotaCurrent"))
            $quota.find(".limit"  ).text(user.get("voQuotaPerMonth"))
            $quota.find(".percentage").toggleClass("error", user.shouldPay())
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
