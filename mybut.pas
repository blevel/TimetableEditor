unit MyBut;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Dialogs, Grids;

type

  { TMyButton }

  TMyButton = class
    Icon: TIcon;
    FRect: TRect;
    constructor Create; virtual; abstract;
    procedure RefreshRect(ATop, ABottom, ALeft, ARight: integer);
  end;

  { TButtonAdd }

  TButtonAdd = class(TMyButton)
    constructor Create; override;
  end;

  { TButtonChHeight }

  TButtonChHeight = class(TMyButton)
    constructor Create; override;
    procedure OnClick(DrawGrid: TDrawGrid; aRow: integer; AHeight: Integer);
  end;

implementation

{ TMyButton }

procedure TMyButton.RefreshRect(ATop, ABottom, ALeft, ARight: integer);
begin
  FRect.Top := ATop;
  FRect.Bottom := ABottom;
  FRect.Right := ARight;
  FRect.Left := ALeft;
end;

{ TButtonChHeight }

constructor TButtonChHeight.Create;
begin
  Icon := TIcon.Create;
  Icon.LoadFromFile('ButtonsIco\downarrow.ico');
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

end.


