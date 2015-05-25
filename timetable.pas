unit TimeTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Grids, StdCtrls, PairSplitter, CheckLst, DBConnection, Meta, MyBut, Windows;

type

  TMyRecord = class
    FData: TStringList;
    FAddButton: TButtonAdd;
    FChHeightButton: TButtonChHeight;
    FTop: integer;
  end;

  { TCell }

  TCell = class
  public
    Height: integer;
    FRecords: array of TMyRecord;
    procedure AddRecord;
  end;

  TMyStringList = class(TStringList)
  public
    ArrButtons: array of TButtonAdd;
  end;

  { TTimeTableForm }

  TTimeTableForm = class(TForm)
    Button1: TButton;
    CheckListBox1: TCheckListBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    DataSource1: TDataSource;
    DrawGrid1: TDrawGrid;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
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

{ TCell }

procedure TCell.AddRecord;
begin
  SetLength(FRecords, length(FRecords) + 1);
  FRecords[high(FRecords)] := TMyRecord.Create;
end;

{ TTimeTableForm }

procedure TTimeTableForm.Button1Click(Sender: TObject);
var
  ARect: TRect;
  i, j, k, l, h: integer;
  buf, SQLbuf: string;
  LocalFlag: boolean = True;
  //But: TButtonAdd;
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
      //ShowMessage(SQLQuery1.SQL.Text);
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
            //FRecords[high(Frecords)].FAddButton := TButtonAdd.Create;
          end;
        end;
        with Cells[high(Cells)][high(Cells[high(Cells)])] do
        begin
          FRecords[high(Frecords)].FAddButton := TButtonAdd.Create;
          FRecords[high(FRecords)].FChHeightButton := TButtonChHeight.Create;
          //FRecords[high(FRecords)].FTop := 40 * FRecords[high(FRecords)].FData.Count;
        end;
        SQLQuery1.Next;
      end;
    end;
  end;
  for i := 1 to high(Cells) do
  begin
    for j := 1 to high(Cells[i]) do
    begin
      Cells[i][j].Height := 0;
      for k := 0 to high(Cells[i][j].FRecords) do
      begin
        Cells[i][j].Height += 25 * Cells[i][j].FRecords[k].FData.Count;
      end;
    end;
  end;
  SQLQuery1.Close;
  DrawGrid1.RowCount := length(Strings);
  DrawGrid1.ColCount := length(Columns);
  DrawGrid1.DefaultRowHeight := 150;
  DrawGrid1.DefaultColWidth := 150;
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
  i, j, CounterOffset: integer;
  LocalFlag: boolean = False;
begin
  if Flag then
  begin
    if (acol = 0) and (aRow > 0) and (aRow <= high(Strings)) then
    begin
      DrawGrid1.Canvas.TextOut(ARect.Left + 1, ARect.Top + 1, Strings[aRow]);
      //DrawGrid1.RowHeights[aRow] := 20;
      //DrawGrid1.ColWidths[aCol] := 180;
    end;
    if (aRow = 0) and (aCol > 0) and (aCol <= high(Columns)) then
    begin
      DrawGrid1.Canvas.TextOut(Arect.Left + 1, Arect.Top + 1, Columns[aCol]);
      //DrawGrid1.RowHeights[aRow] := 50;
      //DrawGrid1.ColWidths[aCol] := 180;
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
            //TextOut(Arect.Left + 1, ARect.Top + 1 + (j + 1) * 20 +
              //LastTopForButtons * i, '-------');
            Draw(Arect.Right - 16, ARect.Top + 1 + (j + 1) * 20 +
              LastTopForButtons * i, FAddButton.Icon);
            Draw(Arect.Right - 33, ARect.Top + 1 + (j + 1) * 20 +
              LastTopForButtons * i, FChHeightButton.Icon);
            FAddButton.RefreshRect(
              ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i,
              ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i + 16,
              Arect.Right - 16,
              Arect.Right
              );
            FChHeightButton.RefreshRect(
              ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i,
              ARect.Top + 1 + (j + 1) * 20 + LastTopForButtons * i + 16,
              Arect.Right - 33,
              Arect.Right - 16
              );
          end;
        end;
        //DrawGrid1.DefaultColWidth := 180;
        //DrawGrid1.DefaultRowHeight := 180;
        //DrawGrid1.RowHeights[aRow] := 50;
        //DrawGrid1.ColWidths[aCol] := 180;
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
            Str +=  #10#13;
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
begin
  APoint.x := X;
  APoint.y := Y;

  for i := 1 to high(Cells) do
  begin
    for j := 1 to high(Cells[i]) do
    begin
      for k := 0 to high(Cells[i][j].FRecords) do
      begin
        if PtInRect(Cells[i][j].FRecords[k].FChHeightButton.FRect, APoint) then
        begin
          //ShowMessage(IntToStr(i) +' '+IntToStr(j));
          Cells[i][j].FRecords[k].FChHeightButton.OnClick(DrawGrid1, j ,Cells[i][j].Height);
          //DrawGrid1.RowHeights[i] := 200;
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
end;

procedure TTimeTableForm.PairSplitter1ChangeBounds(Sender: TObject);
begin

end;

end.
