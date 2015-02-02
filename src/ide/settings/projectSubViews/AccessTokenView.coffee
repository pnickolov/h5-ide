define [ 'backbone', "../template/TplAccessToken", 'i18n!/nls/lang.js', "ApiRequest", "UI.scrollbar" ], (Backbone,template, lang, ApiRequest) ->
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
            @tokens = []
            @

        render: ->
            self = @
            @$el.html MC.template.loadingSpinner()
            project_id = @model.get("id")
            ApiRequest("token_list", {project_id}).then (res)->
              console.log res
              self.$el.html template()
              self.tokens = res[0].tokens
              self.updateTokenList()

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
            tmpl = "MyToken"
            base = 1
            nameMap = {}
            for t in @tokens
                nameMap[ t.name ] = true
            while true
                token_name = tmpl + base
                if nameMap[ token_name ]
                    base += 1
                else
                    break
            project_id = @model.get("id")
            ApiRequest("token_create", {token_name, project_id}).then (res)->
                [name, token] = res
                self.tokens.push {name, token}
                self.updateTokenList()
                self.$el.find("#TokenCreate").removeAttr "disabled"
            , ()->
                notification "error", lang.NOTIFY.FAIL_TO_CREATE_TOKEN
                self.$el.find("#TokenCreate").removeAttr "disabled"
            return

        doneEditToken : ( evt )->
            self = this
            $p = $(evt.currentTarget).closest("li").removeClass("editing")
            $p.children(".tokenName").attr "readonly", true
            token        = $p.children(".tokenToken").text()
            new_token_name = $p.children(".tokenName").val()

            for t in  @tokens
                if t.token is token
                    oldName = t.name
                else if t.name is new_token_name
                    duplicate = true

            if not new_token_name or duplicate
                $p.children(".tokenName").val( oldName )
                return
            project_id = @model.get("id")
            ApiRequest("token_update", {token, new_token_name, project_id}).then ( res )->
                for t, idx in self.tokens
                    if t.token is token
                        t.name = new_token_name
                        break
            ,()->
                # If anything goes wrong, revert the name
                oldName = ""
                $p.children(".tokenName").val( oldName )
                notification "error", lang.NOTIFY.FAIL_TO_UPDATE_TOKEN
            return

        confirmRmToken : ()->
            @$el.find("#TokenRemove").attr "disabled", "disabled"
            self = this
            for t, idx in @tokens
              if t.token is @rmToken
                break
            project_id = @model.get("id")
            token = @rmToken
            token_name = t.name
            ApiRequest("token_remove", {project_id, token, token_name}).then ( res )->
              idx = self.tokens.indexOf t
              if idx >= 0
                self.tokens.splice idx, 1
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

        hasNoToken: ()->
            @tokens.length is 0 or (@tokens.length is 1 and not @tokens[0].name)

        updateTokenList : ()->
            tokens = @tokens
            hasNoToken = @hasNoToken()
            @$el.find("#TokenManager").find(".token-table").toggleClass( "empty", hasNoToken )
            if not hasNoToken
                @$el.find("#TokenList").html MC.template.accessTokenTable( tokens )
            else
                @$el.find("#TokenList").empty()
            return
    }