unit TimeTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Grids, StdCtrls, PairSplitter, CheckLst, DBConnection, Meta, MyBut,
  ChildFirstFrame, Windows, Buttons, Menus, SQLcreating, fpspreadsheet;

type

  { TMyRecord }

  TArrStr = array of string;

  TMyRecord = class
    FData: TStringList;
    //FAddButton: TButtonAdd;
    //FChHeightButton: TButtonChHeight;
    FButtons: array of TMyButton;
    FTop: integer;
    FID: integer;
    FSQL: string;
    procedure AddButton(AButton: TMyButton);
  end;

  { TCell }

  TCell = class
  public
    FHeight: integer;
    FRecords: array of TMyRecord;
    //FChHeightButton: TButtonChHeight;
    FButtons: array of TMyButton;
    FSQL: string;
    FCount: integer;
    FFilled: boolean;
    procedure AddRecord;
    procedure AddButton(AButton: TMyButton);
  end;

  TMyStringList = class(TStringList)
  public
    ArrButtons: array of TButtonAdd;
  end;

  { TTimeTableForm }

  TTimeTableForm = class(TForm)
    DrawGrid: TDrawGrid;
    MainMenu: TMainMenu;
    ExportsItem: TMenuItem;
    SaveDialogTT: TSaveDialog;
    SortOrderBox: TComboBox;
    ExecuteBut: TButton;
    FieldsBox: TCheckListBox;
    ParametersBox: TCheckListBox;
    ChildFirstFrame1: TChildFirstFrame;
    RowsBox: TComboBox;
    ColumnsBox: TComboBox;
    SortBox: TComboBox;
    DataSourceTT: TDataSource;
    LabelCol: TLabel;
    LabelRow: TLabel;
    LabelSelection: TLabel;
    LabelSort: TLabel;
    LabelFilters: TLabel;
    Lable1: TLabel;
    Lable2: TLabel;
    PairSplitter: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ScrollBox1: TScrollBox;
    SQLQueryTT: TSQLQuery;
    procedure ExecuteButClick(Sender: TObject);
    procedure FieldsBoxItemClick(Sender: TObject; Index: integer);
    procedure ExportsItemClick(Sender: TObject);
    procedure DrawGridDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGridMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure DrawGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure FormCreate(Sender: TObject);
    procedure PairSplitterChangeBounds(Sender: TObject);
    procedure FillArr(ASQLQuery: TSQLQuery; ACBox: TComboBox;
      var AArr: TArrStr; var AarrDB: TArrStr);
    procedure CheckRowsForEmty;
    function SaveHTMl(FileName: string):string;
    function SaveXLS(FileName: string): string;
  private
  public
    Columns: array of string;
    Strings: array of string;
    DBColumns: array of string;
    DBStrings: array of string;
    Cells: array of array of TCell;
    Draw: boolean;
    AdditionalFields: array of string;
    LastTopForButtons: integer;
    CellForDrag: TCell;
    FlagForDrag: boolean;
  end;



{ TMyStringList }

const
  SchTabInd = 8;

var
  TimeTableForm: TTimeTableForm;

implementation

{$R *.lfm}

{ TMyRecord }

procedure TMyRecord.AddButton(AButton: TMyButton);
begin
  SetLength(FButtons, length(FButtons) + 1);
  FButtons[high(FButtons)] := AButton;
end;

{ TCell }

procedure TCell.AddRecord;
begin
  SetLength(FRecords, length(FRecords) + 1);
  FRecords[high(FRecords)] := TMyRecord.Create;
end;

procedure TCell.AddButton(AButton: TMyButton);
begin
  SetLength(FButtons, length(FButtons) + 1);
  FButtons[high(FButtons)] := AButton;
end;

{ TTimeTableForm }

procedure TTimeTableForm.ExecuteButClick(Sender: TObject);
var
  i, j, k, l, h, c: integer;
  buf, SQLbuf: string;
  LocalFlag: boolean = True;
  STRCOL, STRROW: string;
begin
  SetLength(Cells, 0);
  SetLength(Strings, 1);
  SetLength(Columns, 1);

  FillArr(SQLQueryTT, ColumnsBox, Columns, DBColumns);
  FillArr(SQLQueryTT, RowsBox, Strings, DBStrings);

  with DataTables.FTables[SchTabInd] do
  begin
    SQLbuf := 'SELECT * FROM ' + TabDBName + ' ';
    SQLbuf += SQLCreateJoin(DataTables.FTables[SchTabInd]);
    SQLbuf += ' ' + SQLCreateQuery(ChildFirstFrame1, TabDBName, False);
    SQLbuf += ' ORDER BY ' + TabFields[ColumnsBox.ItemIndex].FieldTabNForJoin +
      '.' + TabFields[ColumnsBox.ItemIndex].FieldDBName + ' , ' +
      TabFields[RowsBox.ItemIndex].FieldTabNForJoin + '.' +
      TabFields[RowsBox.ItemIndex].FieldDBName + ' , ' +
      TabFields[SortBox.ItemIndex].FieldTabNForJoin + '.' +
      TabFields[SortBox.ItemIndex].FieldDBName;
  end;
  SQLQueryTT.SQL.Text := SQLbuf;
  SQLQueryTT.Open;
  Setlength(Cells, length(Columns) + 1);
  for i := 1 to high(Cells) do
  begin
    SetLength(Cells[i], length(Strings) + 1);
  end;

  for i := 1 to high(Cells) do
  begin
    for j := 1 to high(Cells[i]) do
    begin
      Cells[i][j] := TCell.Create;
      Cells[i][j].FCount := 0;
    end;
  end;


  STRCOl := DataTables.FTables[SchTabInd].TabFields[ColumnsBox.ItemIndex].FieldFNForSel;
  STRROW := DataTables.FTables[SchTabInd].TabFields[RowsBox.ItemIndex].FieldFNForSel;
  while not SQLQueryTT.EOF do
  begin
    for i := 1 to high(Columns) do
    begin
      for j := 1 to high(Strings) do
      begin
        if (SQLQueryTT.FieldByName(STRCOL).AsString = Columns[i]) and
          (SQLQueryTT.FieldByName(STRROW).AsString = Strings[j]) then
        begin
          Cells[i][j].FCount += 1;
        end;
      end;
    end;
    SQLQueryTT.Next;
  end;
  SQLQueryTT.First;

  for i := 1 to high(Cells) do
  begin
    for j := 1 to high(Cells[i]) do
    begin
      Cells[i][j].FFilled := false;
      for k := 0 to Cells[i][j].FCount - 1 do
      begin
        Cells[i][j].AddRecord;
        Cells[i][j].FRecords[high(Cells[i][j].FRecords)].FData := TStringList.Create;
        for l := 0 to high(DataTables.FTables[8].TabFields) - 1 do
        begin
          LocalFlag := True;
          for h := 0 to FieldsBox.Count - 1 do
          begin
            if (DataTables.FTables[SchTabInd].TabFields[l].FieldFNForSel =
              DataTables.FTables[SchTabInd].TabFields[h].FieldFNForSel) and
              (FieldsBox.Checked[h] = False) then
            begin
              LocalFlag := False;
            end;
          end;
          if not LocalFlag then
          begin
            Continue;
          end;
          buf := SQLQueryTT.FieldByName(
            DataTables.FTables[8].TabFields[l].FieldFNForSel).AsString;
          with Cells[i][j] do
          begin
            if ParametersBox.Checked[0] then
            begin
              FRecords[high(Frecords)].FData.Add(
                DataTables.FTables[8].TabFields[l].FieldAppName + ': ' + buf);
            end
            else
            begin
              FRecords[high(Frecords)].FData.Add(buf);
            end;
          end;
        end;
        Cells[i][j].FRecords[high(Cells[i][j].FRecords)].FID :=
          SQLQueryTT.FieldByName(DataTables.FTables[8].TabUniqueF).AsInteger;
        SQLQueryTT.Next;
      end;
      for c := 0 to Cells[i][j].FCount - 1 do
      begin
        with Cells[i][j] do
        begin
          FRecords[c].AddButton(TButtonChange.Create);
          FRecords[c].AddButton(TButtonDelete.Create);
        end;
      end;
      with Cells[i][j] do
      begin
        AddButton(TButtonChHeight.Create);
        AddButton(TButtonAdd.Create);
        AddButton(TButttonShowOnLV.Create);
        FSQL := SQLQueryTT.SQL.Text;
      end;

    end;
  end;

  for i := 1 to high(Cells) do
  begin
    for j := 1 to high(Cells[i]) do
    begin
      Cells[i][j].FHeight := 0;
      for k := 0 to high(Cells[i][j].FRecords) do
      begin
        Cells[i][j].FHeight += 20 * Cells[i][j].FRecords[k].FData.Count + 20;
      end;
    end;
  end;
  SQLQueryTT.Close;


  DrawGrid.RowCount := length(Strings);
  DrawGrid.ColCount := length(Columns);
  with DrawGrid do
  begin
    DefaultRowHeight := 150;
    DefaultColWidth := 150;
    RowHeights[0] := 25;
    ColWidths[0] := 50;
    for i := 1 to RowCount - 1 do
    begin
      RowHeights[i] := 160;
    end;
    for i := 1 to ColCount - 1 do
    begin
      ColWidths[i] := 160;
    end;
    DrawGrid.Repaint;
  end;
  CheckRowsForEmty;
  Draw := True;
end;

procedure TTimeTableForm.FieldsBoxItemClick(Sender: TObject; Index: integer);
var
  i, Count: integer;
begin
  Count := 0;
  for i := 0 to FieldsBox.Count - 1 do
  begin
    if not FieldsBox.Checked[i] then
    begin
      Count += 1;
    end;
  end;
  if Count = FieldsBox.Count then
  begin
    FieldsBox.Checked[Index] := True;
  end;
  ExecuteBut.Click;
end;

procedure TTimeTableForm.ExportsItemClick(Sender: TObject);
begin
  if SaveDialogTT.Execute then
  begin
    if SaveDialogTT.FilterIndex = 1 then
    begin
      SaveHTMl(Utf8ToAnsi(SaveDialogTT.FileName));
    end;
    if SaveDialogTT.FilterIndex = 2 then
    begin
      SaveXLS(Utf8ToAnsi(SaveDialogTT.FileName));
    end;
  end;
end;

procedure TTimeTableForm.DrawGridDrawCell(Sender: TObject;
  aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
var
  i, j, k: integer;
begin
  if Draw then
  begin
    if (acol = 0) and (aRow > 0) and (aRow <= high(Strings)) then
    begin
      DrawGrid.Canvas.TextOut(ARect.Left + 1, ARect.Top + 1, Strings[aRow]);
    end;
    if (aRow = 0) and (aCol > 0) and (aCol <= high(Columns)) then
    begin
      DrawGrid.Canvas.TextOut(Arect.Left + 1, Arect.Top + 1, Columns[aCol]);
    end;
    if (aCol > 0) and (aRow > 0)
    {and (aCol <= high(Cells)) and (aRow <= high(Cells[aRow]))} then
    begin
      LastTopForButtons := 0;
      for i := 0 to FieldsBox.Count - 1 do
      begin
        if FieldsBox.Checked[i] then
        begin
          LastTopForButtons += 20;
        end;
      end;
      LastTopForButtons += 20;
      with DrawGrid.Canvas do
      begin
        for i := 0 to high(Cells[aCol][aRow].FRecords) do
        begin
          with Cells[aCol][aRow].FRecords[i] do
          begin
            for j := 0 to FData.Count - 1 do
            begin
              TextOut(Arect.Left + 1, ARect.Top + 1 + j * 20 +
                LastTopForButtons * i, FData[j]);
              Cells[aCol][aRow].FFilled := true;
            end;
            for k := 0 to high(FButtons) do
            begin
              Draw(
                Arect.Right - 16 - 17 * k, ARect.Top + 1 + (j + 1) *
                20 + LastTopForButtons * i, FButtons[k].Icon
                );
              FButtons[k].RefreshRect(
                ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i,
                ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i + 16,
                Arect.Right - 16 - 17 * k,
                Arect.Right - 17 * k
                );
            end;
          end;
          with Cells[aCol][aRow] do
          begin
            for k := 0 to high(FButtons) do
            begin
              Draw(Arect.Right - 16 - 17 * k, Arect.Top + 1, FButtons[k].Icon);
              FButtons[k].RefreshRect(aRect.Top + 1, aRect.Top + 1 +
                16, aRect.Right - 16 - 17 * k, aRect.Right - 17 * k);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TTimeTableForm.DrawGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
var
  aCol, aRow, i, j: integer;
  Str: string;
begin
  if Draw then
  begin
    DrawGrid.MouseToCell(X, Y, aCol, aRow);
    if (aCol = 0) or (aRow = 0) then
    begin
      DrawGrid.Hint := '';
      exit;
    end;
    Str := '';
    if (aCol > 0) and (aRow > 0) then
    begin
      for i := 0 to high(Cells[aCol][aRow].FRecords) do
      begin
        with Cells[aCol][aRow].FRecords[i] do
        begin
          for j := 0 to FData.Count - 1 do
          begin
            Str += FData[j];
            Str += #10#13;
          end;
          Str += #10#13;
        end;
      end;
      DrawGrid.Hint := Str;
    end;
  end;
end;

procedure TTimeTableForm.DrawGridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  i, j: integer;
  APoint: TPoint;
  aRow, aCol: integer;
begin
  DrawGrid.MouseToCell(X, Y, aCol, aRow);
  if (aCol = 0) or (aRow = 0) then
  begin
    exit;
  end;
  APoint.x := X;
  APoint.y := Y;
  with Cells[aCol][aRow] do
  begin
    for i := 0 to high(FButtons) do
    begin
      if PtInRect(FButtons[i].FRect, APoint) then
      begin
        FButtons[i].OnClick(Self, DrawGrid, aRow, Cells[aCol][aRow].FHeight,
          SQLQueryTT, DataTables.FTables[8], 0, Columns[aCol],
          Strings[aRow], ColumnsBox.ItemIndex, RowsBox.ItemIndex, ChildFirstFrame1);
      end;
    end;
    for i := 0 to high(FRecords) do
    begin
      for j := 0 to high(FRecords[i].FButtons) do
      begin
        if PtInRect(Frecords[i].FButtons[j].FRect, APoint) then
        begin
          SQLQueryTT.Close;
          SQLQueryTT.SQL.Text := Cells[aCol][aRow].FSQL;
          SQLQueryTT.Open;
          while SQLQueryTT.FieldByName(DataTables.FTables[8].TabUniqueF).AsInteger <>
            FRecords[i].FID do
          begin
            SQLQueryTT.Next;
          end;
          FRecords[i].FButtons[j].OnClick(Self, DrawGrid, aRow,
            Cells[aCol][aRow].FHeight,
            SQLQueryTT, DataTables.FTables[8], FRecords[i].FID,
            Columns[aCol], Strings[aRow], ColumnsBox.ItemIndex,
            RowsBox.ItemIndex, ChildFirstFrame1);
          SQLQueryTT.Close;
          exit;
        end;
      end;
    end;
  end;
end;

procedure TTimeTableForm.FormCreate(Sender: TObject);
var
  i: integer;
  Str: array of TStringList;
begin
  //Tag := 8;
  Draw := False;
  FlagForDrag := False;
  for i := 0 to high(DataTables.FTables[8].TabFields) - 1 do
  begin
    with DataTables.FTables[SchTabInd].TabFields[i] do
    begin
      RowsBox.Items.Add(FieldAppName);
      ColumnsBox.Items.Add(FieldAppName);
      SortBox.Items.Add(FieldAppName);
      FieldsBox.Items.Add(FieldAppName);
    end;
  end;
  FieldsBox.CheckAll(cbChecked);
  ScrollBox1.Tag := 8;
  ChildFirstFrame1 := TChildFirstFrame.Create(ScrollBox1);
  with ChildFirstFrame1 do
  begin
    Left := 300;
    Top := 56;
    ExecuteBFrLV := TBitBtn.Create(Self);
  end;
  RowsBox.ItemIndex := 0;
  ColumnsBox.ItemIndex := 0;
  SortBox.ItemIndex := 0;
end;



procedure TTimeTableForm.PairSplitterChangeBounds(Sender: TObject);
begin

end;

procedure TTimeTableForm.FillArr(ASQLQuery: TSQLQuery; ACBox: TComboBox;
  var AArr: TArrStr; var AarrDB: TArrStr);
begin
  ASQLQuery.Close;
  ASQLQuery.SQl.Text := 'SELECT ' + ' * ' +
    ' FROM ' + DataTables.FTables[SchTabInd].TabFields[ACBox.ItemIndex].FieldTabNForJoin
    + ' ORDER BY ' + DataTables.FTables[SchTabInd].TabFields[
    ACBox.ItemIndex].FieldTabNForJoin + '.' +
    DataTables.FTables[SchTabInd].TabFields[ACBox.ItemIndex].FieldFNForJoin;
  ASQLQuery.Open;
  while not ASQLQuery.EOF do
  begin
    SetLength(AArr, length(AArr) + 1);
    AArr[high(AArr)] :=
      ASQLQuery.FieldByName(DataTables.FTables[SchTabInd].TabFields[
      ACBox.ItemIndex].FieldFNForSel).AsString;

    SetLength(AarrDB, length(AarrDB) + 1);
    AarrDB[high(AarrDB)] := ASQLQuery.FieldByName(
      DataTables.FTables[SchTabInd].TabFields[ACBox.ItemIndex].FieldFNForJoin).AsString;
    ASQLQuery.Next;
  end;
  ASQLQuery.Close;
end;

procedure TTimeTableForm.CheckRowsForEmty;
var
  i, j, Count: integer;
begin
  if ParametersBox.Checked[1] then
  begin
    for i := 1 to high(Cells) do
    begin
      Count := 0;
      for j := 1 to high(Cells[i]) do
      begin
        if not Cells[i][j].FFilled then
        begin
          Count += 1;
        end;
      end;
      ShowMessage(IntToStr(Count) + ' ' + IntToStr(length(Cells[i])- 1));
      if Count = length(Cells[i]) then
      begin
      end;
    end;
  end;
end;

function TTimeTableForm.SaveHTMl(FileName: string): string;
var
  i, j, k, l: integer;
  SaveList: TStringList;
  aCol, aRow: integer;
begin
  SaveList := TStringList.Create;
  Result := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN"'#10
           +'"http://www.qyos.am/TR/html4/strict.dtd">'#10
           +'<HTML>'#10
           +'  <HEAD>'#10
           +'    <META http-equiv="Content-Type" content="text/html; charset=utf-8">'#10
           +'    <TITLE>' + Caption + '</TITLE>'#10
           +'  </HEAD>'#10
           +'  <BODY>'#10
           +'    <TABLE CELLSPACING="0" CELLPADDING="0" BORDER="1">'#10
           +'      <TR>'#10
           +'      <TH BGCOLOR="Gainsboro"><br></TH>'#10;
  for i := 1 to high(Columns) do
  begin
    Result +=
            '        <TH BGCOLOR="Gainsboro">' + Columns[i] + '</TH>'#10;
  end;
  Result += '      </TR>'#10;


  for i := 1 to high(Strings) do
  begin
    Result +=
            '      <TR>'#10
           +'        <TH BGCOLOR = "Gainsboro">' + Strings[i] + '</TH>'#10;
    for j := 1 to high(Columns) do
    begin
      if length(Cells[j][i].FRecords) = 0 then
      begin
        Result +=
            '        <TD NOWRAP VALIGN="TOP">';
      end else
      begin
        Result +=
            '        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">';
      end;
      for k := 0  to high(Cells[j][i].FRecords) do
      begin
        for l := 0 to Cells[j][i].FRecords[k].FData.Count - 1 do
        begin
          Result +=
                     Cells[j][i].FRecords[k].FData.Strings[l] + '<br>';
        end;
      end;
      Result +=      '</TD>'#10;
    end;
    Result +=
            '      </TR>'#10;
  end;
  Result += '    </TABLE>'#10
           +'    <TABLE CELLSPACING="0" CELLPADDING="0" BORDER="1">'#10
           +'      <TR>'#10
           +'        <TH BGCOLOR="Gainsboro">Поля</TH>'#10
           +'      </TR>'#10
           +'      <TR>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">';
  for i := 0 to  FieldsBox.Count - 1 do
  begin
    if FieldsBox.Checked[i] then
    begin
      Result +=
                     FieldsBox.Items[i] + '<br>';
    end;
  end;
  Result +=
                     '</TD>'#10
           +'      </TR>'#10
           +'    </TABLE>'#10
           +'    <TABLE СELLSPACING="0" CELLPADDING="0" BORDER="1">'#10
           +'      <TR>'#10
           +'        <TH BGCOLOR="Gainsboro">№</TH>'
           +'        <TH BGCOLOR="Gainsboro">Логическое выражение</TH>'#10
           +'        <TH BGCOLOR="Gainsboro">Фильтр по</TH>'#10
           +'        <TH BGCOLOR="Gainsboro">Оператор выбора</TH>'#10
           +'        <TH BGCOLOR="Gainsboro">Значение</TH>'
           +'      </TR>'#10
           +'      <TR>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">0</TD>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">Нет</TD>'
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + ChildFirstFrame1.BaseParentFrameOnLv.FieldNameBox.Caption + '</TD>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + ChildFirstFrame1.BaseParentFrameOnLv.OperationBox.Caption+ '</TD>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + ChildFirstFrame1.BaseParentFrameOnLv.STRValue.Text +'</TD>'#10
           +'      </TR>';
  for i := 0 to ChildFirstFrame1.GetHighFilter do
  begin
    Result +=
            '      <TR>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + IntToStr(i + 1) + '</TD>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + ChildFirstFrame1.Filter[i].AndOrBox.Caption + '</TD>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + ChildFirstFrame1.Filter[i].BaseParentFrameOnLV.FieldNameBox.Caption + '</TD>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + ChildFirstFrame1.Filter[i].BaseParentFrameOnLV.OperationBox.Caption + '</TD>'#10
           +'        <TD NOWRAP VALIGN="TOP" BGCOLOR="Turquoise">' + ChildFirstFrame1.Filter[i].BaseParentFrameOnLV.STRValue.Text + '</TD>'
           +'      </TR>'#10;
  end;
  Result +=
            '    </TABLE>'#10
           +'  </BODY>'#10
           +'</HTML>'#10;



  ChangeFileExt(FileName, 'html');
  SaveList.Append(Result);
  SaveList.SaveToFile(FileName);
  SaveList.Free;
end;

function TTimeTableForm.SaveXLS(FileName: string): string;
var
  MyFile: TsWorkbook;
  TimeTable, MetaData: TsWorksheet;
  BookName: string = 'Расписание';
  i, j, k, l, Count: integer;
  BufStr :string;
  LittleCount, BigCount, MaxCount: integer;
begin
  MyFile := TsWorkbook.Create;
  TimeTable := MyFile.AddWorksheet(BookName);
  TimeTable.Options := TimeTable.Options + [soHasFrozenPanes];
  TimeTable.LeftPaneWidth := 1;
  TimeTable.TopPaneHeight := 1;
  for i := 1 to high(Columns) do
  begin
    TimeTable.WriteUTF8Text(0, i, Columns[i]);
  end;
  BigCount := 0;
  LittleCount := 0;
  MaxCount := 0;
  for i := 1 to high(Strings) do
  begin
    BigCount +=  MaxCount;
    MaxCount := 0;
    for j := 1 to high(Columns) do
    begin
      LittleCount := 0;
      TimeTable.WriteBorders(i + BigCount, j, [cbEast, cbWest, cbNorth]);
      for k := 0 to high(Cells[j][i].FRecords) do
      begin
        BufStr := '';
        for l := 0 to Cells[j][i].Frecords[k].FData.Count - 1 do
        begin
          BufStr += Cells[j][i].FRecords[k].FData.Strings[l] + #10;
        end;
        BufStr += #10;
        if Cells[j][i].Frecords[k].FData.Count > 0 then
        begin
          TimeTable.WriteBackgroundColor(i + BigCount + LittleCount, j, scYellow);
        end;
        TimeTable.WriteUTF8Text(i + BigCount + LittleCount, j, BufStr);
        TimeTable.WriteWordwrap(i + BigCount + LittleCount, j, true);
        TimeTable.WriteBorders(i + 1 + LittleCount + BigCount, j, [cbEast, cbWest]);
        inc(LittleCount);
        TimeTable.WriteVertAlignment(i + BigCount + LittleCount, j, vaCenter);
      end;
      TimeTable.WriteBorders(i + LittleCount + BigCount, j, [cbNorth]);
      TimeTable.WriteColWidth(j, 25);
      if LittleCount > MaxCount then
      begin
        MaxCount := LittleCount;
      end;
    end;
    TimeTable.MergeCells(i + BigCount, 0, i + MaxCount + BigCount, 0);
    TimeTable.WriteUTF8Text(i + BigCount, 0, Strings[i]);
    TimeTable.WriteVertAlignment(i + BigCount, 0, vaCenter);
  end;
  MetaData := MyFile.AddWorksheet('Фильтры и поля');
  i := 0;
  MetaData.WriteUTF8Text(0, i, '№');
  inc(i);
  MetaData.WriteUTF8Text(0, i, 'Логическое выражение');
  inc(i);
  MetaData.WriteUTF8Text(0, i, 'Фильтр по');
  inc(i);
  MetaData.WriteUTF8Text(0, i, 'Оператор выбора');
  inc(i);
  MetaData.WriteUTF8Text(0, i, 'Значение');
  inc(i);
  for j := 0 to i do
  begin
    MetaData.WriteColWidth(j, 25);
  end;
  i := 0;
  MetaData.WriteUTF8Text(1, i, IntToStr(i));
  inc(i);
  MetaData.WriteUTF8Text(1, i, 'Нет');
  inc(i);
  MetaData.WriteUTF8Text(1, i, ChildFirstFrame1.BaseParentFrameOnLv.FieldNameBox.Caption);
  inc(i);
  MetaData.WriteUTF8Text(1, i, ChildFirstFrame1.BaseParentFrameOnLv.OperationBox.Caption);
  inc(i);
  MetaData.WriteUTF8Text(1, i, ChildFirstFrame1.BaseParentFrameOnLv.STRValue.Text);
  for j := 0 to ChildFirstFrame1.GetHighFilter do
  begin
    i := 0;
    MetaData.WriteUTF8Text(j + 2, i, IntToStr(j + 1));
    inc(i);
    MetaData.WriteUTF8Text(j + 2, i, ChildFirstFrame1.Filter[j].AndOrBox.Caption);
    inc(i);
    MetaData.WriteUTF8Text(j + 2, i, ChildFirstFrame1.Filter[j].BaseParentFrameOnLV.FieldNameBox.Caption);
    inc(i);
    MetaData.WriteUTF8Text(j + 2, i, ChildFirstFrame1.Filter[j].BaseParentFrameOnLV.OperationBox.Caption);
    inc(i);
    MetaData.WriteUTF8Text(j + 2, i, ChildFirstFrame1.Filter[j].BaseParentFrameOnLV.STRValue.Text);
  end;
  MetaData.WriteUTF8Text(j + 4, 0, 'Поля');
  l := 0;
  for i := 0 to FieldsBox.Count - 1 do
  begin
    if FieldsBox.Checked[i] then
    begin
      inc(l);
      MetaData.WriteUTF8Text(j + 5 + l, 0, FieldsBox.Items[i]);
    end;
  end;
  MyFile.WriteToFile(FileName, sfExcel8, true);
  //TimeTable.Free;
  //MetaData.Free;
  //MyFile.Free;
end;

end.

