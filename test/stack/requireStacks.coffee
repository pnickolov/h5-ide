module.exports = []

require("fs").readdirSync('./test/stack/').forEach (file) ->
    console.log(file)
    ext = file.split( '.' )?.pop()
    if ext is 'json'
        module.exports.push require("./" + file)


