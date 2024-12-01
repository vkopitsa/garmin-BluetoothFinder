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

import Toybox.Test;
import Toybox.Lang;
import Tools;
import Hex;
using Toybox.BluetoothLowEnergy;
using Toybox.Sensor;

(:debug)
class IteratorMock {
    var _objects = [] as Lang.Array<Lang.Object>;
    function initialize(objects as Lang.Array<Lang.Object> or Null) {
        if (objects != null) {
            _objects = objects;
        }
    }

    function add(next as Lang.Objec) as IteratorMock {
        _objects.add(next);
        return self;
    }

    function next() as Lang.Object or Null {
        if (_objects.size() <= 0) {
            return null;
        }
        var _next = _objects[0];
        _objects.remove(_next);
        
        return _next;
    }
}

(:debug)
class ScanResultMock extends BluetoothLowEnergy.ScanResult
{
    var uuid = "";
    function initialize(_uuid as Lang.String) {
        ScanResult.initialize();

        uuid = _uuid;
    }

    function isSameDevice(other as BluetoothLowEnergy.ScanResult) as Lang.Boolean {
        var _other = other  as ScanResultMock;
        return uuid.equals(_other.uuid);
    }

    function getDeviceName() as Lang.String or Null {
        return null;
    }

    function getManufacturerSpecificData(manufacturerId as Lang.Number) as Lang.ByteArray {
        var arr = new[0]b;
        return arr;
    }
    
    function getServiceUuids() as BluetoothLowEnergy.Iterator {
        var samsungService =  BluetoothLowEnergy.stringToUuid("0000FD5A-0000-1000-8000-00805F9B34FB");
        return new IteratorMock([samsungService]) as BluetoothLowEnergy.Iterator;
    }

    function getServiceData(uuid as BluetoothLowEnergy.Uuid) as Lang.ByteArray {
        var arr = new[0]b;
        return arr;
    }

    function getRawData() as Lang.ByteArray {
        var arr = [
            [0x06, 0xFF, 0x00, 0x4C, 0x12, 0x19, 0x10],
            [0x07, 0xFF, 0x4C, 0x00, 0x12, 0x02, 0x00, 0x01],
            [2, 1, 6, 17, 6, 186, 86, 137, 166, 250, 191, 162, 189],
            [1, 70, 125, 110, 56, 88, 171, 173, 5, 22, 10, 24, 7, 4],
            Hex.hexToBytes("172b0100ca732e90ede29f00000000007b2d570a2e3d426b"),
            Hex.hexToBytes("0201021bff7500021861b1573461b09e3b4a0e5fd52af05aa411881663f8ff"),
        ] as Lang.Array<Lang.ByteArray>;

        var rawData = Tools.randomItem(arr);
        return rawData;
    }

    function getRssi() as Lang.Number {
        var r = Tools.random(1, 90) as Lang.Number;
        return -1 * r;
    }

    function getQuality() as Lang.Number {
        var quality = 0;
        var dBm = getRssi() as Lang.Number;
        if (dBm <= -100) {
            quality = 0;
        } else if (dBm >= -50) {
            quality = 100;
        } else {
            quality = 2 * (dBm + 100);
        }

        return quality;
    }
}

(:test)
function coreResultsTest(logger as Logger) as Boolean {
    var results = new Core.Results() as Core.Results;

    Test.assert(results.getItems().size() == 0);

    var item1 = new ScanResultMock("1");
    results.addItem(item1);
    results.addItem(item1);
    Test.assert(results.getItems().size() == 1);

    return true;
}

(:test)
function matchManufacturerDataTest(logger as Logger) as Boolean {
    Test.assert(matchManufacturerData(
        [0x00, 0x4C, 0x12, 0x19, 0x10] as Lang.ByteArray,
        [0x00, 0x4C] as Lang.ByteArray,
        [0x12, 0x19, 0x10] as Lang.ByteArray,
        [0xFF, 0x00, 0x18] as Lang.ByteArray
    ));

    Test.assert(!matchManufacturerData(
        [0x00, 0x4C, 0x12, 0x00, 0x18] as Lang.ByteArray,
        [0x00, 0x4C] as Lang.ByteArray,
        [0x12, 0x19, 0x10] as Lang.ByteArray,
        [0xFF, 0x00, 0x18] as Lang.ByteArray
    ));
    return true;
}