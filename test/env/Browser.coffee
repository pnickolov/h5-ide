
zombie = require("zombie")

Browser =
  globalBrowser : new zombie({silent:true})

module.exports = Browser
