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

ScrollView
{
    id : board

    width : 100
    height : 100


    property alias internalBoard : flickBoard

    /*
    function createPostIt(component)
    {
        component.createObject(flickBoard.contentItem)
    }*/

    function resize()
    {
        var vx = 0;
        var vy = 0;

        for ( var key in mainView.localItems ) {

            var item = mainView.localItems[key];

            if (item.x !== undefined)
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

        console.log(">> vx " + vx)
        console.log("vy " + vy)

        flickBoard.width = vx; //Math.max(vx,board.width) /// internalBoardId.scale)*internalBoardId.scale + 10 /// flickBoard.scale //+ 10
        flickBoard.height =vy;  //Math.max(vy,board.height) /// internalBoard.scale)*internalBoardId.scale + 10 // + 10 /// flickBoard.scale //+ 10

    }

    //    anchors.fill: parent

    //signal clicked();

    Item {

        id : flickBoardConatinerId

        width : flickBoard.width*flickBoard.scale + 10
        height : flickBoard.height*flickBoard.scale + 10

        Item
        {
            id : flickBoard

           // color : "red"

            anchors.centerIn: parent

     //       width : internalBoardId.width*internalBoardId.scale + 10
     //       height : internalBoardId.height*internalBoardId.scale + 10

            height : 100//parent.height * 2
            width : 100 //parent.width * 2


            Component.onCompleted:
            {
                //    anchors.fill = parent
                // height = parent.height// - 10
                // width = parent.width// - 10
            }
        }
    }
}
