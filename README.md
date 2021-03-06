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
Type `gulp help` in the terminal


### Custom Gulp Config
Copy `gulpconfig.default` to `gulpconfig.js`. Then modify `gulpconfig.js`


### Modifying gulp tasks
`gulptasks` folder is not watched by the gulp process anymore. You need to manually compile coffees inside `gulptasks` after you modify the file.


### Test
Whoever want to run test must install `zombie` first ( by `npm install zombie` ).
`gulp makegulp` to build the testcase ( from coffeescript to javascript ).
`gulp test` to run test in terminal.


### Use Compass
VisualOps uses compass to pre-process css/scss files. If you need to modify scss, then you need to install compass by (Assuming you have ruby installed on your system):
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
* 请使用`prepare-commit-msg` git-hook来为你的commit message自动加上当前分支名，因为分支以后会被删掉。
* 合并代码时候，禁止使用`git merge -Xignore-space-change`和`git merge -Xignore-all-space`，因为这样会破坏coffeescript的缩进。
* 如果你将要push的分支的远端比本地要新，需要使用`git pull --rebase; git push`，来先将远端rebase到本地，然后再push。
* 使用`gulp debug`和`gulp release`之后，仓库里面会多一个commit（里面包含package.json的修改），这个commit在push到远端的时候，如果和远端冲突了，不要用`git pull --rebase`来解决。只能用merge来解决。

* 开发的代码直接commit到`develop`上面，除非：
1. 你觉得你的这些commit的代码不够稳定，会影响IDE。 
2. 你觉得你的需要一段时间才能完成一个feature。 这两种情况下，请建个feature。 
* `gulp debug`部署mc3.io，只能在`develop`分支做（相对的，`gulp release`只能在`master`做）。这就意味着，如果你要将自己的feature功能发布到mc3。就需要先在本地确保你的feature足够稳定，然后再将你的代码merge到develop，然后再`gulp debug`


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

### # 写详细和有用的注释和commit message
注释不是用来解析代码的，而是用来描述为什么要写这样的代码。

Bad Example:
```js
// render         <--- 这不是废话吗？
view.render()
```

Good Example:
```js
// SgAsso doesn't have portDefs, so the basic validation implemented in ConnectionModel won't work.
// Here, we do our own job.
assignCompsToPorts = function(p1Comp, p2Comp) {}
```
### # 不要写没意义的代码
### # DRY - Don't repeat yourself
