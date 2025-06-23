//+------------------------------------------------------------------+
//|																geLR_MA.mq4		|
//|                      Copyright © 2007, ver 1.0							|
//|                      Forte928           									|
//+------------------------------------------------------------------+
#property copyright "Forte928"
#property link      ""
#define		IndicatorName "geLR_MA"

#property indicator_chart_window


#property indicator_buffers 1
#property indicator_color1 OrangeRed//Goldenrod//LightSkyBlue

extern int		DeGree	=6;			// степень полинома
extern int	 	LRCalc	=100;			// кол-во расчетных данных
extern int		Shift		=0;			// смещение данных
extern int	 	Counter	=3000;

double	FxView1[];
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~V~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Work Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int Ix;

double	Rates[];

double	TimeBuf1[0];
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~V~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization program Buffers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void	InitBufferam(int iBufferSize)
{
	ArrayResize(Rates,iBufferSize);
	ArrayResize(TimeBuf1,iBufferSize);
	return;
}
void	EmptyBufferam()
{
	ArrayInitialize(Rates,EMPTY_VALUE);
	ArrayInitialize(TimeBuf1,EMPTY_VALUE);
	return;
}
void	DoneBufferam()
{
	ArrayResize(Rates,0);
	ArrayResize(TimeBuf1,0);
	return;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~V~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Program Constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int		MaxPeriod=0;
int		CalcCount=0;
//--------------------------- промежуточные буфера ------------------
#define	DGMaximum 20							// степень полинома
double	ayLRMatrix[21,21],ayLRValue[21],ayLRWeight[21];

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Custom indicator initialization function ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int init()
  {
//---- initialization program values  --------------------------------
	MaxPeriod=Shift;
	CalcCount=Counter;
	if (CalcCount==0) CalcCount=Bars-1;
	if (CalcCount<MaxPeriod) CalcCount=MaxPeriod;
	CalcCount=CalcCount+MaxPeriod;
	
	InitBufferam(CalcCount);
	
   if (DeGree>DGMaximum) DeGree=DGMaximum;
   if (DeGree<1) DeGree=1;
//---- initialization indicators -------------------------------------
	SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
	SetIndexLabel(0,"LineReg");
	SetIndexBuffer(0,FxView1);
   IndicatorShortName(IndicatorName+"("+LRCalc+"("+DeGree+"))");
  	IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
	
//----
   return(0);
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~V~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Custom indicator deinitialization function ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define		IndicatorPrefix "LR_MA"

#define gnShift		"CE_Shift"
#define gnCount		"CE_Count"
#define gnEmulate		"_Emulated"
#define gnCalculate	"_CW_"
#define gnPauseCount	"_PauseCount"
string  CWName			="";			// уникальное имя индикатора
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~V~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Start defination ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int start()
{
bool		Emulated		=false;
bool		Calculated	=false;
bool		Checked		=false;

	if (CWName=="") {
		MathSrand(TimeLocal());
		CWName=gnCalculate+IndicatorPrefix+MathRand();
		Print(CWName);
	}

	if (GlobalVariableCheck(gnEmulate)==true)
	{
		Emulated=GlobalVariableGet(gnEmulate);
		if (GlobalVariableCheck(CWName)==false) GlobalVariableSet(CWName,true);
		Calculated=GlobalVariableGet(CWName);
		Checked=true;
	}
	if (Checked==false)
	{
			// проверка условия для продолжения расчета индикатора
				// Rule 1
			//if ((Result==0)||(Result>Bars)) Result=Bars;
			CalcCount=Counter;
			if (CalcCount==0) CalcCount=Bars-1;
			if (CalcCount<MaxPeriod) CalcCount=MaxPeriod;
			CalcCount=CalcCount+MaxPeriod;
			// Rule 2
			if ((CalcCount+MaxPeriod)>Bars) CalcCount=Bars-MaxPeriod;
			// Rule 3
			if (CalcCount<MaxPeriod) CalcCount=0;
			else CalcCount=CalcCount+MaxPeriod;
			
			if (CalcCount==0) return(0);
	}
	else {
		if (Calculated==true) return(0);
	}
	EmptyBufferam();
//+-------------------------- Begin Cycle ---------------------------------------------------+\\
	if (Checked==true)
	{
		Shift=GlobalVariableGet(gnShift);
		LRCalc=GlobalVariableGet(gnCount);
		Comment("Shift :",Shift," LRCalc :",LRCalc);
	}
	
	for (Ix=0;Ix<CalcCount;Ix++) Rates[Ix]=Close[Ix+Shift];

	LineRegressOnArray(Rates,TimeBuf1,DeGree,LRCalc);

	ArrayInitialize(FxView1,EMPTY_VALUE);
	ArrayCopy(FxView1,TimeBuf1,Shift,0,LRCalc);
  	SetIndexDrawBegin(0,LRCalc);


	if ((Checked==true)&&(Calculated==false)) GlobalVariableSet(CWName,true);

//----
   return(0);
  }
//+-----------------------------------------------------------------------------------------------+\\
//+-----------------------------------------------------------------------------------------------+\\
int deinit()
  {
//----
	DoneBufferam();	
	if (CWName!="") {
		if (GlobalVariableCheck(CWName)==true) GlobalVariableDel(CWName);		
		Print("Delete Global Variable");
	}

//----
   return(0);
  }
//+-----------------------------------------------------------------------------------------------+\\
//+-------------------------- LRChannelOnArray ---------------------------------------------------+\\
void LRChannelOnArray(double aySource[],double& ayUpper[],double& ayDowner[],double Chaneff)
{
	for (int Index=ArraySize(aySource)-1;Index>=0; Index--) 
	{
		ayUpper[Index]=aySource[Index]+Chaneff;
		ayDowner[Index]=aySource[Index]-Chaneff;
	}
	return;
}
//+-------------------------- LRConstruct ---------------------------------------------------+\\
void LineRegressOnArray(double aySource[],double& ayResult[],int iDeGree,int iCount)
{
	LRConstruct(aySource,ayLRMatrix,ayLRValue,iDeGree,iCount);
	{
		LRCalcGauss(ayLRMatrix,ayLRValue,ayLRWeight,iDeGree);
		LRCalcOnArray(ayLRWeight,ayResult,iDeGree,iCount);
	}
	return;
}
//+-------------------------- LRConstruct ---------------------------------------------------+\\
double LRConstruct(double aySource[],double& ayMatrix[][],double& ayValue[],int iDeGree,int iCount)
{
	double Zero=0;
	for (int Gx=0;Gx<=iDeGree*2;Gx++)			// Grade+1 по строкам
	{
		double Sv=0;double Qv=0;double Pv=0;
		for (int Index=0;Index<iCount;Index++)		// Grae+1 по столбцам
		{
			Pv=MathPow(Index,Gx);
			Sv=Sv+Pv;
			if (Gx<=iDeGree) Qv=Qv+Pv*aySource[Index];
			Zero=Zero+MathAbs(Qv);
		}
		for (Index=Gx;Index>=0;Index--)
		{
			if ((Index<=iDeGree)&&((Gx-Index)<=iDeGree)) ayMatrix[Gx-Index,Index]=Sv;
		}
		if (Gx<=iDeGree) ayValue[Gx]=Qv;
	}
	return(Zero);
}
//+-------------------------- LRCalcGauss ---------------------------------------------------+\\
void LRCalcGauss(double& ayMatrix[][],double& ayValue[], double& ayWeight[],int iDeGree)
{
double	Qv;
	for (int Ax=0;Ax<iDeGree;Ax++)					// Движение по диагонали 0..Grade-1
	{
		for (int Bx = Ax + 1;Bx<iDeGree;Bx++)		// Движение по строкам Ax+1..Grade-1
		{
			if (ayMatrix[Bx, Ax] != 0)
			{
				Qv = ayMatrix[Bx, Ax] / ayMatrix[Ax, Ax];
				for (int Cx = Ax+1;Cx<iDeGree;Cx++)			// Движение по столбцам Ax+1..Grade-1
				{
					ayMatrix[Bx, Cx] = ayMatrix[Bx, Cx] - Qv * ayMatrix[Ax, Cx];
				}
				ayMatrix[Bx, Ax]=0;
				ayValue[Bx] = ayValue[Bx] - Qv * ayValue[Ax];
			}
		}
	}    

	for (Ax=iDeGree-1;Ax>=0;Ax--)			// Движение по диагонали Grade-1..0
	{
		Qv = ayValue[Ax];
		for (Bx=Ax+1;Bx<iDeGree;Bx++)			// Движение по столбцам Ax..Grade-1
		{
			Qv = Qv - ayMatrix[Ax, Bx] * ayWeight[Bx];
		}
		ayWeight[Ax] = Qv / ayMatrix[Ax, Ax];
	}
return;
}
//+-------------------------- LRCalcOnArray ---------------------------------------------------+\\
void LRCalcOnArray(double ayWeight[],double& ayResult[],int iDeGree,int iCount)
{
	for (int Index=0; Index<iCount; Index++) 
	{
		double SumGree=0;
		for (int Gx=0;Gx<=iDeGree;Gx++)			// Grade+1 по строкам
		{
			SumGree=SumGree+MathPow(Index,Gx)*ayWeight[Gx];
		}
		ayResult[Index]=SumGree;
	} 
	return;
}
//+-------------------------------------------------------------------------------------------+\\

