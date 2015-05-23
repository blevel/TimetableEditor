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
    function CheckAllCards(ID: integer): boolean;
  private
    SaveFirstQuery: string;
    SaveLastQuery: string;
    LastSortCol: TColumn;
    Sorted: Sorting;
  public
    Cards: array of TCardF;
    constructor CreateDirectoryForm(MyParent: TMenuItem; TableInfo: TMyTableInf);
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
    SQLExecute(SQLQuery, SQLCreateQuery(ChildFirstFrameOnLV, SaveFirstQuery));
    with SQLQuery do
    begin
      SaveLastQuery := SQL.Text;
      Prepare;
      with ChildFirstFrameOnLV do
      begin
        if (FType = ftString) then
        begin
          ParamByName('pChildF').AsString := BaseParentFrameOnLV.STRValue.Text;
        end;
        if (FType = ftInteger) then
        begin
          ParamByName('pChildF').AsInteger :=
            StrToInt(BaseParentFrameOnLV.STRValue.Text);
        end;
        str := '';
        for i := 0 to GetHighFilter do
        begin
          if Filter[i].Needed then
          begin
            Table := BaseParentFrameOnLv.Tag;
            Field := Filter[i].BaseParentFrameOnLV.FieldNameBox.ItemIndex;
            FType := DataTables.FTables[Table].TabFields[Field].FieldType;
            str := 'p' + IntToStr(Filter[i].NumberOfParametr);
            if (FType = ftString) then
            begin
              ParamByName(str).AsString := Filter[i].BaseParentFrameOnLV.STRValue.Text;
            end;
            if (FType = ftInteger) then
            begin
              ParamByName(str).AsInteger :=
                StrToInt(Filter[i].BaseParentFrameOnLV.STRValue.Text);
            end;
            EditClean(Filter[i].BaseParentFrameOnLV.STRValue);
          end
          else
            Filter[i].Needed := True;
        end;
        EditClean(BaseParentFrameOnLV.STRValue);
        Open;
        LastControlCheck;
      end;
    end;
    Execute.Enabled := False;
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
  ID, i: integer;
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

procedure TListViewForm.CreateNewRButClick(Sender: TObject);
var
  i: integer;
begin
  if not CheckAllCards(0) then
  begin
    TCardF.CreateCardF(SQLQuery, DataTables.FTables[Tag], 0).Show;
  end;
end;

procedure TListViewForm.DBGridDblClick(Sender: TObject);
var
  ID, i: integer;
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

constructor TListViewForm.CreateDirectoryForm(MyParent: TMenuItem;
  TableInfo: TMyTableInf);
var
  i: integer;
begin
  Tag := MyParent.Tag;
  inherited Create(MyParent);
  Caption := TableInfo.TabAppName;
  AppropriateItem := MyParent;
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
