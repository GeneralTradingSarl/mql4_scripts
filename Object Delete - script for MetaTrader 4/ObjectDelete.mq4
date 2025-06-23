//+------------------------------------------------------------------+
//|script                                           Object Delete.mg4|
//|company                                                       VB. |
//|autor                                                  Vjacheslav |
//+------------------------------------------------------------------+
// taked from here
//+------------------------------------------------------------------+
//|                                                  CLEAR_CHART.mq4 |
//|                                            Aleksandr Pak, Almaty |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
 
#property copyright "VB."
#property link      "dovodilkin@yandex.ru"
#property  show_inputs
#include <WinUser32.mqh>
/*
 it deletes objects from the object list
*/
string s,_color; 
int k,cod_type,cod_col;
 
string type[23]={"OBJ_VLINE","OBJ_HLINE","OBJ_TREND","OBJ_TRENDBYANGLE",
"OBJ_REGRESSION","OBJ_CHANNEL","OBJ_STDDEVCHANNEL",
"OBJ_GANNLINE","OBJ_GANNFAN","OBJ_GANNGRID","OBJ_FIBO","OBJ_FIBOTIMES",
"OBJ_FIBOFAN","OBJ_FIBOARC",
"OBJ_EXPANSION","OBJ_FIBOCHANNEL","OBJ_RECTANGLE","OBJ_TRIANGLE",
"OBJ_ELLIPSE","OBJ_PITCHFORK","OBJ_CYCLES","OBJ_TEXT","OBJ_ARROW","OBJ_LABEL"};
 
int start()
  {
//----
 
   
   
   k=ObjectsTotal();
   
  
  for (int i=k-1;i>=0; i--)// total number of objects
      {
       s=ObjectName(i);// object name
      cod_type=ObjectType(s);// its type
      cod_col=ObjectGet(s,6);// its color
      
      int ret=MessageBox(s+Obj_Clr_ToStr(cod_col)+"?","Delete object ", MB_YESNOCANCEL|MB_ICONQUESTION );
      if(ret==IDCANCEL)return(0);
      if(ret==IDNO) 
        continue;else
       { 
                
        Alert("The object "+type[cod_type]+Obj_Clr_ToStr(cod_col)+" has been deleted. "+"\n","To exit press CANCEL");
        ObjectDelete(s);

       }
 
      }
   
//----   
   return(0);
  }
  
 
string Obj_Clr_ToStr(int code)
{
switch(code)
            {
             case 0:  _color=" (Black) ";break;
             case 25600: _color=" (DarkGreen) ";break;
             case 5197615: _color=" (DarkSlateGray) ";break;       
             case 32896: _color=" (Olive) ";break;             
             case 32768: _color=" (Green) ";break;
             case 8421376: _color=" (Teal) ";break;
             case 8388608: _color=" (Navy) ";break;
             case 8388736:  _color=" (Purple) ";break;
             case 128: _color=" (Maroon) ";break;             
             case 8519755: _color=" (Indigo) ";break;       
             case 7346457: _color=" (MidnightBlue) ";break;                          
             case 9109504: _color=" (DarkBlue) ";break;
             case 3107669: _color=" (DarkOliveGreen) ";break;
             case 1262987: _color=" (SaddleBrown) ";break;
             case 2263842:  _color=" (ForestGreen) ";break;             
             case 2330219: _color=" (OliveDrab) ";break;
             case 5737262: _color=" (SeaGreen) ";break;       
             case 755384: _color=" (DarkGoldenrod) ";break;             
             case 9125192: _color=" (DarkSlateBlue) ";break;
             case 2970272: _color=" (Sienna) ";break;
             case 13434880: _color=" (MediumBlue) ";break;             
             case 2763429: _color=" (Brown) ";break;
             case 13749760: _color=" ( DarkTurquoise) ";break;
             case 6908265: _color=" (DimGray) ";break;
             case 11186720: _color=" (LightSeaGreen) ";break;
             case 13828244: _color=" (DarkViolet) ";break;
             case 2237106: _color=" (FireBrick) ";break;
             case 8721863: _color=" (MediumVioletRed) ";break;
             case 7451452: _color=" (MediumSeaGreen) ";break;             
             case 1993170: _color=" (Chocolate) ";break;
             case 3937500: _color=" (Crimson) ";break;
             case 11829830: _color=" (SteelBlue) ";break;            
             case 2139610 : _color=" (Goldenrod) ";break;
             case 10156544 : _color=" (MediumSpringGreen) ";break;
             case 64636: _color=" (LawnGreen) ";break;
             case 10526303: _color=" (CadetBlue) ";break;             
             case 13382297: _color=" (DarkOrchid) ";break;
             case 3329434: _color=" (YellowGreen) ";break;
             case 3329330: _color=" (LimeGreen) ";break;
             case 17919: _color=" (OrangeRed) ";break;
             case 36095: _color=" (DarkOrange) ";break;
             case 42495: _color=" (Orange) ";break;
             case 55295: _color=" (Gold) ";break;
             case 65535: _color=" (Yellow) ";break;
             case 65407: _color=" (Chartreuse) ";break;
             case 65280: _color=" (Lime) ";break;
             case 8388352: _color=" (SpringGreen) ";break;
             case 16776960: _color=" (Aqua) ";break;
             case 16760576: _color=" (DeepSkyBlue) ";break;
             case 16711680: _color=" (Blue) ";break;
             case 16711935: _color=" (Magenta) ";break;
             case 255: _color=" (Red) ";break;//!            
             case 8421504: _color=" (Gray) ";break;
             case 9470064: _color=" (SlateGray) ";break;
             case 4163021: _color=" (Peru) ";break;
             case 14822282: _color=" (BlueViolet) ";break;
             case 10061943: _color=" (LightSlateGray) ";break;
             case 9639167: _color=" (DeepPink) ";break;
             case 13422920: _color=" (MediumTurquoise) ";break;
             case 16748574: _color=" (DodgerBlue) ";break;
             case 13688896: _color=" (Turquoise) ";break; 
             case 14772545: _color=" (RoyalBlue) ";break;             
             case 13458026: _color=" (SlateBlue) ";break;
             case 7059389: _color=" (DarkKhaki) ";break;
             case 6053069: _color=" (IndianRed) ";break;
             case 13850042: _color=" (MediumOrchid) ";break;
             case 3145645: _color=" (GreenYellow) ";break;
             case 11193702: _color=" (MediumAquamarine) ";break;
             case 9419919: _color=" (DarkSeaGreen) ";break;
             case 4678655: _color=" (Tomato) ";break;
             case 9408444: _color=" (RosyBrown) ";break;
             case 14053594: _color=" (Orchid) ";break;
             case 14381203: _color=" (MediumPurple) ";break;
             case 9662683: _color=" (PaleVioletRed) ";break;
             case 5275647: _color=" (Coral) ";break;
             case 15570276: _color=" (CornflowerBlue) ";break;
             case 11119017: _color=" (DarkGray) ";break;
             case 6333684: _color=" (SandyBrown) ";break;            
             case 15624315: _color=" (MediumSlateBlue) ";break;
             case 9221330: _color=" (Tan) ";break;
             case 8034025: _color=" (DarkSalmon) ";break;
             case 8894686: _color=" (BurlyWood) ";break;
             case 11823615: _color=" (HotPink) ";break;
             case 7504122: _color=" (Salmon) ";break;            
             case 15631086: _color=" (Violet) ";break;
             case 8421616: _color=" (LightCoral) ";break;
             case 15453831: _color=" (SkyBlue) ";break;
             case 8036607: _color=" (LightSalmon) ";break;
             case 14524637: _color=" (Plum) ";break;
             case 9234160: _color=" (Khaki) ";break;
             case 9498256: _color=" (LightGreen) ";break;
             case 13959039: _color=" (Aquamarine) ";break;
             case 12632256: _color=" (Silver) ";break;
             case 16436871: _color=" (LightSkyBlue) ";break;            
             case 14599344: _color=" (LightSteelBlue) ";break;
             case 15128749: _color=" (LightBlue) ";break;
             case 10025880: _color=" (PaleGreen) ";break;
             case 14204888: _color=" (Thistle) ";break;
             case 15130800: _color=" (PowderBlue) ";break;             
             case 11200750: _color=" (PaleGoldenrod) ";break;
             case 15658671: _color=" (PaleTurquoise) ";break;
             case 13882323: _color=" (LightGray) ";break;
             case 11788021: _color=" (Wheat) ";break;
             case 11394815: _color=" (NavajoWhite) ";break;
             case 11920639: _color=" (Moccasin) ";break;
             case 12695295: _color=" (LightPink) ";break;
             case 14474460: _color=" (Gainsboro) ";break;
             case 12180223: _color=" (PeachPuff) ";break;
             case 13353215: _color=" (Pink) ";break;
             case 12903679: _color=" (Bisque) ";break;
             case 13826810: _color=" (LightGoldenrod) ";break;
             case 13495295: _color=" (BlanchedAlmond) ";break;
             case 1349135: _color=" (LemonChiffon) ";break;
             case 14480885: _color=" (Beige) ";break;
             case 14150650: _color=" (AntiqueWhite) ";break;
             case 14020607: _color=" (PapayaWhip) ";break;            
             case 14481663: _color=" (Cornsilk) ";break;
             case 14745599: _color=" (LightYellow) ";break;
             case 16777184: _color=" (LightCyan) ";break;
             case 15134970: _color=" (Linen) ";break;
             case 16443110: _color=" (Lavender) ";break;
             case 14804223: _color=" (MistyRose) ";break;
             case 15136253: _color=" (OldLace) ";break;
             case 16119285: _color=" (WhiteSmoke) ";break;
             case 15660543: _color=" (Seashell) ";break;
             case 15794175: _color=" (Ivory) ";break; 
             case 15794160: _color=" (Honeydew) ";break;
             case 16775408: _color=" (AliceBlue) ";break;
             case 16118015: _color=" (LavenderBlush) ";break;
             case 16449525: _color=" (MintCream) ";break;
             case 16448255: _color=" (Snow) ";break;
             case 16777215: _color=" (White) ";break;
            
              
            }
            return(_color);
}