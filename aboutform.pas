unit AboutForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TAboutF }

  TAboutF = class(TForm)
    LabelName: TLabel;
    LabelTeacherName: TLabel;
    LabelGroupName: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  AboutF: TAboutF;

implementation

{$R *.lfm}

end.

