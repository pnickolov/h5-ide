define [
    'i18n!/nls/lang.js'
    './template/TplProject'
    './views/BasicSettingsView'
    './views/AccessTokenView'
    './views/BillingView'
    './views/TeamView'
    './views/ProviderCredentialView'
    './views/UsageReportView'
    'backbone'
], ( lang, TplProject, BasicSettingsView, AccessTokenView, BillingView, TeamView, ProviderCredentialView, UsageReportView ) ->

    subViewMap = {
        basicsettings       : BasicSettingsView
        accesstoken         : AccessTokenView
        billing             : BillingView
        team                : TeamView
        credential          : ProviderCredentialView
        usagereport         : UsageReportView
    }

    subViewNameMap = {
        basicsettings       : 'Basic Settings'
        accesstoken         : 'API Token'
        billing             : 'Billing'
        team                : 'Team'
        credential          : 'Cloud Access Credential'
        usagereport         : 'Usage Report'
    }

    Backbone.View.extend

        events:
            'click .function-list a'    : 'loadSub'

        initialize: ( options ) ->

            that = @
            @settingsView = options.settingsView
            @listenTo @model, 'change:name', @updateProjectName
            @listenTo @model, 'change:myRole', @refresh, @

        render: ( tab = 'basicsettings' ) ->
            @setElement $( TplProject _.extend @model.toJSON(), { tab: tab, admin:@model.amIAdmin() } )
            @$('.project-subview').html @renderSub( tab ).el
            @

        setElement: ( element, delegate ) ->
            if this.$el then @undelegateEvents()
            this.$el = if element instanceof Backbone.$ then element else Backbone.$( element )
            this.el = this.$el
            if delegate isnt false then this.delegateEvents()
            @

        refresh: () ->

            tab = @$('.function-list a.active').data('id')
            @settingsView.renderProject @model, tab

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

        updateProjectName: () ->

            @$('.settings-nav-project-title').text @model.get 'name'
            @$( '#title-project-name' ).text @model.get 'name'
