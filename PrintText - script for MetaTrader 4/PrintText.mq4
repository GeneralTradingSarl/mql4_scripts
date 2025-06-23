//+X================================================================X+  
//|                                                    PrintText.mq4 | 
//|                           Copyright © 2007,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+  
#property copyright "Copyright © 2007, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
#property show_confirm
//+------------------------------------------------------------------+
//| Äåìîíñòðàöèîííûé ñêðèïò äëÿ âûâîäà òåêñòîâûõ ëåéá                |
//+------------------------------------------------------------------+

//+X================================================================X+ 
//| CreateTextLable() function                                       |
//+X================================================================X+ 
void CreateTextLable
 (string TextLableName, string Text, int TextSize, string FontName, color TextColor, int TextCorner, int X, int Y )
  { 
//---
   ObjectCreate(TextLableName, OBJ_LABEL, 0, 0, 0);
   ObjectSet(TextLableName, OBJPROP_CORNER, TextCorner);
   ObjectSet(TextLableName, OBJPROP_XDISTANCE, X);
   ObjectSet(TextLableName, OBJPROP_YDISTANCE, Y);
   ObjectSetText(TextLableName,Text,TextSize,FontName,TextColor);
//---- 
  }
//+X================================================================X+ 
//| SetTextLable() function                                          |
//+X================================================================X+ 
void SetTextLable
 (string TextLableName, string Text, int TextSize, string FontName, color TextColor, int TextCorner, int X, int Y )
  { 
//---
   ObjectSet(TextLableName, OBJPROP_CORNER, TextCorner);
   ObjectSet(TextLableName, OBJPROP_XDISTANCE, X);
   ObjectSet(TextLableName, OBJPROP_YDISTANCE, Y);
   ObjectSetText(TextLableName,Text,TextSize,FontName,TextColor);
//---- 
  }
//+X================================================================X+ 
//| TimeCount() function                                            |
//+X================================================================X+
void TimeCount
 (string TextLableName, int StartNumber, int StopNumber, int Inerval, int TextSize, string FontName, color TextColor, int TextCorner, int X, int Y )
  { 
//---
   CreateTextLable(TextLableName,"-"+StartNumber+"-",TextSize,FontName,TextColor,TextCorner,X,Y);
   WindowRedraw();
   PlaySound("WAIT");
   for(int Count=StartNumber+1;Count<=StopNumber;Count++)
    {
     Sleep(Inerval);
     PlaySound("WAIT");
     SetTextLable(TextLableName,"-"+ Count+"-",TextSize,FontName,TextColor,TextCorner,X,Y);
     WindowRedraw();
    }
   Sleep(Inerval);
   ObjectDelete(TextLableName);
//---- 
  }
//+X================================================================X+ 
//|PrintText start function                                          |
//+X================================================================X+
int start()
  {
   string STRING1="Demonstration of operation of the script ";
   string STRING2="PrintText.mq4";
   string STRING3="This text will disappear in five seconds";
   string STRING4="Script has ended";
   
   //----+ ÂÛÂÎÄ ÒÅÊÑÒÀ Â ËÅÂÎÌ ÂÅÐÕÍÅÌ ÓÃËÓ ÃÐÀÔÈÊÀ
   CreateTextLable("label_object1",STRING1,20,"Times New Roman",Yellow,0,30,10);
   CreateTextLable("label_object2",STRING2,20,"Times New Roman",Blue,0,380,10);
   CreateTextLable("label_object3",STRING3,25,"Times New Roman",Red,0,10,30);   
   WindowRedraw(); 
   TimeCount("label_objectX",0,5,1000,300,"Times New Roman",Red,1,600,320);
   ObjectDelete("label_object1");
   ObjectDelete("label_object2");
   ObjectDelete("label_object3");
   
   //----+ ÂÛÂÎÄ ÒÅÊÑÒÀ Â ÏÐÀÂÎÌ ÂÅÐÕÍÅÌ ÓÃËÓ ÃÐÀÔÈÊÀ
   CreateTextLable("label_object1",STRING1,20,"Times New Roman",Red,1,170,10);
   CreateTextLable("label_object2",STRING2,20,"Times New Roman",Lime,1,20,10);
   CreateTextLable("label_object3",STRING3,25,"Times New Roman",Magenta,1,10,30);
   WindowRedraw();
   TimeCount("label_objectX",0,5,1000,300,"Times New Roman",Lime,1,600,320); 
   ObjectDelete("label_object1");
   ObjectDelete("label_object2");
   ObjectDelete("label_object3");
   //----+ ÂÛÂÎÄ ÒÅÊÑÒÀ Â ÏÐÀÂÎÌ ÍÈÆÍÅÌ ÓÃËÓ ÃÐÀÔÈÊÀ
   CreateTextLable("label_object1",STRING1,20,"Times New Roman",Aqua,3,170,10);
   CreateTextLable("label_object2",STRING2,20,"Times New Roman",DeepPink,3,20,10);
   CreateTextLable("label_object3",STRING3,25,"Times New Roman",MediumSlateBlue,3,10,30);
   WindowRedraw();
   TimeCount("label_objectX",0,5,1000,300,"Times New Roman",Magenta,1,600,320);
   ObjectDelete("label_object1");
   ObjectDelete("label_object2");
   ObjectDelete("label_object3");
   
   //----+ ÂÛÂÎÄ ÒÅÊÑÒÀ Â ËÅÂÎÌ ÂÅÐÕÍÅÌ ÓÃËÓ ÃÐÀÔÈÊÀ
   CreateTextLable("label_object1",STRING1,20,"Times New Roman",Lime,2,30,10);
   CreateTextLable("label_object2",STRING2,20,"Times New Roman",BlueViolet,2,380,10);
   CreateTextLable("label_object3",STRING3,25,"Times New Roman",Orange,2,10,30);
   WindowRedraw();
   TimeCount("label_objectX",0,5,1000,300,"Times New Roman",Yellow,1,600,320);
   ObjectDelete("label_object1");
   ObjectDelete("label_object2");
   ObjectDelete("label_object3");
   //----+ ÂÛÂÎÄ ÒÅÊÑÒÀ ÏÎ ÖÅÍÒÐÓ ÃÐÀÔÈÊÀ
   CreateTextLable("label_object4",STRING4,50,"Times New Roman",Yellow,0,365,463);
   WindowRedraw();
   Sleep(500);
   SetTextLable("label_object4",STRING4,50,"Times New Roman",Red,0,365,463);
   WindowRedraw();
   Sleep(500);
   SetTextLable("label_object4",STRING4,50,"Times New Roman",Lime,0,365,463);
   WindowRedraw();
   Sleep(500);
   SetTextLable("label_object4",STRING4,50,"Times New Roman",Magenta,0,365,463);
   WindowRedraw();
   Sleep(500);
   SetTextLable("label_object4",STRING4,50,"Times New Roman",Blue,0,365,463);
   WindowRedraw();
   Sleep(500);
   SetTextLable("label_object4",STRING4,50,"Times New Roman",Aqua,0,365,463);
   PlaySound("ALERT");
   WindowRedraw();
   Sleep(500);
   ObjectDelete("label_object4");
//----
   return(0);
  }
//+------------------------------------------------------------------+