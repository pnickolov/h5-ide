#############################
#  View(UI logic) for navigation
#############################

define [ 'event', 'app_model', 'backbone', 'jquery', 'handlebars' ], ( event, app_model ) ->

    NavigationModel = Backbone.Model.extend {

        default : {

        }

        constructor : ->
            #get service(model)
            app_model.list { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null
            app_model.on 'APP_LST_RETURN', ( result ) ->
                console.log 'APP_LST_RETURN'
                console.log result
                #this.trigger 'APP_LST_RETURN', result

    }

    model = new NavigationModel()

    return model