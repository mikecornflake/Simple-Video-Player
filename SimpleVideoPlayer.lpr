program SimpleVideoPlayer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormVideoPlayer;

{$R *.res}

begin
  Application.Title:='Simple Video Player';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmVideoPlayer, frmVideoPlayer);
  Application.Run;
end.

