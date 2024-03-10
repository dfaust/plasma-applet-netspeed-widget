# plasma-applet-netspeed-widget

Plasma 5 and 6 widget that displays the currently used network bandwidth.

![Screen shot of plasma-applet-netspeed-widget](netspeed-widget.png)

Dependencies:

* awk

Optional dependencies:

* plasma-addons (may be called plasma5-addons, kdeplasma-addons or similar - used to launch a user defined application when the applet is clicked)

## Installation

### From openDesktop.org

1. Go to [https://www.opendesktop.org/p/998895/](https://www.opendesktop.org/p/998895/) for the Plasma 5 version, or [https://www.opendesktop.org/p/2136505/](https://www.opendesktop.org/p/2136505/) for the Plasma 6 version.
2. Click on the `Files` tab.
3. Click the `Install` button.
4. Make sure the package `awk` is installed.

### From within the Plasma workspace

1. If your widgets are locked, right-click the desktop and select `Unlock Widgets`.
2. Right-click the desktop and select `Add Widgets...`.
3. Click the `Get new widgets` button in the Widget Explorer that just opened.
4. Type `Netspeed Widget` into the search field.
5. Click the `Install` button next to "Netspeed Widget".
6. Make sure the package `awk` is installed.

### From source

```bash
git clone https://github.com/dfaust/plasma-applet-netspeed-widget
cd plasma-applet-netspeed-widget
./install.sh
```
