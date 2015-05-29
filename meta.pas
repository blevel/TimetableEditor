unit Meta;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB;

type

  { TMyFieldInf }

  TMyFieldInf = record
    FieldDBName: string;
    FieldAppName: string;
    FieldTabNForJoin: string;
    FieldFNForJoin: string;
    FieldFNForSel: string;
    FieldType: TFieldType;
    FieldWidth: integer;
    FieldVisible: boolean;
    FieldNeedFJoin: boolean;
    FieldForSort: string;
  end;

  TMyTableInf = record
    TabDBName: string;
    TabAppName: string;
    TabSaveSQL: string;
    TabUniqueF: string;
    TabIsDirectory: boolean;
    TabFields: array of TMyFieldInf;
  end;

  { TMyTable }

  TMyTable = class
  private
    Tables: array of TMyTableInf;
    function GetCoord(Index: integer): TMyTableInf;
  public
    procedure AddTable(ATDBName: string; ATAppName: string; ATIsDir: boolean; AUniqueField: string = '');
    procedure AddField(AFDBName: string; AFAppName: string;
      AFType: TFieldType; AFWidth: integer; AFVisible: boolean; AFieldNeedFJoin: boolean = false;
      AFieldTabNForJoin: string = ''; AFieldFNForJoin: string = '';
      AFieldFNForSel: string = ''; AFieldForSort: string = '');
    procedure AddSQLInTMT(ATSSQL: string);
    function GetHighTableFA: integer;
    property FTables[Index: integer]: TMyTableInf read GetCoord;
  end;

var
  DataTables: TMyTable;

implementation

{ TMyFieldInf }

procedure TMyTable.AddField(AFDBName: string; AFAppName: string;
  AFType: TFieldType; AFWidth: integer; AFVisible: boolean; AFieldNeedFJoin: boolean = false;
  AFieldTabNForJoin: string = ''; AFieldFNForJoin: string = '';
  AFieldFNForSel: string = ''; AFieldForSort: string = '');
begin
  with Tables[high(tables)] do
  begin
    SetLength(TabFields, length(TabFields) + 1);
    with TabFields[high(TabFields)] do
    begin
      FieldDBName := AFDBName;
      FieldAppName := AFAppName;
      FieldType := AFType;
      FieldWidth := AFWidth;
      FieldVisible := AFVisible;
      FieldTabNForJoin := AFieldTabNForJoin;
      FieldFNForJoin := AFieldFNForJoin;
      FieldFNForSel := AFieldFNForSel;
      FieldNeedFJoin := AFieldNeedFJoin;
      FieldForSort := AFieldForSort;
    end;
  end;
end;

procedure TMyTable.AddSQLInTMT(ATSSQL: string);
begin
  with Tables[high(Tables)] do
  begin
    TabSaveSQL := ATSSQL;
  end;
end;

function TMyTable.GetHighTableFA: integer;
begin
  Result := High(Tables);
end;

{ TMyTable }

function TMyTable.GetCoord(Index: integer): TMyTableInf;
begin
  Result := Tables[Index];
end;

procedure TMyTable.AddTable(ATDBName: string; ATAppName: string; ATIsDir: boolean;
AUniqueField: string = '');
begin
  SetLength(Tables, length(Tables) + 1);
  with Tables[high(Tables)] do
  begin
    TabDBName := ATDBName;
    TabAppName := ATAppName;
    TabIsDirectory := ATIsDir;
    TabUniqueF := AUniqueField;
  end;
end;

initialization
  DataTables := TMyTable.Create;
  with DataTables do
  begin
    AddTable('STUDENTS', 'Список студентов', True, 'STUDENTID');
    AddField('StudentInitials', 'Имя', ftString, 210, True);
    AddField('GROUPID', 'Номер Группы', ftString, 100, True, True,
             'GROUPS', 'GROUPID',
             'GROUPNUMBER');
    AddField('StudentID', 'ИН', ftInteger, 30, false);

    AddTable('Groups', 'Список групп', False, 'GROUPID');
    AddField('GroupNumber', 'Номер группы', ftString, 100, True);
    AddField('GroupName', 'Направление', ftString, 380, True);
    AddField('GroupID', 'ИН', ftInteger, 30, false);


    AddTable('EducActivities', 'Тип занятия', False, 'EDUCID');
    AddField('EducName', 'Название', ftString, 90, True);
    AddField('EducID', 'ИН', ftInteger, 30, false);

    AddTable('Teachers', 'Преподаватели', False, 'TEACHERID');
    AddField('TeacherInitials', 'Имя', ftString, 210, True);
    AddField('TeacherID', 'ИН', ftInteger, 30, false);

    AddTable('Subjects', 'Предметы', False, 'SubjectID');
    AddField('SubjectName', 'Название', ftString, 170, True);
    AddField('SubjectID', 'ИН', ftInteger, 30, false);

    AddTable('Audiences', 'Аудитории', False, 'AudienceID');
    AddField('AudienceNumber', 'Номер', ftString, 50, True);
    AddField('AudienceID', 'ИН', ftInteger, 30, false);

    AddTable('Pairs', 'Пары', False, 'PairID');
    AddField('PairBegin', 'Начало', ftString, 50, True);
    AddField('PairEnd', 'Конец', ftString, 50, True);
    AddField('PairNumber', 'Номер', ftInteger, 45, True);
    AddField('PairID', 'ИН', ftInteger, 30, false);

    AddTable('WeekDays', 'Дни Недели', False, 'WeekDayID');
    AddField('WeekDayName', 'День Недели', ftString, 90, True);
    AddField('WeekDayNumber', 'Номер дня недели', ftInteger, 110, True);
    AddField('WeekDayID', 'ИН', ftInteger, 30, false);

    AddTable('Schedules', 'Расписание', True, 'RECORDID');
    AddField('GROUPID', 'Группа', ftstring, 80, True, True,
             'GROUPS', 'GROUPID',
             'GROUPNUMBER', 'GROUPNUMBER');
    AddField('WEEKDAYID', 'День недели', ftString, 90, True, True,
             'WEEKDAYS', 'WEEKDAYID',
             'WEEKDAYNAME', 'WEEKDAYNUMBER');
    AddField('PAIRID', 'Номер пары', ftInteger, 100, True, True,
             'PAIRS', 'PAIRID',
             'PAIRNUMBER', 'PAIRNUMBER');
    AddField('SUBJECTID', 'Предмет', ftString, 170, True, True,
             'SUBJECTS', 'SUBJECTID',
             'SUBJECTNAME', 'SUBJECTNAME');
    AddField('EDUCID', 'Тип занятия', ftString, 90, True, True,
             'EDUCACTIVITIES', 'EDUCID',
             'EDUCNAME', 'EDUCNAME');
    AddField('TEACHERID', 'Преподаватель', ftString, 210, True, True,
             'TEACHERS', 'TEACHERID',
             'TEACHERINITIALS', 'TEACHERINITIALS');
    AddField('AUDIENCEID', 'Номер аудитории', ftString, 110, True, True,
             'AUDIENCES', 'AUDIENCEID',
             'AUDIENCENUMBER', 'AUDIENCENUMBER');
    AddField('RECORDID', 'Номер в таблице', ftInteger, 110, False);

    AddTable('Teachers_Subjects', 'Преподаватель-Предмет', True, 'RECORDID');
    AddField('TEACHERID', 'Преподаватель', ftString, 210, True, True,
             'TEACHERS', 'TEACHERID',
             'TEACHERINITIALS');
    AddField('SUBJECTID', 'Предмет', ftString, 150, True, True,
             'SUBJECTS', 'SUBJECTID',
             'SUBJECTNAME');
    AddField('RECORDID', 'Номер в таблице', ftInteger, 110, False);

    AddTable('Group_Subjects', 'Группа-Предмет', True, 'RECORDID');
    AddField('GROUPID', 'Группа', ftstring, 60, True, True,
             'GROUPS', 'GROUPID',
             'GROUPNUMBER');
    AddField('SUBJECTID', 'Предмет', ftstring, 150, True, True,
             'SUBJECTS', 'SUBJECTID',
             'SUBJECTNAME');
    AddField('RECORDID', 'Номер в таблице', ftInteger, 110, False);
  end;
end.


