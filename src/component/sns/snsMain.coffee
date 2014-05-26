define [ 'constant', 'CloudResources', 'combo_dropdown', 'toolbar_modal', './component/sns/snsTpl', 'i18n!nls/lang.js' ], ( constant, CloudResources, combo_dropdown, toolbar_modal, template, lang ) ->


    subCol = CloudResources constant.RESTYPE.SUBSCRIPTION, 'us-east-1'
    topicCol = CloudResources constant.RESTYPE.TOPIC, 'us-east-1'


    window.subCol = subCol
    window.topicCol = topicCol


    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            region = Design.instance().region()
            @subCol = CloudResources constant.RESTYPE.SUBSCRIPTION, region
            @topicCol = CloudResources constant.RESTYPE.TOPIC, region
            @topicCol.on 'update', @processCol, @
            @subCol.on 'update', @processCol, @

        initDropdown: ->
            options =
                manageBtnValue      : lang.ide.PROP_INSTANCE_MANAGE_SNS
                filterPlaceHolder   : lang.ide.PROP_INSTANCE_FILTER_SNS

            @dropdown = new combo_dropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manage, @
            @dropdown.on 'change', @set, @
            @dropdown.on 'filter', @filter, @

        initialize: () ->
            @initCol()
            @initDropdown()


        render: ->
            selection = 'FOO'
            @dropdown.setSelection selection
            @el = @dropdown.el
            @

        processCol: ( filter, keyword ) ->
            if @topicCol.isReady() and @subCol.isReady()

                data = @topicCol.map ( tModel ) ->
                    tData = tModel.toJSON()
                    sub = @subCol.where TopicArn: tData.id
                    tData.sub = sub.map ( sModel ) -> sModel.toJSON()
                    tData.subCount = tData.sub.length
                    tData

                if filter
                    len = keyword.length
                    data = _.filter data, ( d ) ->
                        d.Name.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1


                @renderDropdownList data

            false


        renderDropdownList: ( data ) ->
            @dropdown.setContent( template.dropdown_list data ).toggleControls true

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->
            if App.user.hasCredential()
                @topicCol.fetch()
                @subCol.fetch()
                @processCol()
            else
                @renderNoCredential()

        manage: ->

        set: ->

        filter: ( keyword ) ->
            @processCol( true, keyword )




