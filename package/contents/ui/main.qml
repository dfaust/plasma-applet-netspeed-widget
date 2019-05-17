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
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    property bool showSeparately: plasmoid.configuration.showSeparately
    property string speedLayout: plasmoid.configuration.speedLayout
    property bool swapDownUp: plasmoid.configuration.swapDownUp
    property bool showIcons: plasmoid.configuration.showIcons
    property bool showUnits: plasmoid.configuration.showUnits
    property string speedUnits: plasmoid.configuration.speedUnits
    property bool shortUnits: plasmoid.configuration.shortUnits
    property double fontSizeScale: plasmoid.configuration.fontSize / 100
    property double updateInterval: plasmoid.configuration.updateInterval
    property bool customColors: plasmoid.configuration.customColors
    property color byteColor: plasmoid.configuration.byteColor
    property color kilobyteColor: plasmoid.configuration.kilobyteColor
    property color megabyteColor: plasmoid.configuration.megabyteColor
    property color gigabyteColor: plasmoid.configuration.gigabyteColor

    property bool launchApplicationEnabled: plasmoid.configuration.launchApplicationEnabled
    property string launchApplication: plasmoid.configuration.launchApplication
    property bool interfacesWhitelistEnabled: plasmoid.configuration.interfacesWhitelistEnabled
    property var interfacesWhitelist: plasmoid.configuration.interfacesWhitelist

    property var speedData: []

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation {}

    Component.onCompleted: {
        // trigger adding all sources already available
        for (var i in dataSource.sources) {
            dataSource.sourceAdded(dataSource.sources[i]);
        }
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: 'systemmonitor'
        interval: updateInterval * 1000

        onSourceAdded: {
            if (source.indexOf('network/interfaces/lo/') !== -1) {
                return;
            }

            var match = source.match(/^network\/interfaces\/(\w+)\/(receiver|transmitter)\/data(Total)?$/)

            if (match) {
                connectSource(source)

                if (speedData[match[1]] === undefined) {
                    console.log('Network interface added: ' + match[1])
                }
            }
        }

        onSourceRemoved: {
            var match = source.match(/^network\/interfaces\/(\w+)\/(receiver|transmitter)\/data(Total)?$/)

            if (match) {
                disconnectSource(source);

                if (speedData[match[1]] !== undefined) {
                    delete speedData[match[1]]
                    console.log('Network interface removed: ' + source[1])
                }
            }
        }

        onNewData: {
            if (data.value === undefined) {
                return
            }

            var match = sourceName.match(/^network\/interfaces\/(\w+)\/(receiver|transmitter)\/data(Total)?$/)

            if (speedData[match[1]] === undefined) {
                speedData[match[1]] = {down: 0, up: 0, downTotal: 0, upTotal: 0}
            }

            var d = speedData
            var changed = false
            var value = parseFloat(data.value)

            if (match[3] === 'Total') {
                if (match[2] === 'receiver'    && d[match[1]].downTotal != value) {
                    d[match[1]].downTotal = value
                    changed = true
                }
                if (match[2] === 'transmitter' && d[match[1]].upTotal != value) {
                    d[match[1]].upTotal = value
                    changed = true
                }
            } else {
                if (match[2] === 'receiver'    && d[match[1]].down != value) {
                    d[match[1]].down = value
                    changed = true
                }
                if (match[2] === 'transmitter' && d[match[1]].up != value) {
                    d[match[1]].up = value
                    changed = true
                }
            }

            if (changed) {
                speedData = d
            }
        }
    }
}
