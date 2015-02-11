define [
    'i18n!/nls/lang.js'
    './template/TplProject'
    './views/BasicSettingsView'
    './views/AccessTokenView'
    './views/BillingView'
    './views/MemberView'
    './views/ProviderCredentialView'
    './views/UsageReportView'
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

    Backbone.View.extend
        events:
            'click .function-list a'    : 'loadSub'

        initialize: ( options ) ->
            @settingsView = options.settingsView
            @listenTo @model, 'change:name', @updateProjectName

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
