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
    property bool singleLine: parent.height * 0.8 < theme.smallestFont.pixelSize * 2 && plasmoid.formFactor != PlasmaCore.Types.Vertical
    
    property double iconWidth: showIcons ? iconTextMetrics.width * widthHack + unitTextMetrics.height * 0.2 : 0
    property double speedWidth: speedTextMetrics.width * widthHack
    property double unitWidth: showUnits ? unitTextMetrics.width * widthHack + unitTextMetrics.height * 0.2 : 0
    
    property double aspectRatio: {
        if (singleLine) {
            return (2*iconWidth + 2*speedWidth + 2*unitWidth) /    speedTextMetrics.height  + 0.2
        } else {
            return (  iconWidth +   speedWidth +   unitWidth) / (2*speedTextMetrics.height)
        }
    }
    
    property double textHeight: plasmoid.formFactor != PlasmaCore.Types.Vertical ? (singleLine ? height : height / 2) : (width / aspectRatio / 2)
    property double fontPixelSize: textHeight * 0.8
    property double margin: textHeight * 0.2
    
    Layout.minimumWidth: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return 0
        } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
            return parent.height * aspectRatio
        } else {
            return parent.height * aspectRatio
        }
    }
    Layout.minimumHeight: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return parent.width / aspectRatio
        } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
            return 0
        } else {
            return theme.smallestFont.pixelSize / 0.8
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
        text: speedUnits === 'bits' ? 'Mb' : 'MiB'
        font.pixelSize: 64
    }
    
    property double widthHack: 1.11
        
    Text {
        property double w: iconTextMetrics.width * textHeight * widthHack / iconTextMetrics.height

        id: downIcon
        anchors.left: parent.left
        y: 0
        width: w
        height: parent.height / 2
        text: '↓'
        font.pixelSize: fontPixelSize
        color: theme.textColor
        visible: showIcons
    }
    
    Text {
        property double w: speedTextMetrics.width * textHeight * widthHack / speedTextMetrics.height

        id: downText
        horizontalAlignment: Text.AlignRight
        anchors.left: showIcons ? downIcon.right : parent.left
        anchors.leftMargin: showIcons ? margin : 0
        y: 0
        width: w
        height: parent.height / 2
        text: downValue
        font.pixelSize: fontPixelSize
        color: downColor
    }
    
    Text {
        property double w: unitTextMetrics.width * textHeight * widthHack / unitTextMetrics.height

        id: downUnitText
        anchors.left: downText.right
        anchors.leftMargin: margin
        y: 0
        width: w
        height: parent.height / 2
        text: downUnit
        font.pixelSize: fontPixelSize
        color: theme.textColor
        visible: showUnits
    }
    
    Text {
        property double w: iconTextMetrics.width * textHeight * widthHack / iconTextMetrics.height

        id: upIcon
        anchors.left: (singleLine && showUnits) ? downUnitText.right : (singleLine ? downText.right : parent.left)
        anchors.leftMargin: singleLine ? margin : 0
        y: singleLine ? 0 : parent.height / 2
        width: w
        height: parent.height / 2
        text: '↑'
        font.pixelSize: fontPixelSize
        color: theme.textColor
        visible: showIcons
    }
    
    Text {
        property double w: speedTextMetrics.width * textHeight * widthHack / speedTextMetrics.height

        id: upText
        horizontalAlignment: Text.AlignRight
        anchors.left: showIcons ? upIcon.right : ((singleLine && showUnits) ? downUnitText.right : (singleLine ? downText.right : parent.left))
        anchors.leftMargin: singleLine || showIcons ? margin : 0
        y: singleLine ? 0 : parent.height / 2
        width: w
        height: parent.height / 2
        text: upValue
        font.pixelSize: fontPixelSize
        color: upColor
    }
    
    Text {
        property double w: unitTextMetrics.width * textHeight * widthHack / unitTextMetrics.height

        id: upUnitText
        anchors.left: upText.right
        anchors.leftMargin: margin
        y: singleLine ? 0 : parent.height / 2
        width: w
        height: parent.height / 2
        text: upUnit
        font.pixelSize: fontPixelSize
        color: theme.textColor
        visible: showUnits
    }
}
