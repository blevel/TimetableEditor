unit addfilterframe;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Buttons, FilterFrame,
  MyFrame, Meta;

type

  { TAdditionalFilterFrame }

  TAdditionalFilterFrame = class(TMyFrame)
    BaseParentFrameOnLV: TBaseParentFrame;
    AndOrBox: TComboBox;
    DeleteFrame: TBitBtn;
    ExecuteBFCFF: TBitBtn;
    procedure AndOrBoxChange(Sender: TObject);
    constructor CreateAdditional(TheOwner: TComponent; ALeft, ATop: integer);
    function SQLGetOutAddFrame: string;
  private
    FNumberOfParametr: integer;
  public
    Needed: boolean;
    property NumberOfParametr: integer read FNumberOfParametr write FNumberOfParametr;
  end;

implementation

{$R *.lfm}

constructor TAdditionalFilterFrame.CreateAdditional(TheOwner: TComponent;
  ALeft, ATop: integer);
begin
  inherited Create(TheOwner);
  Tag := TheOwner.Tag;
  AddFiltersInfo(DataTables.FTables[tag], BaseParentFrameOnLV.FieldNameBox);
  Parent := TWinControl(TheOwner);
  Name := 'AdditionalFilter' + IntToStr(cardinal(Self));
  Left := Aleft;
  Top := ATop;
end;

procedure TAdditionalFilterFrame.AndOrBoxChange(Sender: TObject);
begin
  ExecuteBFCFF.Enabled := True;
end;

function TAdditionalFilterFrame.SQLGetOutAddFrame: string;
const
  CQuery = '%s.%s ';
var
  Table, Field, Operate: integer;
  str: string;
begin
  Result := '';
  with AndOrBox do
  begin
    case ItemIndex of
      0: Result += ' AND ';
      1: Result += ' OR ';
    end;
  end;
  Table := Tag;
  with BaseParentFrameOnLV do
  begin
    Field := FieldNameBox.ItemIndex;
    Operate := OperationBox.ItemIndex;
    with DataTables.FTables[Table] do
    begin
      with TabFields[Field] do
      begin
        if FieldNeedFJoin then
        begin
          Result += '(' + Format(CQuery, [FieldTabNForJoin, FieldFNForSel]);
        end
        else
        begin
          Result += '(' + Format(CQuery, [TabDBName, FieldDBName]);
        end;
      end;
    end;
    if SQLOperations[Operate] = ' LIKE ' then
    begin
      Result += SQLOperations[Operate];
      Result += ' :p' + IntToStr(FNumberOfParametr) + ' ) ';
      str := BaseParentFrameOnLV.STRValue.Text;
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
    Result += ' :p' + IntToStr(FNumberOfParametr) + ' ) ';
  end;
end;

end.
