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
            subnetId = e.currentTarget.id.slice 7
            checked = e.currentTarget.checked

            selectedSubnetIds = @model.get 'subnetIds'

            if checked
                selectedSubnetIds.push subnetId
            else
                selectedSubnetIds = _.reject selectedSubnetIds, (id) -> id is subnetId

            @model.set 'subnetIds', selectedSubnetIds

        render: ->
            data = @model.toJSON()
            data.azSb = @getAzSb()

            @$el.html template data
            @

        getAzSb: ->
            azsb = []
            azs = Design.modelClassForType(constant.RESTYPE.AZ).allObjects()
            selectedSubnetIds = @model.get 'subnetIds'

            for az in azs
                azsb.push {
                    az: az.get('name')
                    subnets: _.map az.children(), (model) ->
                        _.extend {checked: model.get('name') in selectedSubnetIds}, model.toJSON()
                }

            azsb

    }

    new SubnetGroupView()