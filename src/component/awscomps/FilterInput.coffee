define [ 'constant', 'Design', 'component/awscomps/FilterInputTpl' ], ( constant, Design, template) ->

    ResNameToType = _.invert constant.RESNAME
    ResTypeToShort = _.invert constant.RESTYPE

    DefaultValues = {
      Empty         : '(empty)'
      NotTagged     : 'Not tagged'
      AllValues     : 'All values'
      AllAttributes : 'All Attributes'
    }

    RefRegx = /@\{.+\}/

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

    isResAttributeMatch = ( resource, attr, value ) ->
      unless attr then return true

      if attr is 'name' then return resource.get( 'name' ) is value

      serialized = resource.serialize()
      unless _.isArray(serialized) then serialized = [ serialized ]

      _.some serialized, (serializedItem) ->
        v = serializedItem?.component?.resource?[attr]
        v is value

    hasTag = ( tags, key, value ) ->
      _.some tags, (tag) ->
        tag.get('key') is key and ( arguments.length isnt 3 or tag.get('value') is value )

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
      unFilterTypeInVisualMode: [ constant.RESTYPE.SG ]

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
        _.filter allComp, ( comp ) =>
          if @isVisual
            comp.isVisual() and !comp.port and !_.contains(@unFilterTypeInVisualMode, comp.type)
          else
            !comp.port and _.contains(constant.HASTAG, comp.type)

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
          mode = 'resource_attribute'
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
          effect = if mode is 'resource_attribute' then subKey else key

        mode: mode
        state: state
        key: key
        subKey: subKey
        value: value
        effect: effect

      initialize: (options) ->
        @selection = []

        if options
          @isVisual = options.isVisual
          if options.selection
            for s in options.selection
              @addSelection s

          if options.uid
            comp = Design.instance().component options.uid
            if comp
              @addSelection {
                key   : "#{getResShortNameByType(comp.type)}.name"
                value : comp.get('name')
                type  : 'resource_attribute'
              }

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
        @$(".dropdown").scrollTop 0
        @

      removeDropdown: ->
        @$(".dropdown").html ""

      renderSelection: ->
        @$(".tags").html @tplTag @selection
        @

      renderLineTip: ($fakeInput) ->
        $fakeInput = $fakeInput or @$(".fake-input")
        $ul = @$('.tags')
        $lis = $ul.find('li')

        unless $lis.size()
          @$(".line-tip").text ""
          return

        ulWidth = $ul.width()
        lineWidth = 0
        hideLineNum = 0

        for li, idx in $lis
          $li = $ li
          cs = window.getComputedStyle(li)
          lineWidth += parseInt(cs.width) + parseInt(cs.paddingLeft) + parseInt(cs.paddingRight) + parseInt(cs.marginLeft) + parseInt(cs.marginRight)
          if lineWidth > ulWidth
            hideLineNum = $lis.size() - idx
            break

        if hideLineNum < 1
          @$(".line-tip").text ""
        else
          @$(".line-tip").text "(+" + hideLineNum + ")"

      addSelection: (key, value, type, vtext) ->
        if _.isObject key
          value = key.value
          type = key.type
          vtext = key.vtext
          key = key.key

        else if arguments.length is 1
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
          vtext: vtext or value
          type: type

        if not value and type not in [ 'resource', 'resource_attribute' ] then return

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
          if state is 'resource_attribute'
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

        attrs.push('name')

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
          if attr is 'name'
            dd.push { type: 'attribute_value', value: r.get( 'name' ) }
            break

          serialized = r.serialize()
          unless _.isArray(serialized) then serialized = [ serialized ]

          _.each serialized, (serializedItem) =>
            v = serializedItem?.component?.resource?[attr]
            if v
              dd.push { type: 'attribute_value', value: v, text: @getReadableText(v), vtext: @getReadableText(v) }

        dd = @uniqSortDd dd
        dd.unshift { type: 'attribute_value', value: DefaultValues.AllValues, default: true }

        dd

      getReadableText: (value) ->
        if RefRegx.test value
          id = MC.extractID value
          res = Design.instance().component( id )
          if res then return res.get( 'appId' ) or res.get('name')

        value

      focusInput: ($input) ->
        ($input or @$("input")).focus()
        @renderDropdown()

      clearInput: ($input) ->
        ($input or @$("input")).val ""

      getMatchText: ( data, filter ) ->
        value = data.value.toString()
        text  = data.text.toString()

        # Value Match
        if (matchIdx = value.toLowerCase().indexOf(filter)) isnt -1
          return value.slice(matchIdx, matchIdx + filter.length)
        else if (matchIdx = text.toLowerCase().indexOf(filter)) isnt -1
          return text.slice(matchIdx, matchIdx + filter.length)

      filterByInput: (data, filter) ->
        filter = filter and filter.trim().toLowerCase()

        setSelected = false
        filtered = []

        _.each data, (d) =>
          d.text = d.value.toString() unless d.text
          unless d.text then return

          if d.type is 'label'
            filtered.push d
          else if not filter or match = @getMatchText(d, filter)
            unless setSelected then d.selected = setSelected = true
            d.text = d.text.toString().replace(match, "<span class=\"match\">" + match + "</span>")

            filtered.push d

        # Remove label if it's list empty
        _.filter filtered, (f) ->
          if f.type is 'label'
            return _.some filtered, (ff) -> ff.type is f.for
          true

      fold: (force) ->
        that = @
        unless @hoverDrop
          that.$(".dropdown").empty()
        else if force is true
          @hoverDrop = false
          @fold()

      # @__keydoing mark mouseover caused by up/down(when scroll occured) key
      # not mouse. so that dropdown selected will be right.
      setKeydowning: ->
        clearTimeout @__timeoutResetKeydowning
        @__keydowning = true

      unsetKeydowning: ->
        # Sometimes mouseover caused by up/down triggerd before keyup
        # We delay the flag reset to tell mouseover eventhandler the right situation
        @__timeoutResetKeydowning = setTimeout =>
          @__keydowning = false
        , 300

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
        false

      keyupHandler: (e) ->
        @unsetKeydowning()

        code = e.which
        $input = $(e.currentTarget)
        unless ( _.contains([27, 38, 40], code) )
          @renderDropdown()

      keydownHandler: (e) ->
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
            @setKeydowning()
            $selected = @$(".dropdown .selected")
            $prev = $selected.prevAll('.option').first()
            $dropdown   = @$(".dropdown")
            if $prev.size()
              prevHeight  = $prev.outerHeight()
              prevTop     = $prev.position().top
              ddHeight    = $dropdown.outerHeight()

              if prevTop < 0
                $dropdown[0].scrollTop += prevTop

              $selected.removeClass "selected"
              $prev.addClass "selected"
            else
              @gotoLastDdItem($dropdown, $selected)

            false
          when 40 # Down
            @setKeydowning()
            $selected = @$(".dropdown .selected")
            $next = $selected.nextAll('.option').first()
            $dropdown   = @$(".dropdown")
            if $next.size()
              nextHeight  = $next.outerHeight()
              nextTop     = $next.position().top
              ddHeight    = $dropdown.outerHeight()

              if nextTop + nextHeight > ddHeight
                $dropdown[0].scrollTop += nextTop + nextHeight - ddHeight

              $selected.removeClass "selected"
              $next.addClass "selected"
            else
              @gotoFirstDdItem($dropdown, $selected)

            false

      gotoFirstDdItem: ($dropdown, $selected) ->
        $target = $dropdown.find('li.option').first()
        if $target and $target isnt $selected
          $selected.removeClass 'selected'
          $target.addClass 'selected'
          $dropdown[0].scrollTop = 0

      gotoLastDdItem: ($dropdown, $selected) ->
        $target = $dropdown.find('li.option').last()
        if $target and $target isnt $selected
          $selected.removeClass 'selected'
          $target.addClass 'selected'
          $dropdown[0].scrollTop = $dropdown.height()


      focusInputHandler: ->
        clearTimeout @__timeoutRemoveFocus
        #@renderDropdown()
        @$(".fake-input").addClass "focus"
        @trigger 'focus'

      blurInputHandler: ->
        that = @
        # Because blur event triggerd before click
        # if remove dropdown in blur handler then click event will not be trigger
        # so we delay the removing operation
        @__timeoutRemoveFocus = setTimeout ->
          that.fold()
          that.removeDropdown()
          $fakeInput = that.$(".fake-input")
          $fakeInput.removeClass "focus"
          that.renderLineTip $fakeInput
        , 180

        null

      clickInputHandler: (e) ->
        e.stopPropagation()
        @renderDropdown()
        false

      clickFakeInputHandler: (e) ->
        $(e.currentTarget).addClass "focus"
        @focusInput()
        false

      selectHandler: (e) ->
        @focusInput()
        $tgt = $(e.currentTarget)
        $input = @$("input")
        type = $tgt.data('type')

        state = @getState()

        if state.state is 'value'
          key = state.key + if state.subKey then ".#{state.subKey}" else ''
          @addSelection key, $tgt.data('value'), state.mode, $tgt.data('vtext')
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