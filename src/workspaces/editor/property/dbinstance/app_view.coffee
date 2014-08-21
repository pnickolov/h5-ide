
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
        'click .property-btn-get-system-log': 'openSysLogModal'

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
            @modal.setContent template.log_list logList
        else
            @modal.render template.log_list_empty( {} )

        null

    openOgModal: ->
        ogModel = @resModel.connectionTargets('OgUsage')[0]
        new ogManageApp model: ogModel

    openSysLogModal: ->
        @modal or new toolbar_modal @getModalOptions()

        @modal.delegate {
            'click a.view': 'viewLog'
            'click a.download': 'downloadLog'
            'click .refresh-log': 'viewLog'
            'click .close': 'closeSlide'
        }, @

        @modal.render()
        @getLogList()

        false

    closeSlide: ->
        @modal.cancel()

    getLogList: ->
        that = @

        ApiRequest( 'rds_DescribeDBLogFiles', {
            db_identifier: @resModel.get( 'appId' )
            region_name: @resModel.design().region()
        }).then ( ( result ) ->
            logList = result?.DescribeDBLogFilesResponse?.DescribeDBLogFilesResult?.DescribeDBLogFiles?.DescribeDBLogFilesDetails or {}

            if _.size logList
                if not _.isArray logList then logList = [ logList ]
            else
                logList = null

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
            console.log log
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
            console.log log
            download = JsonExporter.download
            blob = new Blob [ log.LogFileData or '' ]
            download( blob, filename )
            modal.toggleSlide false
        )

    getLogContent: ( filename ) ->
        ApiRequest( 'rds_DownloadDBLogFilePortion', {
            db_identifier: @resModel.get( 'appId' )
            log_filename: filename
        } ).then ( result )->
            console.log result
            return result?.DownloadDBLogFilePortionResponse?.DownloadDBLogFilePortionResult or {}

    getModalOptions: ->
        that = @
        appId = @resModel.get 'appId'

        options = {
            title: "System Log: #{appId}"
            classList: 'syslog-dbinstance'
            context: that
            noCheckbox: true

            columns: [
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
                    width: "20%"
                    name: 'Size'
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
        }

        if @isSafari then options.columns.pop()

        options



  new CGWAppView()
