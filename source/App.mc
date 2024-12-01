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

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.BluetoothLowEnergy;
import Core;

using Toybox.Timer;

class App extends Application.AppBase {
    private var results as Core.Results or Null;
    private var bleDevice;
    private var finderView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        results = new Core.Results() as Core.Results;
        finderView = new AppView(results);
        bleDevice = new AppBleDelegate(results);
        BluetoothLowEnergy.setDelegate(bleDevice);

        fakeDevice();

        Log.debug("Add running...");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var finderDelegate = new AppDelegate(finderView);
        return [ finderView, finderDelegate ];
    }

    (:release)
    function fakeDevice() as Void {}

    (:debug)
    function fakeDevice() as Void {
        var myTimer = new Timer.Timer();
        myTimer.start(method(:timerCallback), 5000, true);
    }

    (:debug)
    function timerCallback() as Void {
        Log.debug("App.timerCallback");
        bleDevice.onScanResults(new IteratorMock([
            new ScanResultMock("1"),
            new ScanResultMock("2"),
            new ScanResultMock("3"),
            new ScanResultMock("4"),
            new ScanResultMock("5"),
            new ScanResultMock("6"),
            new ScanResultMock("7")
        ]) as BluetoothLowEnergy.Iterator as BluetoothLowEnergy.Iterator);
    }
}

function getApp() as App {
    return Application.getApp() as App;
}