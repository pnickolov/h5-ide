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
            @update()
            return

        logout : () -> App.logout()

        shortcuts : ()-> modal MC.template.shortkey()

        settings : ()-> new SettingsDialog()

        update : ()->
            user     = App.user
            overview = user.getBillingOverview()

            $("#HeaderUser")
                .data("tooltip", user.get("email"))
                .children("span")
                .text( user.get("username"))

            $quota = $("#header").children(".voquota").attr("data-tooltip", sprintf(lang.IDE.PAYMENT_HEADER_TOOLTIP, overview.quotaRemain, overview.billingRemain) )

            $quota.find(".currquota").css({"width":overview.quotaPercent + "%"})
            $quota.find(".current").text(overview.quotaRemain)
            $quota.find(".limit"  ).text(overview.quotaTotal)

            $quota.find(".percentage").removeClass("error full")
            if user.shouldPay()
                $quota.addClass("error")
            else if overview.quotaRemain >= overview.quotaTotal
                $quota.addClass("full")
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
