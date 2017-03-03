unit DownloadsDB;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLiteData, uBaseUnit;

type

  { TDownloadsDB }

  TDownloadsDB = class(TSQliteData)
  private
    FCommitCount: Integer;
    FAutoCommitCount: Integer;
    procedure SetAutoCommitCount(AValue: Integer);
  public
    constructor Create(const AFilename: String);
    function Add(var Adlid: Integer;
      const Aenabled: Boolean;
      const Aorder, Ataskstatus, Achapterptr, Anumberofpages, Acurrentpage: Integer;
      const Awebsite, Alink, Atitle, Astatus, Aprogress, Asaveto: String;
      const Adatetime: TDateTime;
      const Achapterslinks, Achaptersnames, Apagelinks, Apagecontainerlinks, Afilenames, Acustomfilenames,
        Afailedchapterslinks, Afailedchaptersnames: String): Boolean;
    procedure Delete(const ADlId: Integer);
    procedure Commit; override;
    property AutoCommitCount: Integer read FAutoCommitCount write SetAutoCommitCount;
  end;

const
  f_dlid               = 0;
  f_enabled            = 1;
  f_order              = 2;
  f_taskstatus         = 3;
  f_chapterptr         = 4;
  f_numberofpages      = 5;
  f_currentpage        = 6;
  f_website            = 7;
  f_link               = 8;
  f_title              = 9;
  f_status             = 10;
  f_progress           = 11;
  f_saveto             = 12;
  f_datetime           = 13;
  f_chapterslinks      = 14;
  f_chaptersnames      = 15;
  f_pagelinks          = 16;
  f_pagecontainerlinks = 17;
  f_filenames          = 18;
  f_customfilenames    = 19;
  f_failedchapterlinks = 20;
  f_failedchapternames = 21;

implementation

{ TDownloadsDB }

procedure TDownloadsDB.SetAutoCommitCount(AValue: Integer);
begin
  if FAutoCommitCount = AValue then Exit;
  FAutoCommitCount := AValue;
end;

constructor TDownloadsDB.Create(const AFilename: String);
begin
  inherited Create;
  FCommitCount := 0;
  FAutoCommitCount := 300;
  Filename := AFilename;
  TableName := 'downloads';
  Table.PacketRecords := 1;
  CreateParams :=
    '"dlid" INTEGER PRIMARY KEY,' +
    '"enabled" BOOLEAN,' +
    '"order" INTEGER,' +
    '"taskstatus" INTEGER,' +
    '"chapterptr" INTEGER,' +
    '"numberofpages" INTEGER,' +
    '"currentpage" INTEGER,' +
    '"website" TEXT,' +
    '"link" TEXT,' +
    '"title" TEXT,' +
    '"status" TEXT,' +
    '"progress" TEXT,' +
    '"saveto" TEXT,' +
    '"datetime" DATETIME,' +
    '"chapterslinks" TEXT,' +
    '"chaptersnames" TEXT,' +
    '"pagelinks" TEXT,' +
    '"pagecontainerlinks" TEXT,' +
    '"filenames" TEXT,' +
    '"customfilenames" TEXT,' +
    '"failedchapterlinks" TEXT,' +
    '"failedchapternames" TEXT';
  FieldsParams := '"dlid","enabled","order","taskstatus","chapterptr","numberofpages","currentpage","website","link","title","status","progress","saveto","datetime","chapterslinks","chaptersnames","pagelinks","pagecontainerlinks","filenames","customfilenames","failedchapterlinks","failedchapternames"';
  SelectParams := 'SELECT ' + FieldsParams + ' FROM '+QuotedStrD(TableName)+' ORDER BY "order"';
end;

function TDownloadsDB.Add(var Adlid: Integer;
  const Aenabled: Boolean;
  const Aorder, Ataskstatus, Achapterptr, Anumberofpages, Acurrentpage: Integer;
  const Awebsite, Alink, Atitle, Astatus, Aprogress, Asaveto: String;
  const Adatetime: TDateTime;
  const Achapterslinks, Achaptersnames, Apagelinks, Apagecontainerlinks, Afilenames, Acustomfilenames,
    Afailedchapterslinks, Afailedchaptersnames: String): Boolean;
begin
  Result := False;
  if (AWebsite = '') or (ALink = '') then Exit;
  if not Connection.Connected then Exit;
  try
    if Adlid <> -1 then
      Connection.ExecuteDirect('UPDATE "downloads" SET ' +
        '"enabled"=' +            QuotedStr(Aenabled) + ', ' +
        '"order"=' +              QuotedStr(Aorder) + ', ' +
        '"taskstatus"=' +         QuotedStr(Ataskstatus) + ',' +
        '"chapterptr"=' +         QuotedStr(Achapterptr) + ',' +
        '"numberofpages"=' +      QuotedStr(Anumberofpages) + ',' +
        '"currentpage"=' +        QuotedStr(Acurrentpage) + ',' +
        '"website"=' +            QuotedStr(Awebsite) + ', ' +
        '"link"=' +               QuotedStr(Alink) + ', ' +
        '"title"=' +              QuotedStr(Atitle) + ', ' +
        '"status"=' +             QuotedStr(Astatus) + ', ' +
        '"progress"=' +           QuotedStr(Aprogress) + ', ' +
        '"saveto"=' +             QuotedStr(Asaveto) + ', ' +
        '"datetime"=' +           QuotedStr(Adatetime) + ', ' +
        '"chapterslinks"=' +      QuotedStr(Achapterslinks) + ', ' +
        '"chaptersnames"=' +      QuotedStr(Achaptersnames) + ', ' +
        '"pagelinks"=' +          QuotedStr(Apagelinks) + ', ' +
        '"pagecontainerlinks"=' + QuotedStr(Apagecontainerlinks) + ', ' +
        '"filenames"=' +          QuotedStr(Afilenames) + ', ' +
        '"customfilenames"=' +    QuotedStr(Acustomfilenames) + ', ' +
        '"failedchapterlinks"=' + QuotedStr(Afailedchapterslinks) + ', ' +
        '"failedchapternames"=' + QuotedStr(Afailedchaptersnames) +
        ' WHERE "dlid"=' + QuotedStr(Adlid))
    else
      with Table do
      begin
        Append;
        Fields[f_enabled           ].AsBoolean   := Aenabled;
        Fields[f_order             ].AsInteger   := Aorder;
        Fields[f_taskstatus        ].AsInteger   := Ataskstatus;
        Fields[f_chapterptr        ].AsInteger   := Achapterptr;
        Fields[f_numberofpages     ].AsInteger   := Anumberofpages;
        Fields[f_currentpage       ].AsInteger   := Acurrentpage;
        Fields[f_website           ].AsString    := Awebsite;
        Fields[f_link              ].AsString    := Alink;
        Fields[f_title             ].AsString    := Atitle;
        Fields[f_status            ].AsString    := Astatus;
        Fields[f_progress          ].AsString    := Aprogress;
        Fields[f_saveto            ].AsString    := Asaveto;
        Fields[f_datetime          ].AsDateTime  := Adatetime;
        Fields[f_chapterslinks     ].AsString    := Achapterslinks;
        Fields[f_chaptersnames     ].AsString    := Achaptersnames;
        Fields[f_pagelinks         ].AsString    := Apagelinks;
        Fields[f_pagecontainerlinks].AsString    := Apagecontainerlinks;
        Fields[f_filenames         ].AsString    := Afilenames;
        Fields[f_customfilenames   ].AsString    := Acustomfilenames;
        Fields[f_failedchapterlinks].AsString    := Afailedchapterslinks;
        Fields[f_failedchapternames].AsString    := Afailedchaptersnames;
        Post;
        Adlid := Fields[f_dlid].AsInteger;
      end;
    Result := True;
    Inc(FCommitCount);
    if FCommitCount >= FAutoCommitCount then
      Commit;
  except
    on E: Exception do
      SendLogException(ClassName + '.Add failed!', E);
  end;
end;

procedure TDownloadsDB.Delete(const ADlId: Integer);
begin
  if ADlId = -1 then Exit;
  if not Connection.Connected then Exit;
  try
    Connection.ExecuteDirect(
      'DELETE FROM "downloads" WHERE "dlid"=' + QuotedStr(ADlId));
    Inc(FCommitCount);
    if FCommitCount >= FAutoCommitCount then
      Commit;
  except
    on E: Exception do
      SendLogException(ClassName + '.Delete failed!', E);
  end;
end;

procedure TDownloadsDB.Commit;
begin
  if not Connection.Connected then Exit;
  try
    Transaction.Commit;
    FCommitCount := 0;
  except
    on E: Exception do
      begin
        Transaction.Rollback;
        SendLogException(ClassName + '.Commit failed! Rollback!', E);
      end;
  end;
end;

end.

