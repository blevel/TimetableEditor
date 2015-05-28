unit MyBut;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Dialogs, Grids, Meta, sqldb, CardForm,
  Forms, ListViewChild, Menus, ListView;

type

  { TMyButton }

  TMyButton = class
    Icon: TIcon;
    FRect: TRect;
    constructor Create; virtual; abstract;
    procedure RefreshRect(ATop, ABottom, ALeft, ARight: integer);
    //procedure OnClick1(SQLQ: TSQLQuery; Table: TMyTableInf; AID: integer); virtual; abstract;
    procedure OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
      aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
      AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer); virtual; abstract;
  end;

  { TButtonAdd }

  TButtonAdd = class(TMyButton)
    constructor Create; override;
    procedure OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
      aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
      AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer); override;
  end;

  { TButtonChHeight }

  TButtonChHeight = class(TMyButton)
    constructor Create; override;
    procedure OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
      aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
      AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer); override;
  end;

  { TButtonChange }

  TButtonChange = class(TMyButton)
    constructor Create; override;
    procedure OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
      aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
      AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer); override;
  end;

  { TButttonShowOnLV }

  TButttonShowOnLV = class(TMyButton)
    constructor Create; override;
    procedure OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
      aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
      AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer); override;
  end;

implementation

{ TButttonShowOnLV }

constructor TButttonShowOnLV.Create;
begin
  Icon := TIcon.Create;
  Icon.LoadFromFile('ButtonsIco\table.ico');
end;

procedure TButttonShowOnLV.OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
  aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
  AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer);
var
  i: integer;
begin
  //TListViewForm.Create(Sender, Table).Show;
 { for i := 0 to Application.ComponentCount - 1 do
  begin
    if (Application.Components[i] is TListChildView) then
    begin
      if (aColTitle = TListChildView(Application.Components[i]).FAColTitle) and
        (aRowTitle =  TListChildView(Application.Components[i]).FARowTitile) then
      begin
        TListChildView(Application.Components[i]).ShowOnTop;
        exit;
      end;
    end;
  end;   }
  for i := 0 to Screen.FormCount - 1 do
  begin
    if (Screen.Forms[i] is TListChildView) then
    begin
      if (aColTitle = TListChildView(Screen.Forms[i]).FAColTitle) and
        (aRowTitle = TListChildView(Screen.Forms[i]).FARowTitile) then
      begin
        Screen.Forms[i].ShowOnTop;
        exit;
      end;
    end;
  end;

  Sender.Tag := 8;
  TListChildView.CreateDirectoryForm(Sender, Table, FNI1, FNI2,
    aColTitle, aRowTitle).Show;
end;

{ TButtonChange }

constructor TButtonChange.Create;
begin
  Icon := TIcon.Create;
  Icon.LoadFromFile('ButtonsIco\pen.ico');
end;

procedure TButtonChange.OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
  aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
  AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer);
var
  flag: boolean;
  i: integer;
begin
  //ShowMessage('dada');
  Flag := False;
  for i := 0 to Application.ComponentCount - 1 do
  begin
    if (Application.Components[i] is TCardF) then
    begin
      if (Table.TabDBName = TCardF(Application.Components[i]).FTable.TabDBName) and
        (AID = TCardF(Application.Components[i]).FID) then
      begin
        TCardF(Application.Components[i]).ShowOnTop;
        Flag := True;
        exit;
      end;
    end;
  end;
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

procedure TButtonChHeight.OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
  aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
  AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer);
begin
  if DrawGrid.RowHeights[aRow] < AHeight then
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

procedure TButtonAdd.OnClick(Sender: TComponent; DrawGrid: TDrawGrid;
  aRow: integer; AHeight: integer; SQLQ: TSQLQuery; Table: TMyTableInf;
  AID: integer; aColTitle, aRowTitle: string; FNI1, FNI2: integer);
var
  Index, i: integer;
begin
  Index := 8;
  for i := 0 to Application.ComponentCount - 1 do
  begin
    if (Application.Components[i] is TCardF) then
    begin
      if (Table.TabDBName = TCardF(Application.Components[i]).FTable.TabDBName) and
        (0 = TCardF(Application.Components[i]).FID) then
      begin
        TCardF(Application.Components[i]).ShowOnTop;
        //Flag := True;
        exit;
      end;
    end;
  end;
  TCardF.CreateCardF(SQLQ, Table, 0).Show;
end;

end.
