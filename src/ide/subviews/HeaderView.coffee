#############################
#  View(UI logic) for dialog
#############################

define [ "./HeaderTpl", "./SettingsDialog", 'backbone' ], ( tmpl, SettingsDialog ) ->

    HeaderView = Backbone.View.extend {

        events   :
            'click #HeaderLogout'                : 'logout'
            'click #HeaderSettings'              : 'settings'
            'click #HeaderShortcuts'             : 'shortcuts'
            'DROPDOWN_CLOSE #HeaderNotification' : 'dropdownClosed'

        initialize : ()->
            @listenTo App.user,  "change", @update
            @listenTo App.model, "change:notification", @updateNotification

            @setElement $(tmpl( App.user.toJSON() )).prependTo("#header-wrapper")
            return

        logout : () -> App.logout()

        shortcuts : ()-> modal MC.template.shortkey()

        settings : ()-> new SettingsDialog()

        update : ()-> $("#HeaderUser").data("tooltip", App.user.get("email")).children("span").text( App.user.get("username"))

        setAlertCount : ( count ) -> $('#NotificationCounter').text( count || "" )

        updateNotification : ()->
            console.info "Notification Updated, Websocket isReady:", App.WS.isReady()

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
    }

    HeaderView
