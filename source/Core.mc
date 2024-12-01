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
using Toybox.Sensor;
using Toybox.BluetoothLowEnergy;
using Toybox.Math;
import Toybox.System;
import Hex;
import Tools;
import Toybox.Application;

module Core
{
    class BLEDevice {
        private var _data as BluetoothLowEnergy.ScanResult;
        private var _uuid as Lang.String;
        private var _name as Lang.String or Null;

        function initialize(data as BluetoothLowEnergy.ScanResult) {
            _data = data;
            _uuid = "ID" + Tools.random(0, 100);
        }

        function getHex() as Lang.String {
            return Hex.bytesToHex(_data.getRawData());
        }

        function setData(data as BluetoothLowEnergy.ScanResult) {
            _data = data;

            Log.debug("BLEDevice.setData");
        }

        function getPackets() {
            Log.debug("BLEDevice.getPackets");
            return Parser.parse(_data.getRawData());
        }

        function setUuid(uuid as Lang.String) {
            _uuid = uuid;
        }

        function getUuid() as Lang.String {
            return _uuid;
        }

        function isSameDevice(other as BluetoothLowEnergy.ScanResult) as Lang.Boolean {
            return _data.isSameDevice(other);
        }

        function getName() as Lang.String {
            if (_data.getDeviceName() != null) {
                return _data.getDeviceName();
            }

            if (_name != null) {
                return _name;
            }

            _name = "Unknown Device";

            var manufacturerSpecificData = getPacketsDataByType(0xFF, getPackets());
            if (manufacturerSpecificData.size() != 0) {
                manufacturerSpecificData =  manufacturerSpecificData[0] as Packet;
                var name = getNameFromManufacturerData(manufacturerSpecificData.raw);
                if (!name.equals("")) {
                    _name = name;
                    return _name;
                }

            }

            return _name;
        }

        function getRssi() as Lang.Number {
            return _data.getRssi();
        }

        function getQuality() as Lang.Number {
            var quality = 0;
            var dBm = _data.getRssi() as Lang.Number;
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

    class Results {
        private var items as Lang.Array<BLEDevice> = [];

        public function addItem(item as BluetoothLowEnergy.ScanResult) as Void {
            var isSameDevice  = false;
            for (var i = 0; i < items.size(); i++) {
                if (items[i] has :isSameDevice and items[i].isSameDevice(item)) {
                    items[i].setData(item);

                    isSameDevice = true;
                    break;
                }
            }

            if (!isSameDevice) {
                items.add(new BLEDevice(item));
            }

            Log.debug("addItem: " + items.size());
        }

        public function getItems() as Lang.Array<BLEDevice> {
            Log.debug("getItems: " + items.size());

            return items;
        }

        public function getItem(uuid as Lang.String) as BLEDevice or Null {
            Log.debug("getItem: " + uuid);

            for (var i = 0; i < items.size(); i++) {
                if (items[i].getUuid().equals(uuid)) {
                    return items[i];
                }
            }

            return null;
        }
    }
}

function matchManufacturerData(data as Lang.ByteArray, manufacturerID as Lang.ByteArray, filterData as Lang.ByteArray, filterMask as Lang.ByteArray) as Lang.Boolean {
    var manufacturerSize = manufacturerID.size();
    var filterSize = filterData.size();

    if (data.size() < manufacturerSize + filterSize) {
        return false;
    }

    var idSection = data.slice(0, manufacturerSize);
    if (!Tools.arraysEqual(manufacturerID, idSection)) {
        return false;
    }

    var filterSection = data.slice(manufacturerSize, manufacturerSize + filterSize);
    for (var i = 0; i < filterSize; i++) {
        if ((filterSection[i] & filterMask[i]) != (filterData[i] & filterMask[i])) {
            return false;
        }
    }

    return true;
}

function getNameFromManufacturerData(raw as ByteArray) as String {
    var array = Application.loadResource(Rez.JsonData.companyIdentifiers) as Array<Array>;
    for (var i = 0; i < array.size(); i++) {
        var conf = array[i] as Array;
        if (conf.size() < 4 ) {
            continue;
        }
        var isMatch = matchManufacturerData(raw, conf[0], conf[1], conf[2]);
        if (isMatch) {
            return conf[3];
        }
    }

    return "";
}