
define [ "Scene", "backbone" ], ( Scene )->

  class SceneManager

    # There can be multiple scenes at a same time. But there's only one scene can be visible ( active ).

    constructor : ()->
      @__scenes      = []
      @__scenesById  = {}
      @__activeScene = null
      @

    __frontActivateList : ( scene )->
      newList = [ scene ]
      for s in @__scenes
        if s isnt scene
          newList.push s
      @__scenes = newList
      return
    __endActivateList : ( scene )->
      newList = []
      for s in @__scenes
        if s isnt scene
          newList.push s
      newList.push scene
      @__scenes = newList
      return


    scenes : ()->   @__scenes.slice 0
    get    : (id)-> @__scenesById[ id ]

    add : ( scene )->
      if @__scenesById[ scene.id ] then return scene

      @__scenesById[ scene.id ] = scene

      # Insert the scene to lastActivateList, so that even if the current
      # scene is never activated, we can activated it automatically when
      # the there's no activated scene.
      # If the scene is already activated before adding, it should be inside the active list.
      if @__activeScene isnt scene
        @__frontActivateList( scene )

      if @__scenes.length is 1 then @activate( scene )

      scene

    activeScene : ()-> @__activeScene
    activate : ( scene )->
      if _.isString( scene ) then scene = @__scenesById[ scene ]

      if scene is @__activeScene or not scene or scene.isRemoved() then return scene

      if @__activeScene then @__activeScene.becomeInactive()

      @__activeScene = scene
      @__endActivateList( scene )

      scene.becomeActive()
      scene

    remove : ( scene, force )->

      if _.isString( scene ) then scene = @__spacesById[ scene ]

      if not scene then return

      if not force and not scene.isRemovable() then return

      if scene.isRemoved() then return

      scene.__isRemoved = true

      # Remove ref
      delete @__scenesById[scene.id]
      @__scenes.splice (@__scenes.indexOf scene), 1

      if @__activeScene is scene
        @__activeScene = null
        if @__scenes.length
          @__scenes[ @__scenes.length - 1 ].activate()
        else
          console.info "Creating default scene."
          (new (Scene.DefaultScene())()).activate()

      # Cleanup
      scene.stopListening()
      scene.cleanup()
      return

    find : ( info )->
      for s in @__scenes
        if s.isWorkingOn( info )
          return s

      null

    hasUnsaveScenes : ()-> @__scenes.some ( s )-> !s.isRemovable()

  SceneManager
