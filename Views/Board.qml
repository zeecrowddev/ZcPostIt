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
import QtQuick.Controls.Styles 1.2
import "mainPresenter.js" as Presenter

ScrollView
{
    id : board

    //property alias contentItem : flickBoard
    property alias contentHeight : flickBoard.contentHeight
    property alias contentWidth : flickBoard.contentWidth

    function createPostIt(component)
    {
        component.createObject(flickBoard.contentItem)
    }

 //   style : ScrollViewStyle {}

    function resize()
    {
        var vx = 0;
        var vy = 0;

        for(var i = 0 ; i < contentItem.children.length ; i++)
        {
            var item = contentItem.children[i];

            if (item.idItem!== undefined)
            {
                if (item.x+item.width > vx)
                {
                    vx = item.x+item.width;
                }
                if (item.y+item.height > vy)
                {
                    vy = item.y+item.height;
                }
            }
        }

        board.contentWidth = vx + 10
        board.contentHeight = vy + 10
    }

    anchors.fill: parent

    signal clicked();

    Flickable
    {
        id : flickBoard

        Component.onCompleted:
        {
            contentHeight = parent.height - 10
            contentWidth = parent.width - 10
        }

        anchors.fill: parent

        MouseArea
        {
            anchors.fill: parent

            onClicked:
            {
                board.clicked();
            }

        }
    }
}
