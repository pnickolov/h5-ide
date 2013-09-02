(function() {
  define(['MC', 'lib/forge/stack'], function(MC, forge_handler_stack) {
    return MC.forge = {
      stack: forge_handler_stack
    };
  });

}).call(this);
