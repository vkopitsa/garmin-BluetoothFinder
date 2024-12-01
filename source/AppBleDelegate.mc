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

using Toybox.BluetoothLowEnergy;
using Toybox.System;
using Toybox.WatchUi;
import Toybox.Lang;

class AppBleDelegate extends BluetoothLowEnergy.BleDelegate {
    private var _results as Core.Results;

    function initialize(results as Core.Results) {
        BleDelegate.initialize();

        _results = results;
    }

    function onScanResults(scanResults) {
		for (var result = scanResults.next(); result != null; result = scanResults.next()) {
			if (result instanceof BluetoothLowEnergy.ScanResult) {
				Log.debug("[ble]: device, appearance: name: " + result.getDeviceName() + " rssi: " + result.getRssi());

				_results.addItem(result);
			}
		}

		Log.debug("[ble]: onScanResults");
	}
}