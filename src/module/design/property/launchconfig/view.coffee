#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars',
        'UI.selectbox',
        'UI.tooltip',
        'UI.notification',
        'UI.modal',
        'UI.tablist',
        'UI.toggleicon' ], ( ide_event, MC ) ->

    LanchConfigView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-launchconfig-tmpl' ).html()

        events   :
            'change .launch-configuration-name'           : 'lcNameChange'
            'change .instance-type-select'                : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-source-check'      : 'sourceCheckChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select'               : "tenancySelect"
            'OPTION_CHANGE #keypair-select'               : "addtoKPList"
            'EDIT_UPDATE #keypair-select'                 : "createtoKPList"

            'click #property-ami'                         : 'openAmiPanel'

        render     : ( attributes ) ->
            console.log 'property:instance render'

            $( '.property-details' ).html this.template this.model.attributes

            this.delegateEvents this.events

        lcNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            id = @model.get 'get_uid'
            MC.validate.preventDupname target, id, name, 'LaunchConfiguration'

            if target.parsley 'validate'
                @trigger "NAME_CHANGE", name

        instanceTypeSelect : ( event, value )->
            this.model.set 'instance_type', value

        ebsOptimizedSelect : ( event ) ->
            this.model.set 'ebs_optimized', event.target.checked

        tenancySelect : ( event, value ) ->
            this.model.set 'tenacy', value


        cloudwatchSelect : ( event ) ->
            this.model.set 'cloudwatch', event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            this.model.set 'user_data', event.target.value

        sourceCheckChange : ( event ) ->
            this.model.set 'source_check', event.target.checked

        addtoKPList : ( event, id ) ->
            this.model.set 'set_kp', id
            notification('info', (id + ' added'), false)
            this.trigger 'REFRESH_KEYPAIR'

        createtoKPList : ( event, id ) ->
            this.model.set 'add_kp', id
            notification('info', (id + ' created'), false)

        openAmiPanel : ( event ) ->
            target = $('#property-ami')

            console.log MC.template.aimSecondaryPanel target.data( 'secondarypanel-data' )
            ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL, {
                title : $( event.target ).text()
                dom   : MC.template.aimSecondaryPanel target.data( 'secondarypanel-data' )
                id    : 'Ami'
            }
            null

    }

    view = new LanchConfigView()

    return view
