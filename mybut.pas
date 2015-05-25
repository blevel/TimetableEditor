unit MyBut;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Dialogs, Grids;

type
  { TButtonAdd }

  TButtonAdd = class
    Icon: TIcon;
    FRect: TRect;
    constructor Create;
    procedure RefreshRect(ATop, ABottom, ALeft, ARight: integer);
  end;

  { TButtonChHeight }

  TButtonChHeight = class
    Icon: TIcon;
    FRect: TRect;
    constructor Create;
    procedure RefreshRect(ATop, ABottom, ALeft, ARight: integer);
    procedure OnClick(DrawGrid: TDrawGrid; aRow: integer; AHeight: Integer);
  end;

implementation

{ TButtonChHeight }

constructor TButtonChHeight.Create;
begin
  Icon := TIcon.Create;
  Icon.LoadFromFile('ButtonsIco\downarrow.ico');
end;

procedure TButtonChHeight.RefreshRect(ATop, ABottom, ALeft, ARight: integer);
begin
  FRect.Top := ATop;
  FRect.Bottom := ABottom;
  FRect.Right := ARight;
  FRect.Left := ALeft;
end;

procedure TButtonChHeight.OnClick(DrawGrid: TDrawGrid; aRow: integer; AHeight: Integer);
begin
  if DrawGrid.RowHeights[aRow] < AHeight  then
  begin
    DrawGrid.RowHeights[aRow] := AHeight;
  end;
  //ShowMessage('Нажал');
end;


{ TButtonAdd }

constructor TButtonAdd.Create;
begin
  Icon := TIcon.Create;
  Icon.LoadFromFile('ButtonsIco\plus.ico');
end;

procedure TButtonAdd.RefreshRect(ATop, ABottom, ALeft, ARight: integer);
begin
  FRect.Top := ATop;
  FRect.Bottom := ABottom;
  FRect.Right := ARight;
  FRect.Left := ALeft;
end;

end.


