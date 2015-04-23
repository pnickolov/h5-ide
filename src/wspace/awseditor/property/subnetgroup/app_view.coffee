#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         './template/app'
         'i18n!/nls/lang.js'
         'constant'
         'Design'
         'CloudResources'
         'ApiRequest'
], ( PropertyView, template, lang, constant, Design, CloudResources, ApiRequest ) ->

  SubnetGroupView = PropertyView.extend

    render: ->
      return if not @appModel

      data = @appModel.toJSON()
      data.azSb = @getAzSb()
      data.sbCount = @appModel.get('Subnets')?.length or 0
      data.name = @model.get 'name'

      @$el.html template.app data
      @renderTagSet()
      data.name

    renderTagSet: (failed, reason)->
      if failed and reason
        @$el.find(".tagTable").html "<div class='dl-vertical'>" + reason + "</div>"
        return false
      if @tagSet
        @$el.find(".tagTable").html template.tagSets {tagSet: @tagSet}
      else
        that = @
        region = Design.instance().region()
        accountNumber = Design.instance().credential().get("awsAccount").split("-").join("")
        if (/^\d+$/).test(accountNumber) is false
          that.renderTagSet(true, lang.PROP.DB_SNAPSHOT_ACCOUNT_NUMBER_INVALID)
          return false
        resourceType = "subgrp"
        name = @appModel.get("id")
        arn = "arn:aws:rds:#{region}:#{accountNumber}:#{resourceType}:#{name}"
        ApiRequest("rds_ListTagsForResource", {
          key_id : Design.instance().credentialId()
          region_name: region
          resource_name: arn
        }).then (result)->
          tagSet = {}
          tags = result.ListTagsForResourceResponse.ListTagsForResourceResult.TagList.Tag || []
          if not tags.length and not _.isArray tags
            tags = [tags]
          _.each tags, (value)->
            tagSet[value.Key] = value.Value
            null
          that.tagSet = tagSet
          that.renderTagSet()
        , ()->
          that.renderTagSet(true, lang.PROP.DB_DB_SUBGROUP_FAILED_FETCHING_TAGS)

    getAzSb: ->
      azSb = {}
      sbAppResources = CloudResources(Design.instance().credentialId(), constant.RESTYPE.SUBNET, Design.instance().region())

      _.each @appModel.get('Subnets'), (sb) ->
          az = sb.SubnetAvailabilityZone.Name
          sbApp = sbAppResources.get sb.SubnetIdentifier
          azSb[az] or azSb[az] = []
          azSb[az].push name: sbApp.get('subnetId'), cidr: sbApp.get('cidrBlock')

      azSb = _.map azSb, ( subnets, az ) -> az: az, subnets: subnets
      azSb


  new SubnetGroupView()
