define ['backbone',
    '../template/TplMember',
    'i18n!/nls/lang.js',
    'UI.bubblepopup',
    'ApiRequest',
    '../models/MemberCollection',
    'UI.selectbox',
    'UI.parsley',
    'UI.errortip',
    'UI.table',
    'MC.validate'
], (Backbone, TplMember, lang, bubblePopup, ApiRequest, MemberCollection) ->

    Backbone.View.extend

        className: 'member-setting'

        events:

            'change #t-m-select-all': '__checkAll'
            'change .one-cb': '__checkOne'
            'click #invite': 'inviteMember'
            'click #delete': 'removeMember'
            'click .done': 'doneModify'
            'click .edit': 'enterModify'
            'click .cancel': 'cancelInvite'

            'focus #mail': 'focusMail'
            'blur #mail': 'blurMail'
            'keyup #mail': 'keyupMail'
            'keypress #mail': 'keypressMail'

        focusMail: () ->

            # @$el.find('.search').show()

        blurMail: () ->

            @$el.find('.search').hide()

        keyupMail: () ->

            @keyupHandle()

        keyupHandle : () ->

            that = @
            mail = that.$el.find('#mail').val()
            $search = that.$el.find('.search')
            if mail.length > 0
                ApiRequest('account_get_userinfo', {
                    user_email: mail
                }).then (data)->
                    if data
                        $search.html TplMember.match({
                            name: Base64.decode(data.username),
                            mail: Base64.decode(data.email)
                        })
                    else
                        $search.html TplMember.nomatch({
                            name: mail
                        })
                .done () ->
                    $search.show()
            else
                $search.hide()

        keypressMail: (event) ->

            @$el.find('#invite').click() if event.keyCode is 13

        initialize: () ->

            @keyupHandle = _.throttle(@keyupHandle, 1000)
            @project = @model
            @memberCol = new MemberCollection({projectId: @project.id})
            # @memberCol = @project.get('members')
            @projectId = @model.get('id')
            @isAdmin = false
            @render()

        render: () ->

            isPrivateProject = @model.get('private')

            if isPrivateProject

                @$el.html TplMember.defaultProject()

            else

                @$el.html TplMember.loading()
                @loadMemList()

            @

        renderMain: () ->

            that = @

            columns = [
                {
                    sortable: true
                    name: lang.IDE.SETTINGS_MEMBER_COLUMN_MEMBER
                },
                {
                    sortable: true
                    width: "20%"
                    name: lang.IDE.SETTINGS_MEMBER_COLUMN_ROLE
                },
                {
                    sortable: true
                    width: "10%"
                    name: lang.IDE.SETTINGS_MEMBER_COLUMN_STATUS
                }
            ]
            if that.isAdmin
                columns = columns.concat([
                    {
                        sortable: false
                        width: "14%"
                        name: ""
                    },
                    {
                        sortable: false
                        width: "55px"
                        name: lang.IDE.SETTINGS_MEMBER_COLUMN_EDIT
                    }
                ])
            that.$el.html TplMember.main({
                limit: that.memberCol.isLimitInvite(),
                number: that.memberCol.limit,
                columns: columns,
                admin: that.isAdmin
            })
            that.memList = that.$el.find('.t-m-content')
            return

        loadMemList: (callback) ->

            that = @
            data = []
            currentMember = null
            currentUserName = App.user.get('username')
            @memberCol.fetch().then () ->
                that.isAdmin = that.memberCol.getCurrentMember()?.isAdmin()
                data = that.memberCol.toJSON()
                return
            .fail (data) ->
                notification 'error', (data.result or data.msg)
                that.$el.find('.loading-spinner').addClass('hide')
            .done () ->
                that.renderMain()
                # refresh project model
                if currentMember
                    that.model.set('myRole', currentMember.role)
                that.$el.find('.content').removeClass('hide')
                that.$el.find('.loading-spinner').addClass('hide')
                that.renderList(data)
                that.__processDelBtn()
                callback() if callback

        renderList: (data) ->

            that = @
            @memList.html TplMember.list({
                admin: that.isAdmin,
                memlist: data
            })
            @$el.find('.memlist-count').text(data.length)

        inviteMember: () ->

            that = @

            $invite = @$el.find('#invite')

            if $invite.prop('disabled') is false

                $mail = @$el.find('#mail')
                mail = $.trim($mail.val())

                # $mail.parsley 'custom', (val) ->
                #     return false if not val
                #     if not MC.validate('email', val)
                #         return lang.IDE.HEAD_MSG_ERR_UPDATE_EMAIL3
                # return if not $mail.parsley 'validate'
                return if not mail

                # change button state
                originTxt = $invite.text()
                $invite.prop 'disabled', true
                $invite.text("#{originTxt}...")

                @memberCol.inviteMember(mail).then ()->
                    $mail.val('')
                    that.loadMemList () ->
                        $invite.text(originTxt)
                        $invite.prop 'disabled', false
                .fail (data) ->
                    if data.error is ApiRequest.Errors.UserNoUser
                        notification 'error', sprintf(lang.IDE.SETTING_MEMBER_LABEL_NO_USER, mail)
                    else
                        notification 'error', data.result
                    $invite.text(originTxt)
                    $invite.prop 'disabled', false

        removeMember: (event) ->

            that = @

            $delete = $(event.currentTarget)

            if $delete.prop('disabled') is false

                memList = []
                _.each that.$el.find('.memlist-item.selected'), (item) ->
                    memId = $(item).data('id')
                    memList.push(memId)

                bubblePopup $delete, TplMember.deletePopup({
                    count: memList.length
                }), {
                    '.confirm': () ->

                        # change button state
                        originTxt = $delete.text()
                        $delete.prop 'disabled', true
                        $delete.text("#{originTxt}...")

                        that.memberCol.removeMember(memList).then ()->
                            that.loadMemList () ->
                                $delete.text(originTxt)
                        .fail (data) ->
                            notification 'error', data.result
                            $delete.text(originTxt)
                            $delete.prop 'disabled', false
                }

        enterModify: (event) ->

            $memItem = $(event.currentTarget).parents('.memlist-item')
            $memItem.addClass('edit')

        doneModify: (event) ->

            that = @

            $done = $(event.currentTarget)

            if $done.prop('disabled') is false

                $memItem = $(event.currentTarget).parents('.memlist-item')
                memId = $memItem.data('id')
                newRole = $memItem.find('.memtype li.selected').data('id')

                memberModel = that.memberCol.get(memId)
                currentMember = that.memberCol.getCurrentMember()

                # if current user is only admin in workspace, failed to change role
                if memberModel is currentMember and
                    currentMember.isAdmin() and
                    newRole is 'collaborator' and
                    currentMember.isOnlyAdmin()

                        notification 'error', lang.IDE.SETTINGS_MEMBER_LABEL_ONLY_ONE_ADMIN
                        $memItem.removeClass('edit')
                        return

                # if no change
                if memberModel.get('role') is newRole
                    $memItem.removeClass('edit')
                    return

                # change button state
                originTxt = $done.text()
                $done.prop 'disabled', true
                $done.text("#{originTxt}...")

                memberModel.updateRole(newRole).then ()->
                    that.loadMemList () ->
                        $done.text(originTxt)
                        $done.prop 'disabled', false
                        $memItem.removeClass('edit')
                .fail (data) ->
                    notification 'error', data.result
                    $done.text(originTxt)
                    $done.prop 'disabled', false
                    $memItem.removeClass('edit')

        cancelInvite: (event) ->

            that = @

            $cancel = $(event.currentTarget)

            if $cancel.prop('disabled') is false

                $memItem = $(event.currentTarget).parents('.memlist-item')
                memId = $memItem.data('id')

                # change button state
                originTxt = $cancel.text()
                $cancel.prop 'disabled', true
                $cancel.text("#{originTxt}...")

                memberModel = that.memberCol.get(memId)
                memberModel.cancelInvite().then ()->
                    that.loadMemList () ->
                        $cancel.text(originTxt)
                        $cancel.prop 'disabled', false
                .fail (data) ->
                    notification 'error', data.result
                    $cancel.text(originTxt)
                    $cancel.prop 'disabled', false

        # follow code ref from toolbarModal
        __checkOne: ( event ) ->

            $target = $ event.currentTarget
            cbAll = @$ '#t-m-select-all'
            cbAmount = @$('.one-cb').length
            checkedAmount = @$('.one-cb:checked').length
            $target.closest('tr').toggleClass 'selected'

            if checkedAmount is cbAmount
                cbAll.prop 'checked', true
            else if cbAmount - checkedAmount is 1
                cbAll.prop 'checked', false
            @__processDelBtn()

        __checkAll: ( event ) ->

            if event.currentTarget.checked
                @$('input[type="checkbox"]:not(:disabled)').prop 'checked', true
                .parents('tr.item').addClass 'selected'
            else
                @$('input[type="checkbox"]').prop 'checked', false
                @$('tr.item').removeClass 'selected'

            @__processDelBtn()

        __processDelBtn: () ->

            that = @
            if that.$('.one-cb:checked').length
                that.$('#delete').prop 'disabled', false
            else
                that.$('#delete').prop 'disabled', true

        getChecked: () ->

            allChecked = @$('.one-cb:checked')
            checkedInfo = []
            allChecked.each () ->
                checkedInfo.push id: @id, value: @value, data: $(@).data()

            checkedInfo
