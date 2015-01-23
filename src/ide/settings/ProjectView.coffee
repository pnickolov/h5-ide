define [
    'i18n!/nls/lang.js'
    './template/TplProject'
    './projectSubViews/BasicSettingsView'
    './projectSubViews/AccessTokenView'
    './projectSubViews/BillingView'
    './projectSubViews/MemberView'
    './projectSubViews/ProviderCredentialView'
    './projectSubViews/UsageReportView'
    'backbone'
], ( lang, TplProject, BasicSettingsView, AccessTokenView, BillingView, MemberView, ProviderCredentialView, UsageReportView ) ->

    subViewMap = {
        BasicSettings       : BasicSettingsView
        AccessToken         : AccessTokenView
        Billing             : BillingView
        Member              : MemberView
        ProviderCredential  : ProviderCredentialView
        UsageReport         : UsageReportView
    }

    subViewNameMap = {
        BasicSettings       : 'Basic Settings'
        AccessToken         : 'Access Token'
        Billing             : 'Billing'
        Member              : 'Member'
        ProviderCredential  : 'Provider Credential'
        UsageReport         : 'Usage Report'
    }

    ProjectView = Backbone.View.extend
        events:
            'click .function-list a'    : 'loadSub'

        initialize: ( options ) ->
            @settingsView = options.settingsView

        render: ( tab = 'BasicSettings' ) ->
            @$el.html TplProject { tab: tab }
            @$('.project-subview').html @renderSub( tab ).el
            @

        loadSub: ( e ) ->
            @$('.project-subview').html(@renderSub($(e.currentTarget).data('id')).el)

        renderSub: ( tab ) ->
            @setTitle tab
            @activeTab tab

            @subView and @subView.remove()
            @subView = new subViewMap[ tab ]( model: @model, settingsView: @settingsView )
            @subView.render()

        setTitle: ( tab ) ->
            projectName = @model.get 'name'
            tabName = subViewNameMap[ tab ]
            @$('.project-title').html "#{projectName} / #{tabName}"

        activeTab: ( tab ) ->
            @$('.function-list a').each () ->
                if $(@).data( 'id' ) is tab
                    $(@).addClass 'active'
                else
                    $(@).removeClass 'active'



    ProjectView
