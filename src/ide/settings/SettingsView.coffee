define [ 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus", "./template/TplSettings", "backbone" ], ( lang, ApiRequest, Modal, TplSettings ) ->
    SettingsView = Backbone.View.extend {
        events:
            '': ''

        initialize: ( options ) ->
            @modal = new Modal {
                template: TplSettings
                mode: 'fullscreen'
                disableFooter: true
                compact: true
                width: "490px"
            }

    }

    SettingsView.TAB =
      CredentialInvalid : -1
      Normal            : 0
      Credential        : 1
      Token             : 2

    SettingsView