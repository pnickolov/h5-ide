
window = require("../env/Browser").window


describe "UI.ModalPlus Test", ()->

  # Sync test
  it "should not render the second modal if the first modal hasn't finished rendering", (done)->

    window.require ['UI.modalplus'], (Modal)->
      modalA = new Modal({title: "test A"})
      modalB = new Modal({title: "test B"})
      console.log modalA, modalB.isOpen()
      if modalB.isOpen()
        done new Error("Second modal shouldn't render.")
      else
        done()

