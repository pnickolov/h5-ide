#############################
#  View(UI logic) for component/awscredential
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'UI.notification'
], ( ide_event ) ->

    AWSCredentialView = Backbone.View.extend {

        events   :
            'closed'                                : 'onClose'
            'click #awsredentials-submit'           : 'onSubmit'
            'click #awsredentials-update-done'      : 'onDone'
            'click .AWSCredentials-account-update'  : 'onUpdate'

        render     : (template) ->
            console.log 'pop-up:awscredential render'
            #
            modal template, false
            #
            this.setElement $( '#AWSCredential-setting' ).closest '#modal-wrap'

        reRender : () ->
            me = this
            console.log 'pop-up:awscredential rerender'

            #this.$el.html this.model.attributes

            if me.model.attributes.is_authenticated
                $('#AWSCredentials-submiting').hide()
                $('#AWSCredentials-update').show()
                $('#aws-credential-update-account-id').text me.model.attributes.account_id
            else
                $('#AWSCredentials-submiting').hide()

                $('#AWSCredential-form').show()
                $('#AWSCredential-info').hide()
                $('#AWSCredential-failed').show()

                # clear the input values
                $('#aws-credential-account-id').val(' ')
                $('#aws-credential-access-key').val(' ')
                $('#aws-credential-secret-key').val(' ')


        onClose : ->
            console.log 'onClose'
            this.trigger 'CLOSE_POPUP'

        onDone : ->
            console.log 'onDone'
            modal.close()
            this.trigger 'CLOSE_POPUP'

        onUpdate : ->
            console.log 'onUpdate'
            $('#AWSCredentials-update').hide()

            $('#AWSCredential-form').show()
            # clear the access key and secret key
            $('#aws-credential-access-key').val(' ')
            $('#aws-credential-secret-key').val(' ')


        onSubmit : () ->
            console.log 'onSubmit'

            # input check
            account_id = $('#aws-credential-account-id').val()
            access_key = $('#aws-credential-access-key').val()
            secret_key = $('#aws-credential-secret-key').val()

            if not account_id
                notification 'error', 'Invalid accout id.'
            else if not access_key
                notification 'error', 'Invalid access key.'
            else if not secret_key
                notification 'error', 'Invalid secret key.'

            # hide AWSCredential-form and show AWSCredentials-submiting
            $('#AWSCredential-form').hide()
            $('#AWSCredentials-submiting').show()

            this.trigger 'AWS_AUTHENTICATION', account_id, access_key, secret_key

    }

    return AWSCredentialView