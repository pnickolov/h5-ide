## Getting Started
* Make sure the newest node.js is installed in system. Recommand version is `v0.10.26`
* Then install `gulp` by running :
```
npm install -g gulp@3.6.0
```
* After `gulp` is installed. Install additional dependencies by running :
```
npm install
```

### Gulp Commands
* `gulp` - Build CoffeeScripts in dev mode, and then runs a static file server and live reload server. This is the same as running `gulp dev;gulp watch`
* `gulp watch` - Compile files when they're modified, and starts a local server @localhost:3000.
* `gulp dev` - Build CoffeeScripts and SCSS in dev mode, excluding `src/service` and `src/model`
* `gulp dev_all` - Build CoffeeScripts and SCSS in dev mode, including `src/service` and `src/model`

* `gulp release` - Build the project in release mode(Concat & Minify). And push to h5-ide-build/master
* `gulp debug`   - The same as `gulp release`, except that source code are not minimized. And are push to h5-ide-build/develop
* `gulp qa`      - The same as `gulp debug`, except that it doesn't push code to remote. And starts a local server. Since the build is almost like the release version. It is recommanded to use this command to create a local version of IDE to test.
* `gulp help`    - Print help message of gulp tasks.


### Custom Gulp Config
Copy `gulpconfig-default.js` to `gulpconfig.js`. Then modify `gulpconfig.js`


### Automated Test
`gulp release` `gulp debug` `gulp qa` will try to run test suit if `zombie` is available. In order to install `zombie`, one need to install an C++ compiler in the system and then run `npm install zombie`


### Use Compass
MadeiraCloud IDE uses compass to pre-process css/scss files. If you need to modify scss, then you need to install compass by (Assuming you have ruby installed on your system):
`sudo gem install compass`


### LiveReload Support
* The built-in livereload server will notify a client when anything under `src/assets` changes. It doesn't reload browser if any js/html file is changed by default.
* In order to use livereload, one must install the [Chrome LiveReload Plugin](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei).
* When plugin is installed, an icon will appear in chrome toolbar. Click the icon to enable/disable livereload.


### Known Issue of Native FsEvent
When pollingWatch is false or "auto" in OSX, gulp use native FsEvent to monitor file changes. The shortcoming of this method is that some action will not be reported by the OS. For example, vim saving file probably won't be reported.

Also, there's some other (rare) issues :
* Occasionally happens : `Assersion Failed`
* When file is changed, the file won't get compiled.

Whenever these (rare) issue happens, close the process by hitting `Ctrl+C`, or close the tab. Then wait for several seconds and re-run the command again.


## 关于 js/ide/config & Module ID
* 首先按照下面的Best Practice来正确选择是否使用Module ID。
* 接着把模块ID和路径的映射添加到js/ide/config的`requirejs.config.paths`里面
* 假如这个模块最终会被合并到一个大的模块`bigModuleA`里面的话，需要把这个模块的ID添加到`requirejs.config.bundles["bigModuleA"]`的数组里。

## 关于Git
* 合并代码时候，禁止使用`git merge -Xignore-space-change`和`git merge -Xignore-all-space`，因为这样会破坏coffeescript的缩进。
* 如果你将要push的分支的远端比本地要新，需要使用`git pull --rebase; git push`，来先将远端rebase到本地，然后再push。


## Best Practice
### # 使用正确的方式定义模块
不要使用这种错误的方式去定义一个模块：
```js
define([], function(){
    return {
        loadModule : loadModule
        unLoadModule : unLoadModule
    };
});
```

模块的定义有两种方式，一种是`对象`，一种是`类`。

`对象`型定义：
```js
/*
  这种模块定义模式适用于：定义helper function集合。
  这些helper function没有特定的作用域。也就是说它们的this指向window。
  它们在逻辑上互不相关，但在功能上相连。每个函数实现一个特定的目的。

  具体例子参考：
  component/exporter/JsonExporter.coffee
  component/exporter/Thumbnail.coffee
  lib/aws/*.coffee
*/
define([], function(){
    return {
        save : function(){}
        load : function(){}
        compress : function(){}
    };
});
```

`类`型定义：
```js
/*
  这种模块定义模式适用于：对象型定义以外的情况。
  这个模块返回一个类，外部使用这个模块需要使用这个类来一个对象。然后外部再操作这个对象来使用这个模块。
  对象的方法一般是内聚的，并且这些方法都有个特定的作用域，那就是这个对象。

  具体例子参考：
  component/sgrule/SgRulePopup.coffee
  module/design/framework/*.coffee
*/
define([], function(){
    function TA() {}

    TA.prototype.verify    = function(){};
    TA.prototype.hide      = function(){};
    TA.prototype.showError = function(){};

    return TA;
});
```

### # 给文件（模块）提供有意义的名字
不要使用`main.coffee`, `view.coffee`, `model.coffee`这种笼统的名字来做为文件名。一般来说可以使用这个模块的名称作为文件名。例如上述例子中的TA模块可以叫做`TA.coffee`。

具体例子参考`module/design/framework/*.coffee`


### # 如果一个文件只在一个大的模块内部被使用，那么就不应该为这个文件在`config.coffee`里创建模块ID。
Bad Example:
```js
// src/js/ide/config.coffee
// https://github.com/MadeiraCloud/h5-ide/commit/fbb2f81#diff-6de95fe0ab25276ee4f5ef715f625a04R167
// 这里的markdown属于stateeditor这个模块，并且只被它使用。所以不应该使用ID
require.config({
  ...
  'markdown' : "component/stateeditor/lib/markdown"
});
```
Good Example:
```js
// src/js/ide/config.coffee
// 这里的UI.tooltip属于ui这个模块，并且也被其他模块使用，所以应该使用ID
require.config({
  'UI.tooltip' : 'ui/common/UI.tooltip'
});
```

### # 写详细和有用的注释
### # 不要写没意义的代码
### # DRY - Don't repeat yourself
