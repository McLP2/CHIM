unit Control;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus, Spin,
  StdCtrls, EditBtn, ComCtrls, ExtCtrls, Math;

type

  { TFMcontrol }

  TFMcontrol = class(TForm)
    BTPreview: TButton;
    BTExport: TButton;
    CBPixelcolor: TColorButton;
    CBAutopreview: TCheckBox;
    FEImageforoverlay: TFileNameEdit;
    FEImagetohide: TFileNameEdit;
    FEEncrypted: TFileNameEdit;
    FEDecrypter: TFileNameEdit;
    GBGenerate: TGroupBox;
    GBExport: TGroupBox;
    GBPreview: TGroupBox;
    IMExport1: TImage;
    IMExport2: TImage;
    IMOutput: TImage;
    IMOverlay: TImage;
    IMHide: TImage;
    LBHidden1: TLabel;
    LBMultipier: TLabel;
    LBHidden: TLabel;
    LBImageforoverlay: TLabel;
    LBImagetohide: TLabel;
    LBPixelcolor: TLabel;
    LBPercentage: TLabel;
    LBHeight: TLabel;
    LBWidth: TLabel;
    MainMenu1: TMainMenu;
    MBFile: TMenuItem;
    MInone2: TMenuItem;
    MIImport: TMenuItem;
    MIOpen: TMenuItem;
    MISave: TMenuItem;
    MBHelp: TMenuItem;
    MIAbout: TMenuItem;
    MIExport: TMenuItem;
    MIClose: TMenuItem;
    MInone1: TMenuItem;
    MIDecrypt: TMenuItem;
    SEHeight: TSpinEdit;
    SEWidth: TSpinEdit;
    SEPercentage: TSpinEdit;
    SEMultiplier: TSpinEdit;
    StatusBar1: TStatusBar;
    procedure FEDecrypterChange(Sender: TObject);
    procedure SaveImages(Sender: TObject);
    procedure FEImageforoverlayChange(Sender: TObject);
    procedure FEImagetohideChange(Sender: TObject);
    procedure FEEncryptedChange(Sender: TObject);
    procedure MICloseClick(Sender: TObject);
    procedure Repaint(Sender: TObject);
    procedure SEPercentageChange(Sender: TObject);
  private
    procedure SaveToJpeg(const bmp: TBitmap; JpegFileName: String);
    procedure SaveToTiff(const bmp: TBitmap; TiffFileName: String);
    procedure SaveToPng(const bmp: TBitmap; PngFileName: String);
    procedure SaveToBmp(const bmp: TBitmap; BmpFileName: String);
  public

  end;

var
  FMcontrol: TFMcontrol;

implementation

{$R *.lfm}

{ TFMcontrol }

procedure TFMcontrol.MICloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFMcontrol.FEImageforoverlayChange(Sender: TObject);
begin
    if FileExists(FEImageforoverlay.FileName) then
      IMOverlay.Picture.LoadFromFile(FEImageforoverlay.FileName)
    else
      IMOverlay.Picture.Clear;
end;

procedure TFMcontrol.SaveImages(Sender: TObject);
var
  Percentage: Integer;
  LineV, LineH: Integer;
  exittext: String;
  Pixelcolor: TColor;
begin
  Randomize;
  IMExport1.Picture.Bitmap.SetSize(SEWidth.Value, SEHeight.Value);
  StatusBar1.Panels.Items[0].Text:='Fülle Bild mit Weiß...';
  StatusBar1.Update;
  if SEPercentage.Value > 50 then
    IMExport1.Picture.Bitmap.Canvas.Brush.Color := CBPixelcolor.ButtonColor
  else
    IMExport1.Picture.Bitmap.Canvas.Brush.Color := clWhite;
  IMExport1.Picture.Bitmap.Canvas.FillRect(0, 0, Width, Height);
  exittext:='Fertig: Fläche gefärbt';

  if not ((SEPercentage.Value = 0) or (SEPercentage.Value = 100)) then begin
  StatusBar1.Panels.Items[0].Text:='Färbe '+IntToStr(SEHeight.Value*SEWidth.Value)+' Pixel mit je '+IntToStr(SEPercentage.Value)+'% Wahrscheinlichkeit...';
  StatusBar1.Update;
  if SEPercentage.Value > 50 then begin
    Percentage := 100 - SEPercentage.Value;
    Pixelcolor := clWhite;
  end else begin
    Percentage := SEPercentage.Value;
    Pixelcolor := CBPixelcolor.ButtonColor;
  end;
  for LineH := 0 to SEHeight.Value do begin
  for LineV := 0 to SEWidth.Value do begin
    if Random(100) < Percentage then
      IMExport1.Picture.Bitmap.Canvas.Pixels[LineV,LineH]:=Pixelcolor;
  end;
  end;
  exittext:=exittext+' und gepixelt';
  end;
  IMExport2.Picture.Bitmap.SetSize(IMExport1.Picture.Bitmap.Width,IMExport1.Picture.Bitmap.Height);
  IMExport2.Picture.Bitmap.Canvas.Draw(0,0,IMExport1.Picture.Graphic);
  IMExport1.Picture.Bitmap.SetSize(Round(IMExport1.Picture.Width * SEMultiplier.Value),Round(IMExport1.Picture.Height * SEMultiplier.Value));
  IMExport1.Picture.Bitmap.Canvas.StretchDraw(Rect(0,0,Round(IMExport1.Picture.Width * SEMultiplier.Value),Round(IMExport1.Picture.Height * SEMultiplier.Value)),IMExport1.Picture.Bitmap);

  if (IMOverlay.Picture.Bitmap.Width > 0) and (IMOverlay.Picture.Bitmap.Height > 0) then begin
  StatusBar1.Panels.Items[0].Text:='Überlagere Bild...';
  StatusBar1.Update;
  IMExport1.Picture.Bitmap.Canvas.StretchDraw(Rect(0,0,IMExport1.Picture.Bitmap.Canvas.Width,IMExport1.Picture.Bitmap.Canvas.Height),IMOverlay.Picture.Graphic);
  exittext:=exittext+' und Bild auf Schlüssel überlagert';
  end;

  case ExtractFileExt(FEDecrypter.FileName) of
  '.png':
  SaveToPng(IMExport1.Picture.Bitmap,FEDecrypter.FileName);
  '.jpg','.jpeg':
  SaveToJpeg(IMExport1.Picture.Bitmap,FEDecrypter.FileName);
  '.tiff':
  SaveToTiff(IMExport1.Picture.Bitmap,FEDecrypter.FileName);
  '.bmp':
  SaveToBmp(IMExport1.Picture.Bitmap,FEDecrypter.FileName);
  otherwise
  SaveToPng(IMExport1.Picture.Bitmap,FEDecrypter.FileName+'.png');
  end;

  if (IMHide.Picture.Bitmap.Width > 0) and (IMHide.Picture.Bitmap.Height > 0) then begin
  StatusBar1.Panels.Items[0].Text:='Verstecke Bild...';
  StatusBar1.Update;
  for LineH := 0 to min(SEHeight.Value,IMHide.Picture.Bitmap.Height) do begin
  for LineV := 0 to min(SEWidth.Value,IMHide.Picture.Bitmap.Width) do begin
    if not ((IMHide.Picture.Bitmap.Canvas.Pixels[LineV,LineH] = clWhite) or (IMHide.Picture.Bitmap.Canvas.Pixels[LineV,LineH] = IMHide.Picture.Bitmap.TransparentColor)) then
      if IMExport2.Picture.Bitmap.Canvas.Pixels[LineV,LineH] = CBPixelcolor.ButtonColor then
        IMExport2.Picture.Bitmap.Canvas.Pixels[LineV,LineH] := clWhite
      else
        IMExport2.Picture.Bitmap.Canvas.Pixels[LineV,LineH] := CBPixelcolor.ButtonColor;
  end;
  end;
  exittext:=exittext+' und Bild versteckt';
  end;
  IMExport2.Picture.Bitmap.SetSize(Round(IMExport2.Picture.Width * SEMultiplier.Value),Round(IMExport2.Picture.Height * SEMultiplier.Value));
  IMExport2.Picture.Bitmap.Canvas.StretchDraw(Rect(0,0,Round(IMExport2.Picture.Width * SEMultiplier.Value),Round(IMExport2.Picture.Height * SEMultiplier.Value)),IMExport2.Picture.Bitmap);

  if (IMOverlay.Picture.Bitmap.Width > 0) and (IMOverlay.Picture.Bitmap.Height > 0) then begin
  StatusBar1.Panels.Items[0].Text:='Überlagere Bild...';
  StatusBar1.Update;
  IMExport2.Picture.Bitmap.Canvas.StretchDraw(Rect(0,0,IMExport2.Picture.Bitmap.Canvas.Width,IMExport2.Picture.Bitmap.Canvas.Height),IMOverlay.Picture.Graphic);
  exittext:=exittext+' und Bild auf Verschlüsseltem überlagert';
  end;

  case ExtractFileExt(FEDecrypter.FileName) of
  '.png':
  SaveToPng(IMExport2.Picture.Bitmap,FEEncrypted.FileName);
  '.jpg','.jpeg':
  SaveToJpeg(IMExport2.Picture.Bitmap,FEEncrypted.FileName);
  '.tiff':
  SaveToTiff(IMExport2.Picture.Bitmap,FEEncrypted.FileName);
  '.bmp':
  SaveToBmp(IMExport2.Picture.Bitmap,FEEncrypted.FileName);
  otherwise
  SaveToPng(IMExport2.Picture.Bitmap,FEEncrypted.FileName+'.png');
  end;

  StatusBar1.Panels.Items[0].Text:=exittext+'.';
  StatusBar1.Update;
end;

procedure TFMcontrol.FEDecrypterChange(Sender: TObject);
begin
    if (DirectoryExists(ExtractFilePath(FEEncrypted.Text)) and DirectoryExists(ExtractFilePath(FEDecrypter.Text))) and
       ((not (ExtractFileName(FEEncrypted.Text) = '')) and (not (ExtractFileName(FEDecrypter.Text) = ''))) then
         BTExport.Enabled:=true
    else
         BTExport.Enabled:=false;
end;

procedure TFMcontrol.FEImagetohideChange(Sender: TObject);
begin
    if FileExists(FEImagetohide.FileName) then
      IMHide.Picture.LoadFromFile(FEImagetohide.FileName)
    else
      IMHide.Picture.Clear;
end;

procedure TFMcontrol.FEEncryptedChange(Sender: TObject);
begin
    if (DirectoryExists(ExtractFilePath(FEEncrypted.Text)) and DirectoryExists(ExtractFilePath(FEDecrypter.Text))) and
       ((not (ExtractFileName(FEEncrypted.Text) = '')) and (not (ExtractFileName(FEDecrypter.Text) = ''))) then
         BTExport.Enabled:=true
    else
         BTExport.Enabled:=false;
end;

procedure TFMcontrol.SaveToJpeg(const bmp: TBitmap; JpegFileName: String);
var
  jpeg : TJpegImage;
begin
  jpeg := TJpegImage.Create;
  try
    jpeg.Assign(bmp);
    jpeg.SaveToFile(JpegFileName);
  finally
    jpeg.Free;
  end;
end;

procedure TFMcontrol.SaveToTiff(const bmp: TBitmap; TiffFileName: String);
var
  tiff : TTiffImage;
begin
  tiff := TTiffImage.Create;
  try
    tiff.Assign(bmp);
    tiff.SaveToFile(TiffFileName);
  finally
    tiff.Free;
  end;
end;

procedure TFMcontrol.SaveToBmp(const bmp: TBitmap; BmpFileName: String);
begin
  bmp.SaveToFile(BmpFileName);
end;

procedure TFMcontrol.SaveToPng(const bmp: TBitmap; PngFileName: String);
var
  png : TPortableNetworkGraphic;
begin
  png := TPortableNetworkGraphic.Create;
  try
    png.Assign(bmp);
    png.SaveToFile(PngFileName);
  finally
    png.Free;
  end;
end;

procedure TFMcontrol.Repaint(Sender: TObject);
var
  Percentage: Integer;
  LineV, LineH: Integer;
  exittext: String;
  Pixelcolor: TColor;
begin
  Randomize;
  IMOutput.Picture.Bitmap.SetSize(SEWidth.Value, SEHeight.Value);
  StatusBar1.Panels.Items[0].Text:='Fülle Bild mit Weiß...';
  StatusBar1.Update;
  if SEPercentage.Value > 50 then
    IMOutput.Picture.Bitmap.Canvas.Brush.Color := CBPixelcolor.ButtonColor
  else
    IMOutput.Picture.Bitmap.Canvas.Brush.Color := clWhite;
  IMOutput.Picture.Bitmap.Canvas.FillRect(0, 0, Width, Height);
  exittext:='Fertig: Fläche gefärbt';

  if not ((SEPercentage.Value = 0) or (SEPercentage.Value = 100)) then begin
  StatusBar1.Panels.Items[0].Text:='Färbe '+IntToStr(SEHeight.Value*SEWidth.Value)+' Pixel mit je '+IntToStr(SEPercentage.Value)+'% Wahrscheinlichkeit...';
  StatusBar1.Update;
  if SEPercentage.Value > 50 then begin
    Percentage := 100 - SEPercentage.Value;
    Pixelcolor := clWhite;
  end else begin
    Percentage := SEPercentage.Value;
    Pixelcolor := CBPixelcolor.ButtonColor;
  end;
  for LineH := 0 to SEHeight.Value do begin
  for LineV := 0 to SEWidth.Value do begin
    if Random(100) < Percentage then
      IMOutput.Picture.Bitmap.Canvas.Pixels[LineV,LineH]:=Pixelcolor;
  end;
  end;
  exittext:=exittext+' und gepixelt';
  end;

  if (IMHide.Picture.Bitmap.Width > 0) and (IMHide.Picture.Bitmap.Height > 0) then begin
  StatusBar1.Panels.Items[0].Text:='Verstecke Bild...';
  StatusBar1.Update;
  for LineH := 0 to min(SEHeight.Value,IMHide.Picture.Bitmap.Height) do begin
  for LineV := 0 to min(SEWidth.Value,IMHide.Picture.Bitmap.Width) do begin
    if not ((IMHide.Picture.Bitmap.Canvas.Pixels[LineV,LineH] = clWhite) or (IMHide.Picture.Bitmap.Canvas.Pixels[LineV,LineH] = IMHide.Picture.Bitmap.TransparentColor)) then
      if IMOutput.Picture.Bitmap.Canvas.Pixels[LineV,LineH] = CBPixelcolor.ButtonColor then
        IMOutput.Picture.Bitmap.Canvas.Pixels[LineV,LineH] := clWhite
      else
        IMOutput.Picture.Bitmap.Canvas.Pixels[LineV,LineH] := CBPixelcolor.ButtonColor;
  end;
  end;
  exittext:=exittext+' und Bild versteckt';
  end;

  if (IMOverlay.Picture.Bitmap.Width > 0) and (IMOverlay.Picture.Bitmap.Height > 0) then begin
  StatusBar1.Panels.Items[0].Text:='Überlagere Bild...';
  StatusBar1.Update;
  IMOutput.Picture.Bitmap.Canvas.StretchDraw(Rect(0,0,IMOutput.Picture.Bitmap.Canvas.Width,IMOutput.Picture.Bitmap.Canvas.Height),IMOverlay.Picture.Graphic);
  exittext:=exittext+' und Bild überlagert';
  end;

  StatusBar1.Panels.Items[0].Text:=exittext+'.';
  StatusBar1.Update;
end;

procedure TFMcontrol.SEPercentageChange(Sender: TObject);
begin
  if SEPercentage.Value = 50 then
    SEPercentage.Font.Color:=clGreen
  else
    SEPercentage.Font.Color:=clBlack;
end;

end.

