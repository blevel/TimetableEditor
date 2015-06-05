unit ListViewChild;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  DBGrids, Menus, Meta, Buttons, ExtCtrls, Grids, DBCtrls, PairSplitter,
  StdCtrls, SQLcreating, ChildFirstFrame, FilterFrame, CardForm, DBConnection, ListView;

type

  { TListChildView }

  TListChildView = class(TListViewForm)
    constructor CreateDirectoryForm(TheOwner: TComponent; TableInfo: TMyTableInf;
  FieldNameIndex1, FieldNameIndex2: integer; STRValue1, STRValue2: string; FilterFrame: TChildFirstFrame);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure AddDefaultFilter(ABaseP: TBaseParentFrame; Index1, Index2: integer;
  Str: string);
    public
      //FAcol: integer;
      //FARow: integer;
      FAColTitle: string;
      FARowTitile: string;
  end;

implementation

{ TListChildView }

constructor TListChildView.CreateDirectoryForm(TheOwner: TComponent; TableInfo: TMyTableInf;
  FieldNameIndex1, FieldNameIndex2: integer; STRValue1, STRValue2: string; FilterFrame: TChildFirstFrame);
var
  i, count: integer;
begin
  TableFill(TheOwner, TableInfo, true);
  with ChildFirstFrameOnLV do
  begin
    AddDefaultFilter(BaseParentFrameOnLv, FieldNameIndex1, 0, STRValue1);
    ChildFirstFrameOnLV.AddFilter.Click;
    AddDefaultFilter(Filter[0].BaseParentFrameOnLV, FieldNameIndex2, 0, STRValue2);
    with FilterFrame do
    begin
      if BaseParentFrameOnLv.STRValue.Text = '' then
      begin
        Execute.Click;
        exit;
      end;
      ChildFirstFrameOnLV.AddFilter.Click;
      AddDefaultFilter(ChildFirstFrameOnLV.Filter[1].BaseParentFrameOnLV,
        BaseParentFrameOnLv.FieldNameBox.ItemIndex, BaseParentFrameOnLv.OperationBox.ItemIndex,
        BaseParentFrameOnLv.STRValue.Text);
      Count := 1;
      for i := 0 to GetHighFilter do
      begin
        ChildFirstFrameOnLV.AddFilter.Click;
        AddDefaultFilter(ChildFirstFrameOnLV.Filter[Count].BaseParentFrameOnLV,
        Filter[i].BaseParentFrameOnLv.FieldNameBox.ItemIndex, Filter[i].BaseParentFrameOnLv.OperationBox.ItemIndex,
        Filter[i].BaseParentFrameOnLv.STRValue.Text);
      end;
    end;
  end;
  Execute.Click;
  OnClose := @FormClose;
end;

procedure TListChildView.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TListChildView.AddDefaultFilter(ABaseP: TBaseParentFrame; Index1, Index2: integer;
  Str: string);
begin
  ABaseP.FieldNameBox.ItemIndex := Index1;
  ABaseP.OperationBox.ItemIndex := Index2;
  ABaseP.STRValue.Text := Str;
end;

end.

