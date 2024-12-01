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

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.BluetoothLowEnergy;
import Toybox.Communications;

class MenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _results as Core.Results;

    function initialize(results as Core.Results) {
        Menu2InputDelegate.initialize();

        _results = results;
    }

    function onSelect(item as WatchUi.MenuItem) {
        var id = item.getId();
        if (id == null) {
            return;
        }
        var BLEDevice = _results.getItem(id.toString()) as Core.BLEDevice;
        if (BLEDevice == null) {
            return;
        }

        var customMenu = new WatchUi.Menu2({:title=>"Actions"});
        customMenu.addItem(new WatchUi.MenuItem("Locate Tracker", null, :locate, null));
        customMenu.addItem(new WatchUi.MenuItem("Dencode", null, :dencode, null));
        WatchUi.pushView(customMenu, new MenuActionsDelegate(BLEDevice), WatchUi.SLIDE_UP );

        WatchUi.requestUpdate();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

}

class MenuActionsDelegate extends WatchUi.Menu2InputDelegate {
    var _dev as Core.BLEDevice;
    function initialize(BLEDevice as Core.BLEDevice) {
        Menu2InputDelegate.initialize();
        _dev = BLEDevice;
    }

    function onSelect(item) {
        var id = item.getId();

        if(id == :locate) {
            var locatorView = new LocatorView(_dev);
            var locatorDelegate = new LocatorDelegate();
            WatchUi.pushView(locatorView, locatorDelegate, WatchUi.SLIDE_UP );
        } else if(id == :dencode) {
            Communications.openWebPage("https://dencode.com/en/string?v=" + _dev.getHex() + "&oe=UTF-8&nl=crlf", null, null);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
