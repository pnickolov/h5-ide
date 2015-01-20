define [ 'backbone', "../template/TplAccessToken", 'i18n!/nls/lang.js',"UI.scrollbar" ], (Backbone,template, lang) ->
    Backbone.View.extend {

        className: "access-token-view"
        events:
            "click #TokenCreate"               : "createToken"
            "click .tokenControl .icon-edit"   : "editToken"
            "click .tokenControl .icon-delete" : "removeToken"
            "click .tokenControl .tokenDone"   : "doneEditToken"
            "click #TokenRemove"               : "confirmRmToken"
            "click #TokenRmCancel"             : "cancelRmToken"

        initialize: ->
            @render()
            @

        render: ->
            @$el.html template()
            @updateTokenList()
            @

        editToken : ( evt )->
            $t = $(evt.currentTarget)
            $p = $t.closest("li").toggleClass("editing", true)
            $p.children(".tokenName").removeAttr("readonly").focus().select()
            return

        removeToken : ( evt )->
            $p = $(evt.currentTarget).closest("li")
            name = $p.children(".tokenName").val()
            @rmToken = $p.children(".tokenToken").text()
            @$el.find("#TokenManager").hide()
            @$el.find("#TokenRmConfirm").show()
            @$el.find("#TokenRmTit").text( sprintf lang.IDE.SETTINGS_CONFIRM_TOKEN_RM_TIT, name )
            return

        createToken : ()->
            @$el.find("#TokenCreate").attr "disabled", "disabled"

            self = this
            App.user.createToken().then ()->
                self.updateTokenList()
                self.$el.find("#TokenCreate").removeAttr "disabled"
            , ()->
                notification "error", lang.NOTIFY.FAIL_TO_CREATE_TOKEN
                self.$el.find("#TokenCreate").removeAttr "disabled"
            return

        doneEditToken : ( evt )->
            $p = $(evt.currentTarget).closest("li").removeClass("editing")
            $p.children(".tokenName").attr "readonly", true

            token        = $p.children(".tokenToken").text()
            newTokenName = $p.children(".tokenName").val()

            for t in  App.user.get("tokens")
                if t.token is token
                    oldName = t.name
                else if t.name is newTokenName
                    duplicate = true

            if not newTokenName or duplicate
                $p.children(".tokenName").val( oldName )
                return

            App.user.updateToken( token, newTokenName ).fail ()->
                # If anything goes wrong, revert the name
                oldName = ""
                $p.children(".tokenName").val( oldName )
                notification "error", lang.NOTIFY.FAIL_TO_UPDATE_TOKEN
            return

        confirmRmToken : ()->
            @$el.find("#TokenRemove").attr "disabled", "disabled"

            self = this
            App.user.removeToken( @rmToken ).then ()->
                self.updateTokenList()
                self.cancelRmToken()
            , ()->
                notification lang.NOTIFY.FAIL_TO_DELETE_TOKEN
                self.cancelRmToken()

            return

        cancelRmToken : ()->
            @rmToken = ""
            @$el.find("#TokenRemove").removeAttr "disabled"
            @$el.find("#TokenManager").show()
            @$el.find("#TokenRmConfirm").hide()
            return

        updateTokenList : ()->
            tokens = App.user.get("tokens") || []
            @$el.find("#TokenManager").find(".token-table").toggleClass( "empty", tokens.length is 0 )
            if tokens.length
                @$el.find("#TokenList").html MC.template.accessTokenTable( tokens )
            else
                @$el.find("#TokenList").empty()
            return
    }