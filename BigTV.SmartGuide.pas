unit BigTV.SmartGuide;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.Grids, HGM.Controls.VirtualTable, Vcl.StdCtrls,
  System.Generics.Collections;

type
  TSmartGuideItem = record
    Channel: string;
    ChannelID: string;
    When: string;
    What: string;
    After: string;
  end;

  TSmartGuide = TTableData<TSmartGuideItem>;

  TFormGuide = class(TForm)
    TableExTvGuide: TTableEx;
    TimerUpdate: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TableExTvGuideGetData(FCol, FRow: Integer; var Value: string);
    procedure FormShow(Sender: TObject);
    procedure TableExTvGuideDblClick(Sender: TObject);
    procedure TimerUpdateTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    FSmartGuide: TSmartGuide;
  end;

var
  FormGuide: TFormGuide;

implementation

uses
  BigTV.Main, DateUtils;

{$R *.dfm}

procedure TFormGuide.Button1Click(Sender: TObject);
var
  i, j, delta: Integer;
  Item: TSmartGuideItem;
begin
  FSmartGuide.BeginUpdate;
  FSmartGuide.Clear;
  for i := 0 to FormMain.Channels.Count - 1 do
  begin
    Item.Channel := IntToStr(i+1) + ' '+ FormMain.Channels[i].Name;
    Item.ChannelID := FormMain.Channels[i].TVGName;
    Item.When := '';
    Item.What := '';
    Item.After := '';
    j := FormMain.Channels[i].NowWatchId;
    if IndexInList(j, FormMain.Channels[i].Guide.Count) then
    begin
      delta := GetMins(TimeOf(Now)) - GetMins(TimeOf(FormMain.Channels[i].Guide[j].Date));
     { if delta > 20 then
      begin
        if IndexInList(j + 1, FormMain.Channels[i].Guide.Count) then
        begin
          Item.What := FormMain.Channels[i].Guide[j + 1].Text;
          delta := GetMins(TimeOf(FormMain.Channels[i].Guide[j + 1].Date)) - GetMins(TimeOf(Now));
          Item.When := '????? ' + IntToStr(delta) + ' ???.';
        end;
        Item.After := '?????? ???? ' + FormMain.Channels[i].Guide[j].Text;
      end
      else
      begin   }
        Item.What := FormMain.Channels[i].Guide[j].Text;
        if delta = 0 then
          Item.When := '????? ??????'
        else
          Item.When := '???? ??? ' + IntToStr(delta) + ' ???.';
        if IndexInList(j + 1, FormMain.Channels[i].Guide.Count) then
          Item.After := '????? ' + FormMain.Channels[i].Guide[j + 1].Text;
     { end;  }
    end;
    FSmartGuide.Add(Item);
  end;
  FSmartGuide.EndUpdate;
end;

procedure TFormGuide.FormCreate(Sender: TObject);
begin
  FSmartGuide := TSmartGuide.Create(TableExTvGuide);
end;

procedure TFormGuide.FormDestroy(Sender: TObject);
begin
  FSmartGuide.Free;
end;

procedure TFormGuide.FormShow(Sender: TObject);
begin
  Button1Click(nil);
end;

procedure TFormGuide.TableExTvGuideDblClick(Sender: TObject);
var
  I: Integer;
begin
  if not IndexInList(TableExTvGuide.ItemIndex, FSmartGuide.Count) then
    Exit;
  I := FormMain.Channels.GetIdByTVGName(FSmartGuide[TableExTvGuide.ItemIndex].ChannelID);
  if not IndexInList(I, FormMain.Channels.Count) then
    Exit;
  FormMain.Play(I);
end;

procedure TFormGuide.TableExTvGuideGetData(FCol, FRow: Integer; var Value: string);
begin
  if not IndexInList(FRow, FSmartGuide.Count) then
    Exit;
  case FCol of
    0:
      Value := FSmartGuide[FRow].Channel;
    1:
      Value := FSmartGuide[FRow].What;
    2:
      Value := FSmartGuide[FRow].When;
    3:
      Value := FSmartGuide[FRow].After;
  end;
end;

procedure TFormGuide.TimerUpdateTimer(Sender: TObject);
begin
  if not Visible then
    Exit;
  Button1Click(nil);
end;

end.

