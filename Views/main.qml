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
import QtQuick.Controls 1.0

import "mainPresenter.js" as Presenter

import ZcClient 1.0

ZcAppView
{
    id : mainView

    anchors.fill : parent

    function createPostIt(idItem)
    {
        if (Presenter.instance[idItem] === undefined ||
                Presenter.instance[idItem] === null)
        {
            //Presenter.instance[idItem] = board.createPostIt(postItComponent)
            postItComponent.createObject(board.contentItem);
        }
    }

    function setPosition(idItem,value)
    {
        if (Presenter.instance[idItem] === undefined ||
                Presenter.instance[idItem] === null)
            return;

        if (value === "")
        {
            Presenter.instance[idItem].x = 0;
            Presenter.instance[idItem].y = 0;
        }
        else
        {
            var position = value.split("|");
            Presenter.instance[idItem].x = position[0];
            Presenter.instance[idItem].y = position[1];
            Presenter.instance[idItem].z = position[2];
            Presenter.instance[idItem].width = position[3];
            Presenter.instance[idItem].height = position[4];

            if (position.length > 5)
            {
                Presenter.instance[idItem].postItColor = position[5];
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
            iconSource: "qrc:/ZcPostIt/Resources/close.png"
            tooltip : "Close Aplication"
            onTriggered:
            {
                mainView.closeTask();
            }
        },
        Action {
            id: plusYellow
            tooltip : "Add a yellow PostIt"
            iconSource : "qrc:/ZcPostIt/Resources/postit_yellow_icon.png"
            onTriggered:
            {
                var idItem = generateId();
                postItDefinition.setItem(idItem,"");
            }
        },
        Action {
            id: plusBlue
            tooltip : "Add a blue PostIt"
            iconSource : "qrc:/ZcPostIt/Resources/postit_blue_icon.png"
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
            iconSource : "qrc:/ZcPostIt/Resources/postit_pink_icon.png"
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
            iconSource : "qrc:/ZcPostIt/Resources/postit_green_icon.png"
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
                    Presenter.instance.setActivePostIt(postIt)
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

                if (visible)
                {
                    postItDefinition.setItem(idItem,newText);
                }
            }

        }
    }


    function generateId()
    {
        var d = new Date();
        return mainView.context.nickname + "|" + d.toLocaleDateString() + "_" + d.toLocaleTimeString() + " " + d.getMilliseconds();
    }

    ZcCrowdActivity
    {
        id : activity

        ZcCrowdActivityItems
        {
            ZcQueryStatus
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
                Presenter.instance[idItem].text = value;

                Presenter.instance[idItem].idItem = idItem;

                if (Presenter.instance[idItem].text === "" ||
                        Presenter.instance[idItem].text === null)
                {
                    var nickName = idItem.split("|");
                    if (nickName.length > 0 && nickName[0] === mainView.context.nickname)
                    {
                        Presenter.instance[idItem].state = "edition"
                    }
                }
            }
            onItemDeleted :
            {
                if (Presenter.instance[idItem] === undefined ||
                        Presenter.instance[idItem] === null)
                    return;
                Presenter.instance[idItem].visible = false;
                Presenter.instance[idItem].parent === null;
                Presenter.instance[idItem] = null;
            }
        }



        ZcCrowdActivityItems
        {
            ZcQueryStatus
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
                    Presenter.instance.forEachInArray(allItems,function(idItem)
                    {
                        mainView.createPostIt(idItem)
                        var value = postItDefinition.getItem(idItem,"");
                        Presenter.instance[idItem].text = value;

                        Presenter.instance[idItem].idItem = idItem;

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
        Presenter.initPresenter()
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
            if (Presenter.instance.activePostIt !== null)
            {
                Presenter.instance.setActivePostIt(null);
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
