####################################
#  pop-up for component/awscredential module
####################################

define [ 'jquery', 'event',
         'text!./template.html'
], ( $, ide_event, template ) ->


    #template = '<script type="text/x-handlebars-template" id="aws-credential-tmpl">' + template + '</script>'
    #$( 'head' ).append template

    #private
    loadModule = () ->

        #
        require [ './component/awscredential/view', './component/awscredential/model' ], ( View, Model ) ->

            #
            view  = new View()
            model = new Model()

            #view
            view.model    = model

            #render
            view.render template

            if $.cookie('has_cred') is 'true'
                # show account setting tab
                view.showSetting('account')
            else
                # show credential setting tab
                view.showSetting('credential', 'is_failed')

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
                    view.showSetting('credential', 'load_resource')

                    # hold on 2 second
                    setTimeout () ->
                        view.showSetting('credential', 'on_update')
                    , 2000

                else
                    view.showSetting('credential', 'is_failed')



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