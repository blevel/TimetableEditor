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
  Tag := TheOwner.Tag;
  FAColTitle := STRValue1;
  FARowTitile := STRValue2;
  inherited Create(TheOwner);
  Caption := TableInfo.TabAppName;
  ShowAllTable(TableInfo);
  with TableInfo do
  begin
    for i := 0 to high(TabFields) do
    begin
      with DBGrid.Columns.Add do
      begin
        if TabFields[i].FieldNeedFJoin then
          FieldName := TabFields[i].FieldFNForSel
        else
          FieldName := TabFields[i].FieldDBName;
        Width := TabFields[i].FieldWidth;
        Title.Caption := TabFields[i].FieldAppName;
        Visible := TabFields[i].FieldVisible;
      end;
    end;
  end;
  LastSortCol := nil;
  ChildFirstFrameOnLV.ExecuteBFrLV := Execute;
  ChildFirstFrameOnLV.BaseParentFrameOnLv.FieldNameBox.ItemIndex := FieldNameIndex1;
  ChildFirstFrameOnLV.BaseParentFrameOnLv.OperationBox.ItemIndex := 0;
  ChildFirstFrameOnLV.BaseParentFrameOnLv.STRValue.Text := STRValue1;
  ChildFirstFrameOnLV.AddFilter.Click;
  ChildFirstFrameOnLV.Filter[0].BaseParentFrameOnLV.FieldNameBox.ItemIndex := FieldNameIndex2;
  ChildFirstFrameOnLV.Filter[0].BaseParentFrameOnLV.OperationBox.ItemIndex := 0;
  ChildFirstFrameOnLV.Filter[0].BaseParentFrameOnLV.STRValue.Text := STRValue2;
  with FilterFrame do
  begin
    if BaseParentFrameOnLv.STRValue.Text = '' then
    begin
      Execute.Click;
      exit;
    end;
    ChildFirstFrameOnLV.AddFilter.Click;
    ChildFirstFrameOnLV.Filter[1].BaseParentFrameOnLV.FieldNameBox.ItemIndex := BaseParentFrameOnLv.FieldNameBox.ItemIndex;
    ChildFirstFrameOnLV.Filter[1].BaseParentFrameOnLV.OperationBox.ItemIndex := BaseParentFrameOnLv.OperationBox.ItemIndex;
    ChildFirstFrameOnLV.Filter[1].BaseParentFrameOnLV.STRValue.Text := BaseParentFrameOnLv.STRValue.Text;
    Count := 1;
    for i := 0 to GetHighFilter do
    begin
      ChildFirstFrameOnLV.AddFilter.Click;
      ChildFirstFrameOnLV.Filter[Count].BaseParentFrameOnLV.FieldNameBox.ItemIndex := Filter[i].BaseParentFrameOnLV.FieldNameBox.ItemIndex;
      ChildFirstFrameOnLV.Filter[Count].BaseParentFrameOnLV.OperationBox.ItemIndex := Filter[i].BaseParentFrameOnLv.OperationBox.ItemIndex;
      ChildFirstFrameOnLV.Filter[Count].BaseParentFrameOnLV.STRValue.Text := Filter[i].BaseParentFrameOnLv.STRValue.Text;
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

end.

