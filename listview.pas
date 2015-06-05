unit ListView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  DBGrids, Menus, Meta, Buttons, ExtCtrls, Grids, DBCtrls, PairSplitter,
  StdCtrls, SQLcreating, ChildFirstFrame, FilterFrame, CardForm, DBConnection;

type

  Sorting = (SortedASC, SortedDESC, UnSorted);

  { TListViewForm }

  TListViewForm = class(TForm)
    BaseParentFrameOnLV: TBaseParentFrame;
    ChangeBut: TButton;
    CreateNewRBut: TButton;
    DelBut: TButton;
    ChildFirstFrameOnLV: TChildFirstFrame;
    Execute: TBitBtn;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    DBNavigator: TDBNavigator;
    GridPanel: TPanel;
    ImageList: TImageList;
    PairSplitter: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ScrollBox: TScrollBox;
    SQLQuery: TSQLQuery;
    AppropriateItem: TMenuItem;
    procedure ChangeButClick(Sender: TObject);
    procedure CreateNewRButClick(Sender: TObject);
    procedure DBGridDblClick(Sender: TObject);
    procedure DelButClick(Sender: TObject);
    procedure DBGridTitleClick(Column: TColumn);
    procedure ExecuteClick(Sender: TObject);
    procedure FieldNameBoxChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ShowAllTable(TableInfo: TMyTableInf);
    procedure EditClean(Edit: TEdit);
    procedure LastControlCheck;
    procedure RefreshCards;
    procedure TableFill(AParent: TComponent; TableInfo: TMyTableInf; ChildFlag: boolean);
    function CheckAllCards(ID: integer): boolean;
  private
    SaveFirstQuery: string;
    SaveLastQuery: string;
    Sorted: Sorting;
  public
    Cards: array of TCardF;
    LastSortCol: TColumn;
    constructor CreateDirectoryForm(MyParent: TObject; TableInfo: TMyTableInf);
    //constructor Create(TheOwner: TComponent; TableInfo: TMyTableInf);
  end;

var
  ListViewForm: TListViewForm;

implementation

{$R *.lfm}

procedure TListViewForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  AppropriateItem.Checked := False;
  CloseAction := caFree;
end;

procedure TListViewForm.ExecuteClick(Sender: TObject);
var
  str: string;
  i, Table, Field: integer;
  FType: TFieldType;
begin
  try
    Table := ChildFirstFrameOnLV.BaseParentFrameOnLv.Tag;
    Field := ChildFirstFrameOnLV.BaseParentFrameOnLv.FieldNameBox.ItemIndex;
    FType := DataTables.FTables[Table].TabFields[Field].FieldType;
    if ChildFirstFrameOnLV.BaseParentFrameOnLv.STRValue.Text = '' then
      exit;
    SQLExecute(SQLQuery, SQLCreateQuery(ChildFirstFrameOnLV, SaveFirstQuery, true));
    with SQLQuery do
    begin
      SQLQuery.Open;
    end;
  except
    on EConvertError do
      ShowMessage('Введены некорректные данные');
  end;
  //ShowMessage(SQLQuery.SQL.Text);
end;

procedure TListViewForm.FieldNameBoxChange(Sender: TObject);
begin
  Execute.Enabled := True;
end;

procedure TListViewForm.DBGridTitleClick(Column: TColumn);
begin
  SQLQuery.Close;
  if (LastSortCol <> Column) then
  begin
    Sorted := UnSorted;
    LastControlCheck;
  end;
  case Sorted of
    UnSorted:
    begin
      SQLQuery.SQL.Text := SaveLastQuery + ' ORDER BY ' + Column.FieldName + ' ASC';
      SQLQuery.Open;
      Sorted := SortedASC;
      LastSortCol := Column;
      Column.Width := Column.Width + 17;
      Column.Title.ImageIndex := 0;
      exit;
    end;
    SortedASC:
    begin
      SQLQuery.SQL.Text := SaveLastQuery + ' ORDER BY ' + Column.FieldName + ' DESC';
      SQLQuery.Open;
      Sorted := SortedDESC;
      Column.Title.ImageIndex := 1;
      exit;
    end;
    SortedDESC:
    begin
      SQLQuery.SQL.Text := SaveLastQuery;
      SQLQuery.Open;
      Sorted := UnSorted;
      Column.Width := Column.Width - 17;
      Column.Title.ImageIndex := -1;
      exit;
    end;
  end;
end;

procedure TListViewForm.ChangeButClick(Sender: TObject);
var
  ID: integer;
begin
  try
    //Edit1.Text := SQLQuery.SQL.Text;
    //ShowMessage(SQLQuery.SQL.Text);
    ID := SQLQuery.Fields.FieldByName(DataTables.FTables[Tag].TabUniqueF).Value;
    if not CheckAllCards(ID) then
    begin
      TCardF.CreateCardF(SQLQuery, DataTables.FTables[Tag], ID).Show;
    end;
  except
    on EVariantError do
      ShowMessage('Выбирите запись для редактирования');
  end;
end;

procedure TListViewForm.CreateNewRButClick(Sender: TObject);
begin
  if not CheckAllCards(0) then
  begin
    TCardF.CreateCardF(SQLQuery, DataTables.FTables[Tag], 0).Show;
  end;
end;

procedure TListViewForm.DBGridDblClick(Sender: TObject);
var
  ID: integer;
begin
  try
    ID := SQLQuery.Fields.FieldByName(DataTables.FTables[Tag].TabUniqueF).Value;
    if not CheckAllCards(ID) then
    begin
      TCardF.CreateCardF(SQLQuery, DataTables.FTables[Tag], ID).Show;
    end;
  except
    on EVariantError do
      ShowMessage('Выбирите запись для редактирования');
  end;
end;

procedure TListViewForm.DelButClick(Sender: TObject);
var
  IDstr: string;
  ans: TModalResult;
begin
  ans := MessageDlg('Вы действительно хотите удалить выбранную запись?',
    mtInformation, [mbYes, mbNo], 0);
  if ans = mrYes then
  begin
    try
      with DataTables.FTables[Tag] do
      begin
        IDstr := SQLQuery.Fields.FieldByName(TabUniqueF).Value;
        SQLQuery.SQL.Text := 'DELETE FROM ' + TabDBName + ' WHERE ' +
          TabDBName + '.' + TabUniqueF + ' = ' + IDstr;
      end;
      SQLQuery.ExecSQL;
      DBConnectionMod.SQLTransaction.Commit;
      WalkOnForms;
    except
      on EDatabaseError do
        ShowMessage('Нельзя удалить первичный ключ');
    end;
  end;
end;

procedure TListViewForm.ShowAllTable(TableInfo: TMyTableInf);
begin
  SQLExecute(SQLQuery, 'SELECT * FROM ' + SQLCreateJoin(TableInfo));
  SaveFirstQuery := SQLCreateJoin(TableInfo);
  SaveLastQuery := SQLQuery.SQL.Text;
  SQLQuery.Open;
end;

procedure TListViewForm.EditClean(Edit: TEdit);
var
  s: string;
begin
  s := Edit.Text;
  if (s[1] = '%') then
  begin
    Delete(s, 1, 1);
    Edit.Text := s;
  end;
  if (s[length(s)] = '%') then
  begin
    Delete(s, length(s), 1);
    Edit.Text := s;
  end;
end;

procedure TListViewForm.LastControlCheck;
begin
  if (LastSortCol <> nil) then
  begin
    if LastSortCol.Title.ImageIndex > -1 then
    begin
      LastSortCol.Title.ImageIndex := -1;
      LastSortCol.Width := LastSortCol.Width - 17;
      LastSortCol := nil;
    end;
  end;
end;

procedure TListViewForm.RefreshCards;
var
  i: integer;
begin
  for i := 0 to Application.ComponentCount - 1 do
  begin
    if (Application.Components[i] is TCardF) then
    begin
      TCardF(Application.Components[i]).RefreshForm;
    end;
  end;
end;

procedure TListViewForm.TableFill(AParent: TComponent; TableInfo: TMyTableInf; ChildFlag: boolean);
var
  i: integer;
begin
  Tag := TMenuItem(AParent).Tag;
  if ChildFlag then
  begin
    inherited Create(AParent);
  end else
  begin
    inherited Create(TMenuItem(AParent));
  end;
  Caption := TableInfo.TabAppName;
  AppropriateItem := TMenuItem(AParent);
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

function TListViewForm.CheckAllCards(ID: integer): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to Application.ComponentCount - 1 do
  begin
    if (Application.Components[i] is TCardF) then
    begin
      if (DataTables.FTables[Tag].TabDBName =
        TCardF(Application.Components[i]).FTable.TabDBName) and
        (ID = TCardF(Application.Components[i]).FID) then
      begin
        TCardF(Application.Components[i]).ShowOnTop;
        Result := True;
        exit;
      end;
    end;
  end;
end;

constructor TListViewForm.CreateDirectoryForm(MyParent: TObject;
  TableInfo: TMyTableInf);
var
  i: integer;
begin
  TableFill(TComponent(MyParent), TableInfo, false);
  //Tag := TMenuItem(MyParent).Tag;
  //inherited Create(TMenuItem(MyParent));
  //Caption := TableInfo.TabAppName;
  //AppropriateItem := TMenuItem(MyParent);
  //ShowAllTable(TableInfo);
  //with TableInfo do
  //begin
  //  for i := 0 to high(TabFields) do
  //  begin
  //    with DBGrid.Columns.Add do
  //    begin
  //      if TabFields[i].FieldNeedFJoin then
  //        FieldName := TabFields[i].FieldFNForSel
  //      else
  //        FieldName := TabFields[i].FieldDBName;
  //      Width := TabFields[i].FieldWidth;
  //      Title.Caption := TabFields[i].FieldAppName;
  //      Visible := TabFields[i].FieldVisible;
  //    end;
  //  end;
  //end;
  //LastSortCol := nil;
  //ChildFirstFrameOnLV.ExecuteBFrLV := Execute;
end;

{constructor TListViewForm.Create(TheOwner: TComponent; TableInfo: TMyTableInf);
var
  i: integer;
begin
  inherited Create(TheOwner);
  Caption := TableInfo.TabAppName;
  //AppropriateItem := TMenuItem(MyParent);
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
end;}

end.
