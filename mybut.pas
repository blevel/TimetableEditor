unit MyBut;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

type

  { TButtonAdd }

  TButtonAdd = class
    Icon: TIcon;
    Offset: integer;
    constructor Create;
  end;

implementation


{ TButtonAdd }

constructor TButtonAdd.Create;
begin
  Icon := TIcon.Create;
  Icon.LoadFromFile('ButtonsIco\plus.ico');
end;

end.


