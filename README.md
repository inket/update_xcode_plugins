### $ update\_xcode\_plugins

This tool adds the missing UUIDs into the installed Xcode plug-ins so that they can be loaded by newer versions of Xcode.

You can choose to run it once or install a **launch agent** that will trigger the tool every time any of your installed plugins are modified or Xcode/Xcode-beta gets updated.

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

![](http://i.imgur.com/XQZHSND.png)

##### Other options

For a dry run,

```shell
$ update_xcode_plugins --dry-run
```

![](http://i.imgur.com/SPdbt2V.png)

To install the launch agent,

```shell
$ update_xcode_plugins --install-launch-agent
```

or to uninstall the launch agent,

```shell
$ update_xcode_plugins --uninstall-launch-agent
```

#### Contact

[@inket](https://github.com/inket) / [@inket](https://twitter.com/inket) on Twitter / [mahdi.jp](https://mahdi.jp)