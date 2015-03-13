// Generated by CoffeeScript 1.7.1
(function() {
  var $, window;

  window = require("../env/Browser").window;

  $ = window.$;

  describe("UI.ModalPlus Test", function() {
    it("should not render the second modal if the first modal hasn't finished rendering", function(done) {
      return window.require(['UI.modalplus'], function(Modal) {
        var modalA, modalB;
        modalA = new Modal({
          title: "test A"
        });
        modalB = new Modal({
          title: "test B"
        });
        return window.setTimeout(function() {
          if ($(".modal-body").size() > 1) {
            done(new Error("Second modal shouldn't render."));
          } else {
            done();
          }
          return modalA.close();
        }, 500);
      });
    });
    return it("should render the second modal if force option is provided before the first modal finished rendering", function(done) {
      return window.require(["UI.modalplus"], function(Modal) {
        return window.setTimeout(function() {
          var modalA, modalB;
          modalA = new Modal({
            title: "test A"
          });
          modalB = new Modal({
            title: "test B",
            force: true
          });
          return window.setTimeout(function() {
            if ($(".modal-body").size() !== 2) {
              return done(new Error("Second modal should render."));
            } else {
              return done();
            }
          }, 500);
        }, 1000);
      });
    });
  });

}).call(this);

//# sourceMappingURL=modal.map