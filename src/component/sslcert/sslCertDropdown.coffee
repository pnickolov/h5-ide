define [ 'constant', 'CloudResources','sslcert_manage', 'combo_dropdown', './component/sslcert/sslCertTpl', 'i18n!nls/lang.js' ], ( constant, CloudResources, sslCertManage, comboDropdown, template, lang ) ->


    sslCertCol = CloudResources constant.RESTYPE.IAM

    window.sslCertCol = sslCertCol

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            @sslCertCol = CloudResources constant.RESTYPE.IAM
            @sslCertCol.on 'update', @processCol, @

        initDropdown: ->
            options =
                manageBtnValue      : lang.ide.PROP_INSTANCE_MANAGE_SSL_CERT
                filterPlaceHolder   : lang.ide.PROP_INSTANCE_FILTER_SSL_CERT

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manage, @
            @dropdown.on 'change', @set, @
            @dropdown.on 'filter', @filter, @

        initialize: () ->
            @initCol()
            @initDropdown()


        render: ->
            @dropdown.setSelection (@sslCertName or 'None')
            @el = @dropdown.el
            @

        processCol: ( filter, keyword ) ->

            if @sslCertCol.isReady()

                data = @sslCertCol.map (sslCertModel) ->
                    sslCertData = sslCertModel.toJSON()
                    return sslCertData

                if filter
                    len = keyword.length
                    data = _.filter data, ( d ) ->
                        d.Name.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1

                @renderDropdownList data

            false

        renderDropdownList: ( data ) ->
            @dropdown.setContent(template.dropdown_list data).toggleControls true

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->
            if App.user.hasCredential()
                @sslCertCol.fetch()
                @processCol()
            else
                @renderNoCredential()

        manage: ->
            new sslCertManage().render()

        set: ->

        filter: (keyword) ->
            @processCol( true, keyword )
