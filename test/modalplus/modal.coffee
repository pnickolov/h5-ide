
window = require("../env/Browser").window

$ = window.$


describe "UI.ModalPlus Test", ()->

  # Sync test
  it "should not render the second modal if the first modal hasn't finished rendering", (done)->

    window.require ['UI.modalplus'], (Modal)->
      modalA = new Modal({title: "test A"})
      modalB = new Modal({title: "test B"})
      window.setTimeout ()->
        if $(".modal-body").size() > 1
          done new Error("Second modal shouldn't render.")
        else
          done()
        modalA.close()
      , 500

  it "should render the second modal if force option is provided before the first modal finished rendering", (done)->

    window.require ["UI.modalplus"], (Modal)->
      window.setTimeout ()->
        modalA = new Modal({title: "test A"})
        modalB = new Modal({title: "test B", force: true})
        window.setTimeout ()->
          if $(".modal-body").size() isnt 2
            done new Error("Second modal should render.")
          else
            done()
        , 500
      , 1000