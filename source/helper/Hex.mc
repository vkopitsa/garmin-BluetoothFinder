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
import Toybox.Test;
import Toybox.System;
using Toybox.StringUtil;
import Tools;

module Hex {

    typedef ArrayType as Array<Number> or ByteArray;
    const hexChars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];

    function bytesToHex(bytes as ArrayType) as String {
        if (StringUtil has :convertEncodedString and bytes instanceof ByteArray) { 
            var options = {
                :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
                :toRepresentation => StringUtil.REPRESENTATION_STRING_HEX,
            };
            return StringUtil.convertEncodedString(bytes as ByteArray, options);
        }

        var s = "";
        for (var i = 0; i < bytes.size(); i++) {
            var l = bytes[i] & 0x0F;
            var h = (bytes[i] >> 4) & 0x0F;
            s = s + hexChars[h] + hexChars[l];
         }
         return s;
    }

    function hexToBytes(hex as String) as ArrayType or Null {
        if (StringUtil has :convertEncodedString) {
            var options = {
                :fromRepresentation => StringUtil.REPRESENTATION_STRING_HEX,
                :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            };
            return StringUtil.convertEncodedString(hex, options);
        }

        var bytes = [];
        if (hex.length() % 2 != 0) {
            return null;
        }
        var hexArr = hex.toCharArray();
        for (var i = 0; i < hexArr.size(); i += 2) {
            var high = hexChars.indexOf(hexArr[i]);
            var low = hexChars.indexOf(hexArr[i+1]);
            if (high == -1 || low == -1) {
                return null;
            }
            bytes.add((high << 4) | low);
        }
        return bytes;
    }

    (:test)
    function testBytesToHex(logger as Test.Logger) {
        var a1 = [169, 74, 143, 229]b;
        var actual = bytesToHex(a1);

        Test.assertMessage(
            "a94a8fe5".equals(actual),
            Lang.format("bytesToHex() Expected: '$1$', actual: '$2$'", ["a94a8fe5", actual])
        );

        return true;
    }

    (:test)
    function testHexToBytes(logger as Test.Logger) {
        var hex = "a94a8fe5";
        var expected = [169, 74, 143, 229]b;
        var actual = hexToBytes(hex);

        Test.assertMessage(
            Tools.arraysEqual(expected, actual),
            Lang.format("hexToBytes() Expected: '$1$', actual: '$2$'", [expected.toString(), actual.toString()])
        );

        return true;
    }
}