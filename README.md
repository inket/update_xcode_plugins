![](https://travis-ci.org/inket/update_xcode_plugins.svg?branch=master)

### $ update\_xcode\_plugins

This tool adds the missing UUIDs into the installed Xcode plug-ins so that they can be loaded by newer versions of Xcode.

You can choose to run it once or install a **launch agent** that will trigger the tool every time any of your installed plugins are modified or Xcode/Xcode-beta gets updated.

This tool also allows you to unsign Xcode in order to run plugins on Xcode 8 and later. For more information on why this is needed, see [alcatraz/Alcatraz#475](https://github.com/alcatraz/Alcatraz/issues/475).

#### Install

```shell
$ gem install update_xcode_plugins
```

(if using system ruby: `sudo gem install update_xcode_plugins`)

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

![](http://i.imgur.com/3044DnB.png)

If you need to unsign without creating a copy of Xcode, at your own risk, use the command:

```shell
$ update_xcode_plugins --unsafe-unsign
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

#### Contact

[@inket](https://github.com/inket) / [@inket](https://twitter.com/inket) on Twitter / [mahdi.jp](https://mahdi.jp)
