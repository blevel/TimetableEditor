unit MyBut;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Dialogs, Grids, Meta, sqldb, CardForm;

type

  { TMyButton }

  TMyButton = class
    Icon: TIcon;
    FRect: TRect;
    constructor Create; virtual; abstract;
    procedure RefreshRect(ATop, ABottom, ALeft, ARight: integer);
    procedure OnClick1(SQLQ: TSQLQuery; Table: TMyTableInf; AID: integer); virtual; abstract;
  end;

  { TButtonAdd }

  TButtonAdd = class(TMyButton)
    constructor Create; override;
    procedure OnClick1(SQLQ: TSQLQuery; Table: TMyTableInf; AID: integer); override;
  end;

  { TButtonChHeight }

  TButtonChHeight = class(TMyButton)
    constructor Create; override;
    procedure OnClick(DrawGrid: TDrawGrid; aRow: integer; AHeight: Integer);
  end;

  { TButtonChange }

  TButtonChange = class(TMyButton)
    constructor Create; override;
    procedure OnClick1(SQLQ: TSQLQuery; Table: TMyTableInf; AID: integer); override;
  end;

implementation

{ TButtonChange }

constructor TButtonChange.Create;
begin
  Icon := TIcon.Create;
  Icon.LoadFromFile('ButtonsIco\pen.ico');
end;

procedure TButtonChange.OnClick1(SQLQ: TSQLQuery; Table: TMyTableInf; AID: integer);
begin
  //ShowMessage('dada');
  TCardF.CreateCardF(SQLQ, Table, AID).Show;
end;

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

procedure TButtonAdd.OnClick1(SQLQ: TSQLQuery; Table: TMyTableInf; AID: integer
  );
var
  Index: integer;
begin
  Index := 8;
  TCardF.CreateCardF(SQLQ, Table, 0).Show;
end;

end.


