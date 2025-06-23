// this code will get the current time , wait until a certain amount of Seconds
// has passed and then continue processing.

// NOTE: the first run will produce a error as the stored Time
// will be re initialised , after that it will function correctly.

//Author: Desmond aka " buju"

extern int wtime=60;      //waiting time in seconds
int handle; 
int stime;
int ftime;

int start()
  {
  
int xtime=(TimeCurrent());                  //get current time

//Print ("current time ", ctime,"  ",xtime);

int newtime=(xtime)+(wtime);              //current time + time to wait
//Print ("newtime ",newtime);

handle=FileOpen("timefile",FILE_BIN|FILE_READ);    //open external file
stime=FileReadInteger(handle,LONG_VALUE);          //read stored time in file
FileClose(handle);                                 //close file
//Print ("stored time ",stime);
//Print ("read from file error ",GetLastError());

{


if (xtime > stime)                                 //if current time greater than stored time

//Print ("time reached ",xtime," ",stime);
ftime = (xtime+wtime);                             //add waiting time to current time = future time
}

//if (xtime > stime) Print ("ftime ",ftime);           
if (xtime > stime) handle=FileOpen("timefile",FILE_BIN|FILE_WRITE);     //if current time greater tha stored time
if (xtime > stime) FileWriteInteger(handle, ftime);                     //open and write future time
if (xtime > stime) FileClose(handle);
Print ("write to file error ",GetLastError());

if (xtime > stime) Alert ("time reached ",stime);        //if future time is reached process ........

Comment("Order Open: ",OrderOpenPrice(),                 //comments ....
         "\ncurrent time ", xtime,
         "\nfuture time ", ftime,
         "\nstored time ",stime
         );
         
} //end prog

