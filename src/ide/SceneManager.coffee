
define [ "backbone" ], ()->

  class SceneManager

    # There can be multiple scenes at a same time. But there's only one scene can be visible ( active ).

    constructor : ()->
      @__scenes      = []
      @__scenesById  = {}
      @__activeScene = null

      @__lastActivateList = []
      @

    scenes : ()->   @__scenes.slice 0
    get    : (id)-> @__scenesById[ id ]

    add : ( scene )->
      if @__scenesById[ scene.id ] then return scene

      @__scenesById[ scene.id ] = scene
      @__scenes.push scene

      if @__scenes.length is 1 then @activate( scene )

      scene

    activeScene : ()-> @__activeScene
    activate : ( scene )->
      if _.isString( scene ) then scene = @__scenesById[ scene ]

      if scene is @__activeScene or not scene or scene.isRemoved() then return scene

      if @__activeScene then @__activeScene.becomeInactive()

      @__activeScene = scene

      @__removefromlastActive( scene )
      @__lastActivateList.push scene

      scene.becomeActive()
      scene

    __removefromlastActive : ( scene )->
      for as, idx in @__lastActivateList
        if as is scene
          @__lastActivateList.splice( idx, 1 )
          break

    remove : ( scene, force )->

      if _.isString( scene ) then scene = @__spacesById[ scene ]

      if not scene then return

      if not force and not scene.isRemovable() then return

      if scene.isRemoved() then return

      scene.__isRemoved = true

      # Remove ref
      delete @__scenesById[scene.id]
      @__scenes.splice (@__scenes.indexOf scene), 1
      @__removefromlastActive( scene )

      if @__activeScene is scene
        @__activeScene = null
        if @__lastActivateList.length
          @__lastActivateList[ @__lastActivateList.length - 1 ].activate()

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
