//+------------------------------------------------------------------+
//|                                 ElliottWaveEasyCounterScript.mq4 |
//|                               Copyright 2011, 2014 TradertoolsFX |
//|                                    http://www.tradertools-fx.com |
//|                                                                  |
//| Copyright (c) 2011, 2014 TradertoolsFX                           |
//|                                                                  |
//| Permission is hereby granted, free of charge, to any person      |
//| obtaining a copy of this software and associated documentation   |
//| files (the "Software"), to deal in the Software without          |
//| restriction, including without limitation the rights             |
//| to use, copy, modify, merge, publish, distribute, sublicense,    |
//| and/or sell copies of the Software, and to permit persons        |
//| to whom the Software is furnished to do so,                      |
//| subject to the following conditions:                             |
//|                                                                  |
//| The above copyright notice and this permission notice shall be   |
//| included in all copies or substantial portions of the Software.  |
//|                                                                  |
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  |
//| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE             |
//| WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR          |
//| PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR    |
//| COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      |
//| LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,  |
//| ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR       |
//| THE USE OR OTHER DEALINGS IN THE SOFTWARE.                       |
//+------------------------------------------------------------------+

#property copyright "Copyright (c) 2011, 2014 TradertoolsFX"
#property link      "http://www.tradertools-fx.com"
#property description "This content is released under the terms of the MIT license (http://opensource.org/licenses/mit-license.html)."
#property version "3.1"
#property strict

#include <ElliottWaveLabel.mqh>

// Internal user parameters
/* NUM_WAVES: Number of waves per cycle.
 * Typically, this is 8 (5 for motive waves, 3 for corrective waves),
 * but it can be whatever you want. */
#define NUM_WAVES   8
#define MODE        LETTER // NUMERIC, LETTER, or ROMAN
#define TEXT_COLOR  Blue
#define FONT_SIZE   14
#define FONT        "Arial"
#define OBJ_PREFIX  "WaveCounter_"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
  {
/* Append file name to object prefix to prevent conflicts
     * if split into multiple scripts (e.g., motive and counter waves). */
   string obj_prefix=StringConcatenate(OBJ_PREFIX,__FILE__,"_");

   ElliottWaveLabel ew_label(MODE,
                             NUM_WAVES,
                             FONT_SIZE,
                             FONT,
                             TEXT_COLOR,
                             obj_prefix);
   ew_label.draw();

   return 0;
  }
//+------------------------------------------------------------------+
