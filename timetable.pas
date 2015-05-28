unit TimeTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Grids, StdCtrls, PairSplitter, CheckLst, DBConnection, Meta, MyBut,
  ChildFirstFrame, Windows, Buttons;

type

  { TMyRecord }

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
    procedure AddRecord;
    procedure AddButton(AButton: TMyButton);
  end;

  TMyStringList = class(TStringList)
  public
    ArrButtons: array of TButtonAdd;
  end;

  { TTimeTableForm }

  TTimeTableForm = class(TForm)
    Button1: TButton;
    CheckListBox1: TCheckListBox;
    ChildFirstFrame1: TChildFirstFrame;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    DataSource1: TDataSource;
    DrawGrid1: TDrawGrid;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ScrollBox1: TScrollBox;
    SQLQuery1: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure CheckListBox1ItemClick(Sender: TObject; Index: integer);
    procedure DrawGrid1DrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGrid1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure FormCreate(Sender: TObject);
    procedure PairSplitter1ChangeBounds(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Columns: array of string;
    Strings: array of string;
    Cells: array of array of TCell;
    //MyButtons: array of array of TButtonAdd;
    Flag: boolean;
    AdditionalFields: array of string;
    LastTopForButtons: integer;
  end;

{ TMyStringList }



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

procedure TTimeTableForm.Button1Click(Sender: TObject);
var
  ARect: TRect;
  i, j, k, l, h: integer;
  buf, SQLbuf: string;
  LocalFlag: boolean = True;
begin
  //Нужно для совпадения номеров клеток
  SetLength(Strings, 1);
  SetLength(Columns, 1);
  SetLength(Cells, 1);


  //Заполняю строки
  SQLQuery1.Close;
  SQLQuery1.SQl.Text := 'SELECT ' +
    TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[1] +
    '.' + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[0] +
    ' FROM ' + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[1];
  SQLQuery1.Open;
  while not SQLQuery1.EOF do
  begin
    SetLength(Strings, length(Strings) + 1);
    Strings[high(Strings)] :=
      SQLQuery1.FieldByName(TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[0]).AsString;
    SQLQuery1.Next;
  end;
  SQLQuery1.Close;


  //Заполняю столбцы
  SQLQuery1.SQl.Text := 'SELECT ' +
    TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[1] +
    '.' + TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[0] +
    ' FROM ' + TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[1];
  SQLQuery1.Open;
  while not SQLQuery1.EOF do
  begin
    SetLength(Columns, length(Columns) + 1);
    Columns[high(Columns)] :=
      SQLQuery1.FieldByName(TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[0]).AsString;
    SQLQuery1.Next;
  end;
  SQLQuery1.Close;



  for i := 1 to high(Columns) do
  begin
    SetLength(Cells, length(Cells) + 1);
    SetLength(Cells[high(Cells)], 1);
    for j := 1 to high(Strings) do
    begin
      SQLQuery1.Close;
      SetLength(Cells[high(Cells)], length(Cells[high(Cells)]) + 1);
      SQLQuery1.SQL.Text := 'SELECT * FROM SCHEDULES';
      for l := 0 to CheckListBox1.Count - 1 do
      begin
        SQLbuf := SQLQuery1.SQL.Text;
        SQLbuf += ' INNER JOIN ' + TStringList(CheckListBox1.Items.Objects[l]).Strings[1] + ' ON SCHEDULES.' + TStringList(CheckListBox1.Items.Objects[l]).Strings[2] +
          ' = ' + TStringList(CheckListBox1.Items.Objects[l]).Strings[1] +
          '.' + TStringList(CheckListBox1.Items.Objects[l]).Strings[2];
        SQLQuery1.SQL.Text := SQLbuf;
      end;
      SQLbuf := SQLQuery1.SQL.Text;
      SQLbuf += ' WHERE ' + TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[0] + ' = ''' + Columns[i] + ''' AND ' +
        TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[0] +
        ' = ''' + Strings[j] + ''' ' + ' ORDER BY ' +
        TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[1] +
        '.' + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[0] +
        ' , ' + TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[1] +
        '.' + TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[0];
      SQLQuery1.SQL.Text := SQLbuf;
      SQLQuery1.Open;

      Cells[high(Cells)][high(Cells[high(Cells)])] := TCell.Create;

      while not SQLQuery1.EOF do
      begin
        Cells[high(Cells)][high(Cells[high(Cells)])].AddRecord;
        with Cells[high(Cells)][high(Cells[high(Cells)])] do
        begin
          FRecords[high(Frecords)].FData := TStringList.Create;
        end;

        for k := 0 to high(DataTables.FTables[8].TabFields) - 1 do
        begin
          LocalFlag := True;
          for h := 0 to CheckListBox1.Count - 1 do
          begin
            if (DataTables.FTables[8].TabFields[k].FieldFNForSel =
              TStringList(CheckListBox1.Items.Objects[h]).Strings[0]) and
              (CheckListBox1.Checked[h] = False) then
            begin
              LocalFlag := False;
            end;
          end;
          if not LocalFlag then
          begin
            Continue;
          end;
          buf := SQLQuery1.FieldByName(
            DataTables.FTables[8].TabFields[k].FieldFNForSel).AsString;
          with Cells[high(Cells)][high(Cells[high(Cells)])] do
          begin
            FRecords[high(Frecords)].FData.Add(buf);
          end;
        end;
        with Cells[high(Cells)][high(Cells[high(Cells)])] do
        begin
          Frecords[high(Frecords)].FID := SQLQuery1.FieldByName(DataTables.FTables[8].TabUniqueF).AsInteger;
        end;

        with Cells[high(Cells)][high(Cells[high(Cells)])] do
        begin
          FRecords[high(FRecords)].AddButton(TButtonChange.Create);
        end;

        SQLQuery1.Next;
      end;
      Cells[high(Cells)][high(Cells[high(Cells)])].AddButton(TButtonChHeight.Create);
      Cells[high(Cells)][high(Cells[high(Cells)])].AddButton(TButtonAdd.Create);
      Cells[high(Cells)][high(Cells[high(Cells)])].AddButton(TButttonShowOnLV.Create);
      Cells[high(Cells)][high(Cells[high(Cells)])].FSQL := SQLQuery1.SQL.Text;
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
  DrawGrid1.DefaultRowHeight := 150;
  DrawGrid1.DefaultColWidth := 150;
  DrawGrid1.RowHeights[0] := 25;
  DrawGrid1.ColWidths[0] := 50;
  Flag := True;
end;

procedure TTimeTableForm.CheckListBox1ItemClick(Sender: TObject; Index: integer);
var
  i, j: integer;
begin
end;

procedure TTimeTableForm.DrawGrid1DrawCell(Sender: TObject;
  aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
var
  i, j, CounterOffset, k: integer;
  LocalFlag: boolean = False;
begin
  if Flag then
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
    {and (aRow <= high(Cells)) and (aCol <= high(Cells[aRow]))} then
    begin
      LastTopForButtons := 0;
      for i := 0 to CheckListBox1.Count - 1 do
      begin
        if CheckListBox1.Checked[i] then
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
            end;
            for k := 0 to high(FButtons) do
            begin
              Draw(
                Arect.Right - 16 - 17*k, ARect.Top + 1 + (j + 1) * 20 +
                LastTopForButtons * i, FButtons[k].Icon
                );
              FButtons[k].RefreshRect(
                ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i,
                ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i + 16,
                Arect.Right - 16 - 17*k,
                Arect.Right - 17*k
                );
            end;
          end;
          with Cells[aCol][aRow] do
          begin
            for k := 0 to high(FButtons) do
            begin
              Draw(Arect.Right - 16 - 17*k, Arect.Top + 1, FButtons[k].Icon);
              FButtons[k].RefreshRect(aRect.Top + 1, aRect.Top + 1 + 16, aRect.Right - 16 - 17*k, aRect.Right - 17*k);
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
  if Flag then
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
  i, j, k: integer;
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
        //SQLQuery1.Close;
        FButtons[i].OnClick(Self, DrawGrid1, aRow, Cells[aCol][aRow].FHeight,
          SQLQuery1, DataTables.FTables[8], 0);
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
          while SQLQuery1.FieldByName(DataTables.FTables[8].TabUniqueF).AsInteger <> FRecords[i].FID do
          begin
            SQLQuery1.Next;
          end;
          FRecords[i].FButtons[j].OnClick(Self, DrawGrid1, aRow, Cells[aCol][aRow].FHeight,
            SQLQuery1, DataTables.FTables[8], FRecords[i].FID);
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
  Flag := False;
  for i := 0 to high(DataTables.FTables[8].TabFields) - 1 do
  begin
    SetLength(Str, length(Str) + 1);
    SetLength(AdditionalFields, length(AdditionalFields) + 1);
    AdditionalFields[high(AdditionalFields)] :=
      DataTables.FTables[8].TabFields[i].FieldFNForSel;
    Str[high(Str)] := TStringList.Create;
    Str[high(Str)].Add(DataTables.FTables[8].TabFields[i].FieldFNForSel);
    Str[high(Str)].Add(DataTables.FTables[8].TabFields[i].FieldTabNForJoin);
    Str[high(Str)].Add(DataTables.FTables[8].TabFields[i].FieldFNForJoin);
    ComboBox1.Items.AddObject(DataTables.FTables[8].TabFields[i].FieldAppName,
      Str[high(Str)]);
    ComboBox2.Items.AddObject(DataTables.FTables[8].TabFields[i].FieldAppName,
      Str[high(Str)]);
    CheckListBox1.AddItem(DataTables.FTables[8].TabFields[i].FieldAppName,
      Str[high(Str)]);
  end;
  CheckListBox1.CheckAll(cbChecked);
  ChildFirstFrame1.ExecuteBFrLV := TBitBtn.Create(Self);
  ComboBox1.ItemIndex := 0;
  ComboBox2.ItemIndex := 0;

end;

procedure TTimeTableForm.PairSplitter1ChangeBounds(Sender: TObject);
begin

end;

end.
