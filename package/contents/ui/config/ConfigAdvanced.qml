/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    property alias cfg_launchApplicationEnabled: launchApplicationEnabled.checked
    property alias cfg_launchApplication: launchApplication.menuId
    property alias cfg_interfacesWhitelistEnabled: interfacesWhitelistEnabled.checked
    property var cfg_interfacesWhitelist: []

    Loader {
        id: 'launcher'
        source: '../Launcher.qml'
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: 'systemmonitor'
    }

    ListModel {
        id: interfacesModel
    }

    GridLayout {
        columns: 2

        CheckBox {
            id: launchApplicationEnabled
            text: i18n('Launch application when clicked:')
            enabled: launcher.item != null
        }

        AppPicker {
            id: launchApplication
            enabled: launcher.item != null && launchApplicationEnabled.checked
        }

        Text {
            text: i18n('If you want to lauch an application,\nyou need to install the package plasma-addons first.')
            visible: launcher.item == null
            Layout.columnSpan: 2
        }

        CheckBox {
            id: interfacesWhitelistEnabled
            text: i18n('Show only the following network interfaces:')
            Layout.columnSpan: 2
        }

        Rectangle {
            height: 200
            border {
                width: 1
                color: "lightgrey"
            }
            radius: 2
            color: interfacesWhitelistEnabled.checked ? "#FFFFFFFF" : "#20FFFFFF"
            Layout.columnSpan: 2
            Layout.fillWidth: true

            ScrollView {
                anchors.fill: parent

                ListView {
                    id: interfacesWhitelist
                    anchors.fill: parent
                    clip: true
                    Layout.columnSpan: 2

                    model: interfacesModel

                    delegate: Item {
                        id: interfaceItem
                        width: parent.width
                        height: units.iconSizes.smallMedium + 2*units.smallSpacing

                        property bool isHovered: false

                        CheckBox {
                            x: units.smallSpacing
                            y: units.smallSpacing

                            text: name
                            checked: shown
                            enabled: interfacesWhitelistEnabled.checked

                            onCheckedChanged: {
                                var index = cfg_interfacesWhitelist.indexOf(name)
                                if (checked && index === -1) {
                                    cfg_interfacesWhitelist.push(name)
                                } else if (!checked && index !== -1) {
                                    cfg_interfacesWhitelist.splice(index, 1)
                                }
                            }
                        }
                    }

                    Component.onCompleted: {
                        listInterfaces()
                    }
                }
            }
        }
    }

    function listInterfaces() {
        for (var i in plasmoid.configuration.interfacesWhitelist) {
            interfacesWhitelist.model.append({name: plasmoid.configuration.interfacesWhitelist[i], shown: true})
        }

        sources_loop:
        for (var i in dataSource.sources) {
            var source = dataSource.sources[i]

            if (source.indexOf('network/interfaces/lo/') !== -1) {
                continue
            }

            var match = source.match(/^network\/interfaces\/(\w+)\/(receiver|transmitter)\/data$/)

            if (match) {
                for (var i=0; i<interfacesWhitelist.model.count; i++) {
                    if (interfacesWhitelist.model.get(i).name == match[1]) {
                        continue sources_loop
                    }
                }

                interfacesWhitelist.model.append({name: match[1], shown: false})
            }
        }
    }
}
