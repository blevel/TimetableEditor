unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, Meta, ListView, AboutForm, CardForm, TimeTable;

type

  { TMainForm }

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    DirectoryMenu: TMenuItem;
    FileMenu: TMenuItem;
    ExitMenu: TMenuItem;
    HelpMenu: TMenuItem;
    AboutMenu: TMenuItem;
    TimeTableMenu: TMenuItem;
    procedure AboutMenuClick(Sender: TObject);
    procedure ExitMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RefreshForms;
    procedure TimeTableMenuClick(Sender: TObject);
  end;

  TObjMenuItem = class(TMenuItem)
    DirectoryForm: TListViewForm;
    constructor CreateDirMenu(ATableInfo: TMyTableInf; ATag: integer);
    procedure MenuDirectoryClick(Sender: TObject);
  private
    TableInfo: TMyTableInf;
  end;

var
  MainForm: TMainForm;


implementation

{$R *.lfm}

constructor TObjMenuItem.CreateDirMenu(ATableInfo: TMyTableInf; ATag: integer);
begin
  inherited Create(Parent);
  Caption := ATableInfo.TabAppName;
  Tag := ATag;
  OnClick := @MenuDirectoryClick;
  TableInfo := ATableInfo;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to DataTables.GetHighTableFA do
  begin
    DirectoryMenu.Add(TObjMenuItem.CreateDirMenu(DataTables.FTables[i], i));
  end;
  WalkOnForms := @RefreshForms;
end;

procedure TMainForm.RefreshForms;
var
  i, k: integer;
begin
  TimeTableForm.ExecuteBut.Click;
  for i := 0 to MainForm.DirectoryMenu.Count - 1 do
  begin
    if DirectoryMenu.Items[i].Checked then
    begin
      k := TObjMenuItem(DirectoryMenu.Items[i]).DirectoryForm.Tag;
      TObjMenuItem(DirectoryMenu.Items[i]).DirectoryForm.ShowAllTable(DataTables.FTables[k]);
      TObjMenuItem(DirectoryMenu.Items[i]).DirectoryForm.RefreshCards;
    end;
  end;
end;

procedure TMainForm.TimeTableMenuClick(Sender: TObject);
begin
  TimeTableForm.Show;
end;

procedure TMainForm.ExitMenuClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.AboutMenuClick(Sender: TObject);
begin
  AboutF.ShowModal;
end;

procedure TObjMenuItem.MenuDirectoryClick(Sender: TObject);
begin
  if TMenuItem(Sender).Checked then
  begin
    DirectoryForm.ShowOnTop;
  end
  else
  begin
    TMenuItem(Sender).Checked := True;
    DirectoryForm := TListViewForm.CreateDirectoryForm(self, TableInfo);
    DirectoryForm.Show;
  end;
end;

end.


