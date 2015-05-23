unit TimeTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Grids, StdCtrls, PairSplitter, CheckLst, DBConnection, Meta, MyBut;

type

  { TTimeTableForm }

  { TMyStringList }
  TMyStringList = class(TStringList)
    public
      ArrButtons: array of TButtonAdd;
  end;

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
    procedure FormCreate(Sender: TObject);
    procedure PairSplitter1ChangeBounds(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Columns: array of string;
    Strings: array of string;
    Cells: array of array of TMyStringList;
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

{ TTimeTableForm }

procedure TTimeTableForm.Button1Click(Sender: TObject);
var
  ARect: TRect;
  i, j, k, l, h: integer;
  buf, SQLbuf: string;
  LocalFlag: boolean = True;
  But: TButtonAdd;
begin
  SQLQuery1.Close;
  SQLQuery1.SQl.Text := 'SELECT ' +
    TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[1] +
    '.' + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[0] +
    ' FROM ' + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[1];
  SQLQuery1.Open;
  SetLength(Strings, 1);
  SetLength(Columns, 1);
  SetLength(Cells, 1);
  //SetLength(MyButtons, 1);
  while not SQLQuery1.EOF do
  begin
    SetLength(Strings, length(Strings) + 1);
    Strings[high(Strings)] :=
      SQLQuery1.FieldByName(TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[0]).AsString;
    SQLQuery1.Next;
  end;
  SQLQuery1.Close;
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
    //SetLength(MyButtons, length(MyButtons) + 1);
    //SetLength(MyButtons[high(MyButtons)], 1);
    for j := 1 to high(Strings) do
    begin
      SQLQuery1.Close;
      SetLength(Cells[high(Cells)], length(Cells[high(Cells)]) + 1);
      SQLQuery1.SQL.Text := 'SELECT * FROM SCHEDULES';
      for l := 0 to CheckListBox1.Count - 1 do
      begin
        SQLbuf := SQLQuery1.SQL.Text;
        SQLbuf += ' INNER JOIN ' + TStringList(CheckListBox1.Items.Objects[l]).Strings[1] + ' ON SCHEDULES.' +
          TStringList(CheckListBox1.Items.Objects[l]).Strings[2] + ' = ' +
          TStringList(CheckListBox1.Items.Objects[l]).Strings[1] +
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
      Cells[high(Cells), high(Cells[high(Cells)])] := TMyStringList.Create;

      while not SQLQuery1.EOF do
      begin
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
            Continue;
          buf := SQLQuery1.FieldByName(
            DataTables.FTables[8].TabFields[k].FieldFNForSel).AsString;
          Cells[high(Cells), high(Cells[high(Cells)])].Add(buf);
        end;
        Cells[high(Cells), high(Cells[high(Cells)])].Add('------');
        But := TButtonAdd.Create;
        But.Offset := Cells[high(Cells)][high(Cells[high(Cells)])].Count-1;
        //But.Left := high(MyButtons)*10;
        with Cells[high(Cells)][high(Cells[high(Cells)])] do
        begin
          SetLength(ArrButtons, length(ArrButtons) + 1);
          ArrButtons[high(ArrButtons)] := But;
        end;
        //MyButtons[high(MyButtons), high(MyButtons[high(MyButtons)])] := But;
        SQLQuery1.Next;
      end;
    end;
  end;
  SQLQuery1.Close;
  DrawGrid1.RowCount := length(Strings);
  DrawGrid1.ColCount := length(Columns);
  DrawGrid1.DefaultRowHeight := 30;
  DrawGrid1.DefaultColWidth := 80;
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
  LocalFlag: Boolean = False;
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
      if Cells[aCol, aRow].Count = 0 then
        exit;
      for i := 0 to Cells[aCol, aRow].Count - 1 do
      begin
        begin
          DrawGrid1.Canvas.TextOut(Arect.Left + 1, Arect.Top + 1 + i * 20,
            Cells[aCol, aRow].Strings[i]);
          //if (Cells[aCol, aRow].Strings[i] = '------') and (not LocalFlag) then
          //DrawGrid1.Canvas.Draw();
        end;
      end;
      CounterOffset := 0;
      for i := 0 to CheckListBox1.Count - 1 do
      begin
        if CheckListBox1.Checked[i] then
        begin
          CounterOffset += 1;
        end;
      end;
      DrawGrid1.Canvas.Draw(aRect.Right - 16, aRect.Top, Cells[aCol][aRow].ArrButtons[0].Icon);
      for i := 0 to high(Cells[aCol][aRow].ArrButtons) do
      begin
        LastTopForButtons := aRect.Top +  CounterOffset*20;
        DrawGrid1.Canvas.Draw(aRect.Right - 16, aRect.Top +  Cells[aCol][aRow].ArrButtons[i].Offset*20, Cells[aCol][aRow].ArrButtons[i].Icon);
      end;
    end;
    DrawGrid1.DefaultColWidth := 100;
    DrawGrid1.DefaultRowHeight := 100;
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
