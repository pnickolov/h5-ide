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
        basicsettings       : BasicSettingsView
        accesstoken         : AccessTokenView
        billing             : BillingView
        member              : MemberView
        credential          : ProviderCredentialView
        usagereport         : UsageReportView
    }

    subViewNameMap = {
        basicsettings       : 'Basic Settings'
        accesstoken         : 'Access Token'
        billing             : 'Billing'
        member              : 'Member'
        credential          : 'Provider Credential'
        usagereport         : 'Usage Report'
    }

    ProjectView = Backbone.View.extend
        events:
            'click .function-list a'    : 'loadSub'

        initialize: ( options ) ->
            @settingsView = options.settingsView

        render: ( tab = 'basicsettings' ) ->
            @$el.html TplProject _.extend @model.toJSON(), { tab: tab }
            @$('.project-subview').html @renderSub( tab ).el
            @

        loadSub: ( e ) ->
            tab = $(e.currentTarget).data('id')
            @settingsView.navigate tab, @model.id
            @$('.project-subview').html(@renderSub(tab).el)

        renderSub: ( tab ) ->
            @setTitle tab
            @activeTab tab

            @subView and @subView.remove()
            @subView = new subViewMap[ tab ]( model: @model, settingsView: @settingsView )
            @subView.render()

        setTitle: ( tab ) ->
            projectName = @model.get 'name'
            tabName = subViewNameMap[ tab ]
            @$('#title-project-name').text projectName
            @$('#title-tab-name').text tabName
            @

        activeTab: ( tab ) ->
            @$('.function-list a').each () ->
                if $(@).data( 'id' ) is tab
                    $(@).addClass 'active'
                else
                    $(@).removeClass 'active'



    ProjectView
