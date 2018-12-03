-- подстановка макросов типа WebEdit

local function InsertMacro( macro_text )
  local info,selection = editor.GetInfo(),editor.GetSelection()
  local saved_text = Editor.SelValue;
  local new_text = macro_text;

  local pos = string.find(new_text, "@t");
  if pos ~= nil and pos > 0 then
    new_text = string.sub(new_text,1,pos-1)..saved_text..string.sub(new_text,pos+2);
  end

  pos = string.find(new_text, "@c");
  if pos ~= nil and pos > 0 then
    new_text = string.sub(new_text,1,pos-1)..string.sub(new_text,pos+2);
  end

  print(new_text);

  if pos ~= nil and pos > 0 then

    local cur_line = 0;
    local exists = 0;
    for s in new_text:gmatch("[^\r\n]+") do
      if string.find(s, "@c") ~= nil then
        exists = 1
        break
      end
      cur_line = cur_line + 1;
    end
    if exists == 0 then
      cur_line = 0
    end

    if selection ~= nil and selection.StartPos ~= nil then
      editor.SetPosition(nil, selection.StartLine + cur_line, selection.StartPos + ( pos - 1 ))
    else
      if info ~= nil then
        editor.SetPosition(nil, info.CurLine + cur_line, info.CurPos + ( pos - 1 ))
      end
    end
  end

end

local function RunMe()
  -- список команд
  items = {};
  items[1] = { text = "a", macro = "<a href=\"@c\">@t</a>" };
  items[2] = { text = "div", macro = "<div>@c@t</div>" };
  -- вызов меню и получение макроса
  IdMenu = "2a1b1346-d061-47ce-aebd-4c3bdc78f596";
  item, index = far.Menu({
    Title = title;
    Id = win.Uuid(IdMenu);
    Bottom = "Up Down Enter"
  },
  items);
  if index ~= nil and items[index].macro ~= '' then
    InsertMacro(items[index].macro);
  end
end

Macro {
  id="ac54350e-2860-4422-9077-4f4f6ecc0eeb";
  area="Editor";
  description="Editor: подстановка макросов типа WebEdit";
  key="CtrlQ";
  action=RunMe;
}
