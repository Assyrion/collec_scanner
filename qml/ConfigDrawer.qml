import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

Drawer {
    id: root

    closePolicy: Popup.CloseOnPressOutside
    edge: Qt.LeftEdge
    onClosed: {
        filterName.clear()
    }

    Text {
        id: title
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter:
            parent.horizontalCenter
        text: qsTr("Filter")
        font.family: "Roboto"
        font.underline: true
        font.pixelSize: 20
        font.bold: true
        color: "white"
    }
    TextField {
        id: filterName
        anchors.top: title.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        placeholderText: qsTr("Search by name")
    }
    Button {
        id: applyFilterBtn
        anchors.top: filterName.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter:
            filterName.horizontalCenter
        text: filterName.text === "" ? "X" : qsTr("OK")
        onClicked: {
            sqlTableModel.filterByTitle(filterName.text)
            close()
        }
    }
    RowLayout {
        id: sortingRow

        anchors.top: applyFilterBtn.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5

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
            onActivated: sqlTableModel.orderBy(currentIndex,
                                               ascDescBox.currentIndex)
        }
        ComboBox {
            id: ascDescBox
            Layout.alignment : Qt.AlignVCenter
            Layout.preferredWidth: parent.width * 0.35

            model: ["ASC", "DESC"]
            onActivated: sqlTableModel.orderBy(sortingComboBox.currentIndex,
                                               currentIndex)
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

            text: qsTr(" file DB ")
            onClicked: loader.loadConfirmSaveDB()
        }
        Button {
            id: exportDBBtn
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnColumn.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)

            text: qsTr("upload DB")
            onClicked: loader.loadConfirmUploadDB()
        }
        Button {
            id: uploadCoversBtn
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnColumn.children.reduce(function(prev, curr) {
                    return curr.implicitWidth > prev ? curr.implicitWidth : prev;
                }, 80)

            text: qsTr("upload Covers")
            onClicked: loader.loadConfirmUploadCovers()

        }
    }
    Loader {
        id: loader
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
                             {   "contentText" : qsTr("DB will be uploaded to server"),
                                 "width" : 2*mainWindow.width/3,
                                 "height": mainWindow.height/4,
                                 "x"     : mainWindow.width/6,
                                 "y"     : mainWindow.height/4+50})

            loader.item.accepted.connect( function() { comManager.uploadDB() } )
        }

        function loadConfirmUploadCovers() {
            loader.setSource("utils/CSActionPopup.qml",
                             {   "contentText" : qsTr("New covers will be uploaded to server"),
                                 "width" : 2*mainWindow.width/3,
                                 "height": mainWindow.height/4,
                                 "x"     : mainWindow.width/6,
                                 "y"     : mainWindow.height/4+50})

            loader.item.accepted.connect( function() { comManager.uploadCovers() } )
        }
    }
}
