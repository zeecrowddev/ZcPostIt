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
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2


import ZcClient 1.0 as Zc

Button {
    id: button

    height: Zc.AppStyleSheet.height(0.3)
    width: Zc.AppStyleSheet.width(0.3)

    style: ButtonStyle {
        background: Rectangle {
            height: Zc.AppStyleSheet.height(0.3)
            width: Zc.AppStyleSheet.width(0.3)

            Image {

                anchors.fill: parent

                source : control.iconSource

                Rectangle {
                    anchors.fill: parent
                    //border.width: 2
                    //border.color: control.pressed ? "#448": "white"
                    //radius: 6
                    color: control.pressed ? "lightgrey" : "transparent"
                }
            }
        }

        label: Text {
            id : text
            text: button.text
            font.pixelSize: Zc.AppStyleSheet.height(0.13)
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "#448"
        }
    }
}
