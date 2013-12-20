(function() {
  $(function() {
    var stateEditorView, updateCSS;
    updateCSS = function() {
      var random;
      random = 1;
      return setTimeout(function() {
        if (random) {
          random = 0;
        } else {
          random = 1;
        }
        $('#css').attr('href', 'index.css?' + random);
        return updateCSS();
      }, 1000);
    };
    updateCSS();
    return stateEditorView = new StateEditorView();
  });

}).call(this);
