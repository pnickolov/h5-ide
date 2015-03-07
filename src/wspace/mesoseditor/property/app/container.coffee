define [ './template/container'
         './template/containerApp'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( Tpl, TplApp, lang, constant, Modal ) ->

    Backbone.View.extend
        className: 'container-settings'
        tagName: 'form'
        events:
            'click #add-item-outside': 'addItem'
            'ADD_ROW .multi-input': 'processMapTitle'
            'REMOVE_ROW .multi-input': 'processMapTitle'

        initialize: ( options ) ->
            @appData = options.appData
            # Bind Parsley
            @$el.prop 'data-bind', true

            modalOptions =
                template        : @el
                title           : 'Container Settings'
                width           : '555px'
                height          : '473px'
                compact         : true
                mode            : 'panel'
                confirm         :
                    text        : 'Save'

            @modal = new Modal modalOptions
            @modal.on 'confirm', @save, @

        render: () ->
            # App Mode
            if @appData
                @$el.html TplApp @appData

            # Stack Model
            else
                @$el.html Tpl @model.container()

        remove: () ->
            @modal?.close()
            Backbone.View.prototype.remove.apply @, arguments

        addItem: ( e ) ->
            $( e.currentTarget ).closest( '.input-item' ).find( '.ipt-controls .icon-add' ).eq( 0 ).click()
            false

        save: ->
            form = @$el
            if not form.parsley 'validate'
                return

            data = @getContainer form

            @model.set 'container', data
            @remove()

        getContainer: ( form ) ->
            data = { docker: {} }
            _.each form.serializeArray(), ( filed ) -> data.docker[ filed.name ] = filed.value

            data.docker.portMappings   = @getMapData @$ '.port-mappings'
            data.docker.parameters     = @getMapData @$ '.parameters'
            data.docker.privileged     = @$( '#cb-privileged' )[ 0 ].checked

            data.volumes        = @getMapData @$ '.volumes'

            data

        getMapData: ( $dom ) ->
            data = []

            $dom.find( '.multi-ipt-row:not(.template)' ).each ->
                item = {}
                $(@).find( '.input' ).each ->
                    $input = $ @
                    value = $input.val()
                    name = $input.data( 'name' )

                    # Some value must be number.
                    if name in [ 'host', 'serviceport' ]
                        value = +value

                    if name is 'container'
                        splits              = value.split '/'
                        item.containerPort  = +splits[ 0 ]
                        item.protocol       = splits[ 1 ]

                    else if name is 'containerPath'
                        splits              = value.split ':'
                        item.containerPath  = splits[ 0 ]
                        item.mode           = splits[ 1 ]

                    else
                        item[ name ] = value

                data.push item

            data

        processMapTitle: ( e ) ->
            $multiInput = $( e.currentTarget )
            hasItem = $multiInput.find( '.multi-ipt-row' ).length > 1

            $multiInput.prev( '.titles' ).toggle hasItem



