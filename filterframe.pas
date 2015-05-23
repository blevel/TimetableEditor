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
    TableDBName: String;
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
  SQLOperations := TStringList.create;

  SQLOperations.Add('=');
  SQLOperations.Add('<');
  SQLOperations.Add('>');
  SQLOperations.Add('<>');
  SQLOperations.Add(' LIKE ');
  SQLOperations.Add(' LIKE ');
end;

end.

