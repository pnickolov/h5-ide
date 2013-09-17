####################################
#  pop-up for component/awscredential module
####################################

define [ 'jquery', 'event',
         'text!./template.html'
], ( $, ide_event, template ) ->


    #template = '<script type="text/x-handlebars-template" id="aws-credential-tmpl">' + template + '</script>'
    #$( 'head' ).append template

    #private
    loadModule = (flag) ->

        #
        require [ './component/awscredential/view', './component/awscredential/model' ], ( View, Model ) ->

            #
            view  = new View()
            model = new Model()

            #view
            view.model    = model

            #render
            view.render template

            if flag is 'new_account'
                view.showSet 'new_account'

            else if model.attributes.is_authenticated
                view.showUpdate()
            else
                if MC.forge.cookie.getCookieByName('has_cred') is 'false' then view.showSet 'is_failed' else view.showSet()

            #
            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            view.on 'AWS_AUTHENTICATION', (account_id, access_key, secret_key) ->
                console.log 'AWS_AUTHENTICATION'
                model.awsAuthenticate access_key, secret_key, account_id

            model.on 'REFRESH_AWS_CREDENTIAL', () ->
                console.log 'UPDATE_AWS_CREDENTIAL'

                # push event
                ide_event.trigger ide_event.UPDATE_AWS_CREDENTIAL

                if model.attributes.is_authenticated

                    # update loading
                    view.showSubmit('LOAD_RESOURCE')

                    # if MC.data.dashboard_type is 'OVERVIEW_TAB'     # overview tab

                    #     #ide_event.onLongListen ide_event.
                    # else if MC.data.dashboard_type is 'REGION_TAB'  # region tab

                    # else    # stack/app tab
                    # hold on 2 second
                    setTimeout () ->
                        view.showUpdate()
                    , 2000

                else
                    view.showSet('is_failed')



    unLoadModule = ( view, model ) ->
        console.log 'awscredential unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule