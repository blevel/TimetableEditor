unit DBConnection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, sqldb, FileUtil, Menus;

type

  { TDBConnectionMod }

  TDBConnectionMod = class(TDataModule)
    IBConnection: TIBConnection;
    SQLTransaction: TSQLTransaction;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DBConnectionMod: TDBConnectionMod;

implementation

{$R *.lfm}


end.

