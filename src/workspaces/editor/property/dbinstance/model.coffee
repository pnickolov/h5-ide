#############################
#  View Mode for design/property/dbinstance
#############################

define [ '../base/model', 'constant', 'event', 'i18n!/nls/lang.js' ], ( PropertyModel, constant, ide_event, lang ) ->

	DBInstanceModel = PropertyModel.extend {

		init : ( uid ) ->

			component = Design.instance().component( uid )
			null
	}

	new DBInstanceModel()
