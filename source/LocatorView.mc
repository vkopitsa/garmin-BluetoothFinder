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

import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.BluetoothLowEnergy;
import Toybox.Lang;
using Toybox.Math;
using Toybox.Graphics as Gfx;
import Rez.Styles;
using Toybox.Sensor;
import Toybox.Activity;

class LocatorView extends WatchUi.View {
    private var _dev as Core.BLEDevice;
    private var rotationAngle = 0; // rotation angle in degrees
    private var headingRssiMap = {}; // heading (int) -> rssi (int)
    private var strongestHeading = 0;
    private var maxRssi = 0;

    function initialize(dev as Core.BLEDevice) {
        View.initialize();

        _dev = dev;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.LocatorLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        Log.debug("LocatorView.onShow");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var x = prompt_loc__title_icon.x-30;
        var y = 10;

        var compasInfo = getCompassInfo();
        rotationAngle = compasInfo[1];
        var adjustedHeading = -((rotationAngle+80) % 360);
        if (adjustedHeading < 0) {
            adjustedHeading += 360;
        }

        var rssiValue = _dev.getQuality();
        if (headingRssiMap.hasKey(adjustedHeading)) {
            if (rssiValue > headingRssiMap.get(adjustedHeading)) {
                headingRssiMap.put(adjustedHeading, rssiValue);
            } else if (rssiValue < headingRssiMap.get(adjustedHeading)){
                headingRssiMap.put(adjustedHeading, 0);
            }
        } else {
            headingRssiMap.put(adjustedHeading, rssiValue);
        }

        // heading with the strongest RSSI
        var headingRssiMapKeys = headingRssiMap.keys();
        for (var i = 0; i < headingRssiMapKeys.size(); i++) {
            var currentRssi = headingRssiMap.get(headingRssiMapKeys[i]);
            if (currentRssi > maxRssi) {
                maxRssi = currentRssi;
                strongestHeading = headingRssiMapKeys[i];
            }
        }

        var polygon = [
            [10+x, 20+y],
            [40+x, 20+y],
            [40+x, 50+y],
            [50+x, 10+y]
        ];

        // rotation center
        var centerX = 30+x, centerY = 30+y;
        var rotatedPolygon = [];
        for (var i = 0; i < polygon.size(); i++) {
            var point = polygon[i];
            rotatedPolygon.add(rotatePoint(point[0], point[1], centerX, centerY, adjustedHeading + strongestHeading));
        }

        // rotated arrow
        dc.setColor(0xFFFFFF, system_color_light__text.background);
        if (isShowHelper(headingRssiMapKeys.size())) {
            dc.fillPolygon(rotatedPolygon);
        }

        var signalText = findDrawableById("signalLocator") as WatchUi.TextArea;
        signalText.setText(
            _dev.getQuality() + "%"
        );
        signalText.setFont(Graphics.FONT_LARGE);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        Log.debug("View.onHide");
    }

    (:release)
    function isShowHelper(c as Number) as Boolean {
        return c > 20;
    }

    (:debug)
    function isShowHelper(c as Number) as Boolean {
        return true;
    }
}

const DEG_TO_RAD = 0.0174532925199;

function rotatePoint(x, y, cx, cy, angle) as [Number, Number] {
    var rad = angle * DEG_TO_RAD;
    var cosA = Math.cos(rad);
    var sinA = Math.sin(rad);

    var dx = x - cx;
    var dy = y - cy;

    return [
        cx + (dx * cosA - dy * sinA),
        cy + (dx * sinA + dy * cosA)
    ];
}

function getCompassInfo() as Array {
    var sensor = Sensor.getInfo();

    var heading = null;

    if (sensor has :heading) {
        if (sensor.heading != null) {
            heading = sensor.heading;
        }
    } else if (sensor has :currentHeading) {
        if (sensor.currentHeading != null) {
            heading = sensor.currentHeading;
        }
    }

    if (heading == null) {
        var activity = Activity.getActivityInfo();

        if (activity.currentHeading != null) {
            heading = activity.currentHeading;
        }
    }

    // TODO
    var declination = 0;
    var radians = (heading == null ? 0 : heading) + declination.toFloat() * Math.PI/180;
    if (radians < 0) {
        radians = 2 * Math.PI + radians;
    }

    return [heading, Math.toDegrees(radians).toNumber(), radians];
}
