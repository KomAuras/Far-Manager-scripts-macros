--[[
  Показывает на панели внизу текущую ветку git
  За основу взят "Запуск макроса по событию смены директории"
  https://forum.farmanager.com/viewtopic.php?t=10521&start=16
--]]

local POLL_INTERVAL = 1000
local BOOST_INTERVAL = 100
local DISPLAY_INTERVAL = 100

local COL_MENUTEXT, COL_MENUSELECTEDTEXT, COL_MENUHIGHLIGHT,
  COL_MENUSELECTEDHIGHLIGHT, COL_MENUBOX, COL_MENUTITLE = 0,1,2,3,4,5

local function split(text, sep)
  local sep, fields = sep or "  ", {}
  local pattern = string.format("([^%s]+)", sep)
  text:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

local function NormalizePath (path)
  return [[\\?\]] .. path:gsub("/", "\\"):gsub("\\+$", "")
end

local function FileExists (path)
  return win.GetFileAttr(path) or win.GetFileAttr(NormalizePath(path))
end

local function GetColor (index)
  return far.AdvControl("ACTL_GETCOLOR", index)
end

local APanelPath = ''
local PPanelPath = ''
local APanelText = ""
local PPanelText = ""
local color = GetColor(9)

local function GetBranchName(file)
  local fp = io.open(file, "r")
  local str = fp:read("*all")
  fp:close()
  str = string.gsub(str, "\n", "")
  names = split(str, "/")
  return names[3]
end

local function RecursiveSearch(path)
  if FileExists(path.."\\.git\\HEAD") then
    return path.."\\.git\\HEAD"
  end
  local lastdotpos = (path:reverse()):find("%\\")
  if lastdotpos == nil then return nil end
  return RecursiveSearch(path:sub(1, -lastdotpos-1))
end

local function GetPanelState()
  if APanelPath ~= APanel.Path0 then
    APanelPath = APanel.Path0
    found = RecursiveSearch(APanelPath)
    if found ~= nil then
      APanelText = GetBranchName(found)
    else
      APanelText = ""
      panel.RedrawPanel(nil, 1)
    end
  end

  if PPanelPath ~= PPanel.Path0 then
    PPanelPath = PPanel.Path0
    found = RecursiveSearch(PPanelPath)
    if found ~= nil then
      PPanelText = GetBranchName(found)
    else
      PPanelText = ""
      panel.RedrawPanel(nil, 0)
    end
  end
end

timer = far.Timer(POLL_INTERVAL, function(timer)
  timer.Enabled = false
  GetPanelState()
  timer.Interval = POLL_INTERVAL
  timer.Enabled = true
end)

otimer = far.Timer(POLL_INTERVAL, function(otimer)
  otimer.Enabled = false
  local b
  if Area.Current == "Shell" then
    if APanel.Visible then
      b = 1
      if not APanel.Left then
        b = PPanel.Width + 1
      end
      far.Text(b, APanel.Height-3, color, APanelText)
    end
    if PPanel.Visible then
      b = 1
      if not PPanel.Left then
        b = APanel.Width + 1
      end
      far.Text(b, PPanel.Height-3, color, PPanelText)
    end
  end
  otimer.Interval = DISPLAY_INTERVAL
  otimer.Enabled = true
end)

timer.Interval = BOOST_INTERVAL

Event {
  description="ShowGitInfo: Clean up timer on exit";
  group="ExitFAR";
  uid="a7ed526d-45f1-43c0-b60a-2417046a53f4";
  action=function()
    --win.OutputDebugString('shutdown timer')
    timer:Close()
    otimer:Close()
  end;
}

Event {
  description="ShowGitInfo: Listen to input events";
  group="ConsoleInput";
  action=function(Rec)
    if ((Rec.EventType == far.Flags.KEY_EVENT) and (Rec.VirtualKeyCode ~= 0)) or
       ((Rec.EventType == far.Flags.MOUSE_EVENT) and (Rec.EventFlags ~= far.Flags.MOUSE_MOVED)) then
      timer.Interval = BOOST_INTERVAL
   end
  end;
}