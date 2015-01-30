define ['ApiRequest', 'backbone', 'crypto'], (ApiRequest) ->

    MemberModel = Backbone.Model.extend({

        defaults:

            id: '',
            avatar: '',
            username: '',
            email: '',
            role: '',
            state: ''
            me: false

            # Base64 encoded
            _username: ''
            _email: ''

            projectId: ''

        updateRole: (newRole) ->

            that = @
            ApiRequest('project_update_role', {
                project_id: @get('projectId'),
                member_id: @id,
                new_role: newRole
            }).then ()->
                that.set('role', newRole)

        cancelInvite: () ->

            that = @
            ApiRequest('project_cancel_invitation', {
                project_id: @get('projectId'),
                member_id: @id
            }).then () ->
                that.collection?.remove(that)

    })

    MemberCollection = Backbone.Collection.extend({

        constructor: (attr) ->

            Backbone.Collection.apply @
            @projectId = attr.projectId

        model: MemberModel

        projectId: ''

        fetch: () ->

            that = @

            ApiRequest('project_list_member', {
                project_id: that.projectId
            }).then (members)->
                models = _.map members, (member) ->
                    userName = Base64.decode(member.username)
                    currentUserName = App.user.get('username')
                    email = Base64.decode(member.email)
                    avatar = CryptoJS.MD5(email.trim().toLowerCase()).toString()
                    return new that.model({
                        id: member.id,
                        avatar: "https://www.gravatar.com/avatar/#{avatar}",
                        username: userName,
                        email: email,
                        role: member.role,
                        state: member.state,
                        me: userName is currentUserName

                        _username: member.username,
                        _email: member.email,

                        projectId: that.projectId
                    })
                that.reset(models)

        removeMember: (memIds) ->

            that = @
            ApiRequest('project_remove_members', {
                project_id: @projectId,
                member_ids: memIds
            }).then () ->
                that.remove(memIds)

        inviteMember: (email) ->

            that = @
            ApiRequest('project_invite', {
                project_id: @projectId,
                member_email: email,
                member_role: 'collaborator',
            }).then () ->
                that.push(new that.model())

        getCurrentMember: () ->

            return @findWhere({
                username: App.user.get('username')
            })

    })

    MemberCollection
