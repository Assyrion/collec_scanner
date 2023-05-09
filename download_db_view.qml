import QtQuick 6.2
import QtQuick.Window 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

Pane {
    id: mainWindow

    Text {
        id: titleText
        anchors.bottom: progressBar.top
        anchors.bottomMargin: 20
        anchors.horizontalCenter:
            parent.horizontalCenter
        text : qsTr("Downloading DB")
        color: "white"
        font.family: "Roboto"
        font.pointSize: 15
    }

    ProgressBar {
        id: progressBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        value: 0
        indeterminate : true
        width: parent.width/2
    }
}

