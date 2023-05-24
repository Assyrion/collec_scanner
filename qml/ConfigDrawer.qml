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
            comManager.uploadDB()
        })
    }

    function showConfirmUploadCovers() {
        var obj = PopupMaker.showConfirmUploadCovers(mainWindow)
        obj.accepted.connect(function() {
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
                        sqlTableModel.filterByTitle(filterName.text)
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
                        sqlTableModel.filterByTitle("")
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
            onActivated: sqlTableModel.setOrderBy(currentIndex,
                                                  ascDescBox.currentIndex)
            Component.onCompleted: {
                model = sqlTableModel.roleNamesList
                currentIndex = sqlTableModel.orderBy
            }
        }
        ComboBox {
            id: ascDescBox
            Layout.alignment : Qt.AlignVCenter
            Layout.preferredWidth: parent.width * 0.35

            model: ["ASC", "DESC"]
            onActivated: sqlTableModel.setOrderBy(sortingComboBox.currentIndex,
                                                  currentIndex)
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

        columnSpacing: 30
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
                sqlTableModel.filterByOwned(checked, notOwnedCheckBox.checked)
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
                sqlTableModel.filterByOwned(ownedCheckBox.checked, checked)
            }
            Component.onCompleted: {
                checked = !(sqlTableModel.ownedFilter % 2)
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



