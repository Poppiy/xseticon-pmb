
<!--#echo json="package.json" key="name" underline="=" -->
xseticon-pmb
============
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Change the window icon of an already-running X11 application. A stripped-down
fork of Paul Evans&#39; `xseticon`.
<!--/#echo -->


This project is based on Paul Evans' very useful `xseticon`.
More specifically, on [commit 8e3da2
](https://github.com/xeyownt/xseticon/tree/8e3da2ab747d06bec3dcdcd8f97b8b8d49e70b6b).



Comparison with upstream
------------------------

The major changes I introduced:

* Removed all the code marked as `FROM programs/xlsfonts/dsimple.c`
  because I'm not 100% sure the licenses are compatible.
  ([Issue #12](https://github.com/xeyownt/xseticon/issues/12))
* Omit window ID detection code.
  That part is suffficiently solved by `xdotool`.
  * This also saves me from any doubt about whether these parts of the
    code are tainted potential xlsfonts license issues.
  * Omitting the mouse aiming code allows to drop the dependency on
    `libxmu-dev`.



Usage
-----

```text
Usage: xseticon-pmb <windowid> <iconfmt> <iconfile>

<windowid>: xterm provides it as $WINDOWID.
    For other applications, xdotool can find it for you.
    Decimal (just an integer) or '0x' + hexadecimal.

<iconfmt>: Image format.
    Currently understands 'png', 'svg' and 'GUESS',
    the latter meaning to naively guess from <iconfile>.

<iconfile>: Path to an image file.
```



<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
GPL-2.0-or-later
<!--/#echo -->
