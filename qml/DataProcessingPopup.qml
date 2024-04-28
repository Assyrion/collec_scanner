import QtQuick 6.3
import QtQuick.Controls 6.3

Popup {
    id: root

    signal cancelled

    property string contentText

    Component.onCompleted: open()

    function setValue(value) {
        progressBar.value = value
    }

    function setMaxValue(value) {
        progressBar.to = value
    }

    dim: true
    modal: true
    closePolicy : progressBar.value > 0 ?
                      Popup.NoAutoClose
                    : Popup.CloseOnPressOutside

    Text {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter:
            parent.horizontalCenter

        property string titleActionText : ""

        text : progressBar.value > 0 ?
                   qsTr("%1 %2/%3")
                   .arg(root.contentText)
                   .arg(progressBar.value)
                   .arg(progressBar.to)
                 : qsTr("%1...")
                   .arg(root.contentText)
        color: "white"
        font.family: "Roboto"
        font.pointSize: 11
    }

    ProgressBar {
        id: progressBar
        anchors.centerIn: parent
        value: 0
        indeterminate : value <= 0
        width: parent.width - 20
    }

    Button {
        text: qsTr("cancel")
        anchors.horizontalCenter:
            parent.horizontalCenter
        anchors.bottom: parent.bottom

        leftPadding: 12
        rightPadding: 12

        font.pointSize: 11

        onClicked: {
            root.cancelled()
            root.close()
        }
    }
}
