local _, F = ...

-- The look: the 3.x double frame our professions wear, at their size, on the Looking For Group window's spot and
-- height. Left pane: the filters, laid again for its width (two columns, one where a cell is too wide) and scrolled,
-- their tabs as the friends list's; Search and Role Check in the foot boxes. Right pane: the results. Our side tabs.

local kit = F.kit
if not kit then return end

-- Our Looking For Group window's art box (Social/GroupFinder.lua ERA_W, ERA_H): this window stands on the same spot.
F.ERA_W = 354
local ERA_H = 440
-- The double frame's sheets (512 + 256) stand 4 right of the window's corner: its frame's left edge on Era's.
local ART_X = 4
local SHEETS = { { key = "questLogDualLeft", w = 512, x = 0 }, { key = "questLogDualRight", w = 256, x = 512 } }
local SHEET_H = 512
local ART_RIGHT = 678
-- The frame's right border again over its side tabs' plates (they hang 3 left of the tab, over the border): the right
-- sheet's last columns, its whole height.
local BORDER_FROM, BORDER_TO, BORDER_H = 673, 682, 440
-- Sheet units from here on (left, top, right, bottom). The panes' dark marble over the book and the parchment.
local LEFT_PANE = { 18, 74, 317, 409 }
local RIGHT_PANE = { 345, 74, 649, 411 }
-- The panes' scroll columns: their middles, the arrows' boxes at each end (centres 81 and 400), the track between.
-- Our slider's arrows hang 5 past its ends; a thin client bar's sit inside its own ends.
local LEFT_COLUMN, RIGHT_COLUMN = 333.5, 662.5
local SLIDER_W, SLIDER_TOP, SLIDER_BOTTOM = 16, 87, 396
local THIN_TOP, THIN_BOTTOM = 74, 409
-- Search and Role Check in the left pane's first and third foot boxes, as the professions' Create All and Create.
local FOOT_TOP, FOOT_H = 412, 21
local SEARCH_FOOT = { 16, 109 }
local ROLE_CHECK_FOOT = { 221, 99 }
-- Close in the right foot box, as the professions' Exit; the empty middle box under plain foot stone (the bar's).
local CLOSE_FOOT = { 591, 81 }
local STONE = { x = 131, y = 410, w = 91, h = 20, fromX = 400 }
-- The title strip, the close button's socket and the eye under the ring (the ring stands 2 higher than Era's).
local TITLE_LEFT, TITLE_RIGHT, TITLE_Y = 74, 640, 14
local CLOSE_X, CLOSE_Y, CLOSE_SIZE = 652, 8, 32
local EYE, EYE_BACK = 136317, 337500
local EYE_X, EYE_Y, EYE_BACK_X, EYE_BACK_Y = 9, 3, 12, 3
local EYE_FIRST = { 0, 0.125, 0, 0.25 }
-- Report a bug at the header's right end, over the results.
local BUG_RIGHT, BUG_Y = 645, 44
-- The filter tabs on the left pane's top edge, clear of the portrait ring; dropped so they sit on the pane, not over it.
local TABS_X, TABS_DROP = 74, 7
-- The whisper and ratings lists from the pane's left edge, their thin bars in its column.
local SIDE_LIST_GAP = 4
-- Rows a size smaller, so a name, its level and icons clear what stands at the row's right.
local ROW_ICON, MEMBER_ICON, ICON_GAP = 16, 18, 2
local STAR_SCALE = 0.8
local NAME_TAIL = { "Level", "ClassIcon", "NewPlayerFriendlyIcon", "LFGFRelation" }
local NAME_GAP, NAME_MIN = 6, 40
-- A result's buttons share one slot at its right; its second line's pieces, left to right.
local ROW_BUTTONS = { "LFGFInvite", "LFGFAskToJoin", "LFGFDelist" }
local LINE_TWO = { "ActivityName", "LFGFZone", "LFGFPlaystyle" }
local SLOT_GAP, LINE_MIN = 4, 16
-- The filters' panel 2 inside the pane; its drop downs and gear on one row at its top; the scroll under them.
local FILTER_INSET = 2
local ROW_X, ROW_Y, ROW_GAP = 6, -6, 4
local CATEGORY_W, GEAR_W = 120, 16
local SCROLL_GAP = 4
local SCROLL_RIGHT = -4
local WHEEL_STEP = 28
-- The re-laid grid: two columns, a cell too wide for one takes the row; rows packed; checkboxes at 26.
local COLUMNS = 2
local CHECK_SIZE = 26
local ROW_PAD = 2
local CELL_INSET = 6
local SECTION_GAP = 10
-- Their section header's gaps (title to rule, rule, rule to content).
local TITLE_TO_RULE, RULE_H, RULE_TO_CONTENT = 4, 4, 8
-- The first side tab off the frame's top right, as the finder's off its art; our finder tabs' faces by page.
local SIDE_X, SIDE_Y = -3, -58
local PAGE_TABS = { "ListingTab", "BrowsingTab", "WhoListingTab" }

local skin, scroll, child, bar
local ourTabs = {}
local glows = setmetatable({}, { __mode = "k" })
local laid = setmetatable({}, { __mode = "k" })
local eyeTurn = 0

local function X(sheetX) return sheetX + ART_X end
function F.Width() return X(ART_RIGHT) + 2 end

local function Box(region, rect)
    region:ClearAllPoints()
    region:SetPoint("TOPLEFT", F.window, "TOPLEFT", X(rect[1]), -rect[2])
    region:SetPoint("BOTTOMRIGHT", F.window, "TOPLEFT", X(rect[3]), -rect[4])
end

---------------------------------------------------------------- the frame

local function Art()
    for _, sheet in ipairs(SHEETS) do
        local tex = skin:CreateTexture(nil, "BACKGROUND", nil, 0)
        kit.SetTex(tex, sheet.key)
        tex:SetSize(sheet.w, SHEET_H)
        tex:SetPoint("TOPLEFT", F.window, "TOPLEFT", ART_X + sheet.x, 0)
    end
    local stone = skin:CreateTexture(nil, "BACKGROUND", nil, 1)
    kit.SetTex(stone, SHEETS[1].key)
    stone:SetTexCoord(STONE.fromX / 512, (STONE.fromX + STONE.w) / 512, STONE.y / 512, (STONE.y + STONE.h) / 512)
    stone:SetSize(STONE.w, STONE.h)
    stone:SetPoint("TOPLEFT", F.window, "TOPLEFT", X(STONE.x), -STONE.y)
    for _, rect in ipairs({ LEFT_PANE, RIGHT_PANE }) do
        local fill = kit.TileTex(skin:CreateTexture(nil, "BACKGROUND", nil, 2), "marbleBg", nil, kit.PANE_SHADE)
        Box(fill, rect)
    end
end

local function BorderOverTabs(frame)
    local over = CreateFrame("Frame", nil, frame)
    over:SetAllPoints(frame)
    over:SetFrameLevel(frame:GetFrameLevel() + 2)
    local sheet = SHEETS[2]
    local strip = over:CreateTexture(nil, "OVERLAY")
    kit.SetTex(strip, sheet.key)
    strip:SetTexCoord((BORDER_FROM - sheet.x) / sheet.w, (BORDER_TO - sheet.x) / sheet.w, 0, BORDER_H / SHEET_H)
    strip:SetSize(BORDER_TO - BORDER_FROM, BORDER_H)
    strip:SetPoint("TOPLEFT", frame, "TOPLEFT", X(BORDER_FROM), 0)
end

local function TurnEye(job)
    local listed = C_LFGList and C_LFGList.HasActiveEntryInfo()
    eyeTurn = listed and (eyeTurn + 1) % kit.ERA_EYE_FRAMES or 0
    kit.EraEyeFrame(job.eye, eyeTurn, EYE_FIRST)
end

local function Eye()
    local back = skin:CreateTexture(nil, "BACKGROUND", nil, -8)
    back:SetTexture(EYE_BACK)
    back:SetSize(64, 64)
    back:SetPoint("TOPLEFT", F.window, "TOPLEFT", EYE_BACK_X, -EYE_BACK_Y)
    local eye = skin:CreateTexture(nil, "BACKGROUND", nil, -7)
    eye:SetTexture(EYE)
    eye:SetTexCoord(unpack(EYE_FIRST))
    eye:SetSize(64, 64)
    eye:SetPoint("TOPLEFT", F.window, "TOPLEFT", EYE_X, -EYE_Y)
    local turn = kit.Attach(skin, { name = "lfgf.eye", every = kit.ERA_EYE_TIME, fn = TurnEye })
    if turn then turn.eye = eye end
end

-- Its portrait frame's own chrome off: the title stays, in our strip.
local function ChromeOff(frame)
    local content = frame.Content
    for _, region in ipairs({ content:GetRegions() }) do region:SetAlpha(0) end
    for _, key in ipairs({ "NineSlice", "PortraitContainer" }) do
        if content[key] then content[key]:Hide() end
    end
    for _, panel in ipairs({ content.FilterPanel, content.ListPanel }) do
        if panel.NineSlice then panel.NineSlice:Hide() end
        if panel.Bg then panel.Bg:SetAlpha(0) end
    end
    -- Its grip and drag bar off: the row places it, as our other windows.
    if frame.ResizeButton then frame.ResizeButton:Hide() end
    if frame.DragBar then frame.DragBar:Hide() end
    if frame.CloseButton then kit.SkinCloseButton(frame.CloseButton) end
end

---------------------------------------------------------------- the filters laid again for the pane

local function Each(list, fn)
    for i = 1, #list do fn(list[i]) end
end

-- What hangs on a cell's root (a label on its drop down, a range on its label) moves with it.
local function Cells(content)
    local pieces = {}
    Each({ content:GetChildren() }, function(kid) pieces[#pieces + 1] = kid end)
    Each({ content:GetRegions() }, function(region) pieces[#pieces + 1] = region end)
    local rootOf = {}
    local function Root(piece, depth)
        if rootOf[piece] ~= nil or depth > 6 then return rootOf[piece] end
        if piece:GetNumPoints() < 1 then return nil end
        local _, rel = piece:GetPoint(1)
        if rel == content then
            rootOf[piece] = piece
        else
            rootOf[piece] = rel and Root(rel, depth + 1) or false
        end
        return rootOf[piece]
    end
    local cells, byRoot = {}, {}
    for _, piece in ipairs(pieces) do
        local root = Root(piece, 0)
        if root then
            local cell = byRoot[root]
            if not cell then
                cell = { root = root, parts = {} }
                byRoot[root] = cell
                cells[#cells + 1] = cell
            end
            cell.parts[#cell.parts + 1] = piece
        end
    end
    return cells
end

-- A cell's box against the content's top left, from what it draws (a check's label counted).
local function Measure(cell, left0, top0)
    local l, r, t, b
    local function Take(region)
        local rl, rr, rt, rb = region:GetLeft(), region:GetRight(), region:GetTop(), region:GetBottom()
        if not (rl and rr and rt and rb) then return end
        l, r = math.min(l or rl, rl), math.max(r or rr, rr)
        t, b = math.max(t or rt, rt), math.min(b or rb, rb)
    end
    for _, part in ipairs(cell.parts) do
        Take(part)
        if part.Text and part.Text.GetLeft then Take(part.Text) end
    end
    if not l then return false end
    cell.x, cell.y, cell.w, cell.h = l - left0, t - top0, r - l, t - b
    return true
end

-- A cell wider than the room: its drop down gives way.
local function Narrow(cell, room)
    local over = cell.w - room
    if over <= 0 then return end
    for _, part in ipairs(cell.parts) do
        if part.GetObjectType and part:GetObjectType() == "DropdownButton" then
            part:SetWidth(math.max(60, part:GetWidth() - over))
            cell.w = cell.w - over
            return
        end
    end
end

local function Move(cell, x, y)
    local root = cell.root
    local point, rel, relPoint, ox, oy = root:GetPoint(1)
    root:ClearAllPoints()
    root:SetPoint(point, rel, relPoint, ox + x - cell.x, oy + y - cell.y)
end

local function SectionHeight(section)
    local height = section.Title:GetStringHeight() + TITLE_TO_RULE + RULE_H
    if not section.collapsed then height = height + RULE_TO_CONTENT + section.Content:GetHeight() end
    section:SetHeight(height)
end

-- The section's head at our size: the smaller title, the rule under it, the section and rule as wide as the pane.
local function TitleFont(section, normal, highlight)
    local header = section.Header
    if header then
        header:SetNormalFontObject(normal)
        header:SetHighlightFontObject(highlight)
        header:SetHeight(section.Title:GetStringHeight())
    elseif section.Title then
        section.Title:SetFontObject(normal)
    end
end

-- The leftmost of the links on the title line (Save new filter, Reset filters, its saved filters).
local function LinksLeft(section)
    local left
    local function Take(region)
        if region == section.Header or region == section.Content or region == section.Divider then return end
        if not (region.IsShown and region:IsShown()) then return end
        local x = region:GetLeft()
        if x and (not left or x < left) then left = x end
    end
    Each({ section:GetChildren() }, Take)
    Each({ section:GetRegions() }, Take)
    return left
end

local function Head(section, width)
    section:SetWidth(width)
    if section.Header then section.Header:SetWidth(width) end
    if section.Title then
        TitleFont(section, GameFontNormal, GameFontHighlight)
        local links, right = LinksLeft(section), section.Title:GetRight()
        if links and right and right + 4 > links then TitleFont(section, GameFontNormalSmall, GameFontHighlightSmall) end
    end
    local rule = section.Divider
    if rule and section.Title then
        rule:SetWidth(width)
        rule:ClearAllPoints()
        rule:SetPoint("TOPLEFT", section, "TOPLEFT", 0, -(section.Title:GetStringHeight() + TITLE_TO_RULE))
    end
end

local function Relay(section, width)
    local content = section.Content
    Head(section, width)
    content:SetWidth(width)
    Each({ content:GetChildren() }, function(kid)
        if kid:GetObjectType() == "CheckButton" then kid:SetSize(CHECK_SIZE, CHECK_SIZE) end
    end)
    local left0, top0 = content:GetLeft(), content:GetTop()
    if not (left0 and top0) then return false end
    local cells = Cells(content)
    for _, cell in ipairs(cells) do
        if not Measure(cell, left0, top0) then return false end
    end
    table.sort(cells, function(a, b)
        if math.abs(a.y - b.y) > 4 then return a.y > b.y end
        return a.x < b.x
    end)
    local colW = width / COLUMNS
    local rows, row = {}, nil
    for _, cell in ipairs(cells) do
        local inset = cell.root:GetObjectType() == "CheckButton" and 0 or CELL_INSET
        Narrow(cell, width - inset)
        Measure(cell, left0, top0)
        local half = cell.w + inset <= colW
        if row and half and row.half and #row < COLUMNS then
            row[#row + 1] = cell
        else
            row = { cell, half = half }
            rows[#rows + 1] = row
        end
        cell.inset = inset
    end
    local y = 0
    for _, r in ipairs(rows) do
        local h = 0
        for _, cell in ipairs(r) do h = math.max(h, cell.h) end
        for i, cell in ipairs(r) do Move(cell, (i - 1) * colW + cell.inset, y - (h - cell.h) / 2) end
        y = y - h - ROW_PAD
    end
    content:SetHeight(math.max(1, -y))
    SectionHeight(section)
    return true
end

local function RelayAll(panel)
    local width = child:GetWidth()
    if width < 10 then return false end
    for _, section in ipairs(panel.FilterSections or {}) do
        if not laid[section] then laid[section] = Relay(section, width) end
    end
    for _, key in ipairs({ "WhispersSection", "RatingsSection" }) do
        if panel[key] and not laid[panel[key]] then
            Head(panel[key], width)
            laid[panel[key]] = true
        end
    end
    return true
end

---------------------------------------------------------------- the filters' scroll

local function Fill()
    local panel = F.window.Content.FilterPanel
    local sections = panel.FilterSections
    local last = sections and sections[#sections]
    local anchor = last and (last.StackAnchor or last)
    local top, bottom = child:GetTop(), anchor and anchor:GetBottom()
    if not (top and bottom) then return end
    local height = math.max(1, top - bottom + SCROLL_GAP)
    child:SetHeight(height)
    bar:SetRange(math.max(0, math.floor(height - scroll:GetHeight() + 0.5)), WHEEL_STEP)
end

-- Cells laid once each, while they show (a hidden one is measured when it next shows); then the scroll's height.
function F.RelayAndFill()
    local panel = F.window.Content.FilterPanel
    if panel:GetTab() == panel.filtersTabID then RelayAll(panel) end
    Fill()
end

-- Their stack hangs off the search row and stands 20 apart: in the scroll from its top, closer.
local function Restack(panel)
    local above
    for _, section in ipairs(panel.FilterSections or {}) do
        section:ClearAllPoints()
        if above then
            section:SetPoint("TOPLEFT", above.StackAnchor or above, "BOTTOMLEFT", 0, -SECTION_GAP)
        else
            section:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -SCROLL_GAP)
        end
        above = section
    end
    kit.NextFrame("lfgf.relay", F.RelayAndFill)
end

local function FilterScroll(panel)
    scroll = CreateFrame("ScrollFrame", nil, panel)
    child = CreateFrame("Frame", nil, scroll)
    child:SetSize(1, 1)
    scroll:SetScrollChild(child)
    for _, section in ipairs(panel.FilterSections or {}) do section:SetParent(child) end
    bar = kit.ClassicScrollBar(panel, scroll, function(value) scroll:SetVerticalScroll(value or 0) end)
    bar:ClearAllPoints()
    bar:SetPoint("TOPLEFT", F.window, "TOPLEFT", X(LEFT_COLUMN) - SLIDER_W / 2, -SLIDER_TOP)
    bar:SetPoint("BOTTOMLEFT", F.window, "TOPLEFT", X(LEFT_COLUMN) - SLIDER_W / 2, -SLIDER_BOTTOM)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(_, delta) bar:SetValue(bar:GetValue() - delta * WHEEL_STEP) end)
    scroll:SetScript("OnSizeChanged", function(self)
        child:SetWidth(self:GetWidth())
        kit.NextFrame("lfgf.fill", Fill)
    end)
    hooksecurefunc(panel, "LayOutSections", Restack)
    Restack(panel)
end

-- The search row in the pane: the two drop downs and the gear on top, Search and Role Check in the foot boxes.
local function SearchRow(panel)
    local category, activity, gear = panel.CategoryDropdown, panel.ActivityDropdown, panel.SettingsGear
    local width = panel:GetWidth()
    category:ClearAllPoints()
    category:SetPoint("TOPLEFT", panel, "TOPLEFT", ROW_X, ROW_Y)
    category:SetWidth(CATEGORY_W)
    if activity then
        activity:ClearAllPoints()
        activity:SetPoint("LEFT", category, "RIGHT", ROW_GAP, 0)
        activity:SetWidth(width - 2 * ROW_X - CATEGORY_W - GEAR_W - 3 * ROW_GAP)
    end
    if gear then
        gear:ClearAllPoints()
        gear:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -ROW_X, ROW_Y - 4)
    end
    for _, pair in ipairs({ { panel.SearchButton, SEARCH_FOOT }, { panel.RoleCheckButton, ROLE_CHECK_FOOT } }) do
        local button, foot = pair[1], pair[2]
        if button then
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", F.window, "TOPLEFT", X(foot[1]), -FOOT_TOP)
            button:SetSize(foot[2], FOOT_H)
        end
    end
    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT", category, "BOTTOMLEFT", 0, -SCROLL_GAP)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", SCROLL_RIGHT, FILTER_INSET)
    child:SetWidth(width - ROW_X + SCROLL_RIGHT)
end

-- The friends list's tabs for theirs, each turning their own tab; theirs out of sight.
local function SyncTabs()
    local panel = F.window.Content.FilterPanel
    local current = panel:GetTab()
    local prev
    for _, entry in ipairs(ourTabs) do
        local theirs = panel:GetTabButton(entry.id)
        local shown = theirs ~= nil and theirs:IsShown()
        entry.tab:SetShown(shown)
        if shown then
            entry.tab:ClearAllPoints()
            if prev then
                entry.tab:SetPoint("LEFT", prev, "RIGHT", 0, 0)
            else
                entry.tab:SetPoint("BOTTOMLEFT", F.window, "TOPLEFT", X(TABS_X), -(LEFT_PANE[2] + TABS_DROP))
            end
            prev = entry.tab
            if entry.id == current then PanelTemplates_SelectTab(entry.tab) else PanelTemplates_DeselectTab(entry.tab) end
        end
    end
    local onFilters = current == panel.filtersTabID
    scroll:SetShown(onFilters)
    bar:SetShown(onFilters)
    if onFilters then kit.NextFrame("lfgf.relay", F.RelayAndFill) end
end

local function FilterTabs(panel)
    if panel.TabSystem then panel.TabSystem:Hide() end
    for i, id in ipairs({ panel.filtersTabID, panel.whispersTabID, panel.ratingsTabID }) do
        local theirs = panel:GetTabButton(id)
        if theirs then
            local tab = CreateFrame("Button", "ClassicUIForeverLFGForeverTab" .. i, F.window, "PanelTopTabButtonTemplate")
            tab:SetText(theirs.Text and theirs.Text:GetText() or "")
            tab:SetScript("OnClick", function()
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
                panel:SetTab(id, true)
            end)
            kit.SkinTopTab(tab, nil, nil, true)
            ourTabs[#ourTabs + 1] = { id = id, tab = tab }
        end
    end
    hooksecurefunc(panel, "SetTab", SyncTabs)
    if panel.TabSystem then hooksecurefunc(panel.TabSystem, "SetTabShown", SyncTabs) end
end

---------------------------------------------------------------- the controls

local function IsDropdown(frame) return frame.Background ~= nil and frame.Arrow ~= nil and frame.Text ~= nil end
local function IsPanelButton(frame) return frame.Left ~= nil and frame.Middle ~= nil and frame.Right ~= nil end

-- Old skins on their checkboxes, drop downs and panel buttons; list rows (in scroll boxes) stay theirs.
local function SkinUnder(frame, depth)
    if depth <= 0 then return end
    for _, kid in ipairs({ frame:GetChildren() }) do
        local kind = kid:GetObjectType()
        if kind == "CheckButton" and kid.Text then
            kit.SkinCheckbox(kid)
        elseif kind == "DropdownButton" and IsDropdown(kid) then
            kit.EraDropdownArt(kid, -4, 0, -27)
            kid.Text:SetFontObject("GameFontHighlightSmall")
        elseif kind == "Button" and IsPanelButton(kid) and not kid.GetTabID then
            kit.SkinRedButton(kid)
        end
        if not kid.ScrollTarget then SkinUnder(kid, depth - 1) end
    end
end

---------------------------------------------------------------- the results, right

-- A thin client bar in a column: its arrows in the column's end boxes, its track between.
local function InColumn(thin, column)
    thin:ClearAllPoints()
    thin:SetPoint("TOP", F.window, "TOPLEFT", X(column), -THIN_TOP)
    thin:SetPoint("BOTTOM", F.window, "TOPLEFT", X(column), -THIN_BOTTOM)
end


local function PlaceList(list)
    Box(list, { RIGHT_PANE[1] + 2, RIGHT_PANE[2] + 1, RIGHT_PANE[3] - 1, RIGHT_PANE[4] - 2 })
    local box, thin = list.ScrollBox, list.ScrollBar
    if box then
        box:ClearAllPoints()
        box:SetPoint("TOPLEFT", list, "TOPLEFT", 2, -2)
        box:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -2, 2)
    end
    if thin then InColumn(thin, RIGHT_COLUMN) end
end

---------------------------------------------------------------- the lists' rows

local dressedRows = setmetatable({}, { __mode = "k" })
local plain = _G.issecretvalue
local function Plain(v) if v ~= nil and not (plain and plain(v)) then return v end end

local function Font(text, font)
    if text and text.SetFontObject then text:SetFontObject(font) end
end

local function SmallIcon(icon)
    if icon and icon.SetSize then icon:SetSize(ROW_ICON, ROW_ICON) end
end

-- A whisper's one line, a rated player's two, a result's: their fonts a size down, class icons at 16, stars smaller.
local function DressRow(row)
    if dressedRows[row] then return end
    dressedRows[row] = true
    Font(row.Name, row.Message and "GameFontNormalSmall" or "GameFontNormal")
    if row.Name and row.Name.SetJustifyH then row.Name:SetJustifyH("LEFT") end
    Font(row.Level, "GameFontDisableSmall")
    Font(row.Message, "GameFontHighlightSmall")
    Font(row.Activity, "GameFontDisableSmallLeft")
    Font(row.ActivityName, "GameFontDisableSmallLeft")
    Font(row.LFGFZone, "GameFontDisableSmallLeft")
    Font(row.LFGFPlaystyle, "GameFontDisableSmallLeft")
    SmallIcon(row.ClassIcon)
    -- Their anchor dropped a 24 icon 5 below the level's foot: ours sits on the level's middle.
    if row.ClassIcon and row.Level then
        row.ClassIcon:ClearAllPoints()
        row.ClassIcon:SetPoint("LEFT", row.Level, "RIGHT", 3, 0)
    end
    -- The client's data display (LFGVanillaListGroupDataDisplayTemplate) made for a 200 wide block beside a long row: its
    -- comment off (on the quests' note line, and in the tooltip), role and member icons at the block's right at our size.
    local display = row.DataDisplay
    if display then
        if display.Comment then display.Comment:SetAlpha(0) end
        local solo = display.Solo
        if solo and solo.RolesText and solo.Roles then
            solo.RolesText:SetAlpha(0)
            for i, icon in ipairs(solo.Roles) do
                icon:SetSize(ROW_ICON, ROW_ICON)
                icon:ClearAllPoints()
                if i == 1 then
                    icon:SetPoint("RIGHT", solo, "RIGHT", -(#solo.Roles - 1) * (ROW_ICON + ICON_GAP), 0)
                else
                    icon:SetPoint("LEFT", solo.Roles[i - 1], "RIGHT", ICON_GAP, 0)
                end
            end
        end
        local all = display.Enumerate
        if all and all.Icons then
            for i, icon in ipairs(all.Icons) do
                icon:SetSize(MEMBER_ICON, MEMBER_ICON)
                icon:ClearAllPoints()
                if i == 1 then
                    icon:SetPoint("RIGHT", all, "RIGHT", 0, 0)
                else
                    icon:SetPoint("RIGHT", all.Icons[i - 1], "LEFT", -ICON_GAP, 0)
                end
            end
        end
        local count = display.PlayerCount
        if count and count.Icon then count.Icon:SetSize(14, 13) end
    end
    for _, kid in ipairs({ row:GetChildren() }) do
        if kid.Buttons then kid:SetScale(STAR_SCALE) end
    end
end

-- The left edge of what stands at a result's right (roles, members, counts, its buttons), visible pieces only.
local function RightStuffLeft(row)
    local left
    local function Take(region)
        if not (region.IsVisible and region:IsVisible()) or region:GetAlpha() == 0 then return end
        local x = Plain(region:GetLeft())
        if x and (not left or x < left) then left = x end
    end
    local function Walk(frame, depth)
        for _, region in ipairs({ frame:GetRegions() }) do
            if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then Take(region) end
        end
        if depth > 0 then
            for _, kid in ipairs({ frame:GetChildren() }) do Walk(kid, depth - 1) end
        end
    end
    if row.DataDisplay then Walk(row.DataDisplay, 3) end
    if row.LFGFInvite then Take(row.LFGFInvite) end
    return left
end

-- A long name gives way, so what hangs off it stays clear of the right side (the client sets its width on each fill).
local function FitName(row)
    local name = row.Name
    if not (name and name:IsShown() and row.DataDisplay) then return end
    local limit = RightStuffLeft(row)
    if not limit then return end
    local right = Plain(name:GetRight())
    for _, key in ipairs(NAME_TAIL) do
        local piece = row[key]
        local x = piece and piece.IsShown and piece:IsShown() and Plain(piece:GetRight())
        if x and (not right or x > right) then right = x end
    end
    local width = Plain(name:GetWidth())
    local over = right and right + NAME_GAP - limit
    if over and over > 0.5 and width then name:SetWidth(math.max(width - over, NAME_MIN)) end
end

-- The left edge of a result's button slot (the one shown), else its right edge.
local function SlotLeft(row)
    local left
    for _, key in ipairs(ROW_BUTTONS) do
        local button = row[key]
        local x = button and button:IsShown() and Plain(button:GetLeft())
        if x and (not left or x < left) then left = x end
    end
    return left or Plain(row:GetRight())
end

-- Roles and members on the name line, left of the buttons (centred on the row, they stood over the second line).
local displaySpot = setmetatable({}, { __mode = "k" })
local function RolesUp(row, slot)
    local display, name = row.DataDisplay, row.Name
    local top, right = Plain(row:GetTop()), Plain(row:GetRight())
    local nt, nb = name and Plain(name:GetTop()), name and Plain(name:GetBottom())
    if not (display and top and right and nt and nb) then return end
    local x, y = math.floor(slot - SLOT_GAP - right + 0.5), math.floor((nt + nb) / 2 - top + 0.5)
    local spot = displaySpot[display]
    if spot and spot[1] == x and spot[2] == y and display:GetNumPoints() == 1 then return end
    displaySpot[display] = { x, y }
    display:ClearAllPoints()
    display:SetPoint("RIGHT", row, "TOPRIGHT", x, y)
end

-- The second line cut at the buttons: a piece with no room left goes unseen.
local function ClipLineTwo(row, slot)
    local limit = slot - SLOT_GAP
    for _, key in ipairs(LINE_TWO) do
        local piece = row[key]
        if piece and piece:IsShown() then
            local left, right = Plain(piece:GetLeft()), Plain(piece:GetRight())
            if left and right then
                local room = limit - left
                piece:SetAlpha(room >= LINE_MIN and 1 or 0)
                if room >= LINE_MIN and right > limit + 0.5 then piece:SetWidth(room) end
            end
        end
    end
end

local function FitResult(row)
    if not row.DataDisplay then return end
    local slot = SlotLeft(row)
    if not slot then return end
    RolesUp(row, slot)
    FitName(row)
    ClipLineTwo(row, slot)
end

local function DressBox(box, fit)
    if not (box and box:IsVisible() and box.ForEachFrame) then return end
    box:ForEachFrame(function(row)
        DressRow(row)
        if fit then FitResult(row) end
    end)
end

-- Rows are made as the lists scroll and filled afresh: dressed once each, names fitted on every beat.
local function DressLists()
    local content = F.window.Content
    local filters = content.FilterPanel
    DressBox(content.ListPanel.ScrollBox, true)
    for _, key in ipairs({ "WhisperLog", "PlayerRatings" }) do
        if filters[key] then DressBox(filters[key].ScrollBox, false) end
    end
end

-- The whisper and ratings lists under their section's rule, across the whole pane; their bars in its column.
local function PlaceSideLists(panel)
    for _, pair in ipairs({ { "WhisperLog", "WhispersSection" }, { "PlayerRatings", "RatingsSection" } }) do
        local list, section = panel[pair[1]], panel[pair[2]]
        if list and section and section.Divider then
            list:ClearAllPoints()
            list:SetPoint("TOPLEFT", section.Divider, "BOTTOMLEFT", -ROW_X, -SIDE_LIST_GAP)
            list:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, FILTER_INSET)
            if list.ScrollBox then
                list.ScrollBox:ClearAllPoints()
                list.ScrollBox:SetAllPoints(list)
            end
            if list.ScrollBar then InColumn(list.ScrollBar, LEFT_COLUMN) end
        end
    end
end

---------------------------------------------------------------- the side tabs

-- The hover mark while the client's tab over one of its tabs takes the mouse.
function F.LightTab(tab, on)
    local glow = glows[tab]
    if not glow then
        glow = tab:CreateTexture(nil, "OVERLAY")
        kit.SetTex(glow, "highlight")
        glow:SetBlendMode("ADD")
        glow:SetAllPoints(tab)
        glows[tab] = glow
    end
    glow:SetShown(on)
end

-- Its page tabs wear our finder tabs' faces and words.
local function PageFaces(frame)
    local entries = kit.FinderTabs and kit.FinderTabs()
    if not entries then return end
    for page, key in ipairs(PAGE_TABS) do
        local tab, entry = frame[key], entries[page]
        if tab and entry then
            tab.Icon:SetTexture(entry.icon)
            tab.Icon:SetTexCoord(0, 1, 0, 1)
            tab.tooltipText = entry.text
        end
    end
end

---------------------------------------------------------------- dress and fit

function F.Dress(frame)
    local content = frame.Content
    local filters = content.FilterPanel
    skin = CreateFrame("Frame", nil, frame)
    skin:SetAllPoints(frame)
    skin:SetFrameLevel(frame:GetFrameLevel())
    Art()
    BorderOverTabs(frame)
    Eye()
    ChromeOff(frame)
    FilterScroll(filters)
    FilterTabs(filters)
    SkinUnder(content, 6)
    -- The frame's own columns hold the bars: no track column of ours over its border.
    kit.SkinScrollBar(content.ListPanel.ScrollBar, false)
    for _, key in ipairs({ "WhisperLog", "PlayerRatings" }) do
        if filters[key] and filters[key].ScrollBar then kit.SkinScrollBar(filters[key].ScrollBar, false) end
    end
    PageFaces(frame)
    local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    close:SetText(CLOSE)
    close:SetScript("OnClick", function() frame:Hide() end)
    kit.SkinRedButton(close)
    close:SetPoint("TOPLEFT", frame, "TOPLEFT", X(CLOSE_FOOT[1]), -FOOT_TOP)
    close:SetSize(CLOSE_FOOT[2], FOOT_H)
    kit.Attach(skin, { name = "lfgf.rows", every = 0.1, fn = DressLists })
end

-- Every show: its size, its pieces on our spots (it places none of them again, its own size and place calls aside).
function F.Fit(frame)
    local w = F.Width()
    frame:SetResizeBounds(w, ERA_H, w, ERA_H)
    frame:SetSize(w, ERA_H)
    local content = frame.Content
    local filters = content.FilterPanel
    Box(filters, { LEFT_PANE[1] + FILTER_INSET, LEFT_PANE[2] + FILTER_INSET, LEFT_PANE[3] - FILTER_INSET,
        LEFT_PANE[4] - FILTER_INSET })
    SearchRow(filters)
    PlaceSideLists(filters)
    PlaceList(content.ListPanel)
    local title = content.TitleContainer
    if title then
        title:ClearAllPoints()
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", X(TITLE_LEFT), -TITLE_Y)
        title:SetPoint("TOPRIGHT", frame, "TOPLEFT", X(TITLE_RIGHT), -TITLE_Y)
    end
    local close = frame.CloseButton
    if close then
        close:ClearAllPoints()
        close:SetPoint("TOPLEFT", frame, "TOPLEFT", X(CLOSE_X), -CLOSE_Y)
        close:SetSize(CLOSE_SIZE, CLOSE_SIZE)
        close:SetFrameLevel(frame:GetFrameLevel() + 20)
    end
    local bug = content.ReportBug
    if bug then
        bug:ClearAllPoints()
        bug:SetPoint("TOPRIGHT", frame, "TOPLEFT", X(BUG_RIGHT), -BUG_Y)
    end
    SyncTabs()
    kit.AdoptSideTabs(frame, nil, nil, { frame, SIDE_X, SIDE_Y })
end
