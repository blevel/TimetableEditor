unit CardForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  sqldb, DB, Meta, DBCtrls, StdCtrls, IBConnection, SQLcreating;

type

  { TCardF }

  TCardF = class(TForm)
    Cancel: TButton;
    Execute: TButton;
    DataCardSource: TDataSource;
    TopPanel: TPanel;
    SQLCardQuery: TSQLQuery;
    procedure CancelClick(Sender: TObject);
    procedure ExecuteClick(Sender: TObject);
    constructor CreateCardF(SQLQuery: TSQLQuery; ATable: TMyTableInf; AID: integer);
    function CreateCBoxes(AParent: TWinControl; AIndex: integer;
      ASQLQuery: TSQLQuery; TableName, FieldName: string;
      strList: TStringList): TCombobox;
    function CreateLable(AParent: TWinControl; ATop: integer; ACaption: string): TLabel;
    function DOSelectQuery(ASQLQuery: TSQLQuery;
      TableName, FieldName: string): TSQLQuery;
    function CreateStringList(ASQLQuery: TSQLQuery; TableName: string;
      FieldName: string): TStringList;
    function CreateEdit(AParent: TWinControl; AIndex: integer; FieldName: string): TEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure RefreshForm;
  private
  public
    ParentQuery: TSQLQuery;
    DataObjects: array of TComponent;
    SaveStr: string;
    UniqueFieldVal: string;
    FlagOfCreate: boolean;
    FTable: TMyTableInf;
    FID: integer;
  end;

type
  TEvent = procedure of object;

var
  CardF: TCardF;
  WalkOnForms: TEvent;

implementation

{$R *.lfm}

{ TCardF }

constructor TCardF.CreateCardF(SQLQuery: TSQLQuery; ATable: TMyTableInf; AID: integer);
var
  i: integer;
  CBox: TComboBox;
  Edit: TEdit;
  Strings: TStringList;
begin
  inherited Create(Application);
  savestr := ' WHERE ';
  if (AID = 0) then
  begin
    FlagOfCreate := True;
  end
  else
  begin
    FlagOfCreate := False;
  end;
  ParentQuery := SQLQuery;
  //Tag := TheOwner.Tag;
  FTable := ATable;
  FID := AID;
  with ATable do
  begin
    UniqueFieldVal := IntToStr(AID);
    for i := 0 to high(TabFields) do
    begin
      if not TabFields[i].FieldVisible then
      begin
        Continue;
      end;
      SetLength(DataObjects, length(DataObjects) + 1);
      if TabFields[i].FieldNeedFJoin then
      begin
        Strings := CreateStringList(SQLCardQuery, TabFields[i].FieldTabNForJoin,
          TabFields[i].FieldFNForJoin);
        CBox := CreateCBoxes(TopPanel, i, SQLCardQuery,
          TabFields[i].FieldTabNForJoin, TabFields[i].FieldFNForSel, Strings);
        CreateLable(TopPanel, CBox.Top, TabFields[i].FieldAppName);
        DataObjects[High(DataObjects)] := CBox;
      end
      else
      begin
        Edit := CreateEdit(TopPanel, i, TabFields[i].FieldDBName);
        CreateLable(TopPanel, Edit.Top, TabFields[i].FieldAppName);
        DataObjects[High(DataObjects)] := Edit;
      end;
    end;
  end;
end;

procedure TCardF.ExecuteClick(Sender: TObject);
var
  flag: boolean;
begin
  flag := false;
  if not FlagOfCreate then
  begin
    SQLCreateUpdate(FTable, DataObjects, UniqueFieldVal, SQLCardQuery);
  end;
  if FlagOfCreate then
  begin
    SQLCreateInsert(FTable, DataObjects, SQLCardQuery, flag);
  end;
  WalkOnForms;
  if not flag then
  begin
    Self.Close;
  end;
end;

procedure TCardF.CancelClick(Sender: TObject);
begin
  Self.Close;
end;


function TCardF.CreateCBoxes(AParent: TWinControl; AIndex: integer;
  ASQLQuery: TSQLQuery; TableName, FieldName: string; strList: TStringList): TCombobox;
var
  SQLQ: TSQLQuery;
begin
  Result := TComboBox.Create(AParent);
  with Result do
  begin
    Result := TComboBox.Create(TopPanel);
    Result.Parent := AParent;
    Result.top := AIndex * 30 + 25;
    Result.Width := 180;
    Result.Left := 120;
  end;
  SQLQ := DOSelectQuery(ASQLQuery, TableName, FieldName);
  Result.Clear;
  with SQLQ do
  begin
    while not SQLQ.EOF do
    begin
      Result.Items.AddObject(FieldByName(FieldName).AsString, strList);
      Next;
    end;
    Close;
  end;
  if not FlagOfCreate then
  begin
    Result.ItemIndex :=
      Result.Items.IndexOf(ParentQuery.Fields.FieldByName(FieldName).Value);
  end;
  Result.Style := csOwnerDrawVariable;
  Result.ReadOnly := true;
end;

function TCardF.CreateLable(AParent: TWinControl; ATop: integer;
  ACaption: string): TLabel;
begin
  Result := TLabel.Create(AParent);
  with Result do
  begin
    Result.Parent := AParent;
    Result.Top := ATop;
    Result.Caption := ACaption;
    Result.Left := 5;
  end;
end;

function TCardF.DOSelectQuery(ASQLQuery: TSQLQuery;
  TableName, FieldName: string): TSQLQuery;
begin
  with ASQLQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT ' + TableName + '.' + FieldName + ' FROM ' + TableName);
    Open;
  end;
  Result := ASQLQuery;
end;

function TCardF.CreateStringList(ASQLQuery: TSQLQuery; TableName: string;
  FieldName: string): TStringList;
var
  SQLQ: TSQLQuery;
begin
  Result := TStringList.Create;
  SQLQ := DOSelectQuery(ASQLQuery, TableName, FieldName);
  while not SQLQ.EOF do
  begin
    with SQLQ do
    begin
      Result.Add(FieldByName(FieldName).AsString);
      Next;
    end;
  end;
  SQLQ.Close;
end;

function TCardF.CreateEdit(AParent: TWinControl; AIndex: integer;
  FieldName: string): TEdit;
begin
  Result := TEdit.Create(TopPanel);
  Result.Parent := AParent;
  Result.Top := AIndex * 30 + 25;
  Result.Left := 120;
  Result.Width := 180;
  if not FlagOfCreate then
  begin
    Result.Text := ParentQuery.Fields.FieldByName(FieldName).Value;
  end;
end;

procedure TCardF.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TCardF.RefreshForm;
var
  i, BufIndex: integer;
  Strings: TStringList;
  SQLQ: TSQLQuery;
begin
  for i := 0 to high(DataObjects) do
  begin
    if FTable.TabFields[i].FieldNeedFJoin then
    begin
      BufIndex := TComboBox(DataObjects[i]).ItemIndex;
      TComboBox(DataObjects[i]).Clear;
      Strings := CreateStringList(SQLCardQuery, Ftable.TabFields[i].FieldTabNForJoin,
        Ftable.TabFields[i].FieldFNForJoin);
      SQLQ := DOSelectQuery(SQLCardQuery, Ftable.TabFields[i].FieldTabNForJoin,
      Ftable.TabFields[i].FieldFNForSel);
      with SQLQ do
      begin
        while not SQLQ.EOF do
        begin
          TComboBox(DataObjects[i]).Items.AddObject(FieldByName(Ftable.TabFields[i].FieldFNForSel).AsString,
          Strings);
          Next;
        end;
        SQLQ.Close;
      end;
      TComboBox(DataObjects[i]).ItemIndex := BufIndex;
    end;
  end;
end;

end.
