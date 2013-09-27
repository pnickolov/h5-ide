#############################
#  View(UI logic) for component/awscredential
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'constant',
         'text!./form.html', 'text!./loading.html', 'text!./skip.html',
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'UI.notification'
], ( ide_event, lang, constant, form_tmpl, loading_tmpl, skip_tmpl ) ->

    last_account_id = null
    last_access_key = null
    last_secret_key = null

    AWSCredentialView = Backbone.View.extend {

        state    : 'credential'

        events   :
            'closed'                                : 'onClose'
            'click #awscredentials-submit'          : 'onSubmit'
            'click #awscredentials-update-done'     : 'onDone'
            'click .AWSCredentials-account-update'  : 'onUpdate'
            'click #awscredentials-cancel'          : 'onAWSCredentialCancel'
            'click #awscredentials-remove'          : 'onAWSCredentialRemove'
            'click #account-setting-tab li a'       : 'onTab'
            'click #account-update-email-link'      : 'onChangeEmail'
            'click #account-change-password'        : 'onChangePassword'
            'click #account-email-update'           : 'clickUpdateEmail'
            'click #account-email-cancel'           : 'clickCancelEmail'
            'click #account-password-update'        : 'clickUpdatePassword'
            'click #account-password-cancel'        : 'clickCancelPassword'
            'blur #aws-credential-account-id'       : 'verificationKey'
            'blur #aws-credential-access-key'       : 'verificationKey'
            'blur #aws-credential-secret-key'       : 'verificationKey'

            #welcome
            'click #awscredentials-skip'            : 'onSkinButton'

        render     : (template) ->
            console.log 'account_setting_tab render'
            #
            modal template, false
            #
            this.setElement $( '#account-setting-wrap' ).closest '#modal-wrap'
            #
            $( '#AWSCredential-form' ).find( 'ul' ).html form_tmpl
            $( '#AWSCredentials-submiting' ).html loading_tmpl

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

            if $( '#awscredentials-skip' ).attr( 'data-type' ) in [ 'back', 'done' ]
                @onDone()
                return

            me = this

            right_count = 0
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

                last_account_id = account_id
                last_access_key = access_key
                last_secret_key = secret_key

                me.trigger 'AWS_AUTHENTICATION', account_id, access_key, secret_key

                if @state is 'welcome'
                    $( '#awscredentials-submit' ).text 'Loading...'
                    $( '#awscredentials-skip' ).hide()

        onAWSCredentialCancel : () ->
            console.log 'account_setting_tab onAWSCredentialCancel'
            me = this

            me.showSetting('credential', 'on_update')

        onAWSCredentialRemove : (event) ->
            console.log 'account_setting_tab onAWSCredentialRemove'
            me = this

            if $('#awscredentials-remove').hasClass('btn btn-silver')
                #remove credential
                me.trigger 'REMOVE_CREDENTIAL'
                me.showSetting('credential')

            else
                me.showSetting('credential', 'on_remove')

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

        clickUpdateEmail : (flag) ->
            console.log 'account_setting_tab clickUpdateEmail'

            me = this

            email = $('#account-email-input').val()
            status = $('#email-verification-status')
            status.removeClass 'error-status'

            if flag and flag is 'is_failed'
                status.show().text 'The email address is already taken.'

            else if email

                # check email format
                if email isnt '' and /\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}/.test(email)  # not email
                    if email is MC.base64Decode($.cookie('email')) # repeat
                        #status.show().text 'This email is repeat.'
                        me.showSetting('account')

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

        verificationKey : ->
            console.log 'verificationKey'

            right_count = 0
            right_count = right_count + 1 if $('#aws-credential-account-id').val().trim()
            right_count = right_count + 1 if $('#aws-credential-access-key').val().trim()
            right_count = right_count + 1 if $('#aws-credential-secret-key').val().trim()

            if right_count is 3
                $('#awscredentials-submit').attr('disabled', false)
            else
                $('#awscredentials-submit').attr('disabled', true)
            null

        onSkinButton : () ->
            console.log 'onSkinButton'
            $target = $( '#awscredentials-skip' )
            if $target.attr( 'data-type' ) is 'skip'
                #
                $target.attr( 'data-type', 'back' )
                $target.text( 'Back' )
                $( '#awscredentials-submit' ).text( 'Done' )
                $( '#awscredentials-submit' ).removeAttr 'disabled'
                #
                $( '#AWSCredential-form' ).find( 'ul' ).html skip_tmpl
                $('#AWSCredential-info').find('p').text 'You can design stack without providing AWS Credentials. We will provide demo mode for your account. Yet, not providing your AWS Credentials now has following drawbacks:'
            else if $target.attr( 'data-type' ) is 'back'
                #
                $target.attr( 'data-type', 'skip' )
                $target.text( 'Skip' )
                $( '#awscredentials-submit' ).attr 'disabled', true
                $( '#awscredentials-submit' ).text( 'Submit' )
                #
                $( '#AWSCredential-form' ).find( 'ul' ).html form_tmpl
                $('#AWSCredential-info').find('p').text 'Welcome to Madeira Cloud, ' + MC.forge.cookie.getCookieByName( 'username' ) + '. To start designing cloud architecture, please provide your AWS credentials:'

            null

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
                $('#AWSCredentials-remove').hide()

                $('#AWSCredential-form').show()
                $('#AWSCredential-form').find('ul').show()
                $('#awscredentials-submit').show()
                $('#AWSCredential-info-wrap').show()
                $('#AWSCredential-info').show()
                $('#AWSCredentials-remove-wrap').hide()

                $('#awscredentials-remove').show()
                $('#awscredentials-cancel').show()
                $('#awscredentials-submit').attr('disabled',"true")

                if not flag     # initial

                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').hide()

                    # set content
                    $('#aws-credential-account-id').val(' ')
                    $('#aws-credential-access-key').val(' ')
                    $('#aws-credential-secret-key').val(' ')

                    #$('#AWSCredential-failed').hide()
                    if @state is 'credential'
                        $('#AWSCredential-info').find('p').text 'To launch and manage AWS resources, please provide your AWS account credentials.'
                    else if @state is 'welcome'
                        $('#AWSCredential-info').find('p').text 'Welcome to Madeira Cloud, ' + MC.forge.cookie.getCookieByName( 'username' ) + '. To start designing cloud architecture, please provide your AWS credentials:'

                    # set buttons style
                    $('#awscredentials-remove').hide()
                    $('#awscredentials-cancel').hide()

                else if flag is 'is_failed'

                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').hide()

                    #$('#AWSCredential-failed').show()
                    $('#AWSCredential-info').find('p').text 'Authentication failed. Please check your AWS Credentials and try again.'

                    right_count = 0
                    if last_account_id
                        $('#aws-credential-account-id').text last_account_id
                        right_count = right_count + 1
                    if last_access_key
                        $('#aws-credential-access-key').text last_access_key
                        right_count = right_count + 1
                    if last_secret_key
                        $('#aws-credential-secret-key').text last_secret_key
                        right_count = right_count + 1

                    if right_count is 3
                        $('#awscredentials-submit').attr('disabled', false)

                    if @state is 'welcome'
                        $( '#awscredentials-submit' ).text 'Submit'
                        $( '#awscredentials-skip' ).show()

                else if flag is 'on_update'

                    $('#AWSCredential-form').hide()
                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').show()

                    #$('#AWSCredential-failed').hide()
                    #$('#AWSCredential-info').find('p').text 'You have connected with following AWS account:'
                    $('#AWSCredential-info-wrap').hide()
                    $('#aws-credential-update-account-id').text me.model.attributes.account_id
                    $('.AWSCredentials-nochange-warn').hide()
                    # check whether there are stopped/running/processing app
                    num = 0
                    for r in constant.REGION_KEYS
                        num++ for app in MC.data.app_list[r]
                    if num>0
                        $('.AWSCredentials-account-update').hide()
                        $('.AWSCredentials-account-update').attr('disabled', true)
                        $('.AWSCredentials-nochange-warn').show()

                    else
                        $('.AWSCredentials-account-update').show()
                        $('.AWSCredentials-account-update').attr('disabled', false)

                    if @state is 'welcome'
                        $( '#awscredentials-skip' ).hide()
                        $( '#awscredentials-skip' ).attr( 'data-type', 'done' )
                        $( '#awscredentials-submit' ).text 'Done'
                        $( '#awscredentials-submit' ).removeAttr 'disabled'

                else if flag is 'in_update'

                    $('#AWSCredentials-submiting').hide()
                    $('#AWSCredentials-update').hide()

                    $('#AWSCredential-info').find('p').text 'If you change AWS Credentials, design previously created in current account may not work due to resource inconsistency. '

                    # set content
                    $('#aws-credential-account-id').val me.model.attributes.account_id

                    # set remove button style
                    $('#awscredentials-remove').removeClass("btn btn-silver")

                else if flag is 'on_submit'

                    $('#AWSCredential-form').hide()
                    $('#AWSCredentials-submiting').show()
                    $('#AWSCredentials-update').hide()

                    $('#AWSCredential-info-wrap').hide()

                else if flag is 'load_resource'

                    $('#AWSCredential-form').hide()
                    $('#AWSCredentials-submiting').show()
                    $('#AWSCredentials-update').hide()

                    $('#AWSCredentials-loading-text').text('Loading resources...')

                    $('#AWSCredential-info-wrap').hide()

                else if flag is 'on_remove'

                    $('#AWSCredential-info').hide()
                    $('#AWSCredentials-remove-wrap').show()
                    $('#AWSCredential-remove-head').find('p').text 'Do you conﬁrm to remove AWS Credentials of account ' + me.model.attributes.account_id + '?'
                    $('#awscredentials-submit').hide()
                    $('#AWSCredential-form').find('ul').hide()

                    # change remove button's style
                    $('#awscredentials-remove').addClass("btn btn-silver")
                    # hide submit botton

            null

    }

    return AWSCredentialView
