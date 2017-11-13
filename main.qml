import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.0
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "jsdb.js" as HoursDB

ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Hours counter")

    property string currentClient: "No client"
    property string startTime: ""
    property bool started: false

    Settings{
        property alias currentClient: root.currentClient
    }

    onStartedChanged: {
        if(started){
            btnStartStopCount.state = "started"
        }
        else{
            btnStartStopCount.state = "stopped"
        }
    }

    Component.onCompleted: {
        HoursDB.openDB()
        updateModelTimes()
    }

    function updateModelClient(){
        modelClient.clear()
        var items = HoursDB.readClients()
        for(var i=0; i<items.length; i++){
            modelClient.append(items[i])
        }
    }

    function updateModelTimes(){
        modelTimes.clear()
        var items = HoursDB.readTimes()
        for(var i=items.length - 1 ; i>=0; i--){
            modelTimes.append(items[i])
        }
    }

    ListModel{
        id: modelClient
        //ListElement{ name: "Company Name"}
    }

    ListModel{
        id: modelTimes
        //ListElement{ customer: "Company One"; begin: "2017-10-12 09:10:12"; finish: "2017-10-12 09:10:12"; note: "Doing random stuff for money"}
        //ListElement{ customer: "Anon Holding"; begin: "2017-10-12 09:10:12"; finish: "2017-10-12 09:10:12"; note: "Working for the glory of it"}
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Dialog {
            id: dialogSaveTime
            title: qsTr("Save?")
            modal : true
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            implicitWidth: parent.width * 0.75
            implicitHeight: parent.height * 0.75
            standardButtons: Dialog.Ok | Dialog.Cancel

            contentItem: TextArea{
                id: textAreaNotes
                placeholderText: qsTr("Add notes here...")
            }

            onAccepted:{
                var stopTime = HoursDB.datetime()
                HoursDB.addTime(currentClient, startTime, stopTime, textAreaNotes.text)
                updateModelTimes()
            }

            //onRejected: console.log("Cancel clicked")
        }

        //First Page
        Page {

            ListView{
                id: lvTimes
                anchors.fill: parent
                spacing: 5
                model: modelTimes
                highlightFollowsCurrentItem: true
                highlight: Rectangle {
                    color: "lightblue"
                    width: parent.width
                }
                focus: true
                delegate: Component {

                    id: lvTimesDelegate

                    Item{
                        id: lvItem
                        width: txt.width
                        height: txt.height

                        Row{
                            spacing: 4

                            Text {
                                id: txt
                                width: root.width*0.5
                                wrapMode: Text.WordWrap
                                text: customer + ":\n" + begin + "\n" + finish + "\n" + note
                                font.pixelSize: 12
                                color: lvItem.ListView.isCurrentItem ? "red" : "black"
                            }

                            Button{
                                text: qsTr("Delete")
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    dlgYesNoDeleteTime.open()
                                }

                                Dialog {
                                    id: dlgYesNoDeleteTime
                                    title: qsTr("Are you sure?")
                                    x: (parent.width - width) / 2
                                    y: (parent.height - height) / 2
                                    parent: ApplicationWindow.overlay
                                    modal: true

                                    Label{
                                        text: qsTr("Delete the entry? This operation cannot be undone")
                                    }

                                    standardButtons: Dialog.Yes | Dialog.No
                                    onAccepted: {
                                        HoursDB.removeTimeById(timeId)
                                        updateModelTimes()
                                    }
                                    //onRejected: console.log("Do nothing")
                                }
                            }

                            Button{
                                text: qsTr("Edit")
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    dlgYesNoEditTime.open()
                                }
                                Dialog {
                                    id: dlgYesNoEditTime
                                    title: qsTr("Edit")
                                    x: (parent.width - width) / 2
                                    y: (parent.height - height) / 2
                                    parent: ApplicationWindow.overlay
                                    modal: true

                                    GridLayout{
                                        columnSpacing: 3
                                        columns: 2

                                        Label{
                                            text: qsTr("customer: ")
                                        }

                                        TextArea{
                                            id: txtAreacustomer
                                            text: customer
                                        }

                                        Label{
                                            text: qsTr("begin: ")
                                        }

                                        TextArea{
                                            id: txtAreabegin
                                            text: begin
                                        }

                                        Label{
                                            text: qsTr("end: ")
                                        }

                                        TextArea{
                                            id: txtAreafinish
                                            text: finish
                                        }

                                        Label{
                                            text: qsTr("Note: ")
                                        }

                                        TextArea{
                                            id: txtAreaNote
                                            text: note
                                        }
                                    }

                                    standardButtons: Dialog.Yes | Dialog.No
                                    onAccepted: {
                                        customer = txtAreacustomer.text
                                        begin = txtAreabegin.text
                                        finish = txtAreafinish.text
                                        note = txtAreaNote.text
                                        HoursDB.updateTimeById(timeId, customer, begin, finish, note)
                                        updateModelTimes()
                                    }
                                    //onRejected: console.log("Do nothing")
                                }
                            }

                        }

                        MouseArea{
                            id: mouse
                            anchors.fill: parent
                            onClicked: {
                                lvTimes.currentIndex = index
                            }
                        }
                    }
                }
            }
        }

        //Second Page
        Page {
            GridLayout {
                id: grid
                anchors.fill: parent
                columnSpacing: 15
                rowSpacing: 15

                columns: 2

                Text {
                    id: txtClientName
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Current customer: ")
                    font.pixelSize: 15
                }

                ComboBox {
                    id: cbClientName
                    textRole: "name"
                    model: modelClient
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onActivated: {
                        currentClient = currentText
                    }

                    Component.onCompleted: {
                        updateModelClient()
                        //print("modelClient stringified: " + JSON.stringify(modelClient))
                        var index = find(currentClient)
                        //print("combobox index: " + index + " for " + currentClient)
                        if(index !== -1)
                            currentIndex = index
                    }
                }

                Button {
                    id: btnRemoveClient
                    Layout.margins: 30
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr("Delete customer")
                    onClicked: confirmationDialog.open()

                    Dialog {
                        id: confirmationDialog

                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        parent: ApplicationWindow.overlay

                        modal: true
                        title: qsTr("Confirm")
                        standardButtons: Dialog.Yes | Dialog.No

                        Column {
                            spacing: 20
                            anchors.fill: parent
                            Label {
                                text: qsTr("Do you really want to delete this customer?")
                            }
                        }
                        onAccepted: {
                            HoursDB.removeClientByName(currentClient)
                            updateModelClient()
                        }
                    }
                }

                Button {
                    id: btnAddClient
                    Layout.margins: 30
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr("Add customer")

                    onClicked: inputDialog.open()

                    Dialog {
                        id: inputDialog

                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        parent: ApplicationWindow.overlay

                        focus: true
                        modal: true
                        title: qsTr("New customer")
                        standardButtons: Dialog.Ok | Dialog.Cancel

                        ColumnLayout {
                            spacing: 20
                            anchors.fill: parent
                            Label {
                                elide: Label.ElideRight
                                text: qsTr("Insert customer name:")
                                Layout.fillWidth: true
                            }
                            TextField {
                                id: tfNewClientName
                                focus: true
                                placeholderText: qsTr("Customer name")
                                Layout.fillWidth: true
                            }
                        }

                        onAccepted: {
                            var newName = tfNewClientName.text
                            HoursDB.addClient(newName)
                            updateModelClient()
                            currentClient = newName
                            cbClientName.currentIndex = cbClientName.find(newName)
                        }
                    }
                }

                Button {
                    id: btnStartStopCount
                    Layout.margins: 30
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: {
                        started = !started
                        if(started){
                            startTime = HoursDB.datetime()
                            //print(startTime)
                            btnStartStopCount.text = btnStartStopCount.text + "\n" + startTime
                        } else {
                            dialogSaveTime.open()
                        }
                    }

                    state: "stopped"

                    states: [
                        State {
                            name: "started"
                            PropertyChanges { target: btnStartStopCount.background; color: "red" }
                            PropertyChanges { target: btnStartStopCount; text: qsTr("Stop") }
                            PropertyChanges { target: btnCancelCount; enabled: true }
                        },
                        State {
                            name: "stopped"
                            PropertyChanges { target: btnStartStopCount.background; color: "green" }
                            PropertyChanges { target: btnStartStopCount; text: qsTr("Start") }
                            PropertyChanges { target: btnCancelCount; enabled: false }
                        }
                    ]

                }

                Button {
                    id: btnCancelCount
                    Layout.margins: 30
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    onClicked: {
                        btnStartStopCount.state = "stopped"
                        started = false
                        HoursDB.datetime()
                    }
                }
            }

        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("Times table")
        }
        TabButton {
            text: qsTr("Customers")
        }
    }
}
