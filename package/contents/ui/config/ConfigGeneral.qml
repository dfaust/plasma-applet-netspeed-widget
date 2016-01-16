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

Item {
    property alias cfg_showIcons: showIcons.checked
    property alias cfg_showUnits: showUnits.checked
    property string cfg_speedUnits: 'bytes'
    property alias cfg_updateInterval: updateInterval.value
    property alias cfg_customColors: customColors.checked
    property alias cfg_byteColor: byteColorPicker.chosenColor
    property alias cfg_kilobyteColor: kilobyteColorPicker.chosenColor
    property alias cfg_megabyteColor: megabyteColorPicker.chosenColor
    property alias cfg_gigabyteColor: gigabyteColorPicker.chosenColor
    
    GridLayout {
        columns: 2

        CheckBox {
            id: showIcons
            text: i18n('Show upload and download icons')
            Layout.columnSpan: 2
        }
        
        CheckBox {
            id: showUnits
            text: i18n('Show speed units')
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Speed units')
            enabled: showUnits.checked
        }
        
        ComboBox {
            id: speedUnits
            enabled: showUnits.checked
            textRole: 'label'
            model: [
                {
                    'label': i18n('bits'),
                    'name': 'bits'
                },
                {
                    'label': i18n('bytes'),
                    'name': 'bytes'
                }
            ]
            onCurrentIndexChanged: cfg_speedUnits = model[currentIndex]['name']

            Component.onCompleted: {
                for (var i = 0; i < model.length; i++) {
                    if (model[i]['name'] == plasmoid.configuration.speedUnits) {
                        speedUnits.currentIndex = i
                    }
                }
            }
        }
        
        Label {
            text: i18n('Update interval')
        }
        
        SpinBox {
            id: updateInterval
            decimals: 1
            stepSize: 0.1
            suffix: ' s'
        }
        
        GroupBox {
            id: customColors
            title: "Custom colors"
            checkable: true
            Layout.columnSpan: 2

            GridLayout {
                columns: 2
                
                Label {
                    text: speedUnits.currentText === 'bits' ? 'b' : 'B'
                    Layout.alignment: Qt.AlignRight
                }

                ColorPicker {
                    id: byteColorPicker
                }

                Label {
                    text: speedUnits.currentText === 'bits' ? 'kb' : 'KiB'
                    Layout.alignment: Qt.AlignRight
                }

                ColorPicker {
                    id: kilobyteColorPicker
                }

                Label {
                    text: speedUnits.currentText === 'bits' ? 'Mb' : 'MiB'
                    Layout.alignment: Qt.AlignRight
                }

                ColorPicker {
                    id: megabyteColorPicker
                }

                Label {
                    text: speedUnits.currentText === 'bits' ? 'Gb' : 'GiB'
                    Layout.alignment: Qt.AlignRight
                }

                ColorPicker {
                    id: gigabyteColorPicker
                }
            }
        }
    }
}
