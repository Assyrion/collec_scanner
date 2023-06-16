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
            dbManager.currentSqlModel.clearDB()
        })
    }

    function showConfirmSaveDB() {
        var obj = PopupMaker.showConfirmSaveDB(mainWindow)
        obj.accepted.connect(function() {
            dbManager.currentSqlModel.saveDBToFile(fileManager)
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
                text: dbManager.currentProxyModel?.titleFilter ?? ""

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
                        dbManager.currentProxyModel.filterByTitle(filterName.text)
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
            onActivated: dbManager.currentProxyModel.sort(currentIndex,
                                                  ascDescBox.currentValue)
            Component.onCompleted: {
                model = dbManager.currentSqlModel.roleNamesList
                currentIndex = dbManager.currentProxyModel.orderBy
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
                dbManager.currentProxyModel.sort(sortingComboBox.currentIndex,
                                                  currentValue)
            }
            Component.onCompleted: {
                currentIndex = dbManager.currentProxyModel.sortOrder
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
                dbManager.currentProxyModel.filterByOwned(checked, notOwnedCheckBox.checked)
            }
            checked : dbManager?.currentProxyModel?.ownedFilter >= 1
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
                dbManager.currentProxyModel.filterByOwned(ownedCheckBox.checked, checked)
            }
            checked : !(dbManager?.currentProxyModel?.ownedFilter % 2)
        }
    }
    ColumnLayout {
        id: essentialsColumn

        visible: platformName == "ps3"

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
                        dbManager.currentProxyModel.filterOnlyEssentials(false)
                    dbManager.currentProxyModel.filterEssentials(checked)
                }
                checked : dbManager?.currentProxyModel?.essentialsFilter
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
                    dbManager.currentProxyModel.filterOnlyEssentials(checked)
                }
                checked: dbManager?.currentProxyModel?.essentialsOnly
                         && dbManager?.currentProxyModel?.essentialsFilter
            }
        }
    }
    ColumnLayout {
        id: platinumColumn

        visible: platformName == "ps3"

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
                        dbManager.currentProxyModel.filterOnlyPlatinum(false)
                    dbManager.currentProxyModel.filterPlatinum(checked)
                }
                checked : dbManager?.currentProxyModel?.platinumFilter
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
                    dbManager.currentProxyModel.filterOnlyPlatinum(checked)
                }
                checked: dbManager?.currentProxyModel?.platinumOnly
                         && dbManager?.currentProxyModel?.platinumFilter
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



