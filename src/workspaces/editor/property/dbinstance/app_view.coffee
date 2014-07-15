
#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ '../base/view', './template/app', 'og_manage_app', 'constant' ], ( PropertyView, template, ogManageApp, constant ) ->

  CGWAppView = PropertyView.extend {

    events:
        'click .db-og-in-app': 'openOgModal'

    openOgModal: ->
        new ogManageApp @model.appId

    render : () ->
        if not @model then return

        data = @model.toJSON()
        data.optionGroups = _.map data.OptionGroupMemberships, (ogm) ->
            ogComp = Design.modelClassForType(constant.RESTYPE.DBOG).findWhere ogName: ogm.OptionGroupName
            _.extend {}, ogm, { isDefault: !ogComp, uid: ogComp?.id or '' }

        @$el.html template.appView data
        @model.get 'ogName'
  }

  new CGWAppView()
