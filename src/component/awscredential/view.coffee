#############################
#  View(UI logic) for component/awscredential
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'UI.notification'
], ( ide_event, lang ) ->

    AWSCredentialView = Backbone.View.extend {

        events   :
            'closed'                                : 'onClose'
            'click #awsredentials-submit'           : 'onSubmit'
            'click #awsredentials-update-done'      : 'onDone'
            'click .AWSCredentials-account-update'  : 'onUpdate'
            'click #account-setting-tab li a'       : 'onTab'
            'click #account-update-email-link'      : 'onChangeEmail'
            'click #account-change-password'        : 'onChangePassword'
            'click #account-email-update'           : 'clickUpdateEmail'
            'click #account-email-cancel'           : 'clickCancelEmail'
            'click #account-password-update'        : 'clickUpdatePassword'
            'click #account-password-cancel'        : 'clickCancelPassword'

        render     : (template) ->
            console.log 'account_setting_tab render'
            #
            modal template, false
            #
            this.setElement $( '#AWSCredential-setting' ).closest '#modal-wrap'

        onClose : ->
            console.log 'account_setting_tab onClose'
            this.trigger 'CLOSE_POPUP'

        onDone : ->
            console.log 'account_setting_tab onDone'
            modal.close()
            this.trigger 'CLOSE_POPUP'

        onUpdate : ->
            console.log 'account_setting_tab onUpdate'

            me = this

            me.showSetting('credential', 'in_update')

        onSubmit : () ->
            console.log 'account_setting_tab onSubmit'

            me = this

            # input check
            account_id = $('#aws-credential-account-id').val().trim()
            access_key = $('#aws-credential-access-key').val().trim()
            secret_key = $('#aws-credential-secret-key').val().trim()

            if not account_id
                notification 'error', lang.ide.HEAD_MSG_ERR_INVALID_ACCOUNT_ID

            else if not access_key
                notification 'error', lang.ide.HEAD_MSG_ERR_INVALID_ACCESS_KEY

            else if not secret_key
                notification 'error', lang.ide.HEAD_MSG_ERR_INVALID_SECRET_KEY

            else
                # show AWSCredentials-submiting
                me.showSetting('credential', 'on_submit')

                me.trigger 'AWS_AUTHENTICATION', account_id, access_key, secret_key

        onTab : (event) ->
            console.log 'account_setting_tab onTab'

            me = this

            obj = $(event.currentTarget)
            if obj.text() is 'AWS Credentials'
                if $.cookie('has_cred') is 'true'
                    me.showSetting('credential', 'on_update')
                else
                    me.showSetting('credential', 'is_failed')

            else
                me.showSetting('account')

            null

        onChangeEmail : (event) ->
            console.log 'account_setting_tab onChangeEmail'

            me = this

            me.showSetting('account', 'on_email')

            null

        clickUpdateEmail : (event) ->
            console.log 'account_setting_tab clickUpdateEmail'

            me = this

            email = $('#account-email-input').val()
            status = $('#email-verification-status')
            status.removeClass 'error-status'

            if email

                # check email format
                if email isnt '' and /\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}/.test(email)  # not email
                    if email is MC.base64Decode($.cookie('email')) # repeat
                        status.show().text 'This email is repeat.'
                    else
                        me.trigger 'UPDATE_ACCOUNT_EMAIL', email
                else
                    status.show().text 'It`s not an email address.'

        clickCancelEmail : (event) ->
            console.log 'account_setting_tab clickCancelEmail'

            me = this

            me.showSetting('account')

        onChangePassword : (event) ->
            console.log 'account_setting_tab onChangePassword'

            me = this

            if $('#account-password-wrap').css('display') == 'none'
                me.showSetting('account', 'on_password')
            else
                me.showSetting('account')

            null

        clickUpdatePassword : (flag) ->
            console.log 'account_setting_tab onUpdatePassword'

            me = this

            password        = $('#account-current-password').val()
            new_password    = $('#account-new-password').val()

            if not password or not new_password

                $('#account-passowrd-info').show()
                $('#account-passowrd-info').text lang.ide.HEAD_MSG_ERR_NULL_PASSWORD

            else if new_password is $.cookie('username') or new_password.length <= 6

                $('#account-passowrd-info').show()
                $('#account-passowrd-info').text lang.ide.HEAD_MSG_ERR_INVALID_PASSWORD

            else if flag is 'error_password'

                $('#account-passowrd-info').show()

                #html_str = sprintf lang.ide.HEAD_MSG_ERR_ERROR_PASSWORD, '<a href=\"javascript:void(0)\">', lang.ide.HEAD_MSG_ERR_RESET_PASSWORD, '</a>'
                #$('#account-passowrd-info').html html_str
                $('#account-passowrd-info').html 'Current password is wrong. <a href="javascript:void(0)">Forget password?</a>'

            else

                $('#account-passowrd-info').hide()
                me.trigger 'UPDATE_ACCOUNT_PASSWORD', password, new_password

        clickCancelPassword : (event) ->
            console.log 'account_setting_tab clickCancelPassword'

            me = this

            me.showSetting('account')

        notify : (type, msg) ->
            notification type, msg

        # show account setting tab or credential setting tab
        showSetting : (tab, flag) ->
            console.log 'account_setting_tab tab and flag:' + tab + ', ' + flag

            me = this

            if tab is 'account'
                $('#account-profile-setting').show()
                $('#AWSCredential-setting').hide()

                $('#account-profile-setting-body').show()
                $('#account-profile-setting-username').show()
                $('#account-profile-setting-email').show()

                if not flag

                    $('#account-email-change-wrap').show()
                    $('#account-email-input-wrap').hide()
                    $('#account-password-wrap').hide()

                    $('#account-profile-username').text $.cookie('username')
                    $('#account-profile-email').text MC.base64Decode($.cookie('email'))

                else if flag is 'on_email'

                    $('#account-email-change-wrap').hide()
                    $('#account-email-input-wrap').show()
                    $('#account-password-wrap').hide()

                    $('#account-email-input').val MC.base64Decode($.cookie('email'))

                else if flag is 'on_password'

                    $('#account-email-change-wrap').show()
                    $('#account-email-input-wrap').hide()
                    $('#account-password-wrap').show()
                    $('#account-passowrd-info').hide()

                    # clear input password
                    $('#account-current-password').val('')
                    $('#account-new-password').val('')

            else if tab is 'credential'

                $('#account-profile-setting').hide()
                $('#AWSCredential-setting').show()
                #$('.modal-footer').hide()

                if not flag     # initial

                    $('#AWSCredential-form').show()
                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').hide()

                    # set content
                    $('#aws-credential-account-id').val(' ')
                    $('#aws-credential-access-key').val(' ')
                    $('#aws-credential-secret-key').val(' ')

                    $('#AWSCredential-failed').hide()
                    $('#AWSCredential-info').show()

                else if flag is 'is_failed'

                    $('#AWSCredential-form').show()
                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').hide()

                    $('#AWSCredential-failed').show()
                    $('#AWSCredential-info').hide()

                else if flag is 'on_update'

                    $('#AWSCredential-form').hide()
                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').show()

                    $('#AWSCredential-failed').hide()
                    $('#AWSCredential-info').show()
                    $('#aws-credential-update-account-id').text me.model.attributes.account_id

                else if flag is 'in_update'

                    $('#AWSCredential-form').show()
                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').hide()

                    # set content
                    $('#aws-credential-account-id').val me.model.attributes.account_id

                else if flag is 'on_submit'

                    $('#AWSCredential-form').hide()
                    $('#AWSCredentials-submiting').show()
                    $('#AWSCredentials-update').hide()

                else if flag is 'load_resource'

                    $('#AWSCredential-form').hide()
                    $('#AWSCredentials-submiting').show()
                    $('#AWSCredentials-update').hide()

                    $('#AWSCredentials-loading-text').text('Loading resources...')

            null

    }

    return AWSCredentialView