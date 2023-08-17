/*---------------------------------------------------------
  The options statement below should be placed
  before the data step when submitting this code.
---------------------------------------------------------*/
options VALIDMEMNAME=EXTEND VALIDVARNAME=ANY;


/*---------------------------------------------------------
  Before this code can run you need to fill in all the
  macro variables below.
---------------------------------------------------------*/
/*---------------------------------------------------------
  Start Macro Variables
---------------------------------------------------------*/
%let SOURCE_HOST=<Hostname>; /* The host name of the CAS server */
%let SOURCE_PORT=<Port>; /* The port of the CAS server */
%let SOURCE_LIB=<Library>; /* The CAS library where the source data resides */
%let SOURCE_DATA=<Tablename>; /* The CAS table name of the source data */
%let DEST_LIB=<Library>; /* The CAS library where the destination data should go */
%let DEST_DATA=<Tablename>; /* The CAS table name where the destination data should go */

/* Open a CAS session and make the CAS libraries available */
options cashost="&SOURCE_HOST" casport=&SOURCE_PORT;
cas mysess;
caslib _all_ assign;

/* Load ASTOREs into CAS memory */
proc casutil;
  Load casdata="Forest___Resale_Price_1.sashdat" incaslib="Models" casout="Forest___Resale_Price_1" outcaslib="casuser" replace;
Quit;

/* Apply the model */
proc cas;
  fcmpact.runProgram /
  inputData={caslib="&SOURCE_LIB" name="&SOURCE_DATA"}
  outputData={caslib="&DEST_LIB" name="&DEST_DATA" replace=1}
  routineCode = "

   /*------------------------------------------
   Generated SAS Scoring Code
     Date             : 17Aug2023:09:55:43
     Locale           : en_US
     Model Type       : Forest
     Interval variable: Resale Price
     Interval variable: Floor Area Sqm
     Interval variable: Hawker Dist
     Interval variable: Mrt Dist
     Interval variable: School Dist
     Interval variable: Lease Commence Date
     Interval variable: Unit_Age
     Class variable   : Storey Range
     Class variable   : Flat Type
     Class variable   : Flat Model
     Class variable   : Town
     Response variable: Resale Price
     ------------------------------------------*/
declare object Forest___Resale_Price_1(astore);
call Forest___Resale_Price_1.score('CASUSER','Forest___Resale_Price_1');
   /*------------------------------------------*/
   /*_VA_DROP*/ drop 'P_Resale_Price'n;
      'P_Resale_Price_9718'n='P_Resale_Price'n;
   /*------------------------------------------*/
";

run;
Quit;

/* Persist the output table */
proc casutil;
  Save casdata="&DEST_DATA" incaslib="&DEST_LIB" casout="&DEST_DATA%str(.)sashdat" outcaslib="&DEST_LIB" replace;
Quit;
