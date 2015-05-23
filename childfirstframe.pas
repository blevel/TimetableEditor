unit ChildFirstFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, FilterFrame,
  AddFilterFrame, Dialogs, Buttons, Meta;

type

  TChildFirstFrame = class(TBaseParentFrame)
    BaseParentFrameOnLv: TBaseParentFrame;
    AddFilter: TBitBtn;
    DeleteLast: TBitBtn;
    ExecuteBFrLV: TBitBtn;
    procedure AddFilterClick(Sender: TObject);
    procedure DeleteLastClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function SQLGetOutCFrame: string;
  private
    FFilters: array of TAdditionalFilterFrame;
    function GetFilter(Index: integer): TAdditionalFilterFrame;
  public
    property Filter[Index: integer]: TAdditionalFilterFrame read GetFilter;
    function GetHighFilter: integer;
  end;

implementation

{$R *.lfm}

procedure TChildFirstFrame.AddFilterClick(Sender: TObject);
var
  LastControl: TWinControl;
  MaxHeight: integer;
begin
  LastControl := TWinControl(Components[(ComponentCount - 1)]);
  MaxHeight := LastControl.Top + LastControl.Height;
  SetLength(FFilters, length(FFilters) + 1);
  FFilters[high(FFilters)] := TAdditionalFilterFrame.CreateAdditional(Self, 0, MaxHeight);
  with FFilters[high(FFilters)] do
  begin
    Tag := Tag;
    DeleteFrame.Tag := high(FFilters);
    DeleteFrame.OnMouseDown := @DeleteClick;
    NumberOfParametr := High(FFilters);
    Needed := true;
    ExecuteBFCFF := ExecuteBFrLV;
  end;
  Self.Height := Self.Height + FFilters[high(FFilters)].Height;
  ExecuteBFrLV.Enabled := True;
end;

procedure TChildFirstFrame.DeleteLastClick(Sender: TObject);
begin
  if (length(FFilters) > 0) then
  begin
    Self.Height := Self.Height - FFilters[high(FFilters)].Height;
    FFilters[high(FFilters)].Free;
    Setlength(FFilters, length(FFilters) - 1);
  end;
  ExecuteBFrLV.Enabled := True;
end;

procedure TChildFirstFrame.DeleteClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, j, CurHeight: integer;
begin
  i := TWinControl(Sender).Tag;
  CurHeight := FFilters[i].Height;
  FFilters[i].Free;
  for j := i to high(FFilters) - 1 do
  begin
    FFilters[j] := FFilters[j + 1];
    FFilters[j].DeleteFrame.Tag := FFilters[j].DeleteFrame.Tag - 1;
  end;
  SetLength(FFilters, length(FFilters) - 1);
  for j := i to high(FFilters) do
  begin
    FFilters[j].Top := FFilters[j].Top - FFilters[j].Height;
  end;
  Self.Height := Self.Height - CurHeight;
  ExecuteBFrLV.Enabled := True;
end;

function TChildFirstFrame.SQLGetOutCFrame: string;
const
  CQuery = '%s.%s ';
var
  Table, Field, Operate: integer;
  str: string;
begin
  Result := '';
  with BaseParentFrameOnLv do
  begin
    Table := Tag;
    Field := FieldNameBox.ItemIndex;
    Operate := OperationBox.ItemIndex;
    with DataTables.FTables[Table] do
    begin
      with TabFields[Field] do
      begin
        if FieldNeedFJoin then
        begin
          Result += ' WHERE (' + Format(CQuery, [FieldTabNForJoin, FieldFNForSel]);
        end
        else
        begin
          Result += ' WHERE (' + Format(CQuery, [TabDBName, FieldDBName]);
        end;
      end;
    end;
    if SQLOperations[Operate] = ' LIKE ' then
    begin
      Result += SQLOperations[Operate];
      Result += ' :pChildF' + ' ) ';
      str := BaseParentFrameOnLv.STRValue.Text;
      if (BaseParentFrameOnLv.OperationBox.ItemIndex = 4) then
      begin
        BaseParentFrameOnLv.STRValue.Text := '%' + str + '%';
      end;
      if (BaseParentFrameOnLv.OperationBox.ItemIndex = 5) then
      begin
        BaseParentFrameOnLv.STRValue.Text := str + '%';
      end;
      exit;
    end;
    Result += SQLOperations[Operate];
    Result += ' :pChildF' + ' ) ';
  end;
end;

function TChildFirstFrame.GetFilter(Index: integer): TAdditionalFilterFrame;
begin
  Result := FFilters[Index];
end;

function TChildFirstFrame.GetHighFilter: integer;
begin
  Result := High(FFilters);
end;

end.
