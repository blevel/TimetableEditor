unit SQLcreating;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Meta, ChildFirstFrame, sqldb, DBConnection, StdCtrls, Dialogs, DB;

function SQLCreateJoin(TableInfo: TMyTableInf): string;
function SQlCreateSetToSel(TableInfo: TMyTableInf): string;
function SQLCreateQuery(AFilterFrame: TChildFirstFrame; ATableName: string): string;
function SQLCreateQueryFTT(AFilterFrame: TChildFirstFrame): string;
function SQLCreateUpdate(Table: TMyTableInf; ADataObjects: array of TComponent;
  AUniqueFieldVal: string; SQLQuery: TSQLQuery): string;
function SQLCreateInsert(Table: TMyTableInf; ADataObjects: array of TComponent;
  SQLQuery: TSQLQuery; var flag: boolean): string;
procedure SQLExecute(SQLQuery: TSQLQuery; AText: string);
procedure SQLPrepare(Table: TMyTableInf; ADataObjects: array of TComponent;
  SQLQuery: TSQLQuery; SQLQ: string);


implementation

function SQLCreateJoin(TableInfo: TMyTableInf): string;
var
  i: integer;
begin
  with TableInfo do
  begin
    Result := TabDBName;
    begin
      for i := 0 to High(TabFields) do
      begin
        with TabFields[i] do
        begin
          if FieldNeedFJoin then
            Result += ' INNER JOIN ' + FieldTabNForJoin + ' ON ' +
              TabDBName + '.' + FieldDBName + ' = ' + FieldTabNForJoin +
              '.' + FieldFNForJoin;
        end;
      end;
    end;
  end;
end;

function SQlCreateSetToSel(TableInfo: TMyTableInf): string;
var
  i: integer;
begin
  with TableInfo do
  begin
    Result := '';
    for i := 0 to High(TabFields) do
    begin
      with TabFields[i] do
      begin
        Result += FieldFNForSel + ' ';
      end;
    end;
  end;
end;

function SQLCreateQuery(AFilterFrame: TChildFirstFrame; ATableName: string): string;

const
  SPQuery = 'SELECT * FROM ';
var
  i: integer;
begin
  Result := SPQuery + ATableName;
  with AFilterFrame do
  begin
    Result += SQLGetOutCFrame;
    for i := 0 to GetHighFilter do
    begin
      if Filter[i].BaseParentFrameOnLV.STRValue.Text = '' then
      begin
        Filter[i].Needed := False;
        //Continue;
      end
      else
        Result += Filter[i].SQLGetOutAddFrame;
    end;
  end;
end;

function SQLCreateQueryFTT(AFilterFrame: TChildFirstFrame): string;
var
  i: integer;

begin
  Result := '';
  with AFilterFrame do
  begin
    if BaseParentFrameOnLv.STRValue.Text = '' then
    begin
      Result := ' ';
      exit;
    end;
    Result += SQLGetOutCFrameFTT;
    for i := 0 to GetHighFilter do
    begin
      if Filter[i].BaseParentFrameOnLV.STRValue.Text = '' then
      begin
        Filter[i].Needed := False;
        //Continue;
      end
      else
        Result += Filter[i].SQLGetOutAddFrameFTT;
    end;
  end;
end;

function SQLCreateUpdate(Table: TMyTableInf; ADataObjects: array of TComponent;
  AUniqueFieldVal: string; SQLQuery: TSQLQuery): string;
var
  i: integer;
  SQLQ: string;
begin
  SQLQ := 'UPDATE ' + Table.TabDBName + ' SET  ';
  with Table do
  begin
    for i := 0 to high(ADataObjects) do
    begin
      SQLQ += Table.TabDBName + '.' + TabFields[i].FieldDBName + ' = ';
      if TabFields[i].FieldVisible then
      begin
        SQLQ += ' :p' + IntToStr(i) + ' ,';
      end;
    end;
    SetLength(SQLQ, length(SQLQ) - 1);
    SQLQ += '  WHERE ' + TabDBName + '.' + TabUniqueF + ' = ' + AUniqueFieldVal;
    SQLPrepare(Table, ADataObjects, SQLQuery, SQLQ);
    Result := SQLQ;
    //ShowMessage(SQLQ);
  end;
end;

function SQLCreateInsert(Table: TMyTableInf; ADataObjects: array of TComponent;
  SQLQuery: TSQLQuery; var flag: boolean): string;
var
  SQLQ: string;
  i: integer;
begin
  with Table do
  begin
    SQLQ := 'INSERT INTO ' + Table.TabDBName + ' VALUES (NULL ,';
    //SQLQ += SQLParamsCreate(Table, ADataObjects);
    for i := 0 to high(ADataObjects) do
    begin
      if TabFields[i].FieldNeedFJoin then
      begin
        if TabFields[i].FieldVisible then
        begin
          if (TComboBox(ADataObjects[i]).ItemIndex = -1) then
          begin
            ShowMessage('Для добавления новой записи все поля должны быть заполнены');
            flag := true;
            Exit;
          end
          else
          begin
            SQLQ += ' :p' + IntToStr(i) + ' ,';
          end;
        end;
      end
      else
      begin
        if (length(TEdit(ADataObjects[i]).Text) = 0) then
        begin
          ShowMessage('Для добавления новой записи все поля должны быть заполнены');
          flag := true;
          Exit;
        end
        else
        begin
          SQLQ += ' :p' + IntToStr(i) + ' ,';
        end;
      end;
    end;
    SetLength(SQLQ, Length(SQLQ) - 1);
    SQLQ += ') RETURNING ' +  TabUniqueF + ' ;';
    SQLPrepare(Table, ADataObjects, SQLQuery, SQLQ);
    Result := SQLQ;
  end;
end;

procedure SQLExecute(SQLQuery: TSQLQuery; AText: string);
begin
  with SQLQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Text := AText;
  end;
end;

procedure SQLPrepare(Table: TMyTableInf; ADataObjects: array of TComponent;
  SQLQuery: TSQLQuery; SQLQ: string);
var
  i: integer;
  BufStr: TStringList;
begin
  try
    with Table do
    begin
      SQLQuery.sql.Text := SQLQ;
      SQLQuery.Prepare;
      for i := 0 to high(ADataObjects) do
      begin
        if TabFields[i].FieldNeedFJoin then
        begin
          if TabFields[i].FieldVisible then
          begin
            BufStr := TStringList(TComboBox(ADataObjects[i]).Items.Objects[TComboBox(ADataObjects[i]).ItemIndex]);
            if TabFields[i].FieldType = ftinteger then
            begin
              SQLQuery.ParamByName('p' + IntToStr(i)).AsInteger :=
                StrToInt(BufStr[TComboBox(ADataObjects[i]).ItemIndex]);
            end;
            if TabFields[i].FieldType = ftString then
            begin
              SQLQuery.ParamByName('p' + IntToStr(i)).AsString :=
                BufStr[TComboBox(ADataObjects[i]).ItemIndex];
            end;
          end;
        end
        else
        begin
          if TabFields[i].FieldType = ftinteger then
          begin
            SQLQuery.ParamByName('p' + IntToStr(i)).AsInteger :=
              StrToInt(TEdit(ADataObjects[i]).Text);
          end;
          if TabFields[i].FieldType = ftstring then
          begin
            SQLQuery.ParamByName('p' + IntToStr(i)).AsString :=
              TEdit(ADataObjects[i]).Text;
          end;
        end;
      end;
      SQLQuery.ExecSQL;
      DBConnectionMod.SQLTransaction.Commit;
    end;
  except
    on EConvertError do ShowMessage('Введены некорректные данные');
  end;
end;

end.




