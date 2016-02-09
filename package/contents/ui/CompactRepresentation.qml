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

Item {
    anchors.fill: parent
    clip: true

    property double marginFactor: 0.2

    property bool singleLine: height / 2 * fontSizeScale < theme.smallestFont.pixelSize && plasmoid.formFactor != PlasmaCore.Types.Vertical

    property double marginWidth: speedTextMetrics.font.pixelSize * marginFactor
    property double iconWidth: showIcons ? iconTextMetrics.advanceWidth + marginWidth : 0
    property double speedWidth: speedTextMetrics.advanceWidth
    property double unitWidth: showUnits ? unitTextMetrics.advanceWidth + marginWidth : 0

    property double aspectRatio: {
        if (singleLine) {
            return (2*iconWidth + 2*speedWidth + 2*unitWidth + marginWidth) * fontSizeScale / speedTextMetrics.height
        } else {
            return (iconWidth + speedWidth + unitWidth) * fontSizeScale / (2*speedTextMetrics.height)
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
            for (var key in totalData) {
                if (details != '') {
                    details += '<br><br>'
                }

                var active = key === activeInterface ? ' (active)' : ''

                details += '<b>' + key + active + '</b><br>'
                details += 'Downloaded: <b>' + totalData[key].downTotal + '</b>, Uploaded: <b>' + totalData[key].upTotal + '</b>'
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
            return shortUnits ? 'm' : 'Mb'
        } else {
            return shortUnits ? 'M' : 'MiB'
        }
    }
        font.pixelSize: 64
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
        width: iconTextMetrics.advanceWidth / iconTextMetrics.height * height * fontSizeScale

        verticalAlignment: Text.AlignVCenter
        anchors.left: offsetItem.right
        y: 0

        text: '↓'
        font.pixelSize: height * fontHeightRatio * fontSizeScale
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

        text: downValue
        font.pixelSize: height * fontHeightRatio * fontSizeScale
        color: downColor
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

        text: downUnit
        font.pixelSize: height * fontHeightRatio * fontSizeScale
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

        text: '↑'
        font.pixelSize: height * fontHeightRatio * fontSizeScale
        color: theme.textColor
        visible: showIcons
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

        text: upValue
        font.pixelSize: height * fontHeightRatio * fontSizeScale
        color: upColor
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

        text: upUnit
        font.pixelSize: height * fontHeightRatio * fontSizeScale
        color: theme.textColor
        visible: showUnits
    }
}
