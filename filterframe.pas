unit FilterFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Dialogs,
  Meta, MyFrame;

type

  TBaseParentFrame = class(TMyFrame)
    OperationBox: TComboBox;
    FieldNameBox: TComboBox;
    STRValue: TEdit;
    SQLOperations: TStringList;
    constructor Create(TheOwner: TComponent); override;
  private
    TableDBName: string;
  end;

implementation

{$R *.lfm}

constructor TBaseParentFrame.Create(TheOwner: TComponent);
begin
  Tag := TheOwner.Tag;
  inherited Create(TheOwner);
  Parent := TWinControl(TheOwner);
  TableDBName := DataTables.FTables[tag].TabDBName;
  AddFiltersInfo(DataTables.FTables[tag], FieldNameBox);
  SQLOperations := TStringList.Create;

  SQLOperations.Add('=');
  SQLOperations.Add('<');
  SQLOperations.Add('>');
  SQLOperations.Add('<>');
  SQLOperations.Add(' LIKE ');
  SQLOperations.Add(' LIKE ');
end;

{procedure sldjfh;
begin
  for i := 0 to High(Cells) do
  begin
    LargeCount += MaxCount;
    MaxCount := 0;
    for j := 0 to High(Cells[i]) do
    begin
      SmallCount := 0;
      Sheet.WriteBorders(i + 1 + SmallCount + LargeCount, j + 1,
        [cbNorth, cbEast, cbWest]);
      for k := 0 to High(Cells[i][j].Data) do
      begin
        Temp := '';
        for t := 0 to Cells[i][j].Data[k].Values.Count - 1 do
        begin
          //Dif := i + 1 + SmallCount + LargeCount;
          Temp += Cells[i][j].Data[k].Values[t] + #10;
        end;
        //ShowMessage(Temp);
        Sheet.WriteWordwrap(i + 1 + SmallCount + LargeCount, j + 1, True);
        Sheet.WriteUTF8Text(i + 1 + SmallCount + LargeCount, j + 1, Temp);
        Sheet.WriteBorders(i + 1 + SmallCount + LargeCount,
          j + 1, [cbEast, cbWest]);
        Inc(SmallCount);
      end;
      //Inc(SmallCount);
      Sheet.WriteBorders(i + SmallCount + LargeCount, j + 1,
        Sheet.GetCell(i + SmallCount + LargeCount, j + 1)^.Border[cbWest]);
      if MaxCount < SmallCount then
        MaxCount := SmallCount;
      //Sheet.WriteWordwrap(i + 1, j + 1, True);
      //Sheet.WriteUTF8Text(i + 1, j + 1, Temp);
      //Sheet.WriteCellValueAsString(i+1,j+1, Temp);
      //Sheet.writeu
      //Sheet.WriteUsedFormatting(i + 1, j + 1, [uffWordWrap]);
    end;
    Sheet.MergeCells(i + LargeCount, 0, i + LargeCount + MaxCount, 0);
    Sheet.WriteUTF8Text(i + LargeCount, 0, VValues[i]);
    Sheet.WriteVertAlignment(i + LargeCount, 0, vaCenter);
  end;
end;             }
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

end.
