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
using Toybox.BluetoothLowEnergy;

(:test)
function PacketTest(logger as Logger) as Boolean {
    var types = [0x1, 0x5, 0xA, 0x1F, 0x21, 0x3D] as Lang.ByteArray;

    logger.debug("Running Packet type tests...");

    var packet1 = new Packet(types[0], null).parse();
    var packet2 = new Packet(types[1], null).parse();
    var packet3 = new Packet(types[2], null).parse();
    var packet4 = new Packet(types[3], null).parse();
    var packet5 = new Packet(types[4], null).parse();
    var packet6 = new Packet(types[5], null).parse();

    Test.assertMessage(packet1[0] == :Flags, "Packet 0x1 type should be 'Flags'");
    Test.assertMessage(packet2[0] == :CompleteListof32bitServiceClassUUIDs, "Packet 0x5 type should be 'Complete List of 32-bit Service Class UUIDs'");
    Test.assertMessage(packet3[0] == :TxPowerLevel, "Packet 0xA type should be 'Tx Power Level'");
    Test.assertMessage(packet4[0] == :Listof32bitServiceSolicitationUUIDs, "Packet 0x1F type should be 'List of 32-bit Service Solicitation UUIDs'");
    Test.assertMessage(packet5[0] == :ServiceData128bitUUID, "Packet 0x21 type should be 'Service Data - 128-bit UUID'");
    Test.assertMessage(packet6[0] == :InformationData3D, "Packet 0x3D type should be '3D Information Data'");

    // toOctetStringArray method
    logger.debug("Running toOctetStringArray tests...");
    var result1 = toOctetStringArray(2, [15, 89, 254, 14, 37, 89] as Lang.ByteArray, null);
    var result2 = toOctetStringArray(4, [15, 89, 254, 14] as Lang.ByteArray, null);
    var result3 = toOctetStringArray(8, [15, 89, 254, 14, 145, 65, 24, 98] as Lang.ByteArray, null);
    var result4 = toOctetStringArray(16, [
        15, 89, 254, 14, 145, 65, 24, 98,
        15, 89, 254, 14, 145, 65, 24, 98,
        15, 89, 254, 14, 145, 65, 24, 98,
        15, 89, 254, 14, 145, 65, 24, 98
    ] as Lang.ByteArray, null);

    Test.assertMessage(result1.size() == 3, "Result 1 should have length 3");
    Test.assertMessage(result2.size() == 1, "Result 2 should have length 1");
    Test.assertMessage(result3.size() == 1, "Result 3 should have length 1");
    Test.assertMessage(result4.size() == 2, "Result 4 should have length 2");

    // packet data resolution
    logger.debug("Running packet data resolution tests...");
    var packetData1 = new Packet(types[0], null).parse();
    var packetData2 = new Packet(types[1], null).parse();
    var packetData3 = new Packet(types[2], null).parse();

    Test.assertMessage(packetData1[1] instanceof Lang.Array, "Packet 0x1 data should be an array");
    Test.assertMessage(packetData2[1] instanceof Lang.Array, "Packet 0x5 data should be an array");
    Test.assertMessage(packetData3[1] instanceof Lang.Number, "Packet 0xA data should be a number");

    logger.debug("All Packet tests passed successfully!");
    return true;
}

(:test)
function ParserTest(logger as Logger) as Boolean {
    var testPayload = [
        2, 1, 6, 17, 6, 186, 86, 137, 166, 250, 191, 162, 189,
        1, 70, 125, 110, 56, 88, 171, 173, 5, 22, 10, 24, 7, 4
    ] as Lang.ByteArray;

    // split function
    logger.debug("Running split function test...");
    var splitResult = Parser.split(testPayload);
    Test.assertMessage(splitResult.size() == 3, "Split should return 3 distinct packets");

    // parse function
    logger.debug("Running parse function test...");
    var parsedPackets = Parser.parse(testPayload);
    Test.assertMessage(parsedPackets.size() == 3, "Parse should return 3 packets");

    for (var i = 0; i < parsedPackets.size(); i++) {
        Test.assertMessage(parsedPackets[i].parse()[0] != :Unknown, "Parsed packet type should not be 'Unknown'");
    }

    // packet details
    Test.assertMessage(parsedPackets[0].parse()[0] == :Flags, "First packet type should be 'Flags'");
    Test.assertMessage(parsedPackets[0].parse()[1].size() == 2, "First packet data size should be 2");

    Test.assertMessage(parsedPackets[1].parse()[0] == :IncompleteListof128bitServiceClassUUIDs,
        "Second packet type should be 'Incomplete List of 128-bit Service Class UUIDs'");
    Test.assertMessage(parsedPackets[1].parse()[1].size() == 1, "Second packet data size should be 1");
    Test.assertMessage(hex(parsedPackets[1].parse()[1]).equals("ba5689a6fabfa2bd01467d6e3858abad"),
        "Second packet data should match expected UUID");

    Test.assertMessage(parsedPackets[2].parse()[0] == :ServiceData, "Third packet type should be 'Service Data'");
    Test.assertMessage(parsedPackets[2].parse()[1].size() == 4, "Third packet data size should be 4");

    logger.debug("All Parser tests passed successfully!");
    return true;
}

(:test)
function ParserTestReal(logger as Logger) as Boolean {
    var testPayload = [
        2, 1, 6, 7, 3, 24, 24, 20, 24, 10, 24, 9, 255, 170, 170, 210,
        91, 0,81, 82, 41, 9, 8, 83, 116, 114, 121, 100, 32, 107, 108
    ] as Lang.ByteArray;
    var parsedPackets = Parser.parse(testPayload);
    Test.assertMessage(parsedPackets[0].type.equals("Flags"), "First packet type should be 'Flags'");

    Test.assertMessage(parsedPackets[1].type.equals("Complete List of 16-bit Service Class UUIDs"),
        "Second packet type should be 'Complete List of 16-bit Service Class UUIDs'");
    Test.assertMessage(parsedPackets[1].hex.equals("181814180a18"), "Data should match expected UUID");
    
    Test.assertMessage(parsedPackets[2].type.equals("Manufacturer Specific Data"), "Third packet type should be 'Manufacturer Specific Data'");
    Test.assertMessage(parsedPackets[2].hex.equals("aaaad25b00515229"), "Data should match expected UUID");


    return true;
}