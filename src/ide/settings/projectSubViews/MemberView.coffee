define ['backbone',
    '../template/TplMember',
    'i18n!/nls/lang.js',
    'UI.bubblepopup',
    'ApiRequest',
    'UI.selectbox',
    'UI.parsley',
    'UI.errortip',
    'UI.table',
    'MC.validate'
], (Backbone, TplMember, lang, bubblePopup, ApiRequest) ->

    Backbone.View.extend

        events:

            'change #t-m-select-all': '__checkAll'
            'change .one-cb': '__checkOne'
            'click #invite': 'inviteMember'
            'click #delete': 'removeMember'
            'click .done': 'doneModify'
            'click .edit': 'enterModify'
            'click .cancel': 'cancelInvite'

        className: 'member-setting'

        initialize: () ->

            @projectId = @model.get('id')
            @isAdmin = false
            @render()

        render: () ->

            @$el.html TplMember.loading()
            @loadMemList()
            @

        renderMain: () ->

            that = @

            columns = [
                {
                    sortable: true
                    name: "Member"
                },
                {
                    sortable: true
                    width: "20%"
                    name: "Role"
                },
                {
                    sortable: true
                    width: "10%"
                    name: "Status"
                }
            ]
            if that.isAdmin
                columns = columns.concat([
                    {
                        sortable: false
                        width: "20%"
                        name: ""
                    },
                    {
                        sortable: false
                        width: "100px"
                        name: "Edit"
                    }
                ])
            that.$el.html TplMember.main({
                columns: columns,
                admin: that.isAdmin
            })
            that.memList = that.$el.find('.t-m-content')

        loadMemList: (callback) ->

            that = @
            data = []
            currentUserName = App.user.get('username')
            ApiRequest('project_list_member', {
                project_id: @projectId
            }).then (members)->
                _.each members, (member) ->
                    userName = Base64.decode(member.username)
                    isMe = userName is currentUserName
                    if isMe
                        if member.role is 'admin'
                            that.isAdmin = true
                        else
                            that.isAdmin = false
                    data.push({
                        id: member.id,
                        me: isMe,
                        avatar: '',
                        username: userName,
                        email: Base64.decode(member.email),
                        role: member.role,
                        state: member.state
                    })
            .done () ->
                that.renderMain()
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
                $invite.text('wait...')

                ApiRequest('project_invite', {
                    project_id: @projectId,
                    member_email: mail,
                    member_role: 'collaborator',
                }).then ()->
                    $mail.val('')
                    that.loadMemList () ->
                        $invite.text(originTxt)
                        $invite.prop 'disabled', false
                .fail (data) ->
                    if data.error is ApiRequest.Errors.UserNoUser
                        notification 'error', 'User Not Found'
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
                        $delete.text('wait...')

                        ApiRequest('project_delete_members', {
                            project_id: that.projectId,
                            member_ids: memList
                        }).then ()->
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

                # change button state
                originTxt = $done.text()
                $done.prop 'disabled', true
                $done.text('wait...')

                ApiRequest('project_update_role', {
                    project_id: that.projectId,
                    member_id: memId,
                    new_role: newRole
                }).then ()->
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
                $cancel.text('wait...')

                ApiRequest('project_cancel_invitation', {
                    project_id: that.projectId,
                    member_id: memId
                }).then ()->
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
