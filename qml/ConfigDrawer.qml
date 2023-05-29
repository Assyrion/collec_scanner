import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

import "utils/PopupMaker.js" as PopupMaker

Drawer {
    id: root

    z: 1
    closePolicy: Popup.CloseOnPressOutside
    edge: Qt.LeftEdge

    function showConfirmClearDB() {
        var obj = PopupMaker.showConfirmClearDB(mainWindow)
        obj.accepted.connect(function() {
            sqlTableModel.clearDB()
        })
    }

    function showConfirmSaveDB() {
        var obj = PopupMaker.showConfirmSaveDB(mainWindow)
        obj.accepted.connect(function() {
            sqlTableModel.saveDBToFile(fileManager)
        })
    }

    function showConfirmUploadDB() {
        var obj = PopupMaker.showConfirmUploadDB(mainWindow)
        obj.accepted.connect(function() {
            obj.close()
            root.close()
            comManager.uploadDB()
        })
    }

    function showConfirmUploadCovers() {
        var obj = PopupMaker.showConfirmUploadCovers(mainWindow)
        obj.accepted.connect(function() {
            obj.close()
            root.close()
            comManager.uploadCovers()
        })
    }

    GroupBox {
        id: filterGroupBox

        title: qsTr("Filter")
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        font.family: "Roboto"

        ColumnLayout {
            id: filterColumn

            anchors.fill: parent
            spacing: 10

            TextField {
                id: filterName

                Layout.preferredWidth: parent.width

                placeholderText: qsTr("Search by name")
                Component.onCompleted: {
                    text = sqlTableModel.titleFilter
                }
            }
            RowLayout {
                id: filterBtnRow

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Button {
                    text: qsTr("Apply")

                    leftPadding: 12
                    rightPadding: 12

                    onClicked: {
                        sortFilterProxyModel.filterByTitle(filterName.text)
                        close()
                    }
                    Layout.fillWidth: true
                    Layout.maximumWidth: filterBtnRow.children.reduce(function(prev, curr) {
                        return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                    }, 80)
                }
                Button {
                    text: qsTr("Remove")

                    leftPadding: 12
                    rightPadding: 12

                    onClicked: {
                        filterName.clear()
                        sortFilterProxyModel.filterByTitle("")
                        close()
                    }
                    Layout.fillWidth: true
                    Layout.maximumWidth: filterBtnRow.children.reduce(function(prev, curr) {
                        return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                    }, 80)
                }
            }
        }
    }
    RowLayout {
        id: sortingRow

        anchors.top: filterGroupBox.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: filterGroupBox.horizontalCenter
        width: filterGroupBox.width

        Text {
            id: sortingText
            Layout.alignment : Qt.AlignVCenter

            text: qsTr("Sort by")
            font.family: "Roboto"
            font.pixelSize: 14
            color: "white"
        }
        ComboBox {
            id: sortingComboBox
            Layout.alignment : Qt.AlignVCenter
            Layout.preferredWidth: parent.width * 0.4

            onModelChanged: currentIndex = 1
            onActivated: sortFilterProxyModel.sort(currentIndex,
                                                  ascDescBox.currentValue)
            Component.onCompleted: {
                model = sqlTableModel.roleNamesList
                currentIndex = sqlTableModel.orderBy
            }
        }
        ComboBox {
            id: ascDescBox
            Layout.alignment : Qt.AlignVCenter
            Layout.preferredWidth: parent.width * 0.35

            textRole : "text"
            valueRole: "value"
            model: [{text: qsTr("ASC"),  value: Qt.AscendingOrder},
                    {text: qsTr("DESC"), value: Qt.DescendingOrder}]

            onActivated: {
                sortFilterProxyModel.sort(sortingComboBox.currentIndex,
                                                  currentValue)
            }
            Component.onCompleted: {
                currentIndex = sqlTableModel.sortOrder
            }
        }
    }
    GridLayout {
        id: ownedGrid

        anchors.top: sortingRow.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10

        rows: 2
        columns: 2

        columnSpacing: 10
        rowSpacing: -5

        Label {
            id: labelOwned
            verticalAlignment:
                Label.AlignVCenter
            font.family: "Roboto"
            font.pixelSize: 14
            color: "white"
            text: qsTr("Games owned")
        }
        CheckBox {
            id: ownedCheckBox

            onClicked: {
                sortFilterProxyModel.filterByOwned(checked, notOwnedCheckBox.checked)
            }
            Component.onCompleted: {
                checked = (sqlTableModel.ownedFilter >= 1)
            }
        }
        Label {
            id: labelNotOwned
            verticalAlignment:
                Label.AlignVCenter
            font.family: "Roboto"
            font.pixelSize: 14
            color: "white"
            text: qsTr("Games not owned")
        }
        CheckBox {
            id: notOwnedCheckBox

            onClicked: {
                sortFilterProxyModel.filterByOwned(ownedCheckBox.checked, checked)
            }
            Component.onCompleted: {
                checked = !(sqlTableModel.ownedFilter % 2)
            }
        }
    }
    ColumnLayout {
        id: essentialsColumn

        anchors.top: ownedGrid.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        width: parent.width * 0.4

        RowLayout {
            id: essentialsRow

            Layout.preferredHeight: essentialsCheckBox.checked ? 30 : 0
            Layout.alignment: Qt.AlignLeft
            spacing: 5
            Label {
                id: labelEssentials
                verticalAlignment:
                    Label.AlignVCenter
                font.family: "Roboto"
                font.pixelSize: 14
                color: "white"
                text: qsTr("Essentials")
            }
            CheckBox {
                id: essentialsCheckBox

                onClicked: {
                    if(!checked)
                        sqlTableModel.essentialsOnly = false
                    sortFilterProxyModel.filterEssentials(checked)
                }
                Component.onCompleted: {
                    checked = sqlTableModel.essentialsFilter
                }
            }
            Behavior on Layout.preferredHeight { NumberAnimation { duration : 100 } }
        }
        RowLayout {
            id: essentialsOnlyRow

            opacity : essentialsRow.Layout.preferredHeight > 0 ? 1 : 0
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignRight
            spacing: 5

            enabled : essentialsCheckBox.checked

            Label {
                id: labelOnlyEssentials
                verticalAlignment:
                    Label.AlignVCenter
                font.family: "Roboto"
                font.pixelSize: 14
                color: "white"
                text: qsTr("only")
            }
            CheckBox {
                id: essentialsOnlyCheckBox

                onClicked: {
                    sortFilterProxyModel.filterOnlyEssentials(checked)
                }
                checked: sqlTableModel?.essentialsOnly
                         && sqlTableModel?.essentialsFilter
            }
        }
    }
    ColumnLayout {
        id: platinumColumn

        anchors.top: essentialsColumn.top
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: parent.width * 0.4

        RowLayout {
            id: platinumRow

            Layout.preferredHeight: platinumCheckBox.checked ? 30 : 0
            Layout.alignment: Qt.AlignLeft
            spacing: 5
            Label {
                id: labelPlatinum
                verticalAlignment:
                    Label.AlignVCenter
                font.family: "Roboto"
                font.pixelSize: 14
                color: "white"
                text: qsTr("Platinum")
            }
            CheckBox {
                id: platinumCheckBox

                onClicked: {
                    if(!checked)
                        sqlTableModel.platinumOnly = false
                    sortFilterProxyModel.filterPlatinum(checked)
                }
                Component.onCompleted: {
                    checked = sqlTableModel.platinumFilter
                }
            }
            Behavior on Layout.preferredHeight { NumberAnimation { duration : 100 } }
        }
        RowLayout {
            id: platinumOnlyRow

            opacity : platinumRow.Layout.preferredHeight > 0 ? 1 : 0
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignRight
            spacing: 5

            enabled : platinumCheckBox.checked

            Label {
                id: labelOnlyPlatinum

                verticalAlignment:
                    Label.AlignVCenter
                font.family: "Roboto"
                font.pixelSize: 14
                color: "white"
                text: qsTr("only")
            }
            CheckBox {
                id: platinumOnlyCheckBox

                onClicked: {
                    sortFilterProxyModel.filterOnlyPlatinum(checked)
                }
                checked: sqlTableModel?.platinumOnly
                         && sqlTableModel?.platinumFilter
            }
        }
    }

    ColumnLayout {
        id: btnColumn

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        width: parent.width
        spacing: 5

        Button {
            id: clearDBBtn
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnColumn.children.reduce(function(prev, curr) {
                return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80)

            leftPadding: 12
            rightPadding: 12

            text: qsTr("clear DB")
            onClicked: showConfirmClearDB()
        }
        Button {
            id: saveDBBtn
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnColumn.children.reduce(function(prev, curr) {
                return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80)

            leftPadding: 12
            rightPadding: 12

            text: qsTr("file DB")
            onClicked: showConfirmSaveDB()
        }
        Button {
            id: exportDBBtn
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnColumn.children.reduce(function(prev, curr) {
                return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80)

            leftPadding: 12
            rightPadding: 12

            text: qsTr("upload DB")
            onClicked: showConfirmUploadDB()
        }
        Button {
            id: uploadCoversBtn
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnColumn.children.reduce(function(prev, curr) {
                return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80)

            leftPadding: 12
            rightPadding: 12

            text: qsTr("upload Covers")
            onClicked: showConfirmUploadCovers()

        }
    }
}



