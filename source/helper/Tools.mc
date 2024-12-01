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
import Toybox.Math;

module Tools {
  const RAND_MAX = 0x7FFFFFF;

  // return a random value on the range [min, max]
  function random(min, max) {
      if (max > RAND_MAX) {
          max = RAND_MAX;
      }
      return min + (Math.rand() % (max - min + 1));
  }

  typedef AnyType as Number or Float or Long or Double or Array or ByteArray;

  // return a random item from array
  function randomItem(array as Lang.Array<AnyType> or Lang.ByteArray) as AnyType {
      var key = random(0, array.size()-1);
      return array[key];
  }

  function arraysEqual(array1 as Lang.Array<AnyType> or Lang.ByteArray, array2 as Lang.Array<AnyType> or Lang.ByteArray) as Lang.Boolean {
    if (array1.size() != array2.size()) {
        return false;
    }

    for (var i = 0; i < array1.size(); i++) {
        if (array1[i] != array2[i]) {
            return false;
        }
    }

    return true;
  }

  (:test)
  function testArraysEqual(logger as Logger) as Boolean {
      Test.assert(arraysEqual(
          [0x4C, 0x00, 0x12, 0x19, 0x10] as Lang.ByteArray,
          [0x4C, 0x00, 0x12, 0x19, 0x10] as Lang.ByteArray
      ));

      Test.assert(!arraysEqual(
          [0x4C, 0x00, 0x10, 0x19, 0x10] as Lang.ByteArray,
          [0x4C, 0x00, 0x12, 0x19, 0x10] as Lang.ByteArray
      ));

      return true;
  }
}