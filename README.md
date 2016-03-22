# plasma-applet-netspeed-widget
Plasma 5 widget that displays the currently used network bandwidth.

Based on the [Plasma 4 widget](http://kde-apps.org/content/show.php/netspeed-plasmoid?content=140504) created by Pinter Sandor.

![Screen shot of plasma-applet-netspeed-widget](netspeed-widget.png)

## Depends on
plasma-framework-devel

## Installation
```
git clone https://github.com/HessiJames/plasma-applet-netspeed-widget
cd plasma-applet-netspeed-widget
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
sudo make install
```
