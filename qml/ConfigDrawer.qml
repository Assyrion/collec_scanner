import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

Drawer {
    id: root

    z: 1
    closePolicy: Popup.CloseOnPressOutside
    edge: Qt.LeftEdge

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
                    text = sqlTableModel.filter
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

            model: sqlTableModel.roleNamesList
            onModelChanged: currentIndex = 1
            onActivated: sqlTableModel.setOrderBy(currentIndex,
                                                  ascDescBox.currentIndex)
            Component.onCompleted: {
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
            onClicked: loader.loadConfirmClearDB()
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
            onClicked: loader.loadConfirmSaveDB()
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
            onClicked: loader.loadConfirmUploadDB()
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
            onClicked: loader.loadConfirmUploadCovers()

        }
    }
    Loader {
        id: loader

        function loadConfirmClearDB() {
            loader.setSource("utils/CSActionPopup.qml",
                             {   "contentText" : qsTr("DB will be entirely cleared.\nThis action is irreversible."),
                                 "width" : 2*mainWindow.width/3,
                                 "height": mainWindow.height/4,
                                 "x"     : mainWindow.width/6,
                                 "y"     : mainWindow.height/4+50})

            loader.item.accepted.connect( function() { sqlTableModel.clearDB() } )
        }

        function loadConfirmSaveDB() {
            loader.setSource("utils/CSActionPopup.qml",
                             {   "contentText" : qsTr("DB content will be written in <DownloadPath>/game_list.csv"),
                                 "width" : 2*mainWindow.width/3,
                                 "height": mainWindow.height/4,
                                 "x"     : mainWindow.width/6,
                                 "y"     : mainWindow.height/4+50})

            loader.item.accepted.connect( function() { sqlTableModel.saveDBToFile(fileManager) } )
        }

        function loadConfirmUploadDB() {
            loader.setSource("utils/CSActionPopup.qml",
                             {   "contentText" : qsTr("DB will be uploaded to server."),
                                 "width" : 2*mainWindow.width/3,
                                 "height": mainWindow.height/4,
                                 "x"     : mainWindow.width/6,
                                 "y"     : mainWindow.height/4+50})

            loader.item.accepted.connect( function() { comManager.uploadDB() } )
        }

        function loadConfirmUploadCovers() {
            loader.setSource("utils/CSActionPopup.qml",
                             {   "contentText" : qsTr("New covers will be uploaded to server."),
                                 "width" : 2*mainWindow.width/3,
                                 "height": mainWindow.height/4,
                                 "x"     : mainWindow.width/6,
                                 "y"     : mainWindow.height/4+50})

            loader.item.accepted.connect( function() { comManager.uploadCovers() } )
        }
    }
}
