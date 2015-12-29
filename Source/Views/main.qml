/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the ZcPostIt application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* ZcPostIt is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

import ZcClient 1.0 as Zc
import "../Components" as PiComponents

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    property var activePostIt : null
    property var localItems : ({})

    PiComponents.ToolBar
    {
        id : toolbarBoard

        height: Zc.AppStyleSheet.height(0.3)

        anchors {
            right: parent.right
            left: parent.left
            top: parent.top
            topMargin : 1
        }

        Row {
            id : toolBarId
            anchors.fill: parent

            PiComponents.ToolButton {
                onClicked: {
                    showPostItEdit("","yellow");
                }
                iconSource: "../Resources/postit_yellow_icon.png"
            }
            PiComponents.ToolButton {
                onClicked: {
                    showPostItEdit("","blue");
                }
                iconSource: "../Resources/postit_blue_icon.png"
            }
            PiComponents.ToolButton {
                onClicked: {
                    showPostItEdit("","green");
                }
                iconSource: "../Resources/postit_green_icon.png"
            }
            PiComponents.ToolButton {
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    showPostItEdit("","pink");
                }
                iconSource: "../Resources/postit_pink_icon.png"
            }
            PiComponents.ToolButton {
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    board.internalBoard.scale += 0.1;
                    board.resize()
                }
                iconSource: "../Resources/loupe_plus.png"
            }
            PiComponents.ToolButton {
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    board.internalBoard.scale -= 0.1;
                    board.resize()
                }
                iconSource: "../Resources/loupe_moins.png"
            }

        }
    }


    PiComponents.ToolBar
    {
        id : toolbarPostit

        visible : false

        anchors {
            right: parent.right
            left: parent.left
            top: parent.top
            topMargin : 1
        }

        RowLayout {
            anchors.fill: parent

            PiComponents.ToolButton {
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    postItModification.clear();
                    postItModification.visible = false
                    toolbarBoard.visible = true
                    toolbarPostit.visible = false
                }
                text: qsTr("Cancel")
            }

            PiComponents.ToolButton {
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    var idItem = postItModification.idItem;
                    if (idItem == "") {
                         idItem = generateId();
                    }
                    postItTextChanged(idItem,postItModification.textPostIt)
                    postItPosition.setItem(idItem,postItModification.getPositionString());

                    postItModification.visible = false
                    toolbarBoard.visible = true
                    toolbarPostit.visible = false
                    postItModification.clear();
                }
                text: qsTr("Ok")
            }
        }
    }

    Board {
        id : board

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top : toolbarBoard.bottom
        }
/*        PinchArea {
            anchors.fill: parent

            onSmartZoom : {

                console.log(">> zoom")
            }
        }*/


        /*onClicked: {
            if (localItems.activePostIt !== null) {
                mainView.setActivePostIt(null);
            }
        }*/
    }

    function showContexctualMenu(idItem) {
        contextualMenu.idItem = idItem
        contextualMenu.show();
    }

    function showPostItEdit(idItem,color) {
        if (idItem!=="") {
            postItModification.idItem = idItem;
        } else {
            postItModification.postItColor = color;
        }

        postItModification.visible = true
        toolbarBoard.visible = false
        toolbarPostit.visible = true
    }

    PiComponents.ActionList {
        id: contextualMenu

        property string idItem : ""

        Action {
            text: qsTr("Edit")
            onTriggered: {
                mainView.showPostItEdit(contextualMenu.idItem,"");
            }
        }

        Action {
            text: qsTr("To Top")
            onTriggered: {

                var maxZ = 0
                for ( var item in localItems ) {
                    if (localItems[item].z !== undefined && localItems[item].z> maxZ) {
                        maxZ = localItems[item].z
                    }
                }

                var currentItem = localItems[contextualMenu.idItem];
                var position = currentItem.x + "|" + currentItem.y + "|" + maxZ+1 + "|" + currentItem.width + "|" + currentItem.height + "|" + currentItem.postItColor;
                postItPosition.setItem(contextualMenu.idItem,position);
            }
        }

        Action {
            text: qsTr("Delete")
            onTriggered: {
                postItDefinition.deleteItem(contextualMenu.idItem);
                postItPosition.deleteItem(contextualMenu.idItem);
            }
        }
    }

    PostItEdit {
        id : postItModification
        visible : false
        anchors {
            top : toolbarPostit.bottom
            left : parent.left
            right : parent.right
            bottom: parent.bottom
        }

    }

    function forEachInArray(array, delegate)
    {
        for (var i=0;i<array.length;i++)
        {
            delegate(array[i]);
        }
    }

    function setActivePostIt(postIt)
    {
        if (mainView.activePostIt !== null)
        {
            mainView.activePostIt.state = "readonly";
        }

        mainView.activePostIt = postIt;
    }

    function createPostItIfNecessary(idItem)
    {
        if (localItems[idItem] === undefined ||
                localItems[idItem] === null)
        {
            localItems[idItem] = postItComponent.createObject(board.internalBoard);
        }
    }

    function setPosition(idItem,value)
    {
        if (localItems[idItem] === undefined ||
                localItems[idItem] === null)
            return;

        if (value === "")
        {
            localItems[idItem].x = 0;
            localItems[idItem].y = 0;
        }
        else
        {
            var position = value.split("|");
            localItems[idItem].x = position[0];
            localItems[idItem].y = position[1];
            localItems[idItem].z = position[2];
            localItems[idItem].width = position[3];
            localItems[idItem].height = position[4];

            if (position.length > 5)
            {
                localItems[idItem].postItColor = position[5];
            }
        }
    }

    function closeTask()
    {
        mainView.close();
    }

    menuActions :
        [
        Action {
            id: closeAction
            text:  "Close ZcPostIt"
            onTriggered:
            {
                board.focus = false;
                Qt.inputMethod.hide();
                mainView.closeTask();
            }
        }
    ]

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }

    function postItTextChanged(idItem,newText) {
        var o =  postItDefinition.getItem(idItem,"");
        postItDefinition.setItem(idItem,newText);

        if (o !== newText)
        {
            var modif = o.text === "" || o.text === null

            // CP : Form qml mock
            var enumModify = Zc.AppNotification !== undefined ? Zc.AppNotification.Modify !== undefined : 2;
            var enumAdd = Zc.AppNotification !== undefined ? Zc.AppNotification.Add !== undefined : 0;
            appNotification.logEvent( modif ? enumAdd : enumModify ,"Post It",newText,"")
        }
    }


    Component
    {
        id : postItComponent

        PostIt
        {
            id : postIt
            boxWidth : mainView.width
            boxHeight : mainView.height

            /*onStateChanged:
            {
                if (state === "edition")
                {
                    mainView.setActivePostIt(postIt)
                }
            }*/

            /*onDeletePostIt:
            {
                postItDefinition.deleteItem(idItem);
                postItPosition.deleteItem(idItem)
            }*/

            onPositionChanged:
            {
                var position = valx + "|" + valy + "|" + valz + "|" + valw + "|" + valh + "|" + c;
                postItPosition.setItem(idItem,position);
            }

            /*    onPostItTextChanged:
            {
                Qt.inputMethod.hide();
                if (visible)
                {
                    var o =  postItDefinition.getItem(idItem,"");

                    postItDefinition.setItem(idItem,newText);

                    if (o !== newText)
                    {
                        var modif = o.text === "" || o.text === null
                        appNotification.logEvent( modif ? Zc.AppNotification.Modify : Zc.AppNotification.Add,"Post It",newText,"")
                    }


                }
            }*/

        }
    }


    function generateId()
    {
        var d = new Date();
        return mainView.context.nickname + "|" + d.toLocaleDateString() + "_" + d.toLocaleTimeString() + " " + d.getMilliseconds();
    }

    Zc.CrowdActivity
    {
        id : activity

        Zc.AppNotification
        {
            id : appNotification
        }

        Zc.CrowdActivityItems
        {
            Zc.QueryStatus
            {
                id : postItDefinitionItemQueryStatus

                onCompleted :
                {
                    postItPosition.loadItems(postItPositionItemQueryStatus);
                }
            }

            id          : postItDefinition
            name        : "PostItDefinition"
            persistent  : true

            onItemChanged :
            {
                mainView.createPostItIfNecessary(idItem)
                var value = postItDefinition.getItem(idItem,"");

                localItems[idItem].text = value;
                localItems[idItem].idItem = idItem;
            }

            onItemDeleted :
            {
                if (localItems[idItem] === undefined ||
                        localItems[idItem] === null)
                    return;
                localItems[idItem].visible = false;
                localItems[idItem].parent === null;
                localItems[idItem] = null;
            }
        }

        Zc.CrowdActivityItems
        {
            Zc.QueryStatus
            {
                id : postItPositionItemQueryStatus

                onCompleted :
                {

                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;

                    var allItems = postItDefinition.getAllItems();
                    if (allItems === null)
                        return;
                    mainView.forEachInArray(allItems,function(idItem)
                    {
                        mainView.createPostItIfNecessary(idItem)
                        var value = postItDefinition.getItem(idItem,"");

                        localItems[idItem].text = value;
                        localItems[idItem].idItem = idItem;

                        mainView.setPosition(idItem,postItPosition.getItem(idItem,""));
                    });

                    board.resize();
                }
            }

            id          : postItPosition
            name        : "PostItPosition"
            persistent  : true

            onItemChanged :
            {
                var value = postItPosition.getItem(idItem,"");
                mainView.setPosition(idItem,value);
                board.resize();
            }
        }

        onStarted :
        {
            postItDefinition.loadItems(postItDefinitionItemQueryStatus);
        }

    }

    onLoaded :
    {
        activity.start();
    }

    onClosed :
    {
        activity.stop();
    }


    Item
    {
        id : mainPanel
        anchors.fill: parent;
    }

    Item
    {
        id : parkingPanelLeft
        anchors.top         : parent.top
        anchors.right       : mainPanel.left
        width               : mainPanel.width
        height              : mainPanel.height
    }
}
