Unit FormVideoPlayer;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  EditBtn, Buttons, Menus, FrameVideoPlayer, FrameVideoBase,
  FormMain, IniFiles, MRUs;

Type

  { TfrmVideoPlayer }

  TfrmVideoPlayer = Class(TFormMain)
    MenuItem1: TMenuItem;
    mnuOpenRecent: TMenuItem;
    mnuExit: TMenuItem;
    mnuFile: TMenuItem;
    mnuOpen: TMenuItem;
    dlgOpen: TOpenDialog;
    pnlVideoPlayer: TPanel;
    Procedure FormActivate(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var CloseAction: TCloseAction);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormDropFiles(Sender: TObject; Const FileNames: Array Of String);
    Procedure mnuExitClick(Sender: TObject);
    Procedure mnuFileClick(Sender: TObject);
    Procedure mnuOpenClick(Sender: TObject);
    Procedure mnuOpenRecentClick(Sender: TObject);
  Private
    fmeVideoPlayer: TFrameVideoPlayer;
    FMRU: TMRU;
    FLoaded: Boolean;

    Procedure OpenVideo(Const AFilename: String);
  Public
    Procedure LoadGlobalSettings(oInifile: TIniFile); Override;
    Procedure SaveGlobalSettings(oInifile: TIniFile); Override;
  End;

Var
  frmVideoPlayer: TfrmVideoPlayer;

Implementation

Uses
  FileSupport, VideoEngineFactory,
  // Include all required video playback engines below this point
  FrameVideoLibmpv;

  {$R *.lfm}

  { TfrmVideoPlayer }

Procedure TfrmVideoPlayer.FormCreate(Sender: TObject);
Begin
  Inherited;

  fmeVideoPlayer := TFrameVideoPlayer.Create(Self);
  fmeVideoPlayer.Parent := pnlVideoPlayer;
  fmeVideoPlayer.Name := 'fmeVideoPlayer';
  fmeVideoPlayer.Align := alClient;
  fmeVideoPlayer.Autoplay := True;
  fmeVideoPlayer.ShowLabel := True;

  // Change this line to swap playback engines.
  fmeVideoPlayer.VideoEngineClass := TVideoEngineFactory.DefaultClass;

  // Disable require --configure
  FAlwaysSaveSettings := True;

  FMRU := TMRU.Create;
  FMRU.Max := 10;
  FMRU.Files := True;

  FLoaded := False;
End;

Procedure TfrmVideoPlayer.FormActivate(Sender: TObject);
Begin
  Inherited;

  If Not FLoaded Then
  Begin
    If Application.ParamCount > 0 Then
      OpenVideo(Application.Params[1]);

    FLoaded := True;
  End;
End;

Procedure TfrmVideoPlayer.FormClose(Sender: TObject; Var CloseAction: TCloseAction);
Begin
  If Assigned(fmeVideoPlayer) Then
    fmeVideoPlayer.Clear;

  Inherited;
End;

Procedure TfrmVideoPlayer.FormDestroy(Sender: TObject);
Begin
  FreeAndNil(FMRU);

  Inherited;
End;

Procedure TfrmVideoPlayer.OpenVideo(Const AFilename: String);
Begin
  If Not FileExists(AFilename) Then
    Exit;

  fmeVideoPlayer.Load(AFilename);
  FMRU.Add(AFilename);
End;

Procedure TfrmVideoPlayer.FormDropFiles(Sender: TObject; Const FileNames: Array Of String);
Var
  sExt: String;
Begin
  If Length(FileNames) = 0 Then
    Exit;

  sExt := ExtractFileExt(LowerCase(FileNames[0]));

  If IsVideo(sExt) Or (sExt = '.pkt') Then
    OpenVideo(FileNames[0]);
End;

Procedure TfrmVideoPlayer.mnuExitClick(Sender: TObject);
Begin
  Close;
End;

Procedure TfrmVideoPlayer.mnuFileClick(Sender: TObject);
Begin
  FMRU.Populate(mnuOpenRecent, @mnuOpenRecentClick);
  mnuOpenRecent.Enabled := FMRU.Count > 0;
End;

Procedure TfrmVideoPlayer.mnuOpenClick(Sender: TObject);
Begin
  If dlgOpen.Execute Then
    OpenVideo(dlgOpen.FileName);
End;

Procedure TfrmVideoPlayer.mnuOpenRecentClick(Sender: TObject);
Begin
  If (Sender Is TMenuItem) And (TMenuItem(Sender).Tag < FMRU.Count) Then
    OpenVideo(FMRU.Value(TMenuItem(Sender).Tag));
End;

Procedure TfrmVideoPlayer.LoadGlobalSettings(oInifile: TIniFile);
Begin
  Inherited;

  FMRU.Load(oInifile, 'Files', 'MRU');
End;

Procedure TfrmVideoPlayer.SaveGlobalSettings(oInifile: TIniFile);
Begin
  Inherited;

  FMRU.Save(oInifile, 'Files', 'MRU');
End;

End.
