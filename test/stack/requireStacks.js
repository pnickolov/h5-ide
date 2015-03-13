module.exports = [];

require("fs").readdirSync('./test/stack/').forEach(function(file) {
  var ext, _ref;
  console.log(file);
  ext = (_ref = file.split('.')) != null ? _ref.pop() : void 0;
  if (ext === 'json') {
    return module.exports.push(require("./" + file));
  }
});
