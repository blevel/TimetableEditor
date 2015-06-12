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

end.
