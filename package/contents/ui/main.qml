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
    property bool showIcons: plasmoid.configuration.showIcons
    property bool showUnits: plasmoid.configuration.showUnits
    property string speedUnits: plasmoid.configuration.speedUnits
    property var fontSizeScale: plasmoid.configuration.fontSize / 100
    property var updateInterval: plasmoid.configuration.updateInterval
    property bool customColors: plasmoid.configuration.customColors
    property var byteColor: plasmoid.configuration.byteColor
    property var kilobyteColor: plasmoid.configuration.kilobyteColor
    property var megabyteColor: plasmoid.configuration.megabyteColor
    property var gigabyteColor: plasmoid.configuration.gigabyteColor

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property bool planar: (plasmoid.formFactor == PlasmaCore.Types.Planar)

    property var downValue: '0.0'
    property var downColor: customColors ? byteColor : theme.textColor
    property var downUnit: speedUnits === 'bits' ? 'b' : 'B'
    property var upValue: '0.0'
    property var upColor: customColors ? byteColor : theme.textColor
    property var upUnit: speedUnits === 'bits' ? 'b' : 'B'

    property var lastTimeActive: []
    property var totalData: []

    property string activeInterface: ''
    property var interfaceSwitchDelay: 3000

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

                if (lastTimeActive[match[1]] === undefined) {
                    lastTimeActive[match[1]] = 0
                    totalData[match[1]] = {downTotal: 0, upTotal: 0}
                    console.log('Network interface added: ' + match[1])
                }
            }
        }

        onSourceRemoved: {
            var match = source.match(/^network\/interfaces\/(\w+)\/(receiver|transmitter)\/data(Total)?$/)

            if (match) {
                disconnectSource(source);

                if (lastTimeActive[match[1]] !== undefined) {
                    delete lastTimeActive[match[1]]
                    delete totalData[match[1]]
                    console.log('Network interface removed: ' + source[1])
                }
            }
        }

        onNewData: {
            if (data.value === undefined) {
                return
            }

            var match = sourceName.match(/^network\/interfaces\/(\w+)\/(receiver|transmitter)\/data(Total)?$/)

            if (match[3] === 'Total') {
                var d = totalData
                if (match[2] === 'receiver') {
                    if (d[match[1]] !== undefined) {
                        d[match[1]].downTotal = formatValue(data.value)
                    }
                }
                if (match[2] === 'transmitter') {
                    if (d[match[1]] !== undefined) {
                        d[match[1]].upTotal = formatValue(data.value)
                    }
                }
                totalData = d
            } else {
                if (activeInterface === '') {
                    activeInterface = match[1]
                }

                if (data.value > 0) {
                    var currentTime = Date.now()
                    lastTimeActive[match[1]] = currentTime

                    if (activeInterface != match[1] && lastTimeActive[activeInterface] < currentTime - interfaceSwitchDelay) {
                        activeInterface = match[1]
                    }
                }

                if (activeInterface == match[1]) {
                    if (sourceName.indexOf('receiver') != -1) {
                        var value = formatSpeed(data.value)
                        downValue = value.value
                        downUnit  = value.unit
                        downColor = value.color
                    }

                    if (sourceName.indexOf('transmitter') != -1) {
                        var value = formatSpeed(data.value)
                        upValue = value.value
                        upUnit  = value.unit
                        upColor = value.color
                    }
                }
            }
        }
    }

    function formatSpeed(value) {
        var unit, color
        value = parseFloat(value)
        if (speedUnits === 'bits') {
            value *= 8
            if (value >= 1000000) {
                value /= 1000000
                unit = 'Gb'
                color = customColors ? gigabyteColor : theme.textColor
            }
            else if (value >= 1000) {
                value /= 1000
                unit = 'Mb'
                color = customColors ? megabyteColor : theme.textColor
            }
            else if (value >= 1) {
                unit = 'Kb'
                color = customColors ? kilobyteColor : theme.textColor
            }
            else {
                value *= 1024
                unit = 'b'
                color = customColors ? byteColor : theme.textColor
            }
        } else {
            if (value >= 1048576) {
                value /= 1048576
                unit = 'GiB'
                color = customColors ? gigabyteColor : theme.textColor
            }
            else if (value >= 1024) {
                value /= 1024
                unit = 'MiB'
                color = customColors ? megabyteColor : theme.textColor
            }
            else if (value >= 1) {
                unit = 'KiB'
                color = customColors ? kilobyteColor : theme.textColor
            }
            else {
                value *= 1024
                unit = 'B'
                color = customColors ? byteColor : theme.textColor
            }
        }
        value = value.toFixed(1)
        return {'value': value, 'unit': unit, 'color': color}
//         return {'value': '1000.0', 'unit': speedUnits === 'bits' ? 'Mb' : 'MiB', 'color': theme.textColor}
    }

    function formatValue(value) {
        var unit
        value = parseFloat(value)
        if (value >= 1048576) {
            value /= 1048576
            unit = 'GiB'
        }
        else if (value >= 1024) {
            value /= 1024
            unit = 'MiB'
        }
        else if (value >= 1) {
            unit = 'KiB'
        }
        else {
            value *= 1024
            unit = 'B'
        }
        return value.toFixed(1) + ' ' + unit
    }
}
