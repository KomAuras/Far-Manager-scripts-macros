Macro {
  area="Editor";
  description="Editor: перезагрузка макросов";
  key="CtrlR";
  action=function()
    far.MacroLoadAll();
    win.OutputDebugString('перечитали макросы!');
  end;
}
