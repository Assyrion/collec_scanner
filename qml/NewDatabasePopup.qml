import QtQuick 6.3
import QtQuick.Controls 6.3
import QtQuick.Layouts 6.3

Popup {
    id: root

    signal cancelled

    dim: true
    modal: true
    closePolicy: Popup.NoAutoClose

    Component.onCompleted: open()

    Image {
        id: iconImg

        anchors.horizontalCenter:
            parent.horizontalCenter
        width: 50

        source: "qrc:/dl_db"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Text {
        id: titleText

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -30
        width: parent.width - 10

        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter

        text : qsTr("A new %1 database is available on the server.<br>Would you like to download it ?")
        .arg(platformName)
        color: "white"
        font.family: "Roboto"
        font.pointSize: 14


    }

    RowLayout {
        id: uploadRow
        anchors.bottom: btnRow.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter:
            parent.horizontalCenter
        width: parent.width - 10
        spacing: 10

        Text {
            id: uploadText

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 3*parent.width/4

            wrapMode: Text.WordWrap

            text : qsTr("Warning : The current database will be replaced ! If you did any modifications, please press the button here")
            color: "white"
            font.family: "Roboto"
            font.pointSize: 8
            font.italic: true
        }
        Button {
            Layout.alignment: Qt.AlignVCenter

            icon.source: "qrc:/ul_db"
            icon.width: 20
            icon.height: 20

            onClicked: {
                comManager.uploadDB()
            }
        }
    }

    RowLayout {
        id: btnRow
        anchors.bottom: parent.bottom
        anchors.horizontalCenter:
            parent.horizontalCenter
        spacing: 25

        Button {
            text: qsTr("OK")
            onClicked: {
                dbManager.currentProxyModel.resetFilter()
                dbManager.reloadDB(platformName)
                root.close()
            }
            leftPadding: 12
            rightPadding: 12

            font.pointSize: 11
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80)
        }
        Button {
            text: qsTr("Cancel")
            onClicked: {
                root.close()
            }
            leftPadding: 12
            rightPadding: 12

            font.pointSize: 11
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: btnRow.children.reduce(function(prev, curr) {
                return curr.implicitWidth > prev ? curr.implicitWidth : prev;
            }, 80)
        }
    }
}
