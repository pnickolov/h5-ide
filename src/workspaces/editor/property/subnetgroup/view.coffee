#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'Design'
], ( PropertyView, template, lang, constant, Design ) ->

    SubnetGroupView = PropertyView.extend {

        events:
            'change .select-subnet-id': 'selectSubnetId'
            'change #property-subnet-name': 'setName'
            'change #property-subnet-desc': 'setDesc'

        setName: (e) ->
            $target = $ e.currentTarget
            if $target.parsley 'validate'
                @model.set 'name', $target.val()

        setDesc: (e) ->
            $target = $ e.currentTarget
            if $target.parsley 'validate'
                @model.set 'description', $target.val()

        selectSubnetId: (e) ->
            sbId = e.currentTarget.id.slice 5
            checked = e.currentTarget.checked

            if checked
                SbAsso = Design.modelClassForType( "SbAsso" )
                new SbAsso @model, Design.instance().component sbId
            else
                _.each @model.connections("SbAsso"), ( sbAsso )->
                    if sbAsso.getTarget(constant.RESTYPE.SUBNET).id is sbId
                        sbAsso.remove()

        render: ->
            data = @model.toJSON()
            data.azSb = @getAzSb()

            @$el.html template data
            @model.get 'name'

        getAzSb: ->
            azsb = []
            azs = Design.modelClassForType(constant.RESTYPE.AZ).allObjects()
            selectedSubnetIds = _.pluck @model.connectionTargets("SbAsso"), 'id'

            for az in azs
                azsb.push {
                    az: az.get('name')
                    subnets: _.map az.children(), (sb) ->
                        _.extend {checked: sb.id in selectedSubnetIds}, sb.toJSON()
                }

            azsb

    }

    new SubnetGroupView()
