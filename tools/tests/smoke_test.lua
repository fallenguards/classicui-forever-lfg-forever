-- Offline test under Lua 5.4: the addon's files in a fake client. LFG Forever's window is made the way it makes it
-- (CreateFrame by name, its scripts set, its panels and tabs, then shown), and the addon must catch it, register it in
-- ClassicUI Forever's window row once, dress it at its first show and lay its pieces without an error.
-- Modes: kit (ClassicUI Forever with its Looking For Group window on), off (that window off), nokit (no kit at all).
-- Run from the addon root: lua tools/tests/smoke_test.lua kit
-- luacheck: std lua54
-- luacheck: ignore 111 112 113 121 122 142 143 211 212 213 431 432

local MODE = arg and arg[1] or "kit"
local ROOT = (arg and arg[0] or ""):gsub("[\\/]tools[\\/]tests[\\/][^\\/]*$", "")
if ROOT == (arg and arg[0]) or ROOT == "" then ROOT = "." end
unpack = table.unpack

local failed = 0
local function Check(ok, what)
    if not ok then
        failed = failed + 1
        print("FAIL [" .. MODE .. "] " .. what)
    end
end

------------------------------------------------------------------ the fake client

local Region = {}
local RegionMT = { __index = Region }
local function New(kind, name, parent)
    local r = setmetatable({ _kind = kind, _name = name, _parent = parent, _points = {}, _shown = true, _w = 0, _h = 0,
        _alpha = 1, _children = {}, _regions = {}, _scripts = {}, _hooks = {}, _level = 1 }, RegionMT)
    if parent then
        local list = (kind == "Texture" or kind == "FontString") and parent._regions or parent._children
        list[#list + 1] = r
        r._level = parent._level + 1
    end
    if name then _G[name] = r end
    return r
end
function Region:GetObjectType() return self._kind end
function Region:GetName() return self._name end
function Region:GetParent() return self._parent end
function Region:SetParent(p)
    local old = self._parent
    if old then
        for i, c in ipairs(old._children) do
            if c == self then table.remove(old._children, i) break end
        end
    end
    self._parent = p
    p._children[#p._children + 1] = self
end
function Region:GetChildren() return unpack(self._children) end
function Region:GetRegions() return unpack(self._regions) end
function Region:GetNumChildren() return #self._children end
function Region:CreateTexture(_, layer) return New("Texture", nil, self) end
function Region:CreateFontString() return New("FontString", nil, self) end
function Region:SetSize(w, h) self._w, self._h = w, h end
function Region:SetWidth(w) self._w = w end
function Region:SetHeight(h) self._h = h end
function Region:GetWidth() return self._w end
function Region:GetHeight() return self._h end
function Region:GetSize() return self._w, self._h end
function Region:ClearAllPoints() self._points = {} end
function Region:SetPoint(point, rel, relPoint, x, y)
    if type(rel) == "number" then rel, relPoint, x, y = self._parent, point, rel, relPoint end
    for i, p in ipairs(self._points) do
        if p[1] == point then table.remove(self._points, i) break end
    end
    table.insert(self._points, { point, rel or self._parent, relPoint or point, x or 0, y or 0 })
end
function Region:SetAllPoints(rel) self._points = { { "TOPLEFT", rel or self._parent, "TOPLEFT", 0, 0 } } end
function Region:GetNumPoints() return #self._points end
function Region:GetPoint(i) local p = self._points[i or 1]; if p then return unpack(p) end end
-- Every region stands at the screen's corner, 100 across: enough for the layout's arithmetic to run.
function Region:GetLeft() return 0 end
function Region:GetRight() return self._w > 0 and self._w or 100 end
function Region:GetTop() return 400 end
function Region:GetBottom() return 380 end
function Region:Show()
    local was = self._shown
    self._shown = true
    if not was then self:Fire("OnShow") end
end
function Region:Hide()
    local was = self._shown
    self._shown = false
    if was then self:Fire("OnHide") end
end
function Region:SetShown(on) if on then self:Show() else self:Hide() end end
function Region:IsShown() return self._shown end
function Region:IsVisible()
    local r = self
    while r do
        if not r._shown then return false end
        r = r._parent
    end
    return true
end
function Region:SetScript(script, fn)
    self._scripts[script] = fn
    self._hooks[script] = nil
end
function Region:GetScript(script) return self._scripts[script] end
function Region:HookScript(script, fn)
    self._hooks[script] = self._hooks[script] or {}
    table.insert(self._hooks[script], fn)
end
function Region:Fire(script, ...)
    if self._scripts[script] then self._scripts[script](self, ...) end
    for _, fn in ipairs(self._hooks[script] or {}) do fn(self, ...) end
end
function Region:SetFrameLevel(l) self._level = l end
function Region:GetFrameLevel() return self._level end
function Region:SetAlpha(a) self._alpha = a end
function Region:GetAlpha() return self._alpha end
function Region:GetStringHeight() return 14 end
function Region:GetStringWidth() return 60 end
function Region:GetText() return self._text end
function Region:SetText(t) self._text = t end
function Region:SetFontObject(f) self._font = f end
function Region:GetFontObject() return self._font end
-- Every other widget call is accepted and answers nothing.
setmetatable(Region, { __index = function() return function() end end })

CreateFrame = function(kind, name, parent, template)
    local f = New(kind, name, parent)
    if template == "PanelTopTabButtonTemplate" then
        f.Left, f.Middle, f.Right = f:CreateTexture(), f:CreateTexture(), f:CreateTexture()
    elseif template == "UIPanelButtonTemplate" then
        f.Left, f.Middle, f.Right = f:CreateTexture(), f:CreateTexture(), f:CreateTexture()
    end
    return f
end
-- The post-hook the client gives: the original first, then the hook, the global replaced.
hooksecurefunc = function(a, b, c)
    local tbl, key, fn = a, b, c
    if type(a) == "string" then tbl, key, fn = _G, a, b end
    local orig = tbl[key]
    tbl[key] = function(...)
        local r = { orig(...) }
        fn(...)
        return unpack(r)
    end
end
InCombatLockdown = function() return false end
PlaySound = function() end
SOUNDKIT = { IG_CHARACTER_INFO_TAB = 1 }
C_LFGList = { HasActiveEntryInfo = function() return false end }
PanelTemplates_SelectTab = function(tab) tab._selected = true end
PanelTemplates_DeselectTab = function(tab) tab._selected = false end
CLOSE = "Close"
GameFontNormal, GameFontHighlight, GameFontNormalSmall, GameFontHighlightSmall = {}, {}, {}, {}
issecretvalue = function() return false end

------------------------------------------------------------------ ClassicUI Forever's kit, recorded

local calls = { register = {}, lend = 0, adopt = 0, skins = 0 }
local kit = {
    version = 1,
    IsOn = function(name) return name == "groupFinder" and MODE == "kit" end,
    OnToggle = function() end,
    SetTex = function() end,
    TileTex = function(tex) return tex end,
    PANE_SHADE = 0.9,
    SkinRedButton = function() calls.skins = calls.skins + 1 end,
    SkinCheckbox = function() calls.skins = calls.skins + 1 end,
    SkinDropdown = function() end,
    EraDropdownArt = function() end,
    SkinScrollBarsUnder = function() end,
    SkinScrollBar = function() end,
    SkinCloseButton = function() end,
    SkinTopTab = function() end,
    ClassicScrollBar = function(parent)
        local bar = New("Slider", nil, parent)
        bar.SetRange = function() end
        bar.GetValue = function() return 0 end
        return bar
    end,
    AdoptSideTabs = function(window, under, own, first)
        calls.adopt = calls.adopt + 1
        calls.first = first
    end,
    RegisterWindow = function(frame, pushable) table.insert(calls.register, { frame, pushable }) end,
    ShowPanel = function() return true end,
    HidePanel = function(frame) frame:Hide() return true end,
    SetSlotWidth = function(frame, w) calls.slot = w end,
    SIDE_TAB_SLOT = 392,
    LendFinderTabs = function(window, hosts) calls.lend = calls.lend + 1; calls.hosts = hosts end,
    FinderTabs = function()
        return { { icon = "i1", text = "Create Listing" }, { icon = "i2", text = "Group Browser" }, { icon = "i3", text = "Who" } }
    end,
    FinderWhoOwn = function() return false end,
    FinderWhoHidden = function() return true end,
    WarmGroupFinder = function() end,
    OpenWhoList = function() calls.who = true end,
    SayNotInCombat = function() end,
    EraEyeFrame = function() end,
    ERA_EYE_FRAMES = 29,
    ERA_EYE_TIME = 0.1,
    Attach = function() return {} end,
    OnVisible = function() end,
    NextFrame = function(_, fn) fn() end,
    NewFrame = function(kind, name, parent) return CreateFrame(kind, name, parent) end,
}
if MODE ~= "nokit" then
    ForeverClassicUI_AttachSkin = function(fn) fn(kit) end
end

------------------------------------------------------------------ the addon

local F = {}
for _, file in ipairs({ "Core.lua", "Frame.lua" }) do
    local chunk = assert(loadfile(ROOT .. "/" .. file))
    chunk("ClassicUIForever_LFGForever", F)
end

------------------------------------------------------------------ LFG Forever's window, as its core/window.lua makes it

local function SideTab(parent)
    local t = CreateFrame("Frame", nil, parent, "LargeSideTabButtonTemplate")
    t.Icon = t:CreateTexture()
    t.SetCustomOnMouseUpHandler = function(self, fn) self._mouseUp = fn end
    return t
end

local function Section(panel)
    local s = CreateFrame("Frame", nil, panel)
    s.Title = s:CreateFontString()
    s.Header = CreateFrame("Button", nil, s)
    s.Divider = s:CreateTexture()
    s.Content = CreateFrame("Frame", nil, s)
    s.Content:SetPoint("TOPLEFT", s.Divider, "BOTTOMLEFT", 0, -8)
    s.StackAnchor = s.Content
    local check = CreateFrame("CheckButton", nil, s.Content, "UICheckButtonTemplate")
    check.Text = check:CreateFontString()
    check:SetPoint("TOPLEFT", s.Content, "TOPLEFT", 0, 0)
    return s
end

local function FilterPanel(content)
    local panel = CreateFrame("Frame", nil, content, "InsetFrameTemplate")
    panel.NineSlice, panel.Bg = CreateFrame("Frame", nil, panel), panel:CreateTexture()
    panel:SetWidth(600)
    panel.CategoryDropdown = CreateFrame("DropdownButton", nil, panel)
    panel.ActivityDropdown = CreateFrame("DropdownButton", nil, panel)
    for _, dd in ipairs({ panel.CategoryDropdown, panel.ActivityDropdown }) do
        dd.Background, dd.Arrow, dd.Text = dd:CreateTexture(), dd:CreateTexture(), dd:CreateFontString()
    end
    panel.SearchButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    panel.RoleCheckButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    panel.SettingsGear = CreateFrame("Button", nil, panel)
    panel.FilterSections = { Section(panel), Section(panel), Section(panel), Section(panel) }
    function panel:LayOutSections()
        local above = self.CategoryDropdown
        for _, s in ipairs(self.FilterSections) do
            s:ClearAllPoints()
            s:SetPoint("TOPLEFT", above, "BOTTOMLEFT", 0, -20)
            above = s.StackAnchor
        end
    end
    panel:LayOutSections()
    panel.WhispersSection, panel.RatingsSection = Section(panel), Section(panel)
    for _, key in ipairs({ "WhisperLog", "PlayerRatings" }) do
        local list = CreateFrame("Frame", nil, panel)
        list.ScrollBox = CreateFrame("Frame", nil, list)
        list.ScrollBox.ScrollTarget = true
        list.ScrollBox.ForEachFrame = function() end
        list.ScrollBar = CreateFrame("EventFrame", nil, list)
        panel[key] = list
    end
    panel.TabSystem = CreateFrame("Frame", nil, panel)
    panel.TabSystem.SetTabShown = function() end
    local buttons, current = {}, 1
    for id = 1, 3 do
        buttons[id] = CreateFrame("Button", nil, panel.TabSystem)
        buttons[id].Text = buttons[id]:CreateFontString()
        buttons[id].Text:SetText("Tab " .. id)
        buttons[id].GetTabID = function() return id end
    end
    panel.filtersTabID, panel.whispersTabID, panel.ratingsTabID = 1, 2, 3
    function panel:GetTabButton(id) return buttons[id] end
    function panel:GetTab() return current end
    function panel:SetTab(id) current = id end
    return panel
end

local function ListPanel(content)
    local list = CreateFrame("Frame", nil, content, "InsetFrameTemplate")
    list.NineSlice, list.Bg = CreateFrame("Frame", nil, list), list:CreateTexture()
    list.ScrollBox = CreateFrame("Frame", nil, list)
    list.ScrollBox.ScrollTarget = true
    list.ScrollBox.ForEachFrame = function() end
    list.ScrollBar = CreateFrame("EventFrame", nil, list)
    return list
end

local frame = CreateFrame("Frame", "LFGForeverFrame", UIParent)
frame:Hide()
local content = CreateFrame("Frame", nil, frame, "PortraitFrameTemplateNoCloseButton")
frame.Content = content
content.NineSlice, content.PortraitContainer = CreateFrame("Frame", nil, content), CreateFrame("Frame", nil, content)
content.TitleContainer = CreateFrame("Frame", nil, content)
frame.CloseButton = CreateFrame("Button", nil, frame)
frame:SetScript("OnShow", function() end)
frame:SetScript("OnHide", function() end)
content.FilterPanel = FilterPanel(content)
content.ListPanel = ListPanel(content)
content.ReportBug = CreateFrame("Button", nil, content)
for _, key in ipairs({ "ListingTab", "BrowsingTab", "WhoListingTab", "BetterTab" }) do frame[key] = SideTab(frame) end
frame.ResizeButton, frame.DragBar = CreateFrame("Button", nil, content), CreateFrame("Button", nil, frame)

local ok, err = pcall(frame.Show, frame)
Check(ok, "its first show runs without an error: " .. tostring(err))

if MODE == "kit" then
    Check(#calls.register == 1 and calls.register[1][1] == frame and calls.register[1][2] == 7,
        "registered once in the window row with the finder's pushable 7")
    Check(calls.lend == 1 and calls.hosts and calls.hosts[1] == frame.ListingTab and calls.hosts[3] == frame.WhoListingTab,
        "its page tabs handed to the finder's tabs")
    Check(calls.adopt >= 1 and calls.first and calls.first[1] == frame, "its side tabs taken from the first spot")
    Check(frame._w == F.Width() and frame._h == 440, "the double frame's size: " .. frame._w .. " x " .. frame._h)
    Check(F.Width() < 700, "no wider than the double frame")
    Check(calls.slot == F.Width() + 392 - 354, "room for the side tabs past the art")
    Check(frame.ListingTab.Icon and frame.ListingTab.tooltipText == "Create Listing", "Create Listing wears our face")
    Check(not frame.WhoListingTab:IsShown(), "Hide Who side tab hides its Who tab too")
    Check(content.FilterPanel.TabSystem:IsShown() == false, "its own filter tabs out of sight")
    Check(calls.skins > 0, "old skins on its controls")
    -- A drag of its title moves the spot it shares with the finder (2026-11-24: hidden, the window could not move).
    Check(frame.DragBar:IsShown(), "its drag bar stays: the window can be dragged by its title")
    Check(not frame.ResizeButton:IsShown(), "its grip off: the row sizes it")
    local sections = content.FilterPanel.FilterSections
    Check(sections[1]:GetParent() ~= content.FilterPanel, "the filter sections moved into the scroll")
    frame.WhoListingTab._mouseUp(frame.WhoListingTab, "LeftButton", true)
    Check(calls.who == true, "its Who tab opens our who list")
    frame:Hide()
    ok, err = pcall(frame.Show, frame)
    Check(ok and #calls.register == 1, "a second show: no error, not registered again " .. tostring(err))
else
    Check(#calls.register == 0, "left as LFG Forever made it")
    Check(frame._w == 0, "its size untouched")
end

if failed > 0 then
    print(failed .. " check(s) failed")
    os.exit(1)
end
print("smoke_test (" .. MODE .. "): ok")
