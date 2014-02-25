## MaderiaCloud IDE

### Getting Started
* Make sure node.js is installed in system. Then install `gulp` by running :
```
npm install -g gulp
```
* After `gulp` is installed. Install additional dependencies by running :
```
npm install
```

### Gulp Commands
* `gulp` - Build CoffeeScripts in dev mode, and then runs a static file server and live reload server
* `gulp watch` - The same as `gulp`, except that it doesn't build CoffScripts at startup
* `gulp dev` - Build CoffeeScripts in dev mode.
* `gulp release` - Build project for release. The build will be in a different repository. (TODO)
* `gulp debug`   - The same as `gulp release`, except that source code are not minimized. (TODO)
* `gulp upgrade` - This is used to upgrade 3rd party module using bower. This command should be used only in rare case. (TODO)


### Custom Gulp Config (TODO)
Copy `gulpconfig-default.js` to `gulpconfig.js`. Then modify `gulpconfig.js`

### LiveReload Support
* The built-in livereload server will notify a client when anything under `src/assets` changes. It doesn't reload browser if any js/html file is changed.
* In order to use livereload, one must install the [Chrome LiveReload Plugin](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei).
* When plugin is installed, an icon will appear in chrome toolbar. Click the icon to enable/disable livereload.

### Known Issue
The gulp tasks of MaderiaCloud IDE use native OS filesystem to monitor file changes instead of node's fileWatcher. This results in some issues (in OSX) :

* Occasionally happens : `Assersion Failed`
* When file is changed, the file won't get compiled.

Whenever these issue happens, close the process by hitting `Ctrl+C`, or close the tab. Then wait for several seconds and re-run the command again.
