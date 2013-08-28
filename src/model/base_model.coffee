#*************************************************************************************
#* Filename     : stack_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:05
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone' ], () ->

    BaseModel = Backbone.Model.extend {

        ERROR : 'SERVICE_ERROR'

        pub   : ( error ) ->
            console.log 'pub'
            console.log error
            base_model.trigger @ERROR, error

        sub   : ( callback ) ->
            console.log 'sub'
            base_model.on @ERROR, callback
    }

    #############################################################
    #private (instantiation)
    base_model = new BaseModel()

    #public (exposes methods)
    base_model

