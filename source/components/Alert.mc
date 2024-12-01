/*   Copyright 2024 Volodymyr Kopytsia
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

// Source: https://forums.garmin.com/developer/connect-iq/f/discussion/106/how-to-show-alert-messages/221#221

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Timer as Timer;

class AlertDelegate extends Ui.InputDelegate
{
    hidden var view;

    function initialize(view) {
        InputDelegate.initialize();
        self.view = view;
    }

    function onKey(evt) {
        view.dismiss();
        return true;
    }

    function onTap(evt) {
        view.dismiss();
        return true;
    }
}

class Alert extends Ui.View
{
    hidden var timer;
    hidden var timeout;
    hidden var text;
    hidden var font;
    hidden var fgcolor;
    hidden var bgcolor;

    function initialize(params) {
        View.initialize();

        text = params.get(:text);
            if (text == null) {
            text = "Alert";
        }

        font = params.get(:font);
        if (font == null) {
            font = Gfx.FONT_MEDIUM;
        }

        fgcolor = params.get(:fgcolor);
        if (fgcolor == null) {
            fgcolor = Gfx.COLOR_BLACK;
        }

        bgcolor = params.get(:bgcolor);
        if (bgcolor == null) {
            bgcolor = Gfx.COLOR_WHITE;
        }

        timeout = params.get(:timeout);
        if (timeout == null) {
            timeout = 2000;
        }

        timer = new Timer.Timer();
    }

    function onShow() {
        timer.start(method(:dismiss), timeout, false);
    }

    function onHide() {
        timer.stop();
    }

    function onUpdate(dc) {
        var tWidth = dc.getTextWidthInPixels(text, font);
        var tHeight = dc.getFontHeight(font);

        var bWidth = tWidth + 14;
        var bHeight = tHeight + 14;

        var bX = (dc.getWidth() - bWidth) / 2;
        var bY = (dc.getHeight() - bHeight) / 2;

        dc.setColor(bgcolor, bgcolor);
        dc.fillRectangle(bX, bY, bWidth, bHeight);

        dc.setColor(fgcolor, bgcolor);
        for (var i = 0; i < 3; ++i) {
            bX += i;
            bY += i;
            bWidth -= (2 * i);
            bHeight -= (2 * i);

            dc.drawRectangle(bX, bY, bWidth, bHeight);
        }

        var tX = dc.getWidth() / 2;
        var tY = bY + bHeight / 2;

        dc.setColor(fgcolor, bgcolor);
        dc.drawText(tX, tY, font, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function dismiss() {
        Ui.popView(SLIDE_IMMEDIATE);
    }

    function pushView(transition) {
        Ui.pushView(self, new AlertDelegate(self), transition);
    }
}