
#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [
    '../base/view'
    './template/app'
    'og_manage_app'
    'constant'
    'toolbar_modal'
    'ApiRequest'
    'JsonExporter'
], ( PropertyView, template, ogManageApp, constant, toolbar_modal, ApiRequest, JsonExporter ) ->

  CGWAppView = PropertyView.extend

    events:
        'click .db-og-in-app': 'openOgModal'
        'click .property-btn-get-system-log': 'openModal'

    initialize: ->
        @isSafari = $("body").hasClass("safari")

    render : () ->

        data = if @model then @model.toJSON() else @resModel.serialize().component.resource
        if not data.Endpoint
          data = _.extend( @resModel.serialize().component.resource,  data)
          data.DBSubnetGroup.DBSubnetGroupName = @resModel.parent().get('name')
        data.optionGroups = _.map data.OptionGroupMemberships, (ogm) ->
            ogComp = Design.modelClassForType(constant.RESTYPE.DBOG).findWhere appId: ogm.OptionGroupName
            _.extend {}, ogm, { isDefault: !ogComp, uid: ogComp?.id or '' }

        @$el.html template.appView data
        @resModel.get 'name'

    renderLogList: ( logList ) ->
        that = @

        if logList
            logList = _.map logList, ( log ) ->
                log.isSafari = that.isSafari
                log
            @modal.options.columns = @getLogColumns()
            @modal.setContent template.log_list logList
        else
            @modal.setContent template.list_empty( {} ), true

        null

    renderEventList: ( eventList ) ->
        that = @

        if eventList
            @modal.options.columns = @getEventColumns()
            @modal.setContent template.event_list eventList
        else
            @modal.setContent template.list_empty( {} ), true

        null


    openOgModal: ->
        ogModel = @resModel.connectionTargets('OgUsage')[0]
        new ogManageApp model: ogModel

    openModal: ->
        new toolbar_modal @getModalOptions()

        @modal.on 'slidedown', @switchLogEvent, @
        @modal.delegate {
            'click a.view': 'viewLog'
            'click a.download': 'downloadLog'
            'click .refresh-log': 'viewLog'
        }, @

        @modal.render()
        @switchLog()

        false

    switchLog: -> @getLogList()

    switchEvent: -> @getEventList()

    switchLogEvent: ( button ) ->
        @modal.toggleSlide( false ).renderListLoading()

        if button is 'event'
            @switchEvent()
        else
            @switchLog()

    getEventList: ->
        that = @

        ApiRequest( 'rds_DescribeEvents', {
            region_name: @resModel.design().region()
            source_id: @resModel.get( 'appId' )
            source_type: 'db-instance'
            event_categories: null
            duration: 20160
        }).then ( ( result ) ->
            eventList = result?.DescribeEventsResponse?.DescribeEventsResult?.Events?.Event or null
            eventList = [ eventList ] if eventList and not _.isArray( eventList )
            that.renderEventList eventList
        ), ( () ->

        )

        null

    getLogList: ->
        that = @

        ApiRequest( 'rds_DescribeDBLogFiles', {
            db_identifier: @resModel.get( 'appId' )
            region_name: @resModel.design().region()
        }).then ( ( result ) ->
            logList = result?.DescribeDBLogFilesResponse?.DescribeDBLogFilesResult?.DescribeDBLogFiles?.DescribeDBLogFilesDetails or null
            logList = [ logList ] if logList and not _.isArray( logList )
            that.renderLogList logList
        ), ( () ->
            that.renderLogList null
            null
        )

        null

    viewLog: ( e ) ->
        modal = @modal
        filename = $( e.currentTarget ).data 'fileName'

        modal.toggleSlide true
        @getLogContent( filename ).then ( ( log ) ->
            log.filename = filename
            modal.setSlide( template.log_content log )

        ), ( () ->
            log = LogFileData: '', filename: filename
            modal.setSlide( template.log_content log )
        )


    downloadLog: ( e ) ->
        modal = @modal
        filename = $( e.currentTarget ).data 'fileName'

        modal.toggleSlide true

        @getLogContent( filename ).then( ( log ) ->
            modal.toggleSlide false
            download = JsonExporter.download
            blob = new Blob [ log.LogFileData or '' ]
            download( blob, filename )
        )

    getLogContent: ( filename ) ->
        ApiRequest( 'rds_DownloadDBLogFilePortion', {
            region_name: @resModel.design().region()
            db_identifier: @resModel.get( 'appId' )
            log_filename: filename
        } ).then ( ( result )->
            return result?.DownloadDBLogFilePortionResponse?.DownloadDBLogFilePortionResult or {}
        ), ( () ->
            return {}
        )

    getModalOptions: ->
        that = @
        appId = @resModel.get 'appId'

        options = {
            title: "Log & Event: #{appId}"
            classList: 'syslog-dbinstance'
            context: that
            noCheckbox: true
            longtermActive: true

            buttons: [
                {
                    icon: 'unknown'
                    type: 'log'
                    name: 'Log'
                    active: true
                }
                {
                    icon: 'unknown'
                    type: 'event'
                    name: 'Event'
                }
            ]

        }

        options.columns = @getLogColumns()

        if @isSafari then options.columns.pop()

        options

    getLogColumns: ->
        [
            {
                sortable: true
                name: 'Name'
            }
            {
                sortable: true
                rowType: 'datetime'
                name: 'Last Written'
                width: "28%"
            }
            {
                sortable: true
                rowType: 'number'
                width: "10%"
                name: 'Size(B)'
            }
            {
                sortable: false
                width: "10%"
                name: 'View'
            }
            {
                sortable: false
                width: "10%"
                name: 'Download'
            }
        ]

    getEventColumns: ->
        [
            {
                sortable: true
                rowType: 'datetime'
                name: 'Time'
                width: "28%"
            }
            {
                sortable: true
                width: "20%"
                name: 'Source'
            }
            {
                sortable: false
                name: 'System Notes'
            }
        ]



  new CGWAppView()
