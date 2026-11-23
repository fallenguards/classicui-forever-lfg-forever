local _, F = ...

-- LFG Forever's window as one of ClassicUI Forever's: caught as it is made, dressed before it first draws, stood in our
-- window row on the finder's spot, and only ever one of it and the group finder up. Its frames hooked, its code untouched.

local FRAME_NAME = "LFGForeverFrame"
local FINDER_ADDON = "Blizzard_GroupFinder_VanillaStyle"
-- Era's number for the group finder this window stands beside (its panel rule: it closes no other window).
local PUSHABLE = 7
-- Its own side tabs by the finder page each stands for.
local PAGE_TABS = { "ListingTab", "BrowsingTab", "WhoListingTab" }
local WHO_PAGE = 3

local kit
if type(ForeverClassicUI_AttachSkin) == "function" then
    ForeverClassicUI_AttachSkin(function(k) kit = k end)
end
if not (kit and kit.version == 1) then return end
F.kit = kit

local window, hooked
local lastPoint
local scriptsSet = {}

local function Finder() return _G["LFGParentFrame"] end

---------------------------------------------------------------- one window at a time

-- The finder opened over this window: this one goes. Next frame: a hide inside the client's show pass would run its
-- panel pass in our name.
local function FinderShown(shown)
    if not shown then return end
    kit.NextFrame("lfgf.finderUp", function()
        local finder = Finder()
        if finder and finder:IsShown() and window and window:IsShown() then window:Hide() end
    end)
end

local finderHeard
local function HearFinder()
    local finder = Finder()
    if finderHeard or not finder then return end
    finderHeard = true
    kit.OnVisible(finder, "lfgf.oneAtATime", FinderShown)
end

---------------------------------------------------------------- its side tabs

-- Reached only without the client's tab over it: in a fight, or before the finder's code loaded.
local function PageTab(page)
    return function(_, button, upInside)
        if button ~= "LeftButton" or not upInside then return end
        if page == WHO_PAGE and not kit.FinderWhoOwn() then
            window:Hide()
            kit.OpenWhoList()
            return
        end
        if InCombatLockdown() then
            kit.SayNotInCombat()
        else
            kit.WarmGroupFinder()
        end
    end
end

local function TakeSideTabs(frame)
    local hosts = {}
    for page, key in ipairs(PAGE_TABS) do
        local tab = frame[key]
        if tab then
            tab:SetCustomOnMouseUpHandler(PageTab(page))
            hosts[page] = tab
        end
    end
    kit.LendFinderTabs(frame, hosts, F.LightTab)
end

-- Hide Who side tab covers its Who tab too.
local function SyncWhoTab()
    local who = window and window.WhoListingTab
    if who then who:SetShown(not kit.FinderWhoHidden()) end
end

---------------------------------------------------------------- showing and hiding

-- Its panels and tabs exist from its first show on.
local dressed
local function DressOnce(frame)
    if dressed then return end
    dressed = true
    F.Dress(frame)
    kit.SetSlotWidth(frame, F.Width() + kit.SIDE_TAB_SLOT - F.ERA_W)
    TakeSideTabs(frame)
end

local function OnShow(self)
    DressOnce(self)
    -- Its own place call ran first (the screen's middle): back on our last anchor, so the row still counts it as ours.
    if lastPoint then
        self:ClearAllPoints()
        self:SetPoint(unpack(lastPoint))
    end
    local finder = Finder()
    if finder and finder:IsShown() then kit.HidePanel(finder) end
    SyncWhoTab()
    F.Fit(self)
    if not InCombatLockdown() then kit.WarmGroupFinder() end
    HearFinder()
end

local function OnHide(self)
    if self:GetNumPoints() == 1 then lastPoint = { self:GetPoint(1) } end
end

local function Hook(frame)
    if hooked then return end
    hooked = true
    if not kit.IsOn("groupFinder") then return end
    -- Ours before the row's: the row reads the anchor put back here.
    frame:HookScript("OnShow", OnShow)
    frame:HookScript("OnHide", OnHide)
    kit.RegisterWindow(frame, PUSHABLE)
    kit.OnToggle(function(key)
        if key == "hideFinderWho" then
            SyncWhoTab()
            if dressed and window:IsShown() then F.Fit(window) end
        end
    end)
    HearFinder()
    if frame:IsShown() then OnShow(frame) end
end

---------------------------------------------------------------- catching the window

-- Its window is made on first open, its scripts set as it is built: hooked once the last is set, so ours run after them.
local function Catch(frame)
    if window or not frame then return end
    window = frame
    F.window = frame
    if frame:GetScript("OnShow") and frame:GetScript("OnHide") then
        Hook(frame)
        return
    end
    hooksecurefunc(frame, "SetScript", function(self, script)
        if script == "OnShow" or script == "OnHide" then scriptsSet[script] = true end
        if scriptsSet.OnShow and scriptsSet.OnHide then Hook(self) end
    end)
end

if _G[FRAME_NAME] then
    Catch(_G[FRAME_NAME])
else
    hooksecurefunc("CreateFrame", function(_, name)
        if not window and name == FRAME_NAME then Catch(_G[FRAME_NAME]) end
    end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, _, name)
    if name ~= FINDER_ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")
    if hooked then HearFinder() end
end)
