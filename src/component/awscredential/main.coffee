####################################
#  pop-up for component/awscredential module
####################################

define [ 'jquery', 'event',
         './template', './welcome',
         'i18n!nls/lang.js'
], ( $, ide_event, template, welcome_tmpl, lang ) ->


    #template = '<script type="text/x-handlebars-template" id="aws-credential-tmpl">' + template + '</script>'
    #$( 'head' ).append template

    view  = null
    model = null

    #private
    loadModule = ( state ) ->

        #
        require [ './component/awscredential/view', './component/awscredential/model' ], ( View, Model ) ->

            return if view or model

            #
            view  = new View()
            model = new Model()

            #view
            view.model    = model

            if state is 'welcome'
                ture_template = welcome_tmpl
                view.state    = 'welcome'
                model.updateAccountService() if MC.common.cookie.getCookieByName( 'state' ) is '1'
            else
                ture_template = template
                view.state    = 'credential'

            #render
            view.render ture_template

            if state is 'welcome'
                view.showSetting('credential')
            else if MC.common.cookie.getCookieByName('has_cred') is 'true'
                # show account setting tab
                view.showSetting('account')
            else
                view.showSetting('credential', 'is_failed')

            #
            view.on 'CLOSE_POPUP', () ->
                unLoadModule()

            view.on 'AWS_AUTHENTICATION', (account_id, access_key, secret_key) ->
                console.log 'AWS_AUTHENTICATION'
                # reset key first
                if model.attributes.is_authenticated
                    model.resetKey(1)

                model.awsAuthenticate access_key, secret_key, account_id

            model.on 'REFRESH_AWS_CREDENTIAL', () ->
                console.log 'UPDATE_AWS_CREDENTIAL'

                # push event
                ide_event.trigger ide_event.UPDATE_AWS_CREDENTIAL

                if view
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

                    view.notify 'info', lang.ide.HEAD_MSG_INFO_UPDATE_EMAIL

                    # update cookie
                    MC.common.cookie.setCookieByName 'email', MC.base64Encode(attributes.email)

                    view.showSetting('account')

                if _.contains(attr_list, 'password')

                    view.notify 'info', lang.ide.HEAD_MSG_INFO_UPDATE_PASSWORD

                    view.showSetting('account')

                if _.contains(attr_list, 'access_key') and _.contains(attr_list, 'secret_key')

                    model.sync_redis()
                    model.resetKey 0
                    #view.notify 'warning', lang.ide.HEAD_MSG_ERR_RESTORE_DEMO_KEY

                null

            model.on 'UPDATE_ACCOUNT_ATTRIBUTES_FAILED', (attributes) ->
                console.log 'UPDATE_ACCOUNT_ATTRIBUTES_FAILED:' + attr_list

                attr_list = _.keys(attributes)

                if _.contains(attr_list, 'email')

                    #view.notify 'error', lang.ide.HEAD_MSG_ERR_UPDATE_EMAIL

                    view.clickUpdateEmail('is_failed')

                if _.contains(attr_list, 'password')

                    #view.notify 'error', lang.ide.HEAD_MSG_ERR_UPDATE_PASSWORD

                    view.clickUpdatePassword('error_password')

                null

            view.on 'REMOVE_CREDENTIAL', () ->
                console.log 'REMOVE_CREDENTIAL'

                #model.removeCredential()
                model.resetKey()

                null

            view.on 'CANCAL_CREDENTIAL', () ->
                console.log 'CANCAL_CREDENTIAL'

                model.resetKey(0)

                null

    unLoadModule = () ->
        console.log 'awscredential unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null
        #
        modal.close()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
