####################################
#  pop-up for component/awscredential module
####################################

define [ 'jquery', 'event',
         'text!./template.html',
         'i18n!nls/lang.js'
], ( $, ide_event, template, lang ) ->


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
                if $.cookie('new_account')
                    view.showSetting('credential')
                else
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

            view.on 'UPDATE_ACCOUNT_EMAIL', (email) ->
                console.log 'UPDATE_ACCOUNT_EMAIL'

                model.updateAccountEmail(email)

            view.on 'UPDATE_ACCOUNT_PASSWORD', (password, new_password) ->
                console.log 'UPDATE_ACCOUNT_PASSWORD'

                model.updateAccountPassword(password, new_password)

            model.on 'UPDATE_ACCOUNT_ATTRIBUTES_SUCCESS', (attributes) ->
                console.log 'UPDATE_ACCOUNT_ATTRIBUTES_SUCCESS:' + attr_list

                attr_list = _.keys(attributes)

                if _.contains(attr_list, 'email')
                    $.cookie 'email', MC.base64Encode(attributes['email']),    { expires: 1 }

                    view.notify 'info', lang.ide.HEAD_MSG_INFO_UPDATE_EMAIL

                if _.contains(attr_list, 'password')

                    view.notify 'info', lang.ide.HEAD_MSG_INFO_UPDATE_PASSWORD

                view.showSetting('account')

            model.on 'UPDATE_ACCOUNT_ATTRIBUTES_FAILED', (attributes) ->
                console.log 'UPDATE_ACCOUNT_ATTRIBUTES_FAILED:' + attr_list

                attr_list = _.keys(attributes)

                if _.contains(attr_list, 'email')

                    view.notify 'error', lang.ide.HEAD_MSG_ERR_UPDATE_EMAIL

                    view.showSetting('account')

                if _.contains(attr_list, 'password')

                    view.notify 'error', lang.ide.HEAD_MSG_ERR_UPDATE_PASSWORD

                    view.clickUpdatePassword('error_password')


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