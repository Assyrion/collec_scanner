import QtQuick 6.2
import QtQuick.Controls 6.2

Popup {
    id: progressDialog


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
    closePolicy : progressBar.value > 0 ? Popup.NoAutoClose
                                        : Popup.CloseOnPressOutside

    Text {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter:
            parent.horizontalCenter
        text : progressBar.value > 0 ?
                   "Downloading " + progressBar.value
                   + "/" + progressBar.to
                 : "Checking missing covers..."
        color: "white"
        font.family: "Roboto"
        font.pointSize: 11
    }

    ProgressBar {
        id: progressBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        value: 0
        indeterminate : value == 0
        width: parent.width - 20
    }
}
