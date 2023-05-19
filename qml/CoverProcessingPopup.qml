import QtQuick 6.2
import QtQuick.Controls 6.2

Popup {
    id: root

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    function setValue(value) {
        progressBar.value = value;
    }

    function reset() {
        progressBar.value = 0;
    }

    function setMaxValue(value) {
        progressBar.to = value;
    }

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
        text : progressBar.value > 0 ?
                   qsTr("Processing %1/%2")
                   .arg(progressBar.value)
                   .arg(progressBar.to)
                 : qsTr("Processing covers...")
        color: "white"
        font.family: "Roboto"
        font.pointSize: 11
    }

    ProgressBar {
        id: progressBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
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
            root.close()
        }
    }
}
