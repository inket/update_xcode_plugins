[![](https://travis-ci.org/inket/update_xcode_plugins.svg?branch=master)](https://travis-ci.org/inket/update_xcode_plugins) [![Coverage Status](https://coveralls.io/repos/github/inket/update_xcode_plugins/badge.svg?branch=master)](https://coveralls.io/github/inket/update_xcode_plugins?branch=master)

![](https://img.shields.io/badge/xcode%207.3-supported-brightgreen.svg) ![](https://img.shields.io/badge/xcode%208.0-supported-brightgreen.svg) ![](https://img.shields.io/badge/xcode%208.1-supported-brightgreen.svg) ![](https://img.shields.io/badge/xcode%208.2-supported-brightgreen.svg)

### $ update\_xcode\_plugins

This tool adds the missing UUIDs into the installed Xcode plugins so that they can be loaded by newer versions of Xcode.

You can choose to run it once or install a **launch agent** that will trigger the tool every time any of your installed plugins are modified or Xcode/Xcode-beta gets updated.

This tool also allows you to unsign Xcode in order to run plugins on Xcode 8 and later. For more information on why this is needed, see [alcatraz/Alcatraz#475](https://github.com/alcatraz/Alcatraz/issues/475).

When unsigning Xcode, you will also be prompted to unsign `xcodebuild`; Doing so will allow `xcodebuild` to load plugins and silence the library validation warnings. More info at [#8](https://github.com/inket/update_xcode_plugins/issues/8#issuecomment-247881598).

If you are having any issues, please check [common issues](#common-issues) before creating an issue.

#### Install

```shell
$ gem install update_xcode_plugins
```

(if using system ruby: `sudo gem install update_xcode_plugins`)

(if still having problems: `sudo gem install -n /usr/local/bin update_xcode_plugins` [#10](https://github.com/inket/update_xcode_plugins/issues/10))

#### Usage

In Terminal:

```shell
$ update_xcode_plugins
```

![](http://i.imgur.com/0aw1bW4.png)

To use plugins on Xcode 8 and later, unsign Xcode with:

```shell
$ update_xcode_plugins --unsign
```

![](http://i.imgur.com/XUco0su.png)

If you need to restore Xcode, use the command:

```shell
$ update_xcode_plugins --restore
```

##### Other options

For a dry run to see which plugins will be updated,

```shell
$ update_xcode_plugins --dry-run
```

To install the launch agent for automatically updating plugins,

```shell
$ update_xcode_plugins --install-launch-agent
```

or to uninstall the launch agent,

```shell
$ update_xcode_plugins --uninstall-launch-agent
```

##### Common Issues

###### Xcode crashes:

  One or more of the plugins you are using are incompatible with your version of Xcode and are causing it to crash. The crash report will generally include the name of the responsible plugin. If unsure, start removing your plugins one by one until you find the culprit.

#### Contact

[@inket](https://github.com/inket) / [@inket](https://twitter.com/inket) on Twitter / [mahdi.jp](https://mahdi.jp)
