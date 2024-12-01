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
using Toybox.Graphics as Gfx;

class AppView extends WatchUi.View {
    private var _results as Core.Results;
    private var _menu as WatchUi.Menu2 or Null;
    private var timer;
    private var menuItemKeys as Lang.Array<Lang.String> = [];

    function initialize(results as Core.Results) {
        View.initialize();

        _results = results;
        timer = new Timer.Timer();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.ScanningLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        start();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function start() as Void {
        timer.start(method(:update), 1000, true);

        startScaning();
    }

    function exit() as Void {
        timer.stop();

        WatchUi.popView(WatchUi.SLIDE_DOWN);

        stopScaning();
    }

    function update() as Void {
        var isNewItem = false;
        var items = _results.getItems() as Lang.Array<Core.BLEDevice>;
        var isMenuInit = items.size() > 0 && _menu == null;
        if (isMenuInit) {
            _menu = new WatchUi.Menu2({:title=>"Devices"});
            WatchUi.switchToView(_menu, new MenuDelegate(_results), WatchUi.SLIDE_UP );
        }

        // clear all value
        for (var ii = 0; ii < menuItemKeys.size(); ii++) {
            clearMenuItem(menuItemKeys[ii]);
        }

        for (var i = 0; i < items.size(); i++) {
            isNewItem = addItemToMenu(items[i]);
        }

        if (isNewItem and !isMenuInit) {
            var alert = new Alert({
                :timeout => 100,
                :font => Gfx.FONT_MEDIUM,
                :text => "New found",
                :fgcolor => Gfx.COLOR_RED,
                :bgcolor => Gfx.COLOR_WHITE
            });

            alert.pushView(WatchUi.SLIDE_IMMEDIATE);
        }

        WatchUi.requestUpdate();
    }

    function addItemToMenu(device as Core.BLEDevice) as Lang.Boolean {
        var rssi = "rssi: " + device.getRssi() + ", " + device.getQuality() + "%";
        var name = device.getName();

        var idx = _menu.findItemById(device.getUuid());
        if (idx == -1) {
            _menu.addItem(new WatchUi.MenuItem(name, rssi, device.getUuid(), null));

            menuItemKeys.add(device.getUuid());
        } else {
            var item = _menu.getItem(idx) as WatchUi.MenuItem;
            item.setSubLabel(rssi);
            _menu.updateItem(item, idx);
        }

        // is new item
        return idx == -1;
    }

    function clearMenuItem(uuid as Lang.String) {
        var rssi = "rssi: -, -%, ";

        var idx = _menu.findItemById(uuid);
        if (idx != -1) {
            var item = _menu.getItem(idx) as WatchUi.MenuItem;
            item.setSubLabel(rssi);
            _menu.updateItem(item, idx);
        }

        // is new item
        return idx == -1;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        Log.debug("View.onHide");
    }

    (:debug)
    function startScaning() as Void {}

    (:release)
    function startScaning() as Void {
        // there is an issue with the CIQ Simulator that causes it to crash when starting a scan
        BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);    
    }

    (:debug)
    function stopScaning() as Void {}

    (:release)
    function stopScaning() as Void {
        // there is an issue with the CIQ Simulator that causes it to crash when starting a scan
        BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);    
    }

}
