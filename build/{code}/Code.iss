//引入botva2的函数声明
#include ".\botva2.iss"

[Code]
// type .\botva2.iss

const
  PRODUCT_REGISTRY_KEY_32 = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppID}_is1';
  PRODUCT_REGISTRY_KEY_64 = 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppID}_is1';
  WM_SYSCOMMAND = $0112;
  CS_DROPSHADOW = 131072;
  GCL_STYLE = -26;
  ID_BUTTON_ON_CLICK_EVENT = 1;
  WIZARDFORM_WIDTH_NORMAL = 600; //常规窗口宽度
  WIZARDFORM_HEIGHT_NORMAL = 400; // 常规窗口高度
  WIZARDFORM_HEIGHT_MORE = 503; // 自定义路径时的窗口高度
  SLIDES_PICTURE_WIDTH = WIZARDFORM_WIDTH_NORMAL; // 幻灯片图片宽度
  SLIDES_PICTURE_HEIGHT = 332;  // 幻灯片图片高度
  SLIDES_PAUSE_SECONDS = 3; // 暂留时间，秒

var
  label_wizardform_main, label_messagebox_main, label_wizardform_more_product_already_installed, label_messagebox_information, label_messagebox_title, label_wizardform_title, label_install_text, label_install_progress : TLabel;
  image_wizardform_background, image_messagebox_background, image_progressbar_background, image_progressbar_foreground, PBOldProc, licenseImg : longint;
  button_license, button_minimize, button_close, button_browse, button_setup_or_next, button_customize_setup, button_uncustomize_setup, checkbox_license, checkbox_setdefault, button_messagebox_close, button_messagebox_ok, button_messagebox_cancel, button_back : hwnd;
  is_wizardform_show_normal, is_installer_initialized, is_platform_windows_7, is_wizardform_released, can_exit_setup, need_to_change_associations : boolean;
  edit_target_path : TEdit;
  version_installed_before : string;
  messagebox_close : TSetupForm;
  wizardform_animation_timer, slide_picture_timer, slide_pause_timer : longword;
  // fake_main_form : TMainForm;
  slide_1_b, slide_2_b, slide_3_b, slide_4_b, slide_1_t, slide_2_t, slide_3_t, slide_4_t : longint;
  cur_pic_no, cur_pic_pos : integer;
  time_counter : integer;
  licenseRich:TRichEditViewer;

//botva2 API .\botva2.iss

//如果使用自定义卸载程序，就修改注册表，将默认卸载程序路径改为我们自己的卸载程序的路径
procedure change_reg_uninst;
begin
  if RegValueExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32, 'UninstallString') then
  begin
    RegDeleteValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32, 'UninstallString');
  end;
  if RegValueExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_64, 'UninstallString') then
  begin
    RegDeleteValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_64, 'UninstallString');
  end;
  if Is64BitInstallMode then
  begin
    RegWriteStringValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_64, 'UninstallString', ExpandConstant('"{app}\Uninstall.exe"'));
  end else
  begin
    RegWriteStringValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32, 'UninstallString', ExpandConstant('"{app}\Uninstall.exe"'));
  end;
end;

//停止轮播计时器
procedure stop_slide_timer;
begin
  if (slide_picture_timer <> 0) then
  begin
    KillTimer(0, slide_picture_timer);
    slide_picture_timer := 0;
  end;
end;

//停止暂停轮播用的计时器
procedure stop_slide_pause_timer;
begin
  if (slide_pause_timer <> 0) then
  begin
    KillTimer(0, slide_pause_timer);
    slide_pause_timer := 0;
    time_counter := 0;
  end;
end;

procedure pictures_slides_animation(HandleW, Msg, idEvent, TimeSys: longword); forward;

//暂停轮播
procedure slide_pause_for_a_while(HandleW, Msg, idEvent, TimeSys: longword);
begin
  stop_slide_timer;
  if (time_counter >= (SLIDES_PAUSE_SECONDS * 1000)) then
  begin
    stop_slide_pause_timer;
    time_counter := 0;
    slide_picture_timer := SetTimer(0, 0, 20, WrapTimerProc(@pictures_slides_animation, 4));
  end else
  begin
    time_counter := time_counter + 50;
  end;
end;

procedure pause_slides_for_a_while();
begin
  if (cur_pic_pos <= 0) then
  begin
    stop_slide_timer;
    if (slide_pause_timer = 0) then
    begin
      slide_pause_timer := SetTimer(0, 0, 10, WrapTimerProc(@slide_pause_for_a_while, 4));
    end;
  end;
end;

//安装时轮播图片
procedure pictures_slides_animation(HandleW, Msg, idEvent, TimeSys: longword);
begin
  cur_pic_pos := cur_pic_pos + 10;
  if (ScaleX(cur_pic_pos) > ScaleX(SLIDES_PICTURE_WIDTH)) then
  begin
    cur_pic_no := cur_pic_no + 1;
    cur_pic_pos := 0;
    pause_slides_for_a_while;
  end else
  begin
    if (cur_pic_no = 1) then
    begin
      ImgSetPosition(slide_1_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_4_t, False);
      ImgSetVisibility(slide_1_t, True);
    end;
    if (cur_pic_no = 2) then
    begin
      ImgSetPosition(slide_2_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_1_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_4_t, False);
      ImgSetVisibility(slide_2_t, True);
      ImgSetVisibility(slide_1_b, True);
      ImgSetVisibility(slide_3_b, False);
      ImgSetVisibility(slide_4_b, False);
      ImgSetVisibility(slide_2_b, False);
    end;
    if (cur_pic_no = 3) then
    begin
      ImgSetPosition(slide_3_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_1_t, False);
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_4_t, False);
      ImgSetVisibility(slide_3_t, True);
      ImgSetVisibility(slide_1_b, False);
      ImgSetVisibility(slide_3_b, False);
      ImgSetVisibility(slide_4_b, False);
      ImgSetVisibility(slide_2_b, True);
    end;
    if (cur_pic_no = 4) then
    begin
      ImgSetPosition(slide_4_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_1_t, False);
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_4_t, True);
      ImgSetVisibility(slide_1_b, False);
      ImgSetVisibility(slide_3_b, True);
      ImgSetVisibility(slide_4_b, False);
      ImgSetVisibility(slide_2_b, False);
    end;
    if (cur_pic_no > 4) then
    begin
      ImgSetPosition(slide_1_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_4_t, False);
      ImgSetVisibility(slide_1_t, True);
      ImgSetVisibility(slide_1_b, False);
      ImgSetVisibility(slide_3_b, False);
      ImgSetVisibility(slide_4_b, True);
      ImgSetVisibility(slide_2_b, False);
      cur_pic_no := 1;
    end;
  end;
  ImgApplyChanges(WizardForm.Handle);
end;

//轮播图片点击事件：打开特定网页
procedure slide_picture_on_click(Sender : TObject);
var
  URL : string;
  ErrorCode : Integer;
begin
  URL := '';
  case cur_pic_no of
    0: URL := 'http://www.example.com/';
    1: URL := 'http://www.example.com/';
    2: URL := 'http://www.example.com/';
    3: URL := 'http://www.example.com/';
    4: URL := 'http://www.example.com/';
  end;
  if URL <> '' then
  begin
    ShellExec('open', URL, '', '', SW_SHOW, ewNoWait,  ErrorCode);
  end;
end;

//停止动画计时器
procedure stop_animation_timer;
begin
  if (wizardform_animation_timer <> 0) then
  begin
    KillTimer(0, wizardform_animation_timer);
    wizardform_animation_timer := 0;
  end;
end;





//窗口变大动画
procedure show_full_wizardform_animation(HandleW, Msg, idEvent, TimeSys: longword);
begin
  if (WizardForm.ClientHeight < ScaleY(WIZARDFORM_HEIGHT_MORE)) then
  begin
    WizardForm.ClientHeight := WizardForm.ClientHeight + ScaleY(10);
  end else
  begin
    stop_animation_timer;
    WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_MORE);
  end;
end;

//窗口变小动画
procedure show_normal_wizardform_animation(HandleW, Msg, idEvent, TimeSys: longword);
begin
  if (WizardForm.ClientHeight > ScaleY(WIZARDFORM_HEIGHT_NORMAL)) then
  begin
    WizardForm.ClientHeight := WizardForm.ClientHeight - ScaleY(10);
  end else
  begin
    stop_animation_timer;
    WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_NORMAL);
  end;
end;


// 查看 license
procedure button_show_license_click(hBtn:HWND);
  begin
    if is_wizardform_show_normal=true then // isWelcomePage 是主页面
    begin
	    is_wizardform_show_normal:=false
      ImgSetVisibility(licenseImg,true) // licenseImg // 背景图
      ImgSetVisibility(image_wizardform_background,false) // BGimg welcome 背景图
      licenseRich.Height:=ScaleY(295) // licenseRich:TRichEditViewer;
      BtnSetVisibility(checkbox_license,false) // checkboxLicense:HWND;
      BtnSetVisibility(button_license,false) // btnShowLicense 应用协议  
      BtnSetVisibility(button_setup_or_next,false) // btnSetup,HWND; // 安装按钮
      BtnSetVisibility(button_back,true)
      image_wizardform_background := ImgLoad(wizardForm.Handle, ExpandConstant('{tmp}\bg_license.png'), 0, 0,ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
      stop_animation_timer;
      is_wizardform_show_normal := False;
      wizardform_animation_timer := SetTimer(0, 0, 1, WrapTimerProc(@show_normal_wizardform_animation, 4));
      BtnSetVisibility(button_customize_setup, False);
      BtnSetVisibility(button_uncustomize_setup, False);
    end else
    begin
      if (WizardForm.ClientHeight > ScaleY(WIZARDFORM_HEIGHT_NORMAL)) then
      begin
        is_wizardform_show_normal:=false;
        ImgSetVisibility(licenseImg,true);
        ImgSetVisibility(image_wizardform_background,false);
        licenseRich.Height:=ScaleY(295); 
        BtnSetVisibility(checkbox_license,false);
        BtnSetVisibility(button_license,false);
        BtnSetVisibility(button_setup_or_next,false);
        BtnSetVisibility(button_back,true);
        image_wizardform_background := ImgLoad(wizardForm.Handle, ExpandConstant('{tmp}\bg_license.png'), 0, 0,ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
        stop_animation_timer;
        is_wizardform_show_normal := False;
        wizardform_animation_timer := SetTimer(0, 0, 1, WrapTimerProc(@show_normal_wizardform_animation, 4));
        BtnSetVisibility(button_customize_setup, False);
        BtnSetVisibility(button_uncustomize_setup, False);
      end else
      begin
        is_wizardform_show_normal:=true
        ImgSetVisibility(image_wizardform_background,true)
        ImgSetVisibility(licenseImg,false)
        licenseRich.Height:=0
        BtnSetVisibility(checkbox_license,true)
        BtnSetVisibility(button_license,true)
        BtnSetVisibility(button_setup_or_next,true)
        BtnSetVisibility(button_back,false)
        image_wizardform_background := ImgLoad(wizardForm.Handle, ExpandConstant('{tmp}\background_welcome.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
        stop_animation_timer;
        wizardform_animation_timer := SetTimer(0, 0, 1, WrapTimerProc(@show_normal_wizardform_animation, 4));
        BtnSetVisibility(button_customize_setup, True);
        BtnSetVisibility(button_uncustomize_setup, False);
      end;
    end;
      ImgApplyChanges(WizardForm.Handle)
  end;


//判断系统版本，这个是决定是否要显示任务栏缩略图的依据
// function is_win7_or_newer : boolean;
// var
//   ver : TWindowsVersion;
// begin
//   GetWindowsVersionEx(ver);
//   if (ver.Major < 6) then
//   begin
//     Result := False;
//   end else
//   begin
//     Result := True;
//   end;
// end;


//调用这个函数可以使矩形窗口转变为圆角矩形窗口
procedure shape_form_round(aForm : TForm; edgeSize : integer);
var
  FormRegion : longword;
begin
  FormRegion := CreateRoundRectRgn(0, 0, aForm.ClientWidth, aForm.ClientHeight, edgeSize, edgeSize);
  SetWindowRgn(aForm.Handle, FormRegion, True);
end;

//这个函数的作用是判断是否已经安装了将要安装的产品，若已经安装，则返回TRUE，否则返回FALSE
function is_installed_before() : boolean;
begin
#ifndef _WIN64
  if is_platform_windows_7 then
  begin
    if Is64BitInstallMode then
    begin
      if RegKeyExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_64) then
      begin
        RegQueryStringValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_64, 'DisplayVersion', version_installed_before);
        Result := True;
      end else
      begin
        version_installed_before := '0.0.0';
        Result := False;
      end;
    end else
    begin
      if RegKeyExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32) then
      begin
        RegQueryStringValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32, 'DisplayVersion', version_installed_before);
        Result := True;
      end else
      begin
        version_installed_before := '0.0.0';
        Result := False;
      end;
    end;
  end else
  begin
    if RegKeyExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32) then
      begin
        RegQueryStringValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32, 'DisplayVersion', version_installed_before);
        Result := True;
      end else
      begin
        version_installed_before := '0.0.0';
        Result := False;
      end;
  end;
#else
  if RegKeyExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32) then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY_32, 'DisplayVersion', version_installed_before);
    Result := True;
  end else
  begin
    version_installed_before := '0.0.0';
    Result := False;
  end;
#endif
end;

//这个函数的作用是判断是否正在安装旧版本（若系统中已经安装了将要安装的产品），是则返回TRUE，否则返回FALSE
function is_installing_older_version() : boolean;
var
  installedVer : array[1..10] of longint;
  installingVer : array[1..10] of longint;
  oldVer, nowVer, version_installing_now : string;
  i, oldTotal, nowTotal, total : integer;
begin
  oldTotal := 1;
  while (Pos('.', version_installed_before) > 0) do
  begin
    oldVer := version_installed_before;
    Delete(oldVer, Pos('.', oldVer), ((Length(oldVer) - Pos('.', oldVer)) + 1));
    installedVer[oldTotal] := StrToIntDef(oldVer, 0);
    oldTotal := oldTotal + 1;
    version_installed_before := Copy(version_installed_before, (Pos('.', version_installed_before) + 1), (Length(version_installed_before) - Pos('.', version_installed_before)));
  end;
  if (version_installed_before <> '') then
  begin
    installedVer[oldTotal] := StrToIntDef(version_installed_before, 0);
  end else
  begin
    oldTotal := oldTotal - 1;
  end;
  version_installing_now := '{#MyAppVersion}';
  nowTotal := 1;
  while (Pos('.', version_installing_now) > 0) do
  begin
    nowVer := version_installing_now;
    Delete(nowVer, Pos('.', nowVer), ((Length(nowVer) - Pos('.', nowVer)) + 1));
    installingVer[nowTotal] := StrToIntDef(nowVer, 0);
    nowTotal := nowTotal + 1;
    version_installing_now := Copy(version_installing_now, (Pos('.', version_installing_now) + 1), (Length(version_installing_now) - Pos('.', version_installing_now)));
  end;
  if (version_installing_now <> '') then
  begin
    installingVer[nowTotal] := StrToIntDef(version_installing_now, 0);
  end else
  begin
    nowTotal := nowTotal - 1;
  end;
  if (oldTotal < nowTotal) then
  begin
    for i := (oldTotal + 1) to nowTotal do
    begin
      installedVer[i] := 0;
    end;
    total := nowTotal;
  end else if (oldTotal > nowTotal) then
  begin
    for i := (nowTotal + 1) to oldTotal do
    begin
      installingVer[i] := 0;
    end;
    total := oldTotal;
  end else
  begin
    total := nowTotal;
  end;
  for i := 1 to total do
  begin
    if (installedVer[i] > installingVer[i]) then
    begin
      Result := True;
      Exit;
    end else if (installedVer[i] < installingVer[i]) then
    begin
      Result := False;
      Exit;
    end else
    begin
      Continue;
    end;
  end;
  Result := False;
end;

//主界面关闭按钮按下时执行的脚本
procedure button_close_on_click(hBtn : hwnd);
begin
  WizardForm.CancelButton.OnClick(WizardForm);
end;

//主界面最小化按钮按下时执行的脚本
procedure button_minimize_on_click(hBtn : hwnd);
begin
  SendMessage(WizardForm.Handle, WM_SYSCOMMAND, 61472, 0);
end;

//主界面自定义安装按钮按下时执行的脚本
procedure button_customize_setup_on_click(hBtn : hwnd);
begin
  if is_wizardform_show_normal then
  begin
    stop_animation_timer;
    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_welcome_more.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_MORE), True, True);
    is_wizardform_show_normal := False;
    wizardform_animation_timer := SetTimer(0, 0, 1, WrapTimerProc(@show_full_wizardform_animation, 4));
    BtnSetVisibility(button_customize_setup, False);
    BtnSetVisibility(button_uncustomize_setup, True);
  end else
  begin
    stop_animation_timer;
    is_wizardform_show_normal := True;
    wizardform_animation_timer := SetTimer(0, 0, 1, WrapTimerProc(@show_normal_wizardform_animation, 4));
    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_welcome.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
    BtnSetVisibility(button_customize_setup, True);
    BtnSetVisibility(button_uncustomize_setup, False);
  end;
  ImgApplyChanges(WizardForm.Handle);
end;

//主界面浏览按钮按下时执行的脚本
procedure button_browse_on_click(hBtn : hwnd);
begin
  WizardForm.DirBrowseButton.OnClick(WizardForm);
  edit_target_path.Text := WizardForm.DirEdit.Text;
end;

//路径输入框文本变化时执行的脚本
procedure edit_target_path_on_change(Sender : TObject);
begin
  WizardForm.DirEdit.Text := edit_target_path.Text;
end;

//同意许可协议的复选框被点击时执行的脚本
procedure checkbox_license_on_click(hBtn : hwnd);
begin
    if BtnGetChecked(checkbox_license) then
    begin
      BtnSetEnabled(button_setup_or_next, True);
    end else
    begin
      BtnSetEnabled(button_setup_or_next, False);
    end;
end;

//设为默认软件的复选框被点击时执行的脚本
procedure checkbox_setdefault_on_click(hBtn : hwnd);
begin
  if BtnGetChecked(checkbox_setdefault) then
  begin
    need_to_change_associations := True;
  end else
  begin
    need_to_change_associations := False;
  end;
end;

//返回设为默认软件复选框的状态，已勾选则返回TRUE，否则返回FALSE
function is_setdefault_checkbox_checked() : boolean;
begin
  Result := need_to_change_associations;
end;

//若设为默认软件的复选框被勾选，则会在文件复制结束时执行此段脚本
procedure check_if_need_change_associations();
begin
  if is_setdefault_checkbox_checked() then
  begin
    //TODO
    MsgBox('此处执行注册文件后缀名的操作。', mbInformation, MB_OK);
  end;
end;

//主界面安装按钮按下时执行的脚本
procedure button_setup_or_next_on_click(hBtn : hwnd);
begin
  WizardForm.NextButton.OnClick(WizardForm);
end;

//复制文件时执行的脚本，每复制1%都会被调用一次，若要调整进度条或进度提示请在此段修改
function PBProc(h : hWnd; Msg, wParam, lParam : longint) : longint;
var
  pr, i1, i2 : EXTENDED;
  w : integer;
begin
  Result := CallWindowProc(PBOldProc, h, Msg, wParam, lParam);
  if ((Msg = $402) and (WizardForm.ProgressGauge.Position > WizardForm.ProgressGauge.Min)) then
  begin
    i1 := WizardForm.ProgressGauge.Position - WizardForm.ProgressGauge.Min;
    i2 := WizardForm.ProgressGauge.Max - WizardForm.ProgressGauge.Min;
    pr := (i1 * 100) / i2;
    label_install_progress.Caption := Format('%d', [Round(pr)]) + '%';
    w := Round((ScaleX(560) * pr) / 100);
    ImgSetPosition(image_progressbar_foreground, ScaleX(20), ScaleY(374), w, ScaleY(6));
    ImgSetVisiblePart(image_progressbar_foreground, 0, 0, w, ScaleY(6));
    ImgApplyChanges(WizardForm.Handle);
  end;
end;

//阅读许可协议的按钮按下时执行的脚本
// procedure button_license_on_click(hBtn : hwnd);
// var
//   ErrorCode : integer;
// begin
//   // button_show_license_click();
//   ShellExec('', '{#MyAppLicenseURL}', '', '', SW_SHOW, ewNoWait, ErrorCode);
// end;

//取消安装弹框的确定按钮按下时执行的脚本
procedure button_messagebox_ok_on_click(hBtn : hwnd);
begin
  can_exit_setup := True;
  messagebox_close.Close();
end;

//取消安装弹框的取消按钮按下时执行的脚本
procedure button_messagebox_cancel_on_click(hBtn : hwnd);
begin
  can_exit_setup := False;
  messagebox_close.Close();
end;

//主界面被点住就随鼠标移动的脚本
procedure wizardform_on_mouse_down(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : integer);
begin
  ReleaseCapture();
  SendMessage(WizardForm.Handle, WM_SYSCOMMAND, $F012, 0);
end;

//取消弹框被点住就随鼠标移动的脚本
procedure messagebox_on_mouse_down(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : integer);
begin
  ReleaseCapture();
  SendMessage(messagebox_close.Handle, WM_SYSCOMMAND, $F012, 0);
end;

//判断系统是否为Win7，是则返回TRUE，否则返回FALSE
procedure determine_wether_is_windows_7_or_not();
var
  sysVersion : TWindowsVersion;
begin
  GetWindowsVersionEx(sysVersion);
  if sysVersion.NTPlatform and (sysVersion.Major = 6) and (sysVersion.Minor = 1) then
  begin
    is_platform_windows_7 := True;
  end else
  begin
    is_platform_windows_7 := False;
  end;
end;

//创建取消弹框的脚本
procedure messagebox_close_create();
begin
  messagebox_close := CreateCustomForm();
  with messagebox_close do
  begin
    BorderStyle := bsNone;
    ClientWidth := ScaleX(380);
    ClientHeight := ScaleY(190);
    Color := clWhite;
    Caption := '';
  end;
  label_messagebox_title := TLabel.Create(messagebox_close);
  with label_messagebox_title do
  begin
    Parent := messagebox_close;
    AutoSize := False;
    Left := ScaleX(30);
    Top := ScaleY(5);
    ClientWidth := ScaleX(500);
    ClientHeight := ScaleY(20);
    Font.Size := 10;
    Font.Color := clWhite;
    Caption := CustomMessage('messagebox_close_title');
    Transparent := True;
    OnMouseDown := @messagebox_on_mouse_down;
  end;
  label_messagebox_information := TLabel.Create(messagebox_close);
  with label_messagebox_information do
  begin
    Parent := messagebox_close;
    AutoSize := False;
    Left := ScaleX(70);
    Top := ScaleY(64);
    ClientWidth := ScaleX(400);
    ClientHeight := ScaleY(20);
    Font.Size := 10;
    Font.Color := clBlack;
    Caption := CustomMessage('messagebox_close_text');
    Transparent := True;
    OnMouseDown := @messagebox_on_mouse_down;
  end;
  label_messagebox_main := TLabel.Create(messagebox_close);
  with label_messagebox_main do
  begin
    Parent := messagebox_close;
    AutoSize := False;
    Left := 0;
    Top := 0;
    ClientWidth := messagebox_close.ClientWidth;
    ClientHeight := messagebox_close.ClientHeight;
    Caption := '';
    Transparent := True;
    OnMouseDown := @messagebox_on_mouse_down;
  end;
  image_messagebox_background := ImgLoad(messagebox_close.Handle, ExpandConstant('{tmp}\background_messagebox.png'), 0, 0, ScaleX(380), ScaleY(190), True, True);
  button_messagebox_close := BtnCreate(messagebox_close.Handle, ScaleX(350), 0, ScaleX(30), ScaleY(30), ExpandConstant('{tmp}\button_close.png'), 0, False);
  BtnSetEvent(button_messagebox_close, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_messagebox_cancel_on_click, 1));
  button_messagebox_ok := BtnCreate(messagebox_close.Handle, ScaleX(206), ScaleY(150), ScaleX(76), ScaleY(28), ExpandConstant('{tmp}\button_ok.png'), 0, False);
  BtnSetEvent(button_messagebox_ok, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_messagebox_ok_on_click, 1));
  button_messagebox_cancel := BtnCreate(messagebox_close.Handle, ScaleX(293), ScaleY(150), ScaleX(76), ScaleY(28), ExpandConstant('{tmp}\button_cancel.png'), 0, False);
  BtnSetEvent(button_messagebox_cancel, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_messagebox_cancel_on_click, 1));
  ImgApplyChanges(messagebox_close.Handle);
end;

//释放安装程序时调用的脚本
procedure release_installer();
begin
  stop_slide_timer;
  stop_animation_timer;
  gdipShutdown();
  messagebox_close.Release();
  WizardForm.Release();
end;

//在初始化之后释放安装程序的脚本
procedure release_installer_after_init();
begin
  messagebox_close.Release();
  WizardForm.Release();
end;

//释放需要的临时资源文件
procedure extract_temp_files();
begin
  ExtractTemporaryFile('license.txt');
  ExtractTemporaryFile('btn_back.png');
  ExtractTemporaryFile('bg_license.png');
  ExtractTemporaryFile('button_customize_setup.png');
  ExtractTemporaryFile('button_uncustomize_setup.png');
  ExtractTemporaryFile('button_finish.png');
  ExtractTemporaryFile('button_setup_or_next.png');
  ExtractTemporaryFile('background_welcome.png');
  ExtractTemporaryFile('background_welcome_more.png');
  ExtractTemporaryFile('button_browse.png');
  ExtractTemporaryFile('progressbar_background.png');
  ExtractTemporaryFile('progressbar_foreground.png');
  ExtractTemporaryFile('button_license.png');
  ExtractTemporaryFile('checkbox_license.png');
  #ifdef RegisteAssociations
    ExtractTemporaryFile('checkbox_setdefault.png');
  #endif
  #ifdef ShowSlidePictures
    ExtractTemporaryFile('slides_picture_1.png');
    ExtractTemporaryFile('slides_picture_2.png');
    ExtractTemporaryFile('slides_picture_3.png');
    ExtractTemporaryFile('slides_picture_4.png');
  #endif
    ExtractTemporaryFile('background_installing.png');
    ExtractTemporaryFile('background_finish.png');
    ExtractTemporaryFile('button_close.png');
    ExtractTemporaryFile('button_minimize.png');
    ExtractTemporaryFile('background_messagebox.png');
    ExtractTemporaryFile('button_cancel.png');
    ExtractTemporaryFile('button_ok.png');
end;

//重载主界面取消按钮被按下后的处理过程
procedure CancelButtonClick(CurPageID : integer; var Cancel, Confirm: boolean);
begin
  Confirm := False;
  //messagebox_close.Center();
  messagebox_close.ShowModal();
  if can_exit_setup then
  begin
    release_installer();
    Cancel := True;
  end else
  begin
    Cancel := False;
  end;
end;

//重载安装程序初始化函数，判断是否已经安装新版本，是则禁止安装
function InitializeSetup() : boolean;
begin
  #ifndef PortableBuild
  #ifdef OnlyInstallNewVersion
    if is_installed_before() then
    begin
      if is_installing_older_version() then
      begin
        MsgBox(CustomMessage('init_setup_outdated_version_warning'), mbInformation, MB_OK);
        Result := False;
      end else
      begin
        Result := True;
      end;
    end else
    begin
      Result := True;
    end;
  #else
    Result := True;
  #endif
  #else
    Result := True;
  #endif
end;

//重载安装程序初始化函数（和上边那个不一样），进行初始化操作
procedure InitializeWizard();
begin
  is_installer_initialized := True;
  is_wizardform_show_normal := True;
  is_wizardform_released := False;
  need_to_change_associations := True;
  determine_wether_is_windows_7_or_not();
  extract_temp_files();
  WizardForm.InnerNotebook.Hide();
  WizardForm.OuterNotebook.Hide();
  WizardForm.Bevel.Hide();
  with WizardForm do
  begin
    BorderStyle := bsNone;
    // Position := poDesktopCenter;
    Position := poScreenCenter;
    ClientWidth := ScaleX(WIZARDFORM_WIDTH_NORMAL);
    ClientHeight := ScaleY(WIZARDFORM_HEIGHT_MORE);
    Color := clWhite;
    NextButton.ClientHeight := 0;
    CancelButton.ClientHeight := 0;
    BackButton.Visible := False;
  end;
  label_wizardform_title := TLabel.Create(WizardForm);
  with label_wizardform_title do
  begin
    Parent := WizardForm;
    AutoSize := False;
    Left := ScaleX(10);
    Top := ScaleY(5);
    ClientWidth := ScaleX(300);
    ClientHeight := ScaleY(20);
    Font.Size := 9;
    Font.Color := clWhite;
    Caption := CustomMessage('wizardform_title');
    Transparent := True;
    OnMouseDown := @wizardform_on_mouse_down;
  end;
  label_wizardform_more_product_already_installed := TLabel.Create(WizardForm);
  with label_wizardform_more_product_already_installed do
  begin
    Parent := WizardForm;
    AutoSize := False;
    Left := ScaleX(85);
    Top := ScaleY(449);
    ClientWidth := ScaleX(300);
    ClientHeight := ScaleY(20);
    Font.Size := 9;
    Font.Color := clGray;
    Caption := CustomMessage('no_change_destdir_warning');
    Transparent := True;
    OnMouseDown := @wizardform_on_mouse_down;
  end;
  label_wizardform_more_product_already_installed.Hide();
  label_wizardform_main := TLabel.Create(WizardForm);
  with label_wizardform_main do
  begin
    Parent := WizardForm;
    AutoSize := False;
    Left := 0;
    Top := 0;
    ClientWidth := WizardForm.ClientWidth;
    ClientHeight := WizardForm.ClientHeight;
    Caption := '';
    Transparent := True;
    OnMouseDown := @wizardform_on_mouse_down;
  end;
  edit_target_path := TEdit.Create(WizardForm);
  with edit_target_path do
  begin
    Parent := WizardForm;
    Text := WizardForm.DirEdit.Text;
    Font.Size := 9;
    BorderStyle := bsNone;
    SetBounds(ScaleX(91), ScaleY(423), ScaleX(402), ScaleY(20));
    OnChange := @edit_target_path_on_change;
    Color := clWhite;
    TabStop := False;
  end;

  // 查看 license 的文本区域
  licenseRich:= TRichEditViewer.Create(WizardForm);
  with licenseRich do
  begin
    Parent:=WizardForm;
    ReadOnly:=true;
    SCROLLBARS:=ssVertical;
    font.Name:='宋体';
    font.Size:=12;
    Color:=clWhite;
    BorderStyle:=bsNone;
    SetBounds(ScaleX(40),ScaleY(45),ScaleY(520),0)
    // Lines.LoadFromFile(ExpandConstant('{#MyAPPLicensePath}'));
    Lines.LoadFromFile(ExpandConstant('{tmp}\license.txt'));
    TabStop:=false;
  end;

  edit_target_path.Hide();

  button_close := BtnCreate(WizardForm.Handle, ScaleX(570), 0, ScaleX(30), ScaleY(30), ExpandConstant('{tmp}\button_close.png'), 0, False);
  BtnSetEvent(button_close, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_close_on_click, 1));

  button_minimize := BtnCreate(WizardForm.Handle, ScaleX(540), 0, ScaleX(30), ScaleY(30), ExpandConstant('{tmp}\button_minimize.png'), 0, False);
  BtnSetEvent(button_minimize, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_minimize_on_click, 1));

  button_setup_or_next := BtnCreate(WizardForm.Handle, ScaleX(211), ScaleY(305), ScaleX(178), ScaleY(43), ExpandConstant('{tmp}\button_setup_or_next.png'), 0, False);
  BtnSetEvent(button_setup_or_next, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_setup_or_next_on_click, 1));

  button_browse := BtnCreate(WizardForm.Handle, ScaleX(506), ScaleY(420), ScaleX(75), ScaleY(24), ExpandConstant('{tmp}\button_browse.png'), 0, False);
  BtnSetEvent(button_browse, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_browse_on_click, 1));
  BtnSetVisibility(button_browse, False);

  button_customize_setup := BtnCreate(WizardForm.Handle, ScaleX(511), ScaleY(374), ScaleX(78), ScaleY(14), ExpandConstant('{tmp}\button_customize_setup.png'), 0, False);
  BtnSetEvent(button_customize_setup, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_customize_setup_on_click, 1));
  button_uncustomize_setup := BtnCreate(WizardForm.Handle, ScaleX(511), ScaleY(374), ScaleX(78), ScaleY(14), ExpandConstant('{tmp}\button_uncustomize_setup.png'), 0, False);
  BtnSetEvent(button_uncustomize_setup, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_customize_setup_on_click, 1));
  BtnSetVisibility(button_uncustomize_setup, False);

  button_back:=BtnCreate(WizardForm.Handle,ScaleX(260),ScaleY(358),ScaleX(80),ScaleY(32),ExpandConstant('{tmp}\btn_back.png'),0,False)
  BtnSetEvent(button_back,ID_BUTTON_ON_CLICK_EVENT,WrapBtnCallback(@button_show_license_click,1));
  BtnSetVisibility(button_back,false)

  PBOldProc := SetWindowLong(WizardForm.ProgressGauge.Handle, -4, PBCallBack(@PBProc, 4));
  ImgApplyChanges(WizardForm.Handle);
  messagebox_close_create();
  SetClassLong(WizardForm.Handle, GCL_STYLE, GetClassLong(WizardForm.Handle, GCL_STYLE) or CS_DROPSHADOW);
  SetClassLong(messagebox_close.Handle, GCL_STYLE, GetClassLong(messagebox_close.Handle, GCL_STYLE) or CS_DROPSHADOW);
  cur_pic_no := 0;
  cur_pic_pos := 0;
#ifdef EnableRoundRect
	shape_form_round(WizardForm,{#RoundRectData});
#endif
end;

//安装程序销毁时会调用这个函数
procedure DeinitializeSetup();
begin
  if ((is_wizardform_released = False) and (can_exit_setup = False)) then
  begin
    stop_slide_timer;
    stop_animation_timer;
    gdipShutdown();
    if is_installer_initialized then
    begin
      release_installer_after_init();
    end;
  end;
end;

//安装页面改变时会调用这个函数
procedure CurPageChanged(CurPageID : integer);
begin
  if (CurPageID = wpWelcome) then
  begin
    //
    licenseImg:=ImgLoad(WizardForm.Handle,ExpandConstant('{tmp}\bg_license.png'),0,0,ScaleX(WIZARDFORM_WIDTH_NORMAL),ScaleY(WIZARDFORM_HEIGHT_NORMAL),true,true);
		ImgSetVisibility(licenseImg,false)

    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_welcome.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
    button_license := BtnCreate(WizardForm.Handle, ScaleX(110), ScaleY(376), ScaleX(96), ScaleY(12), ExpandConstant('{tmp}\button_license.png'), 0, False);
    // BtnSetEvent(button_license, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_license_on_click, 1))
    BtnSetEvent(button_license, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_show_license_click, 1))
    checkbox_license := BtnCreate(WizardForm.Handle, ScaleX(11), ScaleY(374), ScaleX(93), ScaleY(17), ExpandConstant('{tmp}\checkbox_license.png'), 0, True);
    BtnSetEvent(checkbox_license, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@checkbox_license_on_click, 1));
    BtnSetChecked(checkbox_license, True);
    #ifdef RegisteAssociations
        checkbox_setdefault := BtnCreate(WizardForm.Handle, ScaleX(85), ScaleY(470), ScaleX(92), ScaleY(17), ExpandConstant('{tmp}\checkbox_setdefault.png'), 0, True);
        BtnSetEvent(checkbox_setdefault, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@checkbox_setdefault_on_click, 1));
        BtnSetChecked(checkbox_setdefault, True);
        BtnSetVisibility(checkbox_setdefault, True);
    #endif
        edit_target_path.Show();
        BtnSetVisibility(button_browse, True);
        BtnSetVisibility(button_customize_setup, True);
        BtnSetVisibility(button_uncustomize_setup, False);
    #ifndef PortableBuild
        if is_installed_before() then
        begin
          edit_target_path.Enabled := False;
          BtnSetEnabled(button_browse, False);
          label_wizardform_more_product_already_installed.Show();
        end;
    #endif
        WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_NORMAL);
        ImgApplyChanges(WizardForm.Handle);
  end;
  if (CurPageID = wpInstalling) then
  begin
    stop_animation_timer;
    is_wizardform_show_normal := True;
    wizardform_animation_timer := SetTimer(0, 0, 1, WrapTimerProc(@show_normal_wizardform_animation, 4));
    edit_target_path.Hide();
    label_wizardform_more_product_already_installed.Hide();
    BtnSetVisibility(button_browse, False);
    is_wizardform_show_normal := True;
    BtnSetVisibility(button_customize_setup, False);
    BtnSetVisibility(button_uncustomize_setup, False);
    BtnSetVisibility(button_close, False);
    BtnSetPosition(button_minimize, ScaleX(570), 0, ScaleX(30), ScaleY(30));
    #ifdef RegisteAssociations
        BtnSetVisibility(checkbox_setdefault, False);
    #endif
    BtnSetVisibility(button_license, False);
    BtnSetVisibility(checkbox_license, False);
    label_install_text := TLabel.Create(WizardForm);
    with label_install_text do
    begin
      Parent := WizardForm;
      AutoSize := False;
      Left := ScaleX(20);
      Top := ScaleY(349);
      ClientWidth := ScaleX(60);
      ClientHeight := ScaleY(30);
      Font.Size := 10;
      Font.Color := clBlack;
      Caption := CustomMessage('installing_label_text');
      Transparent := True;
      OnMouseDown := @wizardform_on_mouse_down;
    end;
    label_install_progress := TLabel.Create(WizardForm);
    with label_install_progress do
    begin
      Parent := WizardForm;
      AutoSize := False;
      Left := ScaleX(547);
      Top := ScaleY(349);
      ClientWidth := ScaleX(30);
      ClientHeight := ScaleY(30);
      Font.Size := 10;
      Font.Color := clBlack;
      Caption := '';
      Transparent := True;
      Alignment := taRightJustify;
      OnMouseDown := @wizardform_on_mouse_down;
    end;
    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_installing.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
    image_progressbar_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\progressbar_background.png'), ScaleX(20), ScaleY(374), ScaleX(560), ScaleY(6), True, True);
    image_progressbar_foreground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\progressbar_foreground.png'), ScaleX(20), ScaleY(374), 0, 0, True, True);
    BtnSetVisibility(button_setup_or_next, False);
    #ifdef ShowSlidePictures
        slide_1_b := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_1.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        slide_2_b := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_2.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        slide_3_b := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_3.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        slide_4_b := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_4.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        slide_1_t := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_1.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        slide_2_t := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_2.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        slide_3_t := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_3.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        slide_4_t := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\slides_picture_4.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        ImgSetVisibility(slide_1_t, False);
        ImgSetVisibility(slide_2_t, False);
        ImgSetVisibility(slide_3_t, False);
        ImgSetVisibility(slide_4_t, False);
        ImgSetVisibility(slide_1_b, False);
        ImgSetVisibility(slide_2_b, False);
        ImgSetVisibility(slide_3_b, False);
        ImgSetVisibility(slide_4_b, False);
    #endif
    ImgApplyChanges(WizardForm.Handle);
    #ifdef ShowSlidePictures
        stop_slide_timer;
        stop_slide_pause_timer;
        time_counter := 0;
        slide_picture_timer := SetTimer(0, 0, 20, WrapTimerProc(@pictures_slides_animation, 4));
    #endif
  end;
  if (CurPageID = wpFinished) then
  begin
    #ifdef ShowSlidePictures
        stop_slide_timer;
        stop_slide_pause_timer;
        time_counter := 0;
    #endif
      label_install_text.Caption := '';
      label_install_text.Visible := False;
      label_install_progress.Caption := '';
      label_install_progress.Visible := False;
      ImgSetVisibility(image_progressbar_background, False);
      ImgSetVisibility(image_progressbar_foreground, False);
      BtnSetPosition(button_minimize, ScaleX(540), 0, ScaleX(30), ScaleY(30));
      BtnSetVisibility(button_close, True);
      button_setup_or_next := BtnCreate(WizardForm.Handle, ScaleX(214), ScaleY(305), ScaleX(180), ScaleY(44), ExpandConstant('{tmp}\button_finish.png'), 0, False);
      BtnSetEvent(button_setup_or_next, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_setup_or_next_on_click, 1));
      BtnSetEvent(button_close, ID_BUTTON_ON_CLICK_EVENT, WrapBtnCallback(@button_setup_or_next_on_click, 1));
      image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\background_finish.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
      ImgApplyChanges(WizardForm.Handle);
  end;
end;

//安装步骤改变时会调用这个函数
procedure CurStepChanged(CurStep : TSetupStep);
begin
  if (CurStep = ssPostInstall) then
  begin
    #ifdef RegisteAssociations
        check_if_need_change_associations();
    #endif
        //and do other things you want
  end;
  if (CurStep = ssDone) then
  begin
    is_wizardform_released := True;
    release_installer();
    #ifdef UseCustomUninstaller
        change_reg_uninst;
    #endif
  end;
end;

//指定跳过哪些标准页面
function ShouldSkipPage(PageID : integer) : boolean;
begin
  if (PageID = wpLicense) then Result := True;
  if (PageID = wpPassword) then Result := True;
  if (PageID = wpInfoBefore) then Result := True;
  if (PageID = wpUserInfo) then Result := True;
  if (PageID = wpSelectDir) then Result := True;
  if (PageID = wpSelectComponents) then Result := True;
  if (PageID = wpSelectProgramGroup) then Result := True;
  if (PageID = wpSelectTasks) then Result := True;
  if (PageID = wpReady) then Result := True;
  if (PageID = wpPreparing) then Result := True;
  if (PageID = wpInfoAfter) then Result := True;
end;
