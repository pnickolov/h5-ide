
#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ '../base/view', './template/app', 'og_manage_app', 'constant' ], ( PropertyView, template, ogManageApp, constant ) ->

  CGWAppView = PropertyView.extend {

    events:
        'click .db-og-in-app': 'openOgModal'

    openOgModal: ->
        ogModel = @resModel.connectionTargets('OgUsage')[0]
        new ogManageApp model: ogModel

    render : () ->

        data = if @model then @model.toJSON() else @view.resModel.serialize().component.resource
        if not data.Endpoint
          data = _.extend( @resModel.serialize().component.resource,  data)
          data.DBSubnetGroup.DBSubnetGroupName = this.resModel.parent().get('name')
        data.optionGroups = _.map data.OptionGroupMemberships, (ogm) ->
            ogComp = Design.modelClassForType(constant.RESTYPE.DBOG).findWhere appId: ogm.OptionGroupName
            _.extend {}, ogm, { isDefault: !ogComp, uid: ogComp?.id or '' }

        @$el.html template.appView data
        @resModel.get 'name'
  }

  new CGWAppView()
