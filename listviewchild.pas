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
    constructor CreateDirectoryForm(TheOwner: TComponent; TableInfo: TMyTableInf);
    public
      FAcol: integer;
      FARow: integer;
  end;

implementation

{ TListChildView }

constructor TListChildView.CreateDirectoryForm(TheOwner: TComponent; TableInfo: TMyTableInf);
var
  i: integer;
begin
  Tag := TheOwner.Tag;
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
end;
end.

