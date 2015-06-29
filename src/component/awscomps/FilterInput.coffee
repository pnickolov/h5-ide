define [ 'constant', 'Design', 'component/awscomps/FilterInputTpl' ], ( constant, Design, template) ->

    ResNameToType = _.invert constant.RESNAME
    ResTypeToShort = _.invert constant.RESTYPE

    DefaultValues = {
      Empty         : '(empty)'
      NotTagged     : 'Not tagged'
      AllValues     : 'All values'
      AllAttributes : 'All Attributes'
    }

    getResNameByType = ( type ) -> constant.RESNAME[ type ]
    getResShortNameByType = ( type ) -> ResTypeToShort[ type ]?.toLowerCase()
    getResTypeByShortName = (short) -> constant.RESTYPE[ short.toUpperCase() ]

    seperate = (str, sep) ->
      pos = str.indexOf(sep)

      if pos is -1 then return false

      tmp = str.split(sep)
      before = tmp[0]
      after = tmp[1]

      { before: before, after: after, pos: pos }

    isResAttributeMatch = ( resources, attr, value ) ->
      for r in resources
        serialized = resource.serialize()
        unless _.isArray(serialized) then serialized = [ serialized ]

        _.some serialized, (serializedItem) ->
          v = serializedItem?.component?.resource?[attr]
          v is value

    hasTag = ( tags, key, value ) ->
      _.some tags, (tag) ->
        tag.get('key') is key and ( arguments.length is 3 and tag.get('value') is value or true )

    isResMatchTag = ( resource, selTags ) ->
      unless _.size(selTags) then return true

      tags = resource.tags()
      _.every selTags, ( tagValues, tagKey ) ->
        _.some tagValues, (tagValue) ->
          switch tagValue
            when DefaultValues.AllValues then return hasTag tags, tagKey
            when DefaultValues.NotTagged then return !hasTag(tags, tagKey)
            when DefaultValues.Empty     then return hasTag(tags, tagKey, '')
            else                              return hasTag(tags, tagKey, tagValue)

    isResMatchResource = ( res, selectResources ) ->
      unless _.size(selectResources) then return true

      _.some selectResources, ( selRes ) ->
        splitDot      = seperate(selRes.key, '.')

        resShortName  = splitDot?.before or selRes.key
        attr          = splitDot.after or ''
        value         = selRes.value
        type          = getResTypeByShortName( resShortName )

        res.type is type and isResAttributeMatch( res, attr, value )


    filterInput = Backbone.View.extend
      className: "filter-input"
      tplDropdown: template.dropdown
      tplTag: template.tag
      unFilterType: [ constant.RESTYPE.SG ]

      events:
        "click .tags li"            : "clickTagHandler"
        "blur input"                : "blurInputHandler"
        "focus input"               : "focusInputHandler"
        "click input"               : "clickInputHandler"
        "click .fake-input"         : "clickFakeInputHandler"
        "keydown input"             : "keydownHandler"
        "keyup input"               : "keyupHandler"
        "click .dropdown li.option" : "selectHandler"
        "mouseover .dropdown"       : "overDrop"
        "mouseleave .dropdown"      : "leaveDrop"
        "mouseover .dropdown li"    : "overDropItem"

      getFilterableResource: ->
        allComp = Design.instance().getAllComponents()
        _.filter allComp, ( comp ) ->
          comp.isVisual() and !comp.port and !_.contains(@unFilterType, comp.type)

      getMatchedResource: () ->
        selection = @classifySelection(@selection)
        filterable = @getFilterableResource()

        matched = _.filter filterable, (resource) ->
          if isResMatchTag(resource, selection.tags) and isResMatchResource( resource, selection.resources )
            true

        { matched: matched, effect: 0 < matched.length < filterable.length }

      triggerChange: ->
        matched = @getMatchedResource()
        @trigger 'change:filter', matched.matched, matched.effect

      classifySelection: ->
        classified = tags: {}, resources: []

        for sel in @selection
          if sel.type is 'tag'
            classified.tags[ sel.key ] or ( classified.tags[ sel.key ] = [] )
            classified.tags[ sel.key ].push sel.value
          else
            classified.resources.push sel

        classified

      getState: (value) ->
        input = @$("input").get(0)
        text = input.value
        subKey = null
        state = 'value'

        equalSplit = seperate text, '='

        key = (equalSplit?.before or text).trim()
        value = equalSplit?.after or ''

        tagSplit = seperate key, 'tag:'
        dotSplit = seperate key, '.'


        if tagSplit
          mode = 'tag'
          key = tagSplit.after
        else if dotSplit
          mode = 'resource.attribute'
          key = dotSplit.before
          subKey = dotSplit.after
        else
          mode = 'resource'
          subKey = ''

        cursorPos = input.selectionStart

        if equalSplit and cursorPos > equalSplit.pos
          state = 'value'
          effect = value
        else
          state = mode
          effect = if mode is 'resource.attribute' then subKey else key

        mode: mode
        state: state
        key: key
        subKey: subKey
        value: value
        effect: effect

      initialize: (options) ->
        @selection = options.selection  if options and options.selection
        @selection or ( @selection = [] )
        null

      render: ->
        tpl = template.frame
        @$el.html tpl
        @renderSelection()
        @

      renderDropdown: ->
        state = @getState()
        filter = state.effect

        data = @getDropdownData(state.state, state.key, state.subKey)
        data = @filterByInput(data, filter)
        @$(".dropdown").html @tplDropdown data
        @

      removeDropdown: ->
        @$(".dropdown").html ""

      renderSelection: ->
        @$(".tags").html @tplTag @selection
        @

      renderLineTip: ($fakeInput) ->
        $fakeInput = $fakeInput or @$(".fake-input")
        $li = @$(".tags li").first()

        unless $li.size()
          @$(".line-tip").text ""
          return

        computedStyle = window.getComputedStyle($li[0])
        liHeight = $li.outerHeight() + parseInt(computedStyle.marginTop) + parseInt(computedStyle.marginBottom)
        line = Math.floor($fakeInput[0].scrollHeight / liHeight)
        hideLine = line - 1

        if not hideLine or hideLine < 1
          @$(".line-tip").text ""
        else
          @$(".line-tip").text "(+" + hideLine + ")"

      addSelection: (key, value, type) ->

        if arguments.length is 1
            tmp = key.split('=')
            if tmp.length isnt 2 then return
            key = tmp[0].trim()
            value = tmp[1].trim()

        unless type
          state = @getState()
          type = state.mode

        sel =
          key: key
          value: value
          type: type

        if not value and type not in [ 'resource', 'resource.attribute' ] then return

        @clearInput()
        return @ if _.some(@selection, (t) ->
          _.isEqual t, sel
        )
        @selection.push sel
        @triggerChange()
        @renderSelection()
        @

      removeSelection: ($sel) ->
        unless $sel.size() then return

        selection =
          key: $sel.data("key")
          value: $sel.data("value").toString()

        @selection = _.filter(@selection, (s) ->
          s.key isnt selection.key or s.value?.toString() isnt selection.value and !(!s.value and !selection.value)
        )

        @triggerChange()
        $sel.remove()

      removeLastSelection: ->
        $last = @$(".tags li").last()
        @removeSelection $last

      getDropdownData: (state, key, subKey) ->
        if state is 'value'
          if subKey
            @getAttributeValueDd(key, subKey)
          else
            @getTagValueDd(key)
        else
          if state is 'resource.attribute'
            @getAttributeDd(key)
          else
            @getTagKeyDd().concat(@getResourceDd())


      uniqSortDd: (dd) -> _.sortBy (_.uniq dd, (d) -> d.value), 'value'

      getAttributeDd: ( resShortName ) ->
        type = getResTypeByShortName resShortName
        unless type then return

        attrs = []
        resource = Design.modelClassForType(type).first()
        unless type then return

        serialized = resource.serialize()

        unless _.isArray(serialized) then serialized = [ serialized ]

        _.each serialized, (serializedItem) ->
          if serializedItem?.component?.resource
            _.each serializedItem.component.resource, ( v, k ) ->
              unless _.isObject(v) then attrs.push(k)

        dd = _.map attrs, (a) ->
          { type: 'attribute', value: a }

        dd = @uniqSortDd dd

        dd.unshift { type: 'attribute', value: DefaultValues.AllAttributes, default: true }
        dd.unshift { type: 'label', value: 'Attributes', for: 'attribute' }

        dd

      getResourceDd: ->
        resources = @getFilterableResource()

        dd = _.map resources, (r) ->
          { id: r.id, type: 'resource', value: getResShortNameByType(r.type), text: getResNameByType(r.type) }

        dd = @uniqSortDd dd
        dd.unshift { type: 'label', value: 'Resources', for: 'resource' }

        dd

      getTagKeyDd: ->
        tags = Design.modelClassForType(constant.RESTYPE.TAG).all()
        dd = _.map tags, (tag) ->
          { id: tag.id, type: 'tag.key', value: tag.get('key') }

        dd = @uniqSortDd dd
        dd.unshift { type: 'label', value: 'Tag Keys', for: 'tag.key' }

        dd

      getTagValueDd: (tagKey) ->
        tags = Design.modelClassForType(constant.RESTYPE.TAG).all()
        matchTags = _.filter tags, (tag) -> tag.get('key') is tagKey
        dd = _.map matchTags, (tag) ->
          { id: tag.id, type: 'tag.value', value: tag.get('value') }

        dd = @uniqSortDd dd

        for defaultTag in [ DefaultValues.AllValues, DefaultValues.NotTagged, DefaultValues.Empty ]
          dd.unshift { type: 'tag.value', value: defaultTag, default: true }

        dd

      getAttributeValueDd: ( resShortName, attr ) ->
        type = getResTypeByShortName resShortName
        unless type then return

        resources = Design.modelClassForType(type).allObjects()
        dd = []

        for r in resources
          serialized = r.serialize()
          unless _.isArray(serialized) then serialized = [ serialized ]

          _.each serialized, (serializedItem) ->
            v = serializedItem?.component?.resource?[attr]
            if v
              dd.push { id: r.id, type: 'attribute.value', value: v }


        dd = @uniqSortDd dd
        dd.unshift { type: 'attribute.value', value: DefaultValues.AllValues, default: true }

        dd

      focusInput: ($input) ->
        ($input or @$("input")).focus()

      clearInput: ($input) ->
        ($input or @$("input")).val ""

      filterByInput: (data, filter) ->
        filter = filter and filter.trim().toLowerCase()

        setSelected = false
        filtered = []

        _.each data, (d) ->
          d.text = d.value unless d.text
          if d.type is 'label'
            filtered.push d
          else if not filter or (matchIdx = d.value.toLowerCase().indexOf(filter)) > -1
            unless setSelected then d.selected = setSelected = true

            if matchIdx > -1
              match = d.value.slice(matchIdx, matchIdx + filter.length)
              d.text = d.text.replace(match, "<span class=\"match\">" + match + "</span>")

            filtered.push d

        # Remove label if it's list empty
        _.filter filtered, (f) ->
          if f.type is 'label'
            return _.some filtered, (ff) -> ff.type is f.for
          true

        filtered

      fold: (force) ->
        that = @
        unless @hoverDrop
          that.$(".dropdown").empty()
        else if force is true
          @hoverDrop = false
          @fold()

      # ## Event Handler
      overDrop: ->
        @hoverDrop = true
        null

      leaveDrop: ->
        @hoverDrop = false
        null

      overDropItem: (e) ->
        if @__keydowning then return
        $tgt = $(e.currentTarget)
        @$(".dropdown li").removeClass "selected"
        if $tgt.hasClass('option')
          $tgt.addClass "selected"
        else
          $tgt.next('.option').addClass('selected')

      clickTagHandler: (e) ->
        $tgt = $(e.currentTarget)
        @removeSelection $tgt

      keyupHandler: (e) ->
        that = @
        @__timeoutResetKeydowning = setTimeout ->
          that.__keydowning = false
        , 300

        code = e.which
        $input = $(e.currentTarget)
        unless ( _.contains([27, 38, 40], code) )
          @renderDropdown()

      keydownHandler: (e) ->
        clearTimeout @__timeoutResetKeydowning
        @__keydowning = true
        code = e.which
        $input = $(e.currentTarget)
        switch code
          when 8 # Delete
            if $input[0].selectionStart is 0
              @removeLastSelection()
              @focusInput()

          when 13 # Enter
            dropdown = @$(".dropdown")
            if dropdown.children().size()
              @selectHandler currentTarget: dropdown.find(".selected")
            else
              @addSelection $input.val()
          when 27 # Esc
            @fold()
          when 38 # Up
            $selected = @$(".dropdown .selected")
            $prev = $selected.prevAll('.option').first()
            if $prev.size()
              $dropdown   = @$(".dropdown")
              prevHeight  = $prev.outerHeight()
              prevTop     = $prev.position().top
              ddHeight    = $dropdown.outerHeight()

              if prevTop < 0
                $dropdown[0].scrollTop += prevTop

              $selected.removeClass "selected"
              $prev.addClass "selected"
            false
          when 40 # Down
            $selected = @$(".dropdown .selected")
            $next = $selected.nextAll('.option').first()
            if $next.size()
              $dropdown   = @$(".dropdown")
              nextHeight  = $next.outerHeight()
              nextTop     = $next.position().top
              ddHeight    = $dropdown.outerHeight()

              if nextTop + nextHeight > ddHeight
                $dropdown[0].scrollTop += nextTop + nextHeight - ddHeight

              $selected.removeClass "selected"
              $next.addClass "selected"
            false

      focusInputHandler: ->
        clearTimeout @__timeoutRemoveFocus
        #@renderDropdown()
        @$(".fake-input").addClass "focus"

      blurInputHandler: ->
        that = @
        @__timeoutRemoveFocus = setTimeout ->
          that.fold()
          that.removeDropdown()
          $fakeInput = that.$(".fake-input")
          $fakeInput.removeClass "focus"
          that.renderLineTip $fakeInput
        , 180

        null

      clickInputHandler: (e) ->
        @renderDropdown()
        false

      clickFakeInputHandler: (e) ->
        $(e.currentTarget).addClass "focus"
        @$("input").focus()

      selectHandler: (e) ->
        @focusInput()
        $tgt = $(e.currentTarget)
        $input = @$("input")
        type = $tgt.data('type')

        state = @getState()

        if state.state is 'value'
          key = state.key + if state.subKey then ".#{state.subKey}" else ''
          @addSelection key, $tgt.data('value'), state.mode
        else
          key = $tgt.data('value')
          if type is 'attribute'
            if key is DefaultValues.AllAttributes
              @addSelection(state.key, null, state.mode)
              return @renderDropdown()
            else
              key = "#{state.key}.#{key} = "
          else if type is 'resource'
            key = "#{key}."
          else
            key = "tag:#{key} = "

          $input.val(key)

        @renderDropdown()


    filterInput