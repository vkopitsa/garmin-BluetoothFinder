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

using Toybox.System;
using Toybox.Lang;
using Toybox.StringUtil;

class Packet {
    var typeFlag;
    var raw;
    var type;
    var data;
    var hex;

    function initialize(dataType as Lang.Number, data as Lang.ByteArray or Null) {
        self.typeFlag = dataType;
        self.raw = data;
    }

    function parse() {
        return parseData(self, self.typeFlag, self.raw);
    }
}

function hex(arr as Lang.Array<Lang.String>) {
    return arrayToString(arr);
}

function getPacketsDataByType(dataType as Lang.Number, packets as Lang.Array<Packet>) as Lang.Array<Packet> {
    var tmp = [] as Lang.Array<Packet>;
    for (var i = 0; i < packets.size(); i++) {
        if (packets[i].typeFlag == dataType) {
            tmp.add(packets[i]);
        }
    }

    return tmp;
}

function parseData(packet as Packet, dataType as Lang.Number, data as Lang.ByteArray or Null) as Lang.Array or Lang.ByteArray or Lang.Object or Lang.String or Null {
    if (dataType == 0x01) {
        return [:Flags, toStringArray(0, data, dataType)];
    } else if (dataType == 0x02) {
        return [:IncompleteListof16bitServiceClassUUIDs, toOctetStringArray(2, data, dataType)];
    } else if (dataType == 0x03) {
        return [:CompleteListof16bitServiceClassUUIDs, toOctetStringArray(2, data, dataType)];
    } else if (dataType == 0x04) {
        return [:IncompleteListof32bitServiceClassUUIDs, toOctetStringArray(4, data, dataType)];
    } else if (dataType == 0x05) {
        return [:CompleteListof32bitServiceClassUUIDs, toOctetStringArray(4, data, dataType)];
    } else if (dataType == 0x06) {
        return [:IncompleteListof128bitServiceClassUUIDs, toOctetStringArray(16, data, dataType)];
    } else if (dataType == 0x07) {
        return [:CompleteListof128bitServiceClassUUIDs, toOctetStringArray(16, data, dataType)];
    } else if (dataType == 0x08) {
        return [:ShortenedLocalName, toString1(0, data, dataType)];
    } else if (dataType == 0x09) {
        return [:CompleteLocalName, toString1(0, data, dataType)];
    } else if (dataType == 0x0A) {
        return [:TxPowerLevel, toSignedInt(0, data, dataType)];
    } else if (dataType == 0x0D) {
        return [:ClassofDevice, toOctetString(3, data, dataType)];
    } else if (dataType == 0x0E) {
        return [:SimplePairingHashC, toOctetString(16, data, dataType)];
    } else if (dataType == 0x0F) {
        return [:SimplePairingRandomizerR, toOctetString(16, data, dataType)];
    } else if (dataType == 0x10) {
        return [:DeviceID, toOctetString(16, data, dataType)];
    } else if (dataType == 0x11) {
        return [:SecurityManagerOutofBandFlags, toOctetString(16, data, dataType)];
    } else if (dataType == 0x12) {
        return [:SlaveConnectionIntervalRange, toOctetStringArray(2, data, dataType)];
    } else if (dataType == 0x14) {
        return [:Listof16bitServiceSolicitationUUIDs, toOctetStringArray(2, data, dataType)];
    } else if (dataType == 0x1F) {
        return [:Listof32bitServiceSolicitationUUIDs, toOctetStringArray(4, data, dataType)];
    } else if (dataType == 0x15) {
        return [:Listof128bitServiceSolicitationUUIDs, toOctetStringArray(16, data, dataType)];
    } else if (dataType == 0x16) {
        return [:ServiceData, toOctetStringArray(1, data, dataType)];
    } else if (dataType == 0x17) {
        return [:PublicTargetAddress, toOctetStringArray(6, data, dataType)];
    } else if (dataType == 0x18) {
        return [:RandomTargetAddress, toOctetStringArray(6, data, dataType)];
    } else if (dataType == 0x19) {
        return [:Appearance, data];
    } else if (dataType == 0x1A) {
        return [:AdvertisingInterval, toOctetStringArray(2, data, dataType)];
    } else if (dataType == 0x1B) {
        return [:LEBluetoothDeviceAddress, toOctetStringArray(6, data, dataType)];
    } else if (dataType == 0x1C) {
         return [:LERole, data];
    } else if (dataType == 0x1D) {
        return [:SimplePairingHashC256, toOctetStringArray(16, data, dataType)];
    } else if (dataType == 0x1E) {
        return [:SimplePairingRandomizerR256, toOctetStringArray(16, data, dataType)];
    } else if (dataType == 0x20) {
        return [:ServiceData32bitUUID, toOctetStringArray(4, data, dataType)];
    } else if (dataType == 0x21) {
        return [:ServiceData128bitUUID, toOctetStringArray(16, data, dataType)];
    } else if (dataType == 0x3D) {
        return [:InformationData3D, data];
    }  else if (dataType == 0xFF) {
        return [:ManufacturerSpecificData, toOctetStringArray(2, data, dataType)];
    }

    return [:Unknown, null];
}

function toString1(bytesPerEntry as Lang.Number, data as Lang.ByteArray, dataType as Lang.Number) as Lang.String {
    return data != null ? data.toString() : "None";
}

function toSignedInt(bytesPerEntry as Lang.Number, data as Lang.ByteArray, dataType as Lang.Number) as Lang.Number {
    return data != null && data.size() > 0 ? data[0] : 0;
}

function toOctetString(bytes as Lang.Number, data as Lang.ByteArray, dataType as Lang.Number) as Lang.String {
    var s = "";
    for (var i = 0; i < bytes; i++) {
        s = s + data[i].format("%02x");
    }
    return s;
}

function toOctetStringArray(bytesPerEntry as Lang.Number, data as Lang.ByteArray, dataType as Lang.Number or Null) as Lang.Array<Lang.String> {
    if (data == null || data.size() % bytesPerEntry != 0) {
        return [];
    }

    var uuids = [];
    var index = 0;
    while (index < data.size()) {
        var slice = data.slice(index, index + bytesPerEntry);
        uuids.add(toOctetString(bytesPerEntry, slice, dataType));
        index += bytesPerEntry;
    }
    return uuids;
}

function toStringArray(bytesPerEntry as Lang.Number, data as Lang.ByteArray, dataType as Lang.Number) as Lang.Array<Lang.String> {
    var result = [];
    if (data == null) {
        result.add("None");
    } else {
        if (data[0] & (1 << 0)){
            result.add("LE Limited Discoverable Mode");
        }
        if (data[0] & (1 << 1)) {
            result.add("LE General Discoverable Mode");
        }
        if (data[0] & (1 << 2)) {
            result.add("BR/EDR Not Supported");
        }
        if (result.size() == 0) {
            result.add("None");
        }
    }
    return result;
}

function arrayToString(arr as Lang.Array<Lang.String>) as Lang.String {
    if (!(arr instanceof Lang.Array) && !(arr instanceof Lang.ByteArray)) {
        return arr.toString();
    }

    var s = "";
    for (var i = 0; i < arr.size(); i++) {
        s = s + arr[i];
    }

    return s;
}

class Parser {

    static function split(payload as Lang.ByteArray) as Lang.Array<Lang.Dictionary> {
        var splits = [] as Lang.Array<Lang.Dictionary>;
        var index = 0;

        if (payload.size() == 0) {
            return splits;
        }

        var length = payload.size();
        while (index < length) {
            var packetLength = payload[index];
            index++;

            var type = payload[index];
            index++;

            var dataLen = packetLength - 1;
            var data = payload.slice(index, index + dataLen);

            splits.add({ :type => type, :data => data });

            index += dataLen;
        }

        return splits;
    }

    static function parse(buffer as Lang.ByteArray) as Lang.Array<Packet> {
        if (buffer == null || buffer.size() == 0) {
            return [];
        }

        var packets = [];
        var splits = split(buffer);
        for (var i = 0; i < splits.size(); i++) {
            var split = splits[i];
            packets.add(new Packet(split[:type], split[:data]));
        }
        return packets;
    }
}
