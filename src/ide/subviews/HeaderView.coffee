#############################
#  View(UI logic) for dialog
#############################

define [ "./HeaderTpl", "../settings/SettingsView", './BillingDialog', 'i18n!/nls/lang.js', 'UI.modalplus', 'backbone', "UI.selectbox" ], ( tmpl, Settings, BillingDialog, lang, modalPlus ) ->

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

        shortcuts : ()->
            new modalPlus({
                title: lang.IDE.KEY_MOD_TIT
                width: 640
                maxHeight: 560
                template: MC.template.shortkey()
                disableClose: true
                confirm: hide: true
            }).tpl.attr("id", "modal-key-short")

        settings : ()-> new Settings()

        update : ()->
            $quota = $("#header").children(".voquota")
            if App.user.shouldPay()
                $quota.addClass("show")
            else
                $quota.removeClass("show")



        setAlertCount : ( count ) -> $('#NotificationCounter').text( count || "" )

        updateNotification : ()->
            console.log "Notification Updated, Websocket isReady:", App.WS.isReady()

            notification = _.map App.model.get( "notification" ), ( n ) ->
                _.extend {}, n, { operation: lang.TOOLBAR[n.operation.toUpperCase()] or n.operation }

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
