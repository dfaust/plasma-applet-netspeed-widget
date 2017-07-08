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
import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio

Item {
    anchors.fill: parent
    clip: true

    property double marginFactor: 0.2

    property double downSpeed: {
        var speed = 0
        for (var key in speedData) {
            if (interfacesWhitelistEnabled && interfacesWhitelist.indexOf(key) === -1) {
                continue
            }
            speed += speedData[key].down
        }
        return speed
    }

    property double upSpeed: {
        var speed = 0
        for (var key in speedData) {
            if (interfacesWhitelistEnabled && interfacesWhitelist.indexOf(key) === -1) {
                continue
            }
            speed += speedData[key].up
        }
        return speed
    }

    property bool singleLine: (height / 2 * fontSizeScale < theme.smallestFont.pixelSize && plasmoid.formFactor != PlasmaCore.Types.Vertical) || !showSeparately

    property double marginWidth: speedTextMetrics.font.pixelSize * marginFactor
    property double iconWidth: showIcons ? iconTextMetrics.advanceWidth + marginWidth : 0
    property double doubleIconWidth: showIcons ? 2*iconTextMetrics.advanceWidth + marginWidth : 0
    property double speedWidth: speedTextMetrics.advanceWidth
    property double unitWidth: showUnits ? unitTextMetrics.advanceWidth + marginWidth : 0

    property double aspectRatio: {
        if (showSeparately) {
            if (singleLine) {
                return (2*iconWidth + 2*speedWidth + 2*unitWidth + marginWidth) * fontSizeScale / speedTextMetrics.height
            } else {
                return (iconWidth + speedWidth + unitWidth) * fontSizeScale / (2*speedTextMetrics.height)
            }
        } else {
            return (doubleIconWidth + speedWidth + unitWidth) * fontSizeScale / speedTextMetrics.height
        }
    }

    property double fontHeightRatio: speedTextMetrics.font.pixelSize / speedTextMetrics.height

    property double lineHeight: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return width / aspectRatio / 2
        } else {
            return singleLine ? height : height / 2
        }
    }

    property double offset: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return (width - height * aspectRatio) / 2
        } else {
            return 0
        }
    }

    Layout.minimumWidth: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return 0
        } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
            return height * aspectRatio
        } else {
            return height * aspectRatio
        }
    }
    Layout.minimumHeight: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return width / aspectRatio * fontSizeScale * fontSizeScale
        } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
            return 0
        } else {
            return theme.smallestFont.pixelSize / fontSizeScale
        }
    }

    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        icon: 'network-connect'
        mainText: i18n('Network usage')
        subText: {
            var details = ''
            for (var key in speedData) {
                if (interfacesWhitelistEnabled && interfacesWhitelist.indexOf(key) === -1) {
                    continue
                }

                if (details != '') {
                    details += '<br><br>'
                }

                details += '<b>' + key + '</b><br>'
                details += 'Downloaded: <b>' + totalText(speedData[key].downTotal) + '</b>, Uploaded: <b>' + totalText(speedData[key].upTotal) + '</b>'
            }
            return details
        }
    }

    TextMetrics {
        id: iconTextMetrics
        text: '↓'
        font.pixelSize: 64
    }

    TextMetrics {
        id: speedTextMetrics
        text: '1000.0'
        font.pixelSize: 64
    }

    TextMetrics {
        id: unitTextMetrics
        text: {
            if (speedUnits === 'bits') {
                return shortUnits ? 'm' : 'Mb/s'
            } else {
                return shortUnits ? 'M' : 'MiB/s'
            }
        }
        font.pixelSize: 64
    }

    PlasmaCore.DataSource {
        id: appsSource
        engine: 'apps'
        connectedSources: launchApplication
    }

    Kio.KRun {
        id: kRun
    }

    Item {
        id: offsetItem
        width: offset
        height: parent.height
        x: 0
        y: 0
    }

    Text {
        id: downIcon
        clip: true

        height: singleLine ? parent.height : parent.height / 2
        width: showSeparately ? iconTextMetrics.advanceWidth / iconTextMetrics.height * height * fontSizeScale : iconTextMetrics.advanceWidth / iconTextMetrics.height * height * fontSizeScale * 2

        verticalAlignment: Text.AlignVCenter
        anchors.left: offsetItem.right
        y: 0
        font.pixelSize: height * fontHeightRatio * fontSizeScale

        text: showSeparately ? '↓' : '↓↑'
        color: theme.textColor
        visible: showIcons
    }

    Text {
        id: downText
        clip: true

        height: singleLine ? parent.height : parent.height / 2
        width: speedTextMetrics.advanceWidth / speedTextMetrics.height * height * fontSizeScale

        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        anchors.left: showIcons ? downIcon.right : offsetItem.right
        anchors.leftMargin: showIcons ? font.pixelSize * marginFactor : 0
        y: 0
        font.pixelSize: height * fontHeightRatio * fontSizeScale

        text: speedText(showSeparately ? downSpeed : downSpeed + upSpeed)
        color: speedColor(showSeparately ? downSpeed : downSpeed + upSpeed)
    }

    Text {
        id: downUnitText
        clip: true

        height: singleLine ? parent.height : parent.height / 2
        width: unitTextMetrics.advanceWidth / unitTextMetrics.height * height * fontSizeScale

        verticalAlignment: Text.AlignVCenter
        anchors.left: downText.right
        anchors.leftMargin: font.pixelSize * marginFactor
        y: 0
        font.pixelSize: height * fontHeightRatio * fontSizeScale

        text: speedUnit(showSeparately ? downSpeed : downSpeed + upSpeed)
        color: theme.textColor
        visible: showUnits
    }

    Text {
        id: upIcon
        clip: true

        height: singleLine ? parent.height : parent.height / 2
        width: iconTextMetrics.advanceWidth / iconTextMetrics.height * height * fontSizeScale

        verticalAlignment: Text.AlignVCenter
        anchors.left: (singleLine && showUnits) ? downUnitText.right : (singleLine ? downText.right : offsetItem.right)
        anchors.leftMargin: singleLine ? font.pixelSize * marginFactor : 0
        y: singleLine ? 0 : parent.height / 2
        font.pixelSize: height * fontHeightRatio * fontSizeScale

        text: '↑'
        color: theme.textColor
        visible: showSeparately && showIcons
    }

    Text {
        id: upText
        clip: true

        height: singleLine ? parent.height : parent.height / 2
        width: speedTextMetrics.advanceWidth / speedTextMetrics.height * height * fontSizeScale

        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        anchors.left: showIcons ? upIcon.right : ((singleLine && showUnits) ? downUnitText.right : (singleLine ? downText.right : offsetItem.right))
        anchors.leftMargin: (showIcons || singleLine) ? font.pixelSize * marginFactor : 0
        y: singleLine ? 0 : parent.height / 2
        font.pixelSize: height * fontHeightRatio * fontSizeScale

        text: speedText(upSpeed)
        color: speedColor(upSpeed)
        visible: showSeparately
    }

    Text {
        id: upUnitText
        clip: true

        height: singleLine ? parent.height : parent.height / 2
        width: unitTextMetrics.advanceWidth / unitTextMetrics.height * height * fontSizeScale

        verticalAlignment: Text.AlignVCenter
        anchors.left: upText.right
        anchors.leftMargin: font.pixelSize * marginFactor
        y: singleLine ? 0 : parent.height / 2
        font.pixelSize: height * fontHeightRatio * fontSizeScale

        text: speedUnit(upSpeed)
        color: theme.textColor
        visible: showSeparately && showUnits
    }

    MouseArea {
        anchors.fill: parent
        enabled: launchApplicationEnabled

        onClicked: {
            if (appsSource.data[launchApplication]) {
                kRun.openUrl(appsSource.data[launchApplication].entryPath)
            }
        }
    }

    function speedText(value) {
        if (speedUnits === 'bits') {
            value *= 8 * 1.024
            if (value >= 1000000) {
                value /= 1000000
            }
            else if (value >= 1000) {
                value /= 1000
            }
            else if (value < 1) {
                value *= 1000
            }
        } else {
            if (value >= 1048576) {
                value /= 1048576
            }
            else if (value >= 1024) {
                value /= 1024
            }
            else if (value < 1) {
                value *= 1024
            }
        }
        return value.toFixed(1)
    }

    function speedColor(value) {
        if (!customColors) {
            return theme.textColor
        }

        if (speedUnits === 'bits') {
            value *= 8 * 1.024
            if (value >= 1000000) {
                return gigabyteColor
            }
            else if (value >= 1000) {
                return megabyteColor
            }
            else if (value >= 1) {
                return kilobyteColor
            }
            else {
                return byteColor
            }
        } else {
            if (value >= 1048576) {
                return gigabyteColor
            }
            else if (value >= 1024) {
                return megabyteColor
            }
            else if (value >= 1) {
                return kilobyteColor
            }
            else {
                return byteColor
            }
        }
    }

    function speedUnit(value) {
        if (speedUnits === 'bits') {
            value *= 8 * 1.024
            if (value >= 1000000) {
                return shortUnits ? 'g' : 'Gb/s'
            }
            else if (value >= 1000) {
                return shortUnits ? 'm' : 'Mb/s'
            }
            else if (value >= 1) {
                return shortUnits ? 'k' : 'Kb/s'
            }
            else {
                return shortUnits ? 'b' : 'b/s'
            }
        } else {
            if (value >= 1048576) {
                return shortUnits ? 'G' : 'GiB/s'
            }
            else if (value >= 1024) {
                return shortUnits ? 'M' : 'MiB/s'
            }
            else if (value >= 1) {
                return shortUnits ? 'K' : 'KiB/s'
            }
            else {
                return shortUnits ? 'B' : 'B/s'
            }
        }
    }

    function totalText(value) {
        var unit
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
