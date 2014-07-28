#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'Design'
         "component/dbsbgroup/DbSubnetGPopup"
], ( PropertyView, template, lang, constant, Design, DbSubnetGPopup ) ->

    SubnetGroupView = PropertyView.extend {

        events:
            'change #property-subnet-name': 'setName'
            'change #property-subnet-desc': 'setDesc'
            "click .icon-edit" : "editSgb"

        setName: (e) ->
            $target = $ e.currentTarget
            if $target.parsley 'validate'
                @model.set 'name', $target.val()

        setDesc: (e) ->
            $target = $ e.currentTarget
            if $target.parsley 'validate'
                @model.set 'description', $target.val()

        editSgb : ()->
            new DbSubnetGPopup({model:@model})
            return false

        render: ->
            data = @model.toJSON()
            data.azSb = @getAzSb()
            data.sbCount = @model.connectionTargets("SubnetgAsso").length

            @$el.html template data
            @model.get 'name'

        getAzSb: ->
            azsb = []
            azs = Design.modelClassForType(constant.RESTYPE.AZ).allObjects()
            selectedSubnetIds = _.pluck @model.connectionTargets("SubnetgAsso"), 'id'

            for az in azs
                azsb.push {
                    az: az.get('name')
                    subnets: _.map az.children(), (sb) ->
                        _.extend {checked: sb.id in selectedSubnetIds}, sb.toJSON()
                }

            azsb

    }

    new SubnetGroupView()
