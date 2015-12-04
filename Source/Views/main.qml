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

import QtQuick 2.2
import QtQuick.Controls 1.2

import ZcClient 1.0 as Zc

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    property var activePostIt : null
    property var localItems : ({})


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


    function createPostIt(idItem)
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

    toolBarActions :
        [
        Action {
            id: closeAction
            shortcut: "Ctrl+X"
            iconSource: "../Resources/close.png"
            tooltip : "Close Aplication"
            onTriggered:
            {
                board.focus = false;
                Qt.inputMethod.hide();
                mainView.closeTask();
            }
        },
        Action {
            id: plusYellow
            tooltip : "Add a yellow PostIt"
            iconSource : "../Resources/postit_yellow_icon.png"
            onTriggered:
            {
                var idItem = generateId();
                postItDefinition.setItem(idItem,"");
            }
        },
        Action {
            id: plusBlue
            tooltip : "Add a blue PostIt"
            iconSource : "../Resources/postit_blue_icon.png"
            onTriggered:
            {
                var idItem = generateId();
                postItDefinition.setItem(idItem,"");
                postItPosition.setItem(idItem,"0|0|0|200|200|blue");
            }
        },
        Action {
            id: plusPink
            tooltip : "Add a pink PostIt"
            iconSource : "../Resources/postit_pink_icon.png"
            onTriggered:
            {
                var idItem = generateId();
                postItDefinition.setItem(idItem,"");
                postItPosition.setItem(idItem,"0|0|0|200|200|pink");
            }
        }
        ,
        Action {
            id: plusGreen
            tooltip : "Add a green PostIt"
            iconSource : "../Resources/postit_green_icon.png"
            onTriggered:
            {
                var idItem = generateId();
                postItDefinition.setItem(idItem,"");
                postItPosition.setItem(idItem,"0|0|0|200|200|green");
            }
        }
    ]

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }


    Component
    {
        id : postItComponent

        PostIt
        {
            id : postIt
            boxWidth : mainView.width
            boxHeight : mainView.height

            onStateChanged:
            {
                if (state === "edition")
                {
                    mainView.setActivePostIt(postIt)
                }
            }

            onDeletePostIt:
            {
                postItDefinition.deleteItem(idItem);
                postItPosition.deleteItem(idItem)
            }

            onPositionChanged:
            {
                var position = valx + "|" + valy + "|" + valz + "|" + valw + "|" + valh + "|" + c;
                postItPosition.setItem(idItem,position);
            }

            onPostItTextChanged:
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
            }

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
                mainView.createPostIt(idItem)
                var value = postItDefinition.getItem(idItem,"");
                localItems[idItem].text = value;

                localItems[idItem].idItem = idItem;

                if (localItems[idItem].text === "" ||
                        localItems[idItem].text === null)
                {
                    var nickName = idItem.split("|");
                    if (nickName.length > 0 && nickName[0] === mainView.context.nickname)
                    {
                        localItems[idItem].state = "edition"
                    }
                }
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
                        mainView.createPostIt(idItem)
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


    Board
    {
        id : board
        //        parking: parkingPanelLeft
        //        main : mainPanel

        //        state : "show"

        onClicked:
        {
            if (localItems.activePostIt !== null)
            {
                mainView.setActivePostIt(null);
            }
        }
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
