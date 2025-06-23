//+------------------------------------------------------------------+
//|                                                   HtmlParser.mq4 |
//|                                 Copyright © 2011, XrustSolution. |
//|                                           mail: xrustx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, XrustSolution."
#property link      "mail: xrustx@gmail.com"
#property show_inputs
string accData[14];
string headers[14];
string data[5000][14];
string symbols[100];
string fn;
//+------------------------------------------------------------------+
//| extern variables					                                    |
//+------------------------------------------------------------------+
extern	string StatementFilename	  		  = "DetailedStatement.htm";
extern	bool	 DeleteThisGraphicsFromChart						= false	; 
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
	//----
	int i,x,y,z,w,s,e,hd,size; 
	string in,out,prom,res;
	double a,b,c;
	static int prex;
	#define stTr "tr"
	#define stTd "td"
	#define enTr "/tr>"
	#define enTd "/td>"
	#define left "<"
	#define right ">"
	#define empty "&nbsp;"
	#define end "Closed P/L:"	
	//----
	fn = StatementFilename;
	bool start =false;
	hd = FileOpen(fn,FILE_CSV|FILE_READ,"<");
	if(hd<1){Print("Statement File ",fn,"  Not found!!! Please check his!");return(1);} 
	while(!FileIsEnding(hd)){
		prom = FileReadString(hd);
		if(!start){if(StringFind(prom,"table",0)>=0){start=true;continue;}continue;}
		s = StringFind(prom,">",0);
		e = StringFind(prom,"</td>",0);
		if(StringFind(prom,enTr,0)>=0){
				x++;
				if(prex<x){prex=x;y=0;}
		}
		if(s >=0){
		prom = StringSubstr(prom,s+1,e-s+1);
			if(prom!="" && prom!=empty){
				if(x==0){accData[y]=prom;}
				if(x==2){headers[y]=prom;}
				if(x >2){data[x-3][y]=prom;}
				if(x >3){
					if(y==4){bool thisSy=false;
						for(w=0;w<z;w++){if(symbols[w]==prom){thisSy=true;break;}}
						if(!thisSy){symbols[z]=prom;z++;}
					}
				}
				y++;
				if(y>13){y=0;}
			}
		}
		if(StringFind(prom,end,0)>=0){break;}
	} 
	FileClose(hd); 
	ArrayResize(data,x-4);
	ArrayResize(symbols,z);
	for(i=0;i<z;i++){symbols[i]=StringUpper(symbols[i]);out = out + " "+symbols[i];}
	Print("This report contains trading in the :"+out);
	Print("Этот отчет содержит торговые операции по таким инструментам :"+out);
	//----
	size = ArraySize(data);
	for(i=0;i<size;i++){
		string sy = StringUpper(StringTrimLeft(StringTrimRight(data[i][4])));
		if(sy!=Symbol()){continue;}
		SetOrderVisual(txt2type(data[i][2]),
										 data[i][0],
						  StrToTime(data[i][1]),
			 nds(StrToDouble(data[i][5]),sy),
						  StrToTime(data[i][8]),
			 nds(StrToDouble(data[i][9]),sy),
			 nds(StrToDouble(data[i][6]),sy),
			 nds(StrToDouble(data[i][7]),sy),
										 data[i][3],
StringUpper(StringTrimLeft(StringTrimRight(data[i][4]))));
	}
	//----
return(0);}
//+------------------------------------------------------------------+
//|                                 Function  :  		SetOrderVisual |
//|                                 Copyright © 2011, XrustSolution. |
//|                                           mail: xrustx@gmail.com |
//+------------------------------------------------------------------+
void SetOrderVisual(bool typ,string tick,int ot,double op,int ct,
						double cp,double sl,double tp,string lot,string sy){
	string opNm,clNm,lnNm,slNm,tpNm,crNm="copyright";
	int dig = MarketInfo(sy,MODE_DIGITS);
	if(typ){
		color ocl = Red;
		opNm="#"+tick+" sell "+lot+" "+sy+" at "+op;
		clNm="#"+tick+" sell "+lot+" "+sy+" at "+DoubleToStr(op,dig)+" close at "+DoubleToStr(cp,dig);
		lnNm="#"+tick+"  "+DoubleToStr(op,dig)+" -> "+DoubleToStr(cp,dig);
		slNm="#"+tick+" sell "+lot+" "+sy+" at "+DoubleToStr(op,dig)+" stop loss at "+DoubleToStr(sl,dig);
		tpNm="#"+tick+" sell "+lot+" "+sy+" at "+DoubleToStr(op,dig)+" take profit at "+DoubleToStr(tp,dig);
	}else{
		ocl = Blue;
		opNm="#"+tick+" buy "+lot+" "+sy+" at "+op;
		clNm="#"+tick+" buy "+lot+" "+sy+" at "+DoubleToStr(op,dig)+" close at "+DoubleToStr(cp,dig);
		lnNm="#"+tick+"  "+DoubleToStr(op,dig)+" -> "+DoubleToStr(cp,dig);
		slNm="#"+tick+" buy "+lot+" "+sy+" at "+DoubleToStr(op,dig)+" stop loss at "+DoubleToStr(sl,dig);
		tpNm="#"+tick+" buy "+lot+" "+sy+" at "+DoubleToStr(op,dig)+" take profit at "+DoubleToStr(tp,dig);		
	}
	if(!DeleteThisGraphicsFromChart){
		if(ObjectFind(opNm)<0){ObjectCreate(opNm,OBJ_ARROW,0,0,0);}
		ObjectSet(opNm,OBJPROP_PRICE1,op);
		ObjectSet(opNm,OBJPROP_TIME1 ,ot);
		ObjectSet(opNm,OBJPROP_COLOR,ocl);
		ObjectSet(opNm,OBJPROP_ARROWCODE,1);
		ObjectSet(opNm,OBJPROP_BACK,false);
		ObjectSet(opNm,OBJPROP_STYLE,0);
		if(sl!=0){
			if(ObjectFind(slNm)<0){ObjectCreate(slNm,OBJ_ARROW,0,0,0);}
			ObjectSet(slNm,OBJPROP_PRICE1,sl);
			ObjectSet(slNm,OBJPROP_TIME1 ,ot);
			ObjectSet(slNm,OBJPROP_COLOR,Red);
			ObjectSet(slNm,OBJPROP_ARROWCODE,4);
			ObjectSet(slNm,OBJPROP_BACK,false);
			ObjectSet(slNm,OBJPROP_STYLE,0);
		}
		if(tp!=0){
			if(ObjectFind(tpNm)<0){ObjectCreate(tpNm,OBJ_ARROW,0,0,0);}
			ObjectSet(tpNm,OBJPROP_PRICE1,tp);
			ObjectSet(tpNm,OBJPROP_TIME1 ,ot);
			ObjectSet(tpNm,OBJPROP_COLOR,Blue);
			ObjectSet(tpNm,OBJPROP_ARROWCODE,4);
			ObjectSet(tpNm,OBJPROP_BACK,false);
			ObjectSet(tpNm,OBJPROP_STYLE,0);
		}	
		if(ObjectFind(clNm)<0){ObjectCreate(clNm,OBJ_ARROW,0,0,0);}
		ObjectSet(clNm,OBJPROP_PRICE1,cp);
		ObjectSet(clNm,OBJPROP_TIME1 ,ct);
		ObjectSet(clNm,OBJPROP_COLOR,Goldenrod);
		ObjectSet(clNm,OBJPROP_ARROWCODE,3);
		ObjectSet(clNm,OBJPROP_BACK,false);
		ObjectSet(clNm,OBJPROP_STYLE,0);	
		if(ObjectFind(lnNm)<0){ObjectCreate(lnNm,OBJ_TREND,0,0,0,0,0);}
		ObjectSet(lnNm,OBJPROP_PRICE1,op);
		ObjectSet(lnNm,OBJPROP_TIME1 ,ot);
		ObjectSet(lnNm,OBJPROP_PRICE2,cp);
		ObjectSet(lnNm,OBJPROP_TIME2 ,ct);	
		ObjectSet(lnNm,OBJPROP_COLOR,ocl);
		ObjectSet(lnNm,OBJPROP_BACK,false);
		ObjectSet(lnNm,OBJPROP_RAY ,false);
		ObjectSet(lnNm,OBJPROP_STYLE,2);
		if(ObjectFind(crNm)<0){ObjectCreate(crNm,OBJ_LABEL,0,0,0);}
		ObjectSet(crNm,OBJPROP_XDISTANCE,4);
		ObjectSet(crNm,OBJPROP_YDISTANCE,5);
		ObjectSet(crNm,OBJPROP_COLOR,SlateGray);
		ObjectSet(crNm,OBJPROP_CORNER,3);
		ObjectSet(crNm,OBJPROP_BACK,false);
		ObjectSet(crNm,OBJPROP_STYLE,0);
		ObjectSetText(crNm,"Copyright © 2011, XrustSolution.",8,"Tahoma");		
	}else{
		if(ObjectFind(opNm)==0){ObjectDelete(opNm);}
		if(ObjectFind(slNm)==0){ObjectDelete(slNm);}
		if(ObjectFind(tpNm)==0){ObjectDelete(tpNm);}
		if(ObjectFind(clNm)==0){ObjectDelete(clNm);}
		if(ObjectFind(lnNm)==0){ObjectDelete(lnNm);}
		if(ObjectFind(crNm)==0){ObjectDelete(crNm);}
	}	
	return;
}
//+------------------------------------------------------------------+
//|                                 Function  :         			  nds |
//|                                 Copyright © 2011, XrustSolution. |
//|                                           mail: xrustx@gmail.com |
//+------------------------------------------------------------------+
//|  Нормализует значение соответственно точности котировки          |
//|  Мультивалютный вариант                                          |
//|  Normalizes the values of the accuracy of quotes                 |
//|  Multi-currency variant                                          |
//+------------------------------------------------------------------+
double nds(double in, string sy=""){
   if(sy==""){sy=Symbol();}
   return(NormalizeDouble(in,MarketInfo(sy,MODE_DIGITS)));
}
//+------------------------------------------------------------------+
//|                                 Function  :         		txt2type |
//|                                 Copyright © 2011, XrustSolution. |
//|                                           mail: xrustx@gmail.com |
//+------------------------------------------------------------------+
bool txt2type(string in){
	if(StringFind(in,"buy")>=0||StringFind(in,"BUY")>=0){return(false);}else{return(true);}
}
//+------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru         |
//+------------------------------------------------------------------+
//|  Версия   : 01.09.2005                                           |
//|  Описание : Возвращает строку в ВЕРХНЕМ регистре                 |
//+------------------------------------------------------------------+
string StringUpper(string s) {
  int c, i, k=StringLen(s), n;
  for (i=0; i<k; i++) {
    n=0;
    c=StringGetChar(s, i);
    if (c>96 && c<123) n=c-32;    // a-z -> A-Z
    if (c>223 && c<256) n=c-32;   // а-я -> А-Я
    if (c==184) n=168;            //  ё  ->  Ё
    if (n>0) s=StringSetChar(s, i, n);
  }
  return(s);
}
//+------------------------------------------------------------------+