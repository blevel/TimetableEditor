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
    destructor Destroy; override;
  end;

  TMyStringList = class(TStringList)
  public
    ArrButtons: array of TButtonAdd;
  end;

  { TTimeTableForm }

  TTimeTableForm = class(TForm)
    DrawGrid1: TDrawGrid;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    SaveDialog1: TSaveDialog;
    SortOrderBox: TComboBox;
    ExecuteBut: TButton;
    FieldsBox: TCheckListBox;
    ParametersBox: TCheckListBox;
    ChildFirstFrame1: TChildFirstFrame;
    RowsBox: TComboBox;
    ColumnsBox: TComboBox;
    SortBox: TComboBox;
    DataSource1: TDataSource;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Lable1: TLabel;
    Lable2: TLabel;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ScrollBox1: TScrollBox;
    SQLQuery1: TSQLQuery;
    procedure ExecuteButClick(Sender: TObject);
    procedure FieldsBoxItemClick(Sender: TObject; Index: integer);
    procedure MenuItem1Click(Sender: TObject);
    procedure ParametersBoxItemClick(Sender: TObject; Index: integer);
    procedure DrawGrid1DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure DrawGrid1DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure DrawGrid1DrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGrid1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure FormCreate(Sender: TObject);
    procedure PairSplitter1ChangeBounds(Sender: TObject);
    procedure FillArr(ASQLQuery: TSQLQuery; ACBox: TComboBox;
      var AArr: TArrStr; var AarrDB: TArrStr);
    procedure CheckRowsForEmty;
    function SaveHTMl(FileName: string):string;
    function SaveXLS(FileName: string): string;
    //constructor Create(TheOwner: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Columns: array of string;
    Strings: array of string;
    DBColumns: array of string;
    DBStrings: array of string;
    Cells: array of array of TCell;
    //MyButtons: array of array of TButtonAdd;
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

destructor TCell.Destroy;
begin
  //for i := 0 to high(FRecords) do
  //begin

  //end;
  inherited Destroy;
end;

{ TTimeTableForm }

procedure TTimeTableForm.ExecuteButClick(Sender: TObject);
var
  i, j, k, l, h, c: integer;
  buf, SQLbuf: string;
  LocalFlag: boolean = True;
  STRCOL, STRROW: string;
begin
  //Нужно для совпадения номеров клеток
  //for i := 0 to high(Cells) do
  //begin
  //  for j := 0 to high(Cells[i]) do
  //  begin
  //    //Cells[i][j].Free;
  //    //Freemem(Cells[i][j]);
  //    if Cells[i][j] <> Nil then
  //    begin
  //      Cells[i][j].Destroy;
  //    end;
  //  end;
  //end;
  SetLength(Cells, 0);
  //for i := 0 to high(Strings) do
  //begin
  //  Strings[i]
  //end;
  SetLength(Strings, 1);
  SetLength(Columns, 1);

  FillArr(SQLQuery1, ColumnsBox, Columns, DBColumns);
  FillArr(SQLQuery1, RowsBox, Strings, DBStrings);

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


  //ShowMessage(SQLbuf);
  //if SortBox.ItemIndex = 0 then
  //begin
  //  SQLbuf += ' DESC ';
  //end;
  //if SortBox.ItemIndex = 1 then
  //begin
  //  SQLbuf += ' ASC ';
  //end;

  SQLQuery1.SQL.Text := SQLbuf;
  //Edit1.Text := SQLQuery1.SQL.Text;
  SQLQuery1.Open;
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
  while not SQLQuery1.EOF do
  begin
    for i := 1 to high(Columns) do
    begin
      for j := 1 to high(Strings) do
      begin
        if (SQLQuery1.FieldByName(STRCOL).AsString = Columns[i]) and
          (SQLQuery1.FieldByName(STRROW).AsString = Strings[j]) then
        begin
          Cells[i][j].FCount += 1;
        end;
      end;
    end;
    SQLQuery1.Next;
  end;
  //SQLbuf := SQLQuery1.SQL.Text;
  //SQLQuery1.Close;
  //SQLQuery1.SQL.Text := SQLbuf;
  //SQLQuery1.Open;
  SQLQuery1.First;

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
          buf := SQLQuery1.FieldByName(
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
          SQLQuery1.FieldByName(DataTables.FTables[8].TabUniqueF).AsInteger;
        SQLQuery1.Next;
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
        FSQL := SQLQuery1.SQL.Text;
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
  SQLQuery1.Close;


  DrawGrid1.RowCount := length(Strings);
  DrawGrid1.ColCount := length(Columns);
  with DrawGrid1 do
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
    DrawGrid1.Repaint;
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

procedure TTimeTableForm.MenuItem1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    if SaveDialog1.FilterIndex = 1 then
    begin
      SaveHTMl(Utf8ToAnsi(SaveDialog1.FileName));
    end;
    if SaveDialog1.FilterIndex = 2 then
    begin
      SaveXLS(Utf8ToAnsi(SaveDialog1.FileName));
    end;
  end;
end;

procedure TTimeTableForm.ParametersBoxItemClick(Sender: TObject; Index: integer);
begin
  // ExecuteBut.Click;
end;

procedure TTimeTableForm.DrawGrid1DragDrop(Sender, Source: TObject; X, Y: integer);
var
  i: integer;
  Str: string;
  aCol, aRow: integer;
begin
  //if not FlagForDrag then
  //begin
  //  exit;
  //end;
  Str := '';
  DrawGrid1.MouseToCell(X, Y, aCol, aRow);
  //aCol := aCol -1; aRow := aRow - 1;
  if (aCol <= 0) or (aRow <= 0) then
  begin
    FlagForDrag := False;
    exit;
  end;
  if RowsBox.ItemIndex = ColumnsBox.ItemIndex then
  begin
    FlagForDrag := False;
    exit;
  end;
  with CellForDrag do
  begin
    for i := 0 to high(FRecords) do
    begin
      try
        Str := '';
        SQLQuery1.Close;
        Str += 'UPDATE ' + DataTables.FTables[8].TabDBName + ' SET ' +
          'Schedules' + '.' + TStringList(RowsBox.Items.Objects[RowsBox.ItemIndex]).Strings[2] + ' = ' + DBStrings[aRow - 1] + ', Schedules' + '.' +
          TStringList(ColumnsBox.Items.Objects[ColumnsBox.ItemIndex]).Strings[2] +
          ' = ' + DBColumns[aCol - 1] + ' WHERE Schedules.RECORDID = ' +
          IntToStr(FRecords[i].FID);
        SQLQuery1.SQL.Text := Str;
        SQLQuery1.ExecSQL;
        DBConnectionMod.SQLTransaction.Commit;
      except
        on E: EDatabaseError do
        begin
          //ShowMessage(E.ToString);
          SQLQuery1.Close;
          Str := '';
          Str += 'UPDATE ' + DataTables.FTables[8].TabDBName + ' SET ' +
            'Schedules' + '.' + TStringList(
            RowsBox.Items.Objects[RowsBox.ItemIndex]).Strings[2] +
            ' = ' + DBColumns[aRow - 1] + ', Schedules' + '.' +
            TStringList(ColumnsBox.Items.Objects[ColumnsBox.ItemIndex]).Strings[2] +
            ' = ' + DBStrings[aCol - 1] + ' WHERE Schedules.RECORDID = ' +
            IntToStr(FRecords[i].FID);
          SQLQuery1.SQL.Text := Str;
          SQLQuery1.ExecSQL;
          DBConnectionMod.SQLTransaction.Commit;
        end;
      end;
      //ShowMessage(SQLQuery1.SQL.Text);
    end;
    ExecuteBut.Click;
    FlagForDrag := False;
  end;
end;

procedure TTimeTableForm.DrawGrid1DragOver(Sender, Source: TObject;
  X, Y: integer; State: TDragState; var Accept: boolean);
var
  aCol, aRow: integer;
begin
  DrawGrid1.MouseToCell(X, Y, aCol, aRow);
  if (aCol = 0) or (aRow = 0) then
  begin
    FlagForDrag := False;
    exit;
  end;
  //if RowsBox.ItemIndex = ColumnsBox.ItemIndex then
  //begin
  //  FlagForDrag:=False;
  //  exit;
  //end;
  if length(Cells[aCol][aRow].FRecords) = 0 then
  begin
    //CellForDrag := TCell.Create;
    //CellForDrag := Cells[aCol][aRow];
    FlagForDrag := False;
    exit;
  end;
  CellForDrag := TCell.Create;
  CellForDrag := Cells[aCol][aRow];
  FlagForDrag := True;
end;

procedure TTimeTableForm.DrawGrid1DrawCell(Sender: TObject;
  aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
var
  i, j, k: integer;
begin
  if Draw then
  begin
    if (acol = 0) and (aRow > 0) and (aRow <= high(Strings)) then
    begin
      DrawGrid1.Canvas.TextOut(ARect.Left + 1, ARect.Top + 1, Strings[aRow]);
    end;
    if (aRow = 0) and (aCol > 0) and (aCol <= high(Columns)) then
    begin
      DrawGrid1.Canvas.TextOut(Arect.Left + 1, Arect.Top + 1, Columns[aCol]);
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
      with DrawGrid1.Canvas do
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

procedure TTimeTableForm.DrawGrid1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
var
  aCol, aRow, i, j: integer;
  Str: string;
begin
  if Draw then
  begin
    DrawGrid1.MouseToCell(X, Y, aCol, aRow);
    if (aCol = 0) or (aRow = 0) then
    begin
      DrawGrid1.Hint := '';
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
      DrawGrid1.Hint := Str;
    end;
  end;
end;

procedure TTimeTableForm.DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  i, j: integer;
  APoint: TPoint;
  aRow, aCol: integer;
begin
  DrawGrid1.MouseToCell(X, Y, aCol, aRow);
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
        FButtons[i].OnClick(Self, DrawGrid1, aRow, Cells[aCol][aRow].FHeight,
          SQLQuery1, DataTables.FTables[8], 0, Columns[aCol],
          Strings[aRow], ColumnsBox.ItemIndex, RowsBox.ItemIndex, ChildFirstFrame1);
      end;
    end;
    for i := 0 to high(FRecords) do
    begin
      for j := 0 to high(FRecords[i].FButtons) do
      begin
        if PtInRect(Frecords[i].FButtons[j].FRect, APoint) then
        begin
          SQLQuery1.Close;
          SQLQuery1.SQL.Text := Cells[aCol][aRow].FSQL;
          SQLQuery1.Open;
          while SQLQuery1.FieldByName(DataTables.FTables[8].TabUniqueF).AsInteger <>
            FRecords[i].FID do
          begin
            SQLQuery1.Next;
          end;
          FRecords[i].FButtons[j].OnClick(Self, DrawGrid1, aRow,
            Cells[aCol][aRow].FHeight,
            SQLQuery1, DataTables.FTables[8], FRecords[i].FID,
            Columns[aCol], Strings[aRow], ColumnsBox.ItemIndex,
            RowsBox.ItemIndex, ChildFirstFrame1);
          SQLQuery1.Close;
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
  //ChildFirstFrame1.Parent.Tag := 8;
  RowsBox.ItemIndex := 0;
  ColumnsBox.ItemIndex := 0;
  SortBox.ItemIndex := 0;
  //SortOrderBox.ItemIndex := 0;
  //ExecuteBut.Click;
end;



procedure TTimeTableForm.PairSplitter1ChangeBounds(Sender: TObject);
begin

end;

procedure TTimeTableForm.FillArr(ASQLQuery: TSQLQuery; ACBox: TComboBox;
  var AArr: TArrStr; var AarrDB: TArrStr);
begin
  ASQLQuery.Close;
  ASQLQuery.SQl.Text := 'SELECT ' + ' * ' +
    //TStringList(ACBox.Items.Objects[ACBox.ItemIndex]).Strings[1] +
    //'.' + TStringList(ACBox.Items.Objects[ACBox.ItemIndex]).Strings[0] +
    ' FROM ' + DataTables.FTables[SchTabInd].TabFields[ACBox.ItemIndex].FieldTabNForJoin
    + ' ORDER BY ' + DataTables.FTables[SchTabInd].TabFields[
    ACBox.ItemIndex].FieldTabNForJoin + '.' +
    DataTables.FTables[SchTabInd].TabFields[ACBox.ItemIndex].FieldFNForJoin;
  //ShowMessage(ASQLQuery.SQl.Text);
  //Edit1.Text := ASQLQuery.SQl.Text;
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
    //for i := 1 to high(Cells) do
    //begin
    //  Count := 0;
    //  for j := 1 to high(Cells[i]) do
    //  begin
    //    if Cells[i][j].FHeight <= 10 then
    //    begin
    //      Count += 1;
    //    end;
    //    ShowMessage(IntToStr(Count) + ' ' + IntToStr(length(Cells[i]) - 1));
    //    if Count = length(Cells[i]) - 1 then
    //    begin
    //      //ShowMessage(IntToStr(Count) + ' ' + IntToStr(length(Cells[i])));
    //    end;
    //  end;
    //end;
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
           // '      </TR>'#10
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
  for i := 1 to high(Strings) do
  begin
    //TimeTable.WriteUTF8Text(i, 0, Strings[i]);
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
      //WriteBorder, options :=
      //BufStr += #10;
      //BufStr += ' ';
      //TimeTable.WriteUTF8Text(i, j, BufStr);
      //TimeTable.WriteWordwrap(i, j, true);
      TimeTable.WriteColWidth(j, 25);
      if LittleCount > MaxCount then
      begin
        MaxCount := LittleCount;
      end;
    end;
    TimeTable.MergeCells(i + BigCount, 0, i + MaxCount + BigCount, 0);
    TimeTable.WriteUTF8Text(i + BigCount, 0, Strings[i]);
    TimeTable.WriteVertAlignment(i + BigCount, 0, vaCenter);;
    //TimeTable.WriteRowHeight(i, 25);
  end;
  //TimeTable.MergeCells(0 , 0, 0 + 5, 0);
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
end;

end.


{procedure JDLSK;

begin
  if SaveDialog.Execute then
  begin
    MyFile := TsWorkbook.Create();
    MyFile.SetDefaultFont('Calibri', 9);
    MyFile.UsePalette(@PALETTE_BIFF8, Length(PALETTE_BIFF8));
    MyFile.FormatSettings.CurrencyFormat := 2;
    MyFile.FormatSettings.NegCurrFormat := 14;
    MyFile.Options := MyFile.Options + [boCalcBeforeSaving];

    Sheet := MyFile.AddWorksheet('Расписание');
    Sheet.Options := Sheet.Options + [soHasFrozenPanes];
    Sheet.LeftPaneWidth := 1;
    Sheet.TopPaneHeight := 1;
    //Sheet.Options := Sheet.Options - [soShowGridLines];
    for i := 1 to HValues.Count do
      Sheet.WriteColWidth(i, 52);
    Sheet.WriteColWidth(0, Wspace div 6 + 1);

    SmallIndent := 0;
    MaxIndent := 0;
    LargeIndent := 0;

    for i := 0 to HValues.Count - 1 do
      Sheet.WriteUTF8Text(0, i + 1, HValues[i]);

    for i := 0 to High(Cells) do
    begin
      LargeIndent += MaxIndent;
      MaxIndent := 0;
      for j := 0 to High(Cells[i]) do
      begin
        SmallIndent := 0;
        Sheet.WriteBorders(i + 1 + LargeIndent, j + 1, [cbEast, cbWest, cbNorth]);
        for k := 0 to High(Cells[i][j].Data) do
        begin
          Temp := '';
          for t := 0 to Cells[i][j].Data[k].Values.Count - 1 do
            Temp += Cells[i][j].Data[k].Values[t] + #10;

          Sheet.WriteWordwrap(i + 1 + SmallIndent + LargeIndent, j + 1, True);
          Sheet.WriteUTF8Text(i + 1 + SmallIndent + LargeIndent, j + 1, Temp);
          Sheet.WriteBorders(i + 2 + SmallIndent + LargeIndent, j + 1, [cbEast, cbWest]);
          Inc(SmallIndent);
        end;
        Sheet.WriteBorders(i + 1 + SmallIndent + LargeIndent, j + 1,
          [cbNorth]);
        if MaxIndent < SmallIndent then
          MaxIndent := SmallIndent - 1;
      end;
      Sheet.MergeCells(i + 1 + LargeIndent, 0, i + 1 + LargeIndent + MaxIndent, 0);
      Sheet.WriteUTF8Text(i + 1 + LargeIndent, 0, VValues[i]);
      Sheet.WriteVertAlignment(i + 1 + LargeIndent, 0, vaCenter);
    end;
    //for i := 0 to LargeIndent do
    // Sheet.WriteBorders(i,0,[cbEast,cbNorth,cbSouth,cbWest]);
    MyFile.WriteToFile(SaveDialog.FileName, sfExcel8, True);
  end;
end;}


















