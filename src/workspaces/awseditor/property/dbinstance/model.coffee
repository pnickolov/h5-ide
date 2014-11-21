#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'event', 'i18n!/nls/lang.js' ], ( PropertyModel, constant, ide_event, lang ) ->

	DBInstanceModel = PropertyModel.extend

		init : ( uid ) ->

			component = Design.instance().component( uid )
			attr = component?.toJSON()
			attr.uid = uid
			@set attr

			null

	new DBInstanceModel()
