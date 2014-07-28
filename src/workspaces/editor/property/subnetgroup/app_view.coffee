#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         './template/app'
         'i18n!/nls/lang.js'
         'constant'
         'Design'
         'CloudResources'
], ( PropertyView, template, lang, constant, Design, CloudResources ) ->

  SubnetGroupView = PropertyView.extend

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
      sbCount = @$('.property-control-group input:checked').size()

      @$('.property-head-num-wrap').html "(#{sbCount})"

      if checked
        SbAsso = Design.modelClassForType( "SubnetgAsso" )
        new SbAsso @model, Design.instance().component sbId
      else
        _.each @model.connections("SubnetgAsso"), ( sbAsso )->
          if sbAsso.getTarget(constant.RESTYPE.SUBNET).id is sbId
            sbAsso.remove()

    render: ->
      return if not @appModel

      data = @appModel.toJSON()
      data.azSb = @getAzSb()
      data.sbCount = @appModel.get('Subnets')?.length or 0

      @$el.html template.app data
      @model.get 'name'

    getAzSb: ->
      azSb = {}
      sbAppResources = CloudResources(constant.RESTYPE.SUBNET, Design.instance().region())

      _.each @appModel.get('Subnets'), (sb) ->
          az = sb.SubnetAvailabilityZone.Name
          sbApp = sbAppResources.get sb.SubnetIdentifier
          azSb[az] or azSb[az] = []
          azSb[az].push name: sbApp.get('subnetId'), cidr: sbApp.get('cidrBlock')

      azSb = _.map azSb, ( subnets, az ) -> az: az, subnets: subnets
      azSb


  new SubnetGroupView()
