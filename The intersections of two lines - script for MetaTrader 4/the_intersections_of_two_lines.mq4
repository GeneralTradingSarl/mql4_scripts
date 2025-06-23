//+------------------------------------------------------------------+
//|                               the_intersections_of_two_lines.mq4 |
//|                           2021, Nabi Karamalizadeh, JahanWeb co. |
//|                                          http://www.jahanweb.com |
//+------------------------------------------------------------------+
#property copyright "2021, Nabi Karamalizadeh, JahanWeb co."
#property link      "@JahanChart http://www.jahanweb.com"
#property description "The intersections of two lines"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   // Linear Equation:
   //
   // y = m x + b
   //
   //             y1 - y2
   // y - y1 = ( --------- ) ( x - x1 )
   //             x1 - x2
   //
   // y = mA (x - xA1) + yA1
   // y = mB (x - xB1) + yB1
   //
   
   // Lines object name
   string lineNameA = "LineA";
   string lineNameB = "LineB";
   
   // Line 1, Point 1
   double xA1 = ObjectGet(lineNameA, OBJPROP_TIME1);
   double yA1 = ObjectGet(lineNameA, OBJPROP_PRICE1);

   // Line 1, Point 2
   double xA2 = ObjectGet(lineNameA, OBJPROP_TIME2);
   double yA2 = ObjectGet(lineNameA, OBJPROP_PRICE2);

   // Line 2, Point 1
   double xB1 = ObjectGet(lineNameB, OBJPROP_TIME1);
   double yB1 = ObjectGet(lineNameB, OBJPROP_PRICE1);

   // Line 2, Point 2
   double xB2 = ObjectGet(lineNameB, OBJPROP_TIME2);
   double yB2 = ObjectGet(lineNameB, OBJPROP_PRICE2);

   // Line slope
   double mA = (yA1 - yA2) / (xA1 - xA2);
   double mB = (yB1 - yB2) / (xB1 - xB2);

   // Calculate intersection points
   double x = (-mB*xB1 + yB1 + mA*xA1 - yA1) / (mA - mB);
   double y = mA * (x - xA1) + yA1;

   // Show results
   Print("Intersections Points: X=", (datetime)x, " , Y=", (double)y);

  }
//+------------------------------------------------------------------+
