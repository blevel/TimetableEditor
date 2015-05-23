unit MyFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Meta, StdCtrls;

type

  TMyFrame = class(TFrame)
    constructor Create(TheOwner: TComponent); override;
    procedure AddFiltersInfo(Table: TMyTableInf; CBox: TComboBox);
  end;

implementation

{$R *.lfm}

constructor TMyFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
end;

procedure TMyFrame.AddFiltersInfo(Table: TMyTableInf; CBox: TComboBox);
var
  i: integer;
begin
  with Table, CBox do
  begin
    Items.Clear;
    for i := 0 to high(TabFields) do
    begin
      with TabFields[i] do
      begin
        if FieldVisible then
        begin
          Items.Add(FieldAppName);
        end;
      end;
    end;
    ItemIndex := 0;
  end;
end;

end.

