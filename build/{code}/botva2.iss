//这里存放的是botva2的函数声明

[Code]
type
  TBtnEventProc = procedure(h : hwnd);
  TPBProc = function(h : hwnd; Msg, wParam, lParam : longint) : longint;
  Win7TTimerProc = procedure(HandleW, Msg, idEvent, TimeSys: longword);

//botva2 API
function ImgLoad(h : hwnd; FileName : PAnsiChar; Left, Top, Width, Height : integer; Stretch, IsBkg : boolean) : longint; external 'ImgLoad@files:botva2.dll stdcall delayload';
procedure ImgSetVisibility(img : longint; Visible : boolean); external 'ImgSetVisibility@files:botva2.dll stdcall delayload';
procedure ImgApplyChanges(h : hwnd); external 'ImgApplyChanges@files:botva2.dll stdcall delayload';
procedure ImgSetPosition(img : longint; NewLeft, NewTop, NewWidth, NewHeight : integer); external 'ImgSetPosition@files:botva2.dll stdcall delayload';
procedure ImgRelease(img : longint); external 'ImgRelease@files:botva2.dll stdcall delayload';
procedure CreateFormFromImage(h : hwnd; FileName : PAnsiChar); external 'CreateFormFromImage@files:botva2.dll stdcall delayload';
procedure gdipShutdown();  external 'gdipShutdown@files:botva2.dll stdcall delayload';
function WrapBtnCallback(Callback : TBtnEventProc; ParamCount : integer) : longword; external 'wrapcallback@files:innocallback.dll stdcall delayload';
function BtnCreate(hParent : hwnd; Left, Top, Width, Height : integer; FileName : PAnsiChar; ShadowWidth : integer; IsCheckBtn : boolean) : hwnd;  external 'BtnCreate@files:botva2.dll stdcall delayload';
procedure BtnSetVisibility(h : hwnd; Value : boolean); external 'BtnSetVisibility@files:botva2.dll stdcall delayload';
procedure BtnSetEvent(h : hwnd; EventID : integer; Event : longword); external 'BtnSetEvent@files:botva2.dll stdcall delayload';
procedure BtnSetEnabled(h : hwnd; Value : boolean); external 'BtnSetEnabled@files:botva2.dll stdcall delayload';
function BtnGetChecked(h : hwnd) : boolean; external 'BtnGetChecked@files:botva2.dll stdcall delayload';
procedure BtnSetChecked(h : hwnd; Value : boolean); external 'BtnSetChecked@files:botva2.dll stdcall delayload';
procedure BtnSetPosition(h : hwnd; NewLeft, NewTop, NewWidth, NewHeight : integer);  external 'BtnSetPosition@files:botva2.dll stdcall delayload';
function PBCallBack(P : TPBProc; ParamCount : integer) : longword; external 'wrapcallback@files:innocallback.dll stdcall delayload';
procedure ImgSetVisiblePart(img : longint; NewLeft, NewTop, NewWidth, NewHeight : integer); external 'ImgSetVisiblePart@files:botva2.dll stdcall delayload';
function WrapTimerProc(Callback: Win7TTimerProc; ParamCount: integer): longword; external 'wrapcallback@files:InnoCallback.dll stdcall delayload';
//Windows API
function CreateRoundRectRgn(p1, p2, p3, p4, p5, p6 : integer) : THandle; external 'CreateRoundRectRgn@gdi32.dll stdcall';
function SetWindowRgn(h : hwnd; hRgn : THandle; bRedraw : boolean) : integer; external 'SetWindowRgn@user32.dll stdcall';
function ReleaseCapture() : longint; external 'ReleaseCapture@user32.dll stdcall';
function CallWindowProc(lpPrevWndFunc : longint; h : hwnd; Msg : UINT; wParam, lParam : longint) : longint; external 'CallWindowProcW@user32.dll stdcall';
function SetWindowLong(h : hwnd; Index : integer; NewLong : longint) : longint; external 'SetWindowLongW@user32.dll stdcall';
function GetWindowLong(h : hwnd; Index : integer) : longint; external 'GetWindowLongW@user32.dll stdcall';
function GetDC(hWnd: HWND): longword; external 'GetDC@user32.dll stdcall';
function BitBlt(DestDC: longword; X, Y, Width, Height: integer; SrcDC: longword; XSrc, YSrc: integer; Rop: DWORD): BOOL; external 'BitBlt@gdi32.dll stdcall';
function ReleaseDC(hWnd: HWND; hDC: longword): integer; external 'ReleaseDC@user32.dll stdcall';
function SetTimer(hWnd, nIDEvent, uElapse, lpTimerFunc: longword): longword; external 'SetTimer@user32.dll stdcall';
function KillTimer(hWnd, nIDEvent: longword): longword; external 'KillTimer@user32.dll stdcall';
function SetClassLong(h : hwnd; nIndex : integer; dwNewLong : longint) : DWORD; external 'SetClassLongW@user32.dll stdcall';
function GetClassLong(h : hwnd; nIndex : integer) : DWORD; external 'GetClassLongW@user32.dll stdcall';