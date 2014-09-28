#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'Design'
         "DbSubnetGPopup"
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
            that = @
            subnetGPopup = new DbSubnetGPopup({model:@model})
            @listenTo subnetGPopup, 'update', () ->
                that.render()
                @stopListening subnetGPopup
                subnetGPopup.remove()

            return false

        render: ->
            subnets = @model.connectionTargets("SubnetgAsso").map ( sb )->
                {
                    name : sb.get("name")
                    cidr : sb.get("cidr")
                    az   : sb.parent().get("name")
                }

            data         = @model.toJSON()
            data.sbCount = subnets.length
            data.azSb    = _.groupBy subnets, "az"
            data.isAppEdit = @isAppEdit

            @$el.html template data
            @model.get 'name'
    }

    new SubnetGroupView()
