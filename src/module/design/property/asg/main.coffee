####################################
#  Controller for design/property/launchconfig module
####################################

define [ 'jquery',
         'text!/module/design/property/asg/template.html',
         'text!/module/design/property/asg/term_template.html',
         'text!/module/design/property/asg/policy_template.html',
         'text!/module/design/property/asg/app_template.html',
         'event'
], ( $, template, term_template, policy_template, app_template, ide_event ) ->

    #
    current_view     = null
    current_model    = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-asg-tmpl">' + template + '</script>'
    term_template = '<script type="text/x-handlebars-template" id="property-asg-term-tmpl">' + term_template + '</script>'
    policy_template = '<script type="text/x-handlebars-template" id="property-asg-policy-tmpl">' + policy_template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-asg-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( term_template ).append( policy_template ).append( app_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        # What does this mean ?
        MC.data.current_sub_main = current_main


        require [ './module/design/property/asg/view',
                  './module/design/property/asg/model',
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model
            #

            #view
            view.model    = model

            model.setUID uid

            if tab_type == "OPEN_APP"
                model.getASGDetailApp uid

            else
                model.getASGDetail uid

            view.render( tab_type == "OPEN_APP" )
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.asg.AutoScalingGroupName

            view.on 'SET_SNS_OPTION', ( checkArray ) ->

                model.setSNSOption uid, checkArray

            view.on 'SET_TERMINATE_POLICY', ( policies ) ->

                model.setTerminatePolicy policies

            view.on 'SET_HEALTH_TYPE', ( type ) ->

                model.setHealthCheckType uid, type

            view.on 'SET_ASG_NAME', ( name ) ->

                model.setASGName uid, name
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, name

            view.on 'SET_ASG_MIN', ( value ) ->

                model.setASGMin uid, value

            view.on 'SET_ASG_MAX', ( value ) ->

                model.setASGMax uid, value

            view.on 'SET_DESIRE_CAPACITY', ( value ) ->

                model.setASGDesireCapacity uid, value

            view.on 'SET_COOL_DOWN', ( value ) ->

                model.setASGCoolDown uid, value

            view.on 'SET_HEALTH_CHECK_GRACE', ( value ) ->

                model.setHealthCheckGrace uid, value

            view.on 'SET_POLICY', ( data ) ->

                model.setPolicy uid, data

            view.on 'DELETE_POLICY', ( uid ) ->

                model.delPolicy uid


    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
