unit TimeTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Grids, StdCtrls, PairSplitter, CheckLst, DBConnection, Meta, MyBut,
  ChildFirstFrame, Windows, Buttons, SQLcreating;

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
    CheckListBox2: TCheckListBox;
    ChildFirstFrame1: TChildFirstFrame;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    DataSource1: TDataSource;
    DrawGrid1: TDrawGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Lable1: TLabel;
    Lable2: TLabel;
    Edit1: TEdit;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ScrollBox1: TScrollBox;
    SQLQuery1: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure CheckListBox1ItemClick(Sender: TObject; Index: integer);
    procedure CheckListBox2ItemClick(Sender: TObject; Index: integer);
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
    Flag: boolean;
    AdditionalFields: array of string;
    LastTopForButtons: integer;
    CellForDrag: TCell;
    FlagForDrag: boolean;
  end;



{ TMyStringList }



var
  TimeTableForm: TTimeTableForm;

implementation

{$R *.lfm}

{ TMyRecord }

procedure EditClean(Edit: TEdit);
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
  i, j, k, l, h, c: integer;
  buf, SQLbuf: string;
  LocalFlag: boolean = True;
  STRCOL, STRROW: string;
begin
  //Нужно для совпадения номеров клеток
  SetLength(Strings, 1);
  SetLength(Columns, 1);

  FillArr(SQLQuery1, ComboBox2, Columns, DBColumns);
  FillArr(SQLQuery1, ComboBox1, Strings, DBStrings);


  SQLQuery1.SQL.Text := 'SELECT * FROM SCHEDULES';
  for l := 0 to CheckListBox1.Count - 1 do
  begin
    SQLbuf := SQLQuery1.SQL.Text;
    SQLbuf += ' INNER JOIN ' + TStringList(CheckListBox1.Items.Objects[l]).Strings[1] +
      ' ON SCHEDULES.' + TStringList(CheckListBox1.Items.Objects[l]).Strings[2] +
      ' = ' + TStringList(CheckListBox1.Items.Objects[l]).Strings[1] +
      '.' + TStringList(CheckListBox1.Items.Objects[l]).Strings[2];
    SQLQuery1.SQL.Text := SQLbuf;
  end;
  SQLbuf := SQLQuery1.SQL.Text;
  SQLbuf += ' ' + SQLCreateQueryFTT(ChildFirstFrame1);
  SQLbuf += ' ORDER BY ' + TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[1]
  + '.' + TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[3] + ' , '
  + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[1] + '.'
  + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[3] + ' , '
  + TStringList(ComboBox3.Items.Objects[ComboBox3.ItemIndex]).Strings[1] + '.'
  + TStringList(ComboBox3.Items.Objects[ComboBox3.ItemIndex]).Strings[3];


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


  STRCOl := TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[0];
  STRROW := TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[0];
  while not SQLQuery1.EOF do
  begin
    for i := 1 to high(Columns) do
    begin
      for j := 1 to high(Strings) do
      begin
        //ShowMessage(Strings[i] +' ' + Columns[j]);
        //ShowMessage(SQLQuery1.FieldByName(STRCOL).AsString + ' ' + SQLQuery1.FieldByName(STRROW).AsString);
        if (SQLQuery1.FieldByName(STRCOL).AsString = Columns[i]) and
          (SQLQuery1.FieldByName(STRROW).AsString = Strings[j]) then
        begin
          Cells[i][j].FCount += 1;
        end;
      end;
    end;
    SQLQuery1.Next;
  end;
  SQLbuf := SQLQuery1.SQL.Text;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := SQLbuf;
  SQLQuery1.Open;

  for i := 1 to high(Cells) do
  begin
    for j := 1 to high(Cells[i]) do
    begin
      for k := 0 to Cells[i][j].FCount - 1 do
      begin
        Cells[i][j].AddRecord;
        Cells[i][j].FRecords[high(Cells[i][j].FRecords)].FData := TStringList.Create;
        for l := 0 to high(DataTables.FTables[8].TabFields) - 1 do
        begin
          LocalFlag := True;
          for h := 0 to CheckListBox1.Count - 1 do
          begin
            if (DataTables.FTables[8].TabFields[l].FieldFNForSel =
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
            DataTables.FTables[8].TabFields[l].FieldFNForSel).AsString;
          with Cells[i][j] do
          begin
            if CheckListBox2.Checked[0] then
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
        ;
        SQLQuery1.Next;
      end;
      for c := 0 to Cells[i][j].FCount - 1 do
      begin
        with Cells[i][j] do
        begin
          FRecords[c].AddButton(TButtonChange.Create);
          FRecords[c].AddButton(TButtonDelete.Create);
          //Frecords[c].FID :=
          //  SQLQuery1.FieldByName(DataTables.FTables[8].TabUniqueF).AsInteger;
        end;
      end;
      Cells[i][j].AddButton(TButtonChHeight.Create);
      Cells[i][j].AddButton(TButtonAdd.Create);
      Cells[i][j].AddButton(TButttonShowOnLV.Create);
      Cells[i][j].FSQL := SQLQuery1.SQL.Text;
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
  DrawGrid1.Repaint;
end;

procedure TTimeTableForm.CheckListBox1ItemClick(Sender: TObject; Index: integer);
var
  i, Count: integer;
begin
  Count := 0;
  for i := 0 to CheckListBox1.Count - 1 do
  begin
    if not CheckListBox1.Checked[i] then
    begin
      Count += 1;
    end;
  end;
  if Count = CheckListBox1.Count then
  begin
    CheckListBox1.Checked[Index] := True;
  end;
  Button1.Click;
end;

procedure TTimeTableForm.CheckListBox2ItemClick(Sender: TObject; Index: integer);
begin
  Button1.Click;
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
  if ComboBox1.ItemIndex = ComboBox2.ItemIndex then
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
        'Schedules' + '.' + TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[2] + ' = ' + DBStrings[aRow - 1] + ', Schedules' + '.' +
        TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[2] +
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
            'Schedules' + '.' +
            TStringList(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Strings[2] +
            ' = ' + DBColumns[aRow - 1] + ', Schedules' + '.' +
            TStringList(ComboBox2.Items.Objects[ComboBox2.ItemIndex]).Strings[2] +
            ' = ' + DBStrings[aCol - 1] + ' WHERE Schedules.RECORDID = ' +
            IntToStr(FRecords[i].FID);
          SQLQuery1.SQL.Text := Str;
          SQLQuery1.ExecSQL;
          DBConnectionMod.SQLTransaction.Commit;
        end;
      end;
      //ShowMessage(SQLQuery1.SQL.Text);
    end;
    Button1.Click;
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
  //if ComboBox1.ItemIndex = ComboBox2.ItemIndex then
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
    {and (aCol <= high(Cells)) and (aRow <= high(Cells[aRow]))} then
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
        //SQLQuery1.Close;
        FButtons[i].OnClick(Self, DrawGrid1, aRow, Cells[aCol][aRow].FHeight,
          SQLQuery1, DataTables.FTables[8], 0, Columns[aCol],
          Strings[aRow], ComboBox2.ItemIndex, ComboBox1.ItemIndex, ChildFirstFrame1);
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
            Columns[aCol], Strings[aRow], ComboBox2.ItemIndex,
            ComboBox1.ItemIndex, ChildFirstFrame1);
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
  Flag := False;
  FlagForDrag := False;
  for i := 0 to high(DataTables.FTables[8].TabFields) - 1 do
  begin
    SetLength(Str, length(Str) + 1);
    SetLength(AdditionalFields, length(AdditionalFields) + 1);
    AdditionalFields[high(AdditionalFields)] :=
      DataTables.FTables[8].TabFields[i].FieldFNForSel;
    Str[high(Str)] := TStringList.Create;
    with DataTables.FTables[8].TabFields[i] do
    begin
      with Str[high(Str)] do
      begin
        Add(FieldFNForSel);
        Add(FieldTabNForJoin);
        Add(FieldFNForJoin);
        Add(FieldForSort);
      end;
      ComboBox1.Items.AddObject(FieldAppName, Str[high(Str)]);
      ComboBox2.Items.AddObject(FieldAppName, Str[high(Str)]);
      ComboBox3.Items.AddObject(FieldAppName, Str[high(Str)]);
      CheckListBox1.AddItem(FieldAppName, Str[high(Str)]);
    end;
  end;
  CheckListBox1.CheckAll(cbChecked);
  ScrollBox1.Tag := 8;
  ChildFirstFrame1 := TChildFirstFrame.Create(ScrollBox1);
  with ChildFirstFrame1 do
  begin
    Left := 300;
    Top := 56;
    ExecuteBFrLV := TBitBtn.Create(Self);
  end;
  //ChildFirstFrame1.Parent.Tag := 8;
  ComboBox1.ItemIndex := 0;
  ComboBox2.ItemIndex := 0;
  ComboBox3.ItemIndex := 0;
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
    ' FROM ' + TStringList(ACBox.Items.Objects[ACBox.ItemIndex]).Strings[1] +
    ' ORDER BY ' + TStringList(ACBox.Items.Objects[ACBox.ItemIndex]).Strings[1] +
    '.' + TStringList(ACBox.Items.Objects[ACBox.ItemIndex]).Strings[3];
  //ShowMessage(ASQLQuery.SQl.Text);
  Edit1.Text := ASQLQuery.SQl.Text;
  ASQLQuery.Open;
  while not ASQLQuery.EOF do
  begin
    SetLength(AArr, length(AArr) + 1);
    AArr[high(AArr)] :=
      ASQLQuery.FieldByName(TStringList(ACBox.Items.Objects[ACBox.ItemIndex]).Strings[0]).AsString;

    SetLength(AarrDB, length(AarrDB) + 1);
    AarrDB[high(AarrDB)] := ASQLQuery.FieldByName(
      TStringList(ACBox.Items.Objects[ACBox.ItemIndex]).Strings[2]).AsString;
    ASQLQuery.Next;
  end;
  ASQLQuery.Close;
end;

end.
