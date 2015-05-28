program HotLine;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main, Meta, ListView, AboutForm, SQLcreating, FilterFrame,
  ChildFirstFrame, addfilterframe, MyFrame, CardForm, DBConnection, TimeTable,
  MyBut, ListViewChild;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDBConnectionMod, DBConnectionMod);
  //Application.CreateForm(TListViewForm, ListViewForm);
  Application.CreateForm(TAboutF, AboutF);
  Application.CreateForm(TTimeTableForm, TimeTableForm);
  //Application.CreateForm(TCardF, CardF);
  Application.Run;
end.

