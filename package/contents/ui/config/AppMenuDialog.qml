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
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Dialog {
    id: appMenuDialog
    title: i18n('Choose an application')
    standardButtons: StandardButton.Cancel

    width: 300
    height: 400

    property string selectedMenuId: ''

    PlasmaCore.DataSource {
        id: appsSource
        engine: 'apps'
        connectedSources: sources
    }

    ListModel {
        id: appsModel
    }

    PlasmaExtras.ScrollArea {
        width: parent.width
        height: 400

        ListView {
            id: apps
            anchors.fill: parent
            clip: true

            model: appsModel

            highlight: PlasmaComponents.Highlight {}
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            delegate: Item {
                width: parent.width
                height: units.iconSizes.small + 2*units.smallSpacing

                property bool isHovered: false

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: {
                        apps.currentIndex = index
                        isHovered = true
                    }
                    onExited: {
                        isHovered = false
                    }

                    onClicked: {
                        selectedMenuId = desktop
                        appMenuDialog.accept()
                    }

                    RowLayout {
                        x: units.smallSpacing
                        y: units.smallSpacing

                        Item { // Hack - since setting the dimensions of PlasmaCore.IconItem won't work
                            height: units.iconSizes.small
                            width: height

                            PlasmaCore.IconItem {
                                anchors.fill: parent
                                source: appsSource.data[desktop].iconName
                                active: isHovered
                            }
                        }

                        PlasmaComponents.Label {
                            text: appsSource.data[desktop].name
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            section.property: 'category'
            section.delegate: Item {
                width: parent.width
                height: units.iconSizes.small + 2*units.smallSpacing

                Rectangle {
                    anchors.fill: parent
                    color: theme.complementaryBackgroundColor

                    PlasmaComponents.Label {
                        x: units.smallSpacing
                        y: 0
                        width: parent.width - 2*units.smallSpacing
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: section
                        font.bold: true
                        color: theme.complementaryTextColor
                    }
                }
            }

            Component.onCompleted: {
                listMenuEntries('/')
            }
        }
    }

    function listMenuEntries(menuId) {
        for (var i = 0; i < appsSource.data[menuId].entries.length; i++) {
            var entry = appsSource.data[menuId].entries[i]
            if (/\.desktop$/.test(entry)) {
                var category = (menuId == '/') ? '/' : menuId.slice(0, -1);
                appsModel.append({desktop: entry, category: category})
            } else if (/\/$/.test(entry) && entry != '.hidden/') {
                listMenuEntries(entry)
            }
        }
    }
}
