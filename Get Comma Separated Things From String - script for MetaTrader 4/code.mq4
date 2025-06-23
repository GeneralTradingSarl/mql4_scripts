//+------------------------------------------------------------------+
//|                       Get Last Round Time And Date Acc To TF.mq4 |
//|                                                         IronFist |
//|                         https://www.mql5.com/en/users/sahilbagdi |
//+------------------------------------------------------------------+
#property copyright "IronFist"
#property link      "https://www.mql5.com/en/users/sahilbagdi"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Alert(Get_Comma_Separated_Things_From_String(0));
  }
//+------------------------------------------------------------------+

input string String = "1Aa@!,2Bb@!,3Cc@!,4Dd@!,5Ee@!,6Ff@!,7Gg@!,8Hh@!,9Ii@!";

//+------------------------------------------------------------------+
//|Get Comma Separated Things From String                            |
//+------------------------------------------------------------------+
string Get_Comma_Separated_Things_From_String(int Position_Number_Or_Negative_1_For_Num_Of_Things)
{
 string _Distances_ = String,To_Be_Added_To_Array = "",distances[9999];_Distances_ += ",";;ArrayResize(distances,StringLen(_Distances_)+11);
 int Count = 0;for(int i=0; i<=StringLen(_Distances_); i++){if(StringGetChar(_Distances_,i)==44) Count++;} if(Position_Number_Or_Negative_1_For_Num_Of_Things==-1) return((string)Count);
 for(int i=0; i<StringLen(_Distances_); i++)
  {
   if(StringGetChar(_Distances_,i)==44)
    {
     for(int j=0; j<ArraySize(distances); j++){string no_need[1];if(distances[j]==no_need[0]) {distances[j]=To_Be_Added_To_Array;i++;break;}}
     To_Be_Added_To_Array="";
    }
   int To_Be_Added_To_To_Be_Added_To_Array = StringGetChar(_Distances_,i);
   To_Be_Added_To_Array += CharToString(To_Be_Added_To_To_Be_Added_To_Array);
  }
 return(distances[Position_Number_Or_Negative_1_For_Num_Of_Things]);
}