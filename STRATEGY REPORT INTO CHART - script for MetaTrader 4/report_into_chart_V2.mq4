//use this script to draw trades from a file with results from metatrader's strategy tester to a chart
//how does it work ?
//1. load "StrategyTester.htm" to the experts/files directory
//2. run this script on a appropriate chart
//3. enjoy it

//tested on Metatrader version 4, build 216

#property copyright "Copyright © 2008, Globus 2008"
#property link      "globus@email.cz"

bool Erase_All_Object  =   true; //should be all object be erased before drawing of the report?
string reportname      =   "StrategyTester.htm"; //name of html file created from strategy tester
int Hour_shift=0; //amount of hours in case if arrows are displayed wrong

void start()
{
   bool FlagCont=true;
   string var,piece,value;
   string results[0][8];
   int row,begin,end,cnt,cntOrders,all;
   double orders[];
   double stoploss,takeprofit;
   string description,lots;
   
   string ticket; 
   string opentime; 
   string type; 
   double openprice;
   string closetime;
   double closeprice;
   int count=0;
   string name;
 
   
   int handle=FileOpen(reportname,FILE_READ,0x7F);
   if(handle<0)
     {
         Alert("File "+reportname+" does not exist !");
         return;
     }         
   FileSeek(handle,0,SEEK_SET);

   while(FlagCont)
      {
         var=FileReadString(handle);
         piece=StringSubstr(var,29,6);
         if(piece=="Symbol")
            {
               piece=StringSubstr(var,54,6);
               if(piece!=Symbol()) 
                  {
                     Alert("Strategy was testing on ",piece," chart. It is not possible to draw results to ",Symbol()," chart !");
                     return;
                  }
            }           
         piece=StringSubstr(var,0,11);
         if(piece=="<tr bgcolor") FlagCont=false;
      }
   
   while(FileIsEnding(handle)==false)
      {
         while (FileIsLineEnding(handle)) 
            {
               ArrayResize(results,row+1);
               
               var=FileReadString(handle);
               if(var=="") break;
               begin=StringFind(var, "<td>",0)+4;                             //Position of action
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][0]= value;                                        //number of action
               //-----------------
               begin=StringFind(var, "date>",end)+5;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][1]= value;                                        //time of action
               //-----------------
               begin=StringFind(var, "<td>",end)+4;                           //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][2]= value;                                        //type of action
               //-----------------
               begin=StringFind(var, "<td>",end)+4;                           //Find the beginning of the position 
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][3]= value;                                        //order's number 
               //-----------------
               begin=StringFind(var, "mspt>",end)+5;                          //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][4]= value;                                        //lot size
               //-----------------
               if(Digits==4) begin=StringFind(var, "0\.0000;",end)+10;         //Find the beginning of the position
               else begin=StringFind(var, "0\.00;",end)+8;
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][5]= value;                                        //open price
               //-----------------
               begin=StringFind(var, "right>",end)+6;                         //Find the beginning of the position 
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][6]= value;                                        //stoploss
               //-----------------
               begin=StringFind(var, "right>",end)+6;                         //Find the beginning of the position
               end=StringFind(var, "</td>",begin);                            //Find the end of position
               value = StringSubstr(var, begin, end-begin);                   //Read the value
               results[row][7]= value;                                        //take profit
               
               row++;
            }
         break;  
      }  
       
         
   if(Erase_All_Object) ObjectsDeleteAll(); 
   Comment("First trade opened - ",results[0][1], "  last trade closed - ",results[row-1][1]);
   for(cnt=1;cnt<=row;cnt++) 
      {
         ArrayResize(orders,cnt);         
         orders[cnt-1]=StrToInteger(results[cnt-1][3]);
      }   
   cntOrders=orders[ArrayMaximum(orders)];
   
   for(cnt=1;cnt<=cntOrders;cnt++) // check all trades
      {
         for(all=0;all<ArraySize(results);all++) //check all entry of one trade
            {
               if(cnt!=StrToInteger(results[all][3])) continue;
               if(results[all][2]=="buy" || results[all][2]=="sell") 
                  {
                     type=results[all][2];
                     opentime=results[all][1];
                     lots=results[all][4]; 
                     openprice=StrToDouble(results[all][5]);                                 
                     ticket=cnt;
                     stoploss=StrToDouble(results[all][6]); 
                     takeprofit=StrToDouble(results[all][7]);
                     description=StringConcatenate("#",ticket," lots:",lots," time:",opentime," SL:",results[all][6]," TP:",results[all][7]);
                     
                     name="Open trade - Object Nr. "+DoubleToStr(count,0);
                     count++;
       
                     ObjectCreate(name, OBJ_ARROW, 0, StrToTime(opentime)+Hour_shift*3600, openprice); 
                     ObjectSet(name, OBJPROP_ARROWCODE, 241);        
                     if(type=="buy")ObjectSet(name, OBJPROP_COLOR, Aqua);
                     else ObjectSet(name, OBJPROP_COLOR, Tomato);
                     ObjectSet(name, OBJPROP_BACK, true);       
                     ObjectSetText(name, description,10,"Arial", Blue);
                     
                     name="Set SL - Object Nr. "+DoubleToStr(count,0); //draw SL
                     count++;
       
                     ObjectCreate(name, OBJ_TREND, 0, StrToTime(opentime)+Hour_shift*3600, StrToDouble(results[all][6]),StrToTime(opentime)+Period()*60, StrToDouble(results[all][6]));  
                     ObjectSet(name, OBJPROP_RAY, false); 
                     ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID); 
                     if(type=="buy")ObjectSet(name, OBJPROP_COLOR, Magenta);
                     else ObjectSet(name, OBJPROP_COLOR, FireBrick);
                     ObjectSetText(name, StringConcatenate("#",ticket," set SL"),10,"Arial", Blue);          

                     name="Set TP- Object Nr. "+DoubleToStr(count,0); //draw TP
                     count++;
       
                     ObjectCreate(name, OBJ_TREND, 0, StrToTime(opentime)+Hour_shift*3600, StrToDouble(results[all][7]),StrToTime(opentime)+Period()*60, StrToDouble(results[all][7]));  
                     ObjectSet(name, OBJPROP_RAY, false); 
                     ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID); 
                     if(type=="buy")ObjectSet(name, OBJPROP_COLOR, SlateBlue);
                     else ObjectSet(name, OBJPROP_COLOR, DodgerBlue);
                     ObjectSetText(name, StringConcatenate("#",ticket," set TP"),10,"Arial", Blue);          
                  }

               if(results[all][2]=="s/l" || results[all][2]=="t/p" || results[all][2]=="close" || results[all][2]=="close at stop")
                  {
                     closetime=results[all][1];
                     closeprice=StrToDouble(results[all][5]);
                     
                     name="Close trade - Object Nr. "+DoubleToStr(count,0);
                     count++;
              
                     ObjectCreate(name, OBJ_ARROW, 0, StrToTime(closetime)+Hour_shift*3600, closeprice);  
                     ObjectSet(name, OBJPROP_ARROWCODE, 242);        
                     if(type=="buy")ObjectSet(name, OBJPROP_COLOR, Aqua);
                     else ObjectSet(name, OBJPROP_COLOR, Tomato);
                     ObjectSetText(name, description,10,"Arial", Blue);
       
                     name="Connection - Object Nr. "+DoubleToStr(count,0);
                     count++;
       
                     ObjectCreate(name, OBJ_TREND, 0, StrToTime(opentime)+Hour_shift*3600, openprice,StrToTime(closetime), closeprice);  
                     ObjectSet(name, OBJPROP_RAY, false); 
                     ObjectSet(name, OBJPROP_STYLE, STYLE_DOT); 
                     if(type=="buy")ObjectSet(name, OBJPROP_COLOR, Aqua);
                     else ObjectSet(name, OBJPROP_COLOR, Tomato);
                     ObjectSetText(name, StringConcatenate("#",ticket,"   ",openprice," --> ",closeprice),10,"Arial", Blue);          
                  } 
                  
                  
               if(results[all][2]=="modify")
                  {
                     name="Modify SL - Object Nr. "+DoubleToStr(count,0);
                     count++;
       
                     ObjectCreate(name, OBJ_TREND, 0, StrToTime(opentime)+Hour_shift*3600, StrToDouble(results[all][6]),StrToTime(opentime)+Period()*60, StrToDouble(results[all][6]));  
                     ObjectSet(name, OBJPROP_RAY, false); 
                     ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID); 
                     if(type=="buy")ObjectSet(name, OBJPROP_COLOR, Teal);
                     else ObjectSet(name, OBJPROP_COLOR, YellowGreen);
                     ObjectSetText(name, StringConcatenate("#",ticket," modify SL"),10,"Arial", Blue);          

                     name="Modify TP- Object Nr. "+DoubleToStr(count,0);
                     count++;
       
                     ObjectCreate(name, OBJ_TREND, 0, StrToTime(opentime)+Hour_shift*3600, StrToDouble(results[all][7]),StrToTime(opentime)+Period()*60, StrToDouble(results[all][7]));  
                     ObjectSet(name, OBJPROP_RAY, false); 
                     ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID); 
                     if(type=="buy")ObjectSet(name, OBJPROP_COLOR, OrangeRed);
                     else ObjectSet(name, OBJPROP_COLOR, Peru);
                     ObjectSetText(name, StringConcatenate("#",ticket," modify TP"),10,"Arial", Blue);          
                     
                  }
             } // end -check all entry of one trade

      }   //end -  check all trades            
FileClose(handle);
}






