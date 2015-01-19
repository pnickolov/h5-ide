define ['backbone', '../template/TplMember', 'i18n!/nls/lang.js', 'UI.selectbox', 'UI.parsley', 'MC.validate'], (Backbone, TplMember, lang) ->

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

            @render()

        render: () ->

            @$el.html TplMember.main(
                {
                    columns: [
                        {
                            sortable: true
                            name: "Member"
                        },
                        {
                            sortable: true
                            rowType: 'datetime'
                            width: "15%"
                            name: "Role"
                        },
                        {
                            sortable: true
                            width: "10%"
                            name: "Status"
                        },
                        {
                            sortable: false
                            width: "20%"
                            name: ""
                        },
                        {
                            sortable: false
                            width: "150px"
                            name: "Edit"
                        }
                    ]
                }
            )
            @memList = @$el.find('.t-m-content')
            @loadMemList()
            @

        loadMemList: () ->

            that = @
            data = [
                {
                    id: "1"
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "ADMIN"
                    status: "Active"
                    canCancel: true
                },
                {
                    id: "2"
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "COLLABORATOR"
                    status: "Pending"
                },
                {
                    id: "3"
                    avatar: ""
                    name: "John Doe"
                    mail: "id@mc2.io"
                    role: "OBSERVER"
                    status: "Active"
                }
            ]
            setTimeout () ->
                that.$el.find('.content').removeClass('hide')
                that.$el.find('.loading-spinner').addClass('hide')
                that.renderList(data)
            , 1000

        renderList: (data) ->

            @memList.html TplMember.list(data)
            @$el.find('.memlist-count').text(data.length)

        inviteMember: () ->

            $invite = @$el.find('#invite')

            if $invite.prop('disabled') is false

                $mail = @$el.find('#mail')
                mail = $mail.val()

                $mail.parsley 'custom', (val) ->
                    if not MC.validate('email', val)
                        return lang.IDE.HEAD_MSG_ERR_UPDATE_EMAIL3
                # return if not $mail.parsley 'validate'

                # change button state
                originTxt = $invite.text()
                $invite.prop 'disabled', true
                $invite.text('wait...')

                setTimeout () ->
                    $invite.text(originTxt)
                    $invite.prop 'disabled', false
                , 1000

        removeMember: (event) ->

            $delete = $(event.currentTarget)

            if $delete.prop('disabled') is false

                memList = []
                _.each @$el.find('.memlist-item.selected'), (item) ->
                    memId = $(item).data('id')
                    memList.push(memId)

                # change button state
                originTxt = $delete.text()
                $delete.prop 'disabled', true
                $delete.text('wait...')

                setTimeout () ->
                    $delete.text(originTxt)
                    $delete.prop 'disabled', false
                , 1000

        enterModify: (event) ->

            $memItem = $(event.currentTarget).parents('.memlist-item')
            $memItem.addClass('edit')

        doneModify: (event) ->

            $done = $(event.currentTarget)

            if $done.prop('disabled') is false

                $memItem = $(event.currentTarget).parents('.memlist-item')
                memId = $memItem.data('id')
                role = $memItem.find('.memtype li.selected').data('id')

                # change button state
                originTxt = $done.text()
                $done.prop 'disabled', true
                $done.text('wait...')

                setTimeout () ->
                    $done.text(originTxt)
                    $done.prop 'disabled', false
                    $memItem.removeClass('edit')
                , 1000

        cancelInvite: (event) ->

            $cancel = $(event.currentTarget)

            if $cancel.prop('disabled') is false

                $memItem = $(event.currentTarget).parents('.memlist-item')
                memId = $memItem.data('id')

                # change button state
                originTxt = $cancel.text()
                $cancel.prop 'disabled', true
                $cancel.text('wait...')

                setTimeout () ->
                    $cancel.text(originTxt)
                    $cancel.prop 'disabled', false
                , 1000

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
