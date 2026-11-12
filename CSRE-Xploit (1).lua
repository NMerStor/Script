--[[
    CSRE-Xploit v2.0  |  Bubble UI Library
    Single-file Luau UI framework (Rayfield / WindUI style).

    Components : Button, Toggle, Slider, Dropdown (single / multi), Textbox, Keybind,
                 ColorPicker, Label, Paragraph, Divider
    Window     : Tabs, collapsible Sections, minimize, confirm-close dialog, notifications,
                 mobile floating toggle bubble, toggle key, auto "Settings" tab
    Theming    : 8 presets + custom themes, live re-theme, background image / color / accent
    Config     : Flags + SaveConfig / LoadConfig (needs executor file API)

    Usage:
        local UI = loadstring(...)()          -- or just use the global CSRE_Xploit
        local Window = UI:CreateWindow({ Title = "My Hub", Theme = "Ocean" })
        local Tab = Window:CreateTab({ Name = "Main", Icon = "M" })
        local Section = Tab:CreateSection("Combat")
        Section:CreateToggle({ Name = "Enabled", Flag = "enabled", Callback = function(v) end })
        Window:CreateSettingsTab()

    To see every component:   getgenv().CSRE_DEMO = true   before running this file,
    or call  UI:Demo()  yourself.

    No remote loaders and no game-specific exploit code are included. Put your own
    logic inside component callbacks.
]]

local env = (type(getgenv) == "function" and getgenv()) or _G

-- Re-executing the script cleanly replaces the previous instance instead of stacking UIs.
if type(env.CSRE_Xploit) == "table" and type(env.CSRE_Xploit.Destroy) == "function" then
    pcall(env.CSRE_Xploit.Destroy, env.CSRE_Xploit)
end

local CSRE_Xploit = (function()
    --// Services
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer

    local WHITE = Color3.new(1, 1, 1)
    local BLACK = Color3.new(0, 0, 0)

    --// Theme presets
    local ThemePresets = {
        Bubble = {
            Window = Color3.fromRGB(224, 250, 255),
            Header = Color3.fromRGB(0, 190, 235),
            HeaderDark = Color3.fromRGB(0, 137, 205),
            Panel = Color3.fromRGB(208, 244, 252),
            Card = Color3.fromRGB(235, 251, 255),
            CardHover = Color3.fromRGB(213, 246, 255),
            Accent = Color3.fromRGB(0, 190, 225),
            AccentDark = Color3.fromRGB(0, 132, 190),
            Text = Color3.fromRGB(28, 71, 112),
            SubText = Color3.fromRGB(91, 128, 158),
            Stroke = Color3.fromRGB(112, 219, 242),
            ToggleOff = Color3.fromRGB(174, 211, 226),
            Danger = Color3.fromRGB(232, 73, 91),
            Shadow = Color3.fromRGB(0, 99, 145),
        },
        Ocean = {
            Window = Color3.fromRGB(14, 31, 48),
            Header = Color3.fromRGB(0, 143, 190),
            HeaderDark = Color3.fromRGB(0, 91, 143),
            Panel = Color3.fromRGB(18, 48, 68),
            Card = Color3.fromRGB(24, 60, 82),
            CardHover = Color3.fromRGB(32, 77, 101),
            Accent = Color3.fromRGB(0, 204, 220),
            AccentDark = Color3.fromRGB(0, 142, 177),
            Text = Color3.fromRGB(226, 248, 255),
            SubText = Color3.fromRGB(155, 194, 211),
            Stroke = Color3.fromRGB(43, 151, 181),
            ToggleOff = Color3.fromRGB(66, 100, 119),
            Danger = Color3.fromRGB(236, 86, 105),
            Shadow = Color3.fromRGB(0, 0, 0),
        },
        Midnight = {
            Window = Color3.fromRGB(20, 21, 29),
            Header = Color3.fromRGB(40, 43, 59),
            HeaderDark = Color3.fromRGB(28, 30, 43),
            Panel = Color3.fromRGB(26, 28, 39),
            Card = Color3.fromRGB(35, 38, 52),
            CardHover = Color3.fromRGB(46, 50, 67),
            Accent = Color3.fromRGB(0, 190, 220),
            AccentDark = Color3.fromRGB(0, 130, 174),
            Text = Color3.fromRGB(242, 246, 255),
            SubText = Color3.fromRGB(157, 166, 188),
            Stroke = Color3.fromRGB(68, 79, 101),
            ToggleOff = Color3.fromRGB(74, 80, 99),
            Danger = Color3.fromRGB(235, 77, 97),
            Shadow = Color3.fromRGB(0, 0, 0),
        },
        Light = {
            Window = Color3.fromRGB(245, 248, 252),
            Header = Color3.fromRGB(67, 137, 235),
            HeaderDark = Color3.fromRGB(43, 102, 199),
            Panel = Color3.fromRGB(232, 238, 247),
            Card = Color3.fromRGB(255, 255, 255),
            CardHover = Color3.fromRGB(235, 244, 255),
            Accent = Color3.fromRGB(48, 133, 226),
            AccentDark = Color3.fromRGB(31, 99, 190),
            Text = Color3.fromRGB(36, 50, 73),
            SubText = Color3.fromRGB(105, 119, 143),
            Stroke = Color3.fromRGB(183, 204, 229),
            ToggleOff = Color3.fromRGB(186, 199, 216),
            Danger = Color3.fromRGB(222, 68, 84),
            Shadow = Color3.fromRGB(56, 91, 133),
        },
        Rose = {
            Window = Color3.fromRGB(43, 26, 39),
            Header = Color3.fromRGB(224, 92, 153),
            HeaderDark = Color3.fromRGB(166, 53, 115),
            Panel = Color3.fromRGB(59, 34, 53),
            Card = Color3.fromRGB(76, 43, 66),
            CardHover = Color3.fromRGB(94, 51, 80),
            Accent = Color3.fromRGB(255, 117, 181),
            AccentDark = Color3.fromRGB(207, 68, 139),
            Text = Color3.fromRGB(255, 239, 248),
            SubText = Color3.fromRGB(204, 160, 185),
            Stroke = Color3.fromRGB(173, 87, 137),
            ToggleOff = Color3.fromRGB(112, 76, 99),
            Danger = Color3.fromRGB(245, 83, 105),
            Shadow = Color3.fromRGB(20, 5, 15),
        },
    }

    --// Extra presets (hex) --------------------------------------------------------
    local function hexTheme(map)
        local result = {}
        for key, hex in pairs(map) do
            result[key] = Color3.fromHex("#" .. hex)
        end
        return result
    end

    ThemePresets.Amethyst = hexTheme({
        Window = "1A1426", Header = "8B5CF6", HeaderDark = "5B21B6", Panel = "221A33",
        Card = "2E2445", CardHover = "3C3059", Accent = "A78BFA", AccentDark = "7C3AED",
        Text = "F3EEFF", SubText = "B7A6DB", Stroke = "5B4694", ToggleOff = "56456F",
        Danger = "F43F5E", Shadow = "000000",
    })
    ThemePresets.Emerald = hexTheme({
        Window = "0F1F1A", Header = "10B981", HeaderDark = "047857", Panel = "132A22",
        Card = "1B382E", CardHover = "25493D", Accent = "34D399", AccentDark = "059669",
        Text = "E8FFF6", SubText = "9CCBB8", Stroke = "2E7D63", ToggleOff = "3F6355",
        Danger = "F43F5E", Shadow = "000000",
    })
    ThemePresets.Sunset = hexTheme({
        Window = "2A1618", Header = "F97316", HeaderDark = "DB2777", Panel = "3A1F22",
        Card = "4A292C", CardHover = "5E3337", Accent = "FB923C", AccentDark = "EA580C",
        Text = "FFF1E8", SubText = "D9A98F", Stroke = "9A4B3A", ToggleOff = "6E4A44",
        Danger = "EF4444", Shadow = "000000",
    })

    -- Every preset gets the status colors used by notifications.
    for _, preset in pairs(ThemePresets) do
        preset.Success = preset.Success or Color3.fromRGB(46, 204, 113)
        preset.Warning = preset.Warning or Color3.fromRGB(255, 176, 46)
    end

    --// Utilities -------------------------------------------------------------------
    local function copyTable(source)
        local result = {}
        for key, value in pairs(source) do
            result[key] = value
        end
        return result
    end

    local function mergeTheme(base, overrides)
        local result = copyTable(base)
        if type(overrides) == "table" then
            for key, value in pairs(overrides) do
                if result[key] ~= nil and typeof(value) == "Color3" then
                    result[key] = value
                end
            end
        end
        return result
    end

    -- amount > 0 lightens, amount < 0 darkens
    local function shade(color, amount)
        if amount >= 0 then
            return color:Lerp(WHITE, amount)
        end
        return color:Lerp(BLACK, -amount)
    end

    local function luminance(color)
        return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
    end

    local function make(className, properties, parent)
        local object = Instance.new(className)
        if properties then
            for key, value in pairs(properties) do
                object[key] = value
            end
        end
        if parent then
            object.Parent = parent
        end
        return object
    end

    local function corner(parent, radius)
        return make("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, parent)
    end

    local function stroke(parent, color, thickness, transparency)
        return make("UIStroke", {
            Color = color or BLACK,
            Thickness = thickness or 1,
            Transparency = transparency or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, parent)
    end

    local function tween(object, duration, properties, style, direction)
        local info = TweenInfo.new(
            duration or 0.16,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        )
        local animation = TweenService:Create(object, info, properties)
        animation:Play()
        return animation
    end

    local function makeLabel(parent, text, size, position, fontSize, color, bold)
        return make("TextLabel", {
            BackgroundTransparency = 1,
            Text = text or "",
            Size = size,
            Position = position or UDim2.fromOffset(0, 0),
            Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = fontSize or 14,
            TextColor3 = color or WHITE,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = false,
            BorderSizePixel = 0,
        }, parent)
    end

    local function firstChar(text)
        return tostring(text):match("[\1-\127\194-\244][\128-\191]*") or "?"
    end

    local function isImageIcon(icon)
        if type(icon) == "number" then
            return true
        end
        if type(icon) ~= "string" then
            return false
        end
        return icon:match("^%d%d%d%d%d+$") ~= nil
            or icon:find("rbxassetid://", 1, true) == 1
            or icon:find("rbxasset://", 1, true) == 1
            or icon:find("rbxthumb://", 1, true) == 1
    end

    local function assetUri(value)
        if value == nil or value == "" then
            return ""
        end
        local text = tostring(value)
        if text:find("rbxassetid://", 1, true) or text:find("rbxasset://", 1, true) or text:find("rbxthumb://", 1, true) then
            return text
        end
        if text:match("^%d+$") then
            return "rbxassetid://" .. text
        end
        -- Pasted link such as https://www.roblox.com/library/123456/Name -> take the id.
        local id = text:match("(%d%d%d+)")
        if id then
            return "rbxassetid://" .. id
        end
        return text
    end

    local function safeCall(callback, ...)
        if type(callback) ~= "function" then
            return true
        end
        local ok, result = xpcall(callback, function(err)
            return debug.traceback(tostring(err), 2)
        end, ...)
        if not ok then
            warn("[CSRE-Xploit] Callback error: " .. tostring(result))
        end
        return ok, result
    end

    local function isPointer(input)
        local kind = input.UserInputType
        return kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch
    end

    local function isMotion(input)
        local kind = input.UserInputType
        return kind == Enum.UserInputType.MouseMovement or kind == Enum.UserInputType.Touch
    end

    local function normalize(config, defaultName)
        if type(config) == "string" then
            config = { Name = config }
        end
        config = copyTable(config or {})
        if config.Name == nil then
            config.Name = config.Title or defaultName
        end
        config.Name = tostring(config.Name)
        return config
    end

    --// UI parent resolution: gethui > CoreGui > PlayerGui
    local function parentScreenGui(screenGui)
        if type(syn) == "table" and type(syn.protect_gui) == "function" then
            pcall(syn.protect_gui, screenGui)
        end

        local candidates = {}
        if type(gethui) == "function" then
            local ok, hidden = pcall(gethui)
            if ok and hidden then
                table.insert(candidates, hidden)
            end
        end

        local okCore, coreGui = pcall(function()
            return game:GetService("CoreGui")
        end)
        if okCore and coreGui then
            table.insert(candidates, coreGui)
        end

        if LocalPlayer then
            local okPlayer, playerGui = pcall(function()
                return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
            end)
            if okPlayer and playerGui then
                table.insert(candidates, playerGui)
            end
        end

        for _, parent in ipairs(candidates) do
            if pcall(function() screenGui.Parent = parent end) then
                return true
            end
        end
        return false
    end

    --// Theme bindings: every colored instance is registered once and re-colored on SetTheme.
    local function applyRecord(record, theme, animate)
        if record.Dead or not record.Inst then
            return
        end
        local source = record.Source
        local value
        if type(source) == "function" then
            value = source(theme)
        else
            value = theme[source]
        end
        if value == nil then
            return
        end
        if animate and typeof(value) ~= "ColorSequence" then
            tween(record.Inst, 0.2, { [record.Prop] = value })
        else
            record.Inst[record.Prop] = value
        end
    end

    -- Drag helper. Target must use AnchorPoint (0.5, 0.5).
    local function makeDraggable(window, handle, target, minVisibleX, minVisibleY, onTap)
        local dragging = false
        local moved = false
        local dragStart
        local startPosition

        handle.InputBegan:Connect(function(input)
            if isPointer(input) then
                dragging = true
                moved = false
                dragStart = input.Position
                startPosition = target.Position
                local changed
                changed = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        changed:Disconnect()
                        dragging = false
                        if not moved and onTap then
                            onTap()
                        end
                    end
                end)
            end
        end)

        window:_Track(UserInputService.InputChanged:Connect(function(input)
            if not dragging or not isMotion(input) then
                return
            end
            local delta = input.Position - dragStart
            if not moved and delta.Magnitude < 6 then
                return
            end
            moved = true

            local viewport = window.Gui.AbsoluteSize
            local size = target.AbsoluteSize
            local visibleX = math.min(minVisibleX, size.X)
            local visibleY = math.min(minVisibleY, size.Y)
            local centerX = startPosition.X.Scale * viewport.X + startPosition.X.Offset + delta.X
            local centerY = startPosition.Y.Scale * viewport.Y + startPosition.Y.Offset + delta.Y
            centerX = math.clamp(centerX, visibleX - size.X / 2, math.max(visibleX - size.X / 2, viewport.X - visibleX + size.X / 2))
            centerY = math.clamp(centerY, size.Y / 2, math.max(size.Y / 2, viewport.Y - visibleY + size.Y / 2))
            target.Position = UDim2.new(
                startPosition.X.Scale, centerX - startPosition.X.Scale * viewport.X,
                startPosition.Y.Scale, centerY - startPosition.Y.Scale * viewport.Y
            )
        end))
    end

    --// Config encoding -------------------------------------------------------------
    local function encodeValue(value)
        local kind = typeof(value)
        if kind == "Color3" then
            return {
                R = math.floor(value.R * 255 + 0.5),
                G = math.floor(value.G * 255 + 0.5),
                B = math.floor(value.B * 255 + 0.5),
            }
        elseif kind == "EnumItem" then
            return value.Name
        end
        return value
    end

    local function decodeValue(optionType, value)
        if optionType == "ColorPicker" and type(value) == "table" then
            return Color3.fromRGB(value.R or 255, value.G or 255, value.B or 255)
        elseif optionType == "Keybind" and type(value) == "string" then
            local ok, key = pcall(function()
                return Enum.KeyCode[value]
            end)
            if ok then
                return key
            end
            return nil
        end
        return value
    end

    local function cleanName(name)
        local cleaned = tostring(name or ""):gsub("[^%w_%- ]", "")
        cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
        if cleaned == "" then
            cleaned = "default"
        end
        return cleaned
    end

    --// Library root ----------------------------------------------------------------
    local Library = {
        Name = "CSRE-Xploit",
        Version = "2.0.0",
        Themes = ThemePresets,
        Theme = copyTable(ThemePresets.Bubble),
        ThemeName = "Bubble",
        Flags = {},
        Options = {},
        ConfigFolder = "CSRE-Xploit",
        _windows = {},
        _destroyed = false,
    }

    local WindowMethods, TabMethods, SectionMethods, ComponentMethods = {}, {}, {}, {}
    WindowMethods.__index = WindowMethods
    TabMethods.__index = TabMethods
    SectionMethods.__index = SectionMethods
    ComponentMethods.__index = ComponentMethods

    function Library:SetTheme(theme)
        if type(theme) == "string" then
            local preset = ThemePresets[theme]
            if not preset then
                warn("[CSRE-Xploit] Unknown theme: " .. theme)
                return self
            end
            self.Theme = copyTable(preset)
            self.ThemeName = theme
        elseif type(theme) == "table" then
            self.Theme = mergeTheme(self.Theme, theme)
            self.ThemeName = "Custom"
        else
            warn("[CSRE-Xploit] SetTheme expects a preset name or a color table")
            return self
        end
        for _, window in ipairs(self._windows) do
            window:_ApplyTheme(true)
        end
        return self
    end

    function Library:GetTheme()
        return copyTable(self.Theme)
    end

    function Library:RegisterTheme(name, theme)
        ThemePresets[tostring(name)] = mergeTheme(ThemePresets.Midnight, theme)
        return self
    end

    function Library:GetThemeNames()
        local names = {}
        for name in pairs(ThemePresets) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end

    function Library:Notify(config)
        local window = self._windows[#self._windows]
        if window and not window._destroyed then
            return window:Notify(config)
        end
        warn("[CSRE-Xploit] Create a window before calling Notify().")
    end

    --// Config save / load (needs executor file API) -----------------------------------
    local function fileApiAvailable()
        return type(writefile) == "function" and type(readfile) == "function"
    end

    function Library:_ConfigPath(name)
        return self.ConfigFolder .. "/" .. cleanName(name) .. ".json"
    end

    function Library:SaveConfig(name)
        if not fileApiAvailable() then
            return false, "This executor has no file API (writefile/readfile)."
        end
        local data = {}
        for flag, option in pairs(self.Options) do
            local ok, value = pcall(function()
                return option:GetValue()
            end)
            if ok and value ~= nil then
                data[flag] = encodeValue(value)
            end
        end
        local ok, err = pcall(function()
            if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(self.ConfigFolder) then
                makefolder(self.ConfigFolder)
            end
            writefile(self:_ConfigPath(name), HttpService:JSONEncode(data))
        end)
        if not ok then
            return false, tostring(err)
        end
        return true
    end

    function Library:LoadConfig(name)
        if not fileApiAvailable() then
            return false, "This executor has no file API (writefile/readfile)."
        end
        local path = self:_ConfigPath(name)
        if type(isfile) == "function" and not isfile(path) then
            return false, "Config not found: " .. cleanName(name)
        end
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if not ok or type(decoded) ~= "table" then
            return false, "Config file is corrupt."
        end
        for flag, raw in pairs(decoded) do
            local option = self.Options[flag]
            if option and type(option.SetValue) == "function" then
                local value = decodeValue(option.Type, raw)
                if value ~= nil then
                    pcall(function()
                        option:SetValue(value)
                    end)
                end
            end
        end
        return true
    end

    function Library:ListConfigs()
        local names = {}
        if type(listfiles) == "function" then
            local ok, files = pcall(listfiles, self.ConfigFolder)
            if ok and type(files) == "table" then
                for _, path in ipairs(files) do
                    local name = tostring(path):match("([^/\\]+)%.json$")
                    if name then
                        table.insert(names, name)
                    end
                end
            end
        end
        table.sort(names)
        return names
    end

    function Library:DeleteConfig(name)
        if type(delfile) ~= "function" then
            return false, "This executor has no delfile."
        end
        local ok, err = pcall(delfile, self:_ConfigPath(name))
        return ok, ok and nil or tostring(err)
    end

    --// Component base ----------------------------------------------------------------
    function ComponentMethods:Bind(instance, property, source)
        return self.Window:_Bind(instance, property, source, self.Scope)
    end

    function ComponentMethods:Connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(self.Conns, connection)
        table.insert(self.Window._conns, connection)
        return connection
    end

    function ComponentMethods:_Register(value)
        local flag = self.Config.Flag
        if flag then
            self.Flag = flag
            self.Window.Library.Flags[flag] = value
            self.Window.Library.Options[flag] = self
        end
    end

    function ComponentMethods:_SetFlag(value)
        if self.Flag then
            self.Window.Library.Flags[self.Flag] = value
        end
    end

    function ComponentMethods:_Emit(value, ...)
        self:_SetFlag(value)
        safeCall(self.Callback, value, ...)
    end

    function ComponentMethods:SetCallback(callback)
        self.Callback = callback
        return self
    end

    function ComponentMethods:SetName(text)
        if self.TitleLabel then
            self.TitleLabel.Text = tostring(text)
        end
        return self
    end

    function ComponentMethods:SetVisible(state)
        if self.Row then
            self.Row.Visible = state ~= false
        end
        return self
    end

    function ComponentMethods:Destroy()
        if self.Destroyed then
            return
        end
        self.Destroyed = true
        if self._onDestroy then
            pcall(self._onDestroy)
        end
        for _, connection in ipairs(self.Conns) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        self.Window:_Kill(self.Scope)
        if self.Flag then
            local library = self.Window.Library
            if library.Options[self.Flag] == self then
                library.Options[self.Flag] = nil
                library.Flags[self.Flag] = nil
            end
        end
        if self.Row then
            self.Row:Destroy()
        end
    end

    local function newComponent(section, className, name, height, config, plain)
        local window = section.Tab.Window
        section._count = section._count + 1

        local comp = setmetatable({
            Window = window,
            Section = section,
            Config = config,
            Scope = {},
            Conns = {},
            Destroyed = false,
            Callback = config.Callback or config.Function,
        }, ComponentMethods)

        local row = make(className, {
            Name = name,
            Size = UDim2.new(1, 0, 0, height),
            BorderSizePixel = 0,
            LayoutOrder = section._count,
        }, section.Holder)
        if className == "TextButton" then
            row.Text = ""
            row.AutoButtonColor = false
        end

        if plain then
            row.BackgroundTransparency = 1
        else
            corner(row, 10)
            comp:Bind(row, "BackgroundColor3", "Panel")
            comp:Bind(stroke(row, BLACK, 1, 0.15), "Color", "Stroke")
        end

        comp.Row = row
        comp.Instance = row
        return comp
    end

    local function addTitle(comp, parent, text, size, position)
        local label = makeLabel(parent, text, size, position, 12, nil, true)
        label.TextTruncate = Enum.TextTruncate.AtEnd
        comp:Bind(label, "TextColor3", "Text")
        comp.TitleLabel = label
        return label
    end

    --// Components ----------------------------------------------------------------------
    function SectionMethods:CreateButton(config)
        config = normalize(config, "Button")
        local comp = newComponent(self, "TextButton", "Button", 39, config)
        comp.Type = "Button"
        local window = comp.Window
        local row = comp.Row

        local label = addTitle(comp, row, config.Name, UDim2.new(1, -45, 1, 0), UDim2.fromOffset(12, 0))
        local arrow = makeLabel(row, ">", UDim2.fromOffset(24, 39), UDim2.new(1, -30, 0, 0), 16, nil, true)
        arrow.TextXAlignment = Enum.TextXAlignment.Center
        comp:Bind(arrow, "TextColor3", "AccentDark")

        comp:Connect(row.MouseEnter, function()
            tween(row, 0.12, { BackgroundColor3 = window.Library.Theme.CardHover })
        end)
        comp:Connect(row.MouseLeave, function()
            tween(row, 0.12, { BackgroundColor3 = window.Library.Theme.Panel })
        end)

        function comp:Fire()
            safeCall(comp.Callback)
        end
        comp:Connect(row.Activated, function()
            tween(row, 0.08, { BackgroundColor3 = window.Library.Theme.Accent })
            task.delay(0.1, function()
                if not comp.Destroyed then
                    tween(row, 0.2, { BackgroundColor3 = window.Library.Theme.Panel })
                end
            end)
            comp:Fire()
        end)

        function comp:SetText(value)
            label.Text = tostring(value)
            return comp
        end
        return comp
    end

    function SectionMethods:CreateToggle(config)
        config = normalize(config, "Toggle")
        local comp = newComponent(self, "TextButton", "Toggle", 40, config)
        comp.Type = "Toggle"
        local window = comp.Window
        local row = comp.Row
        local state = config.Default == true

        addTitle(comp, row, config.Name, UDim2.new(1, -75, 1, 0), UDim2.fromOffset(12, 0))

        local switch = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(43, 23),
            BorderSizePixel = 0,
        }, row)
        corner(switch, 12)
        local switchRecord = comp:Bind(switch, "BackgroundColor3", function(t)
            return state and t.Accent or t.ToggleOff
        end)
        local knob = make("Frame", {
            Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3),
            Size = UDim2.fromOffset(17, 17),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
        }, switch)
        corner(knob, 9)

        local function render()
            applyRecord(switchRecord, window.Library.Theme, true)
            tween(knob, 0.14, { Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3) })
        end

        function comp:SetValue(value, silent)
            value = value == true
            if value == state then
                return comp
            end
            state = value
            render()
            if not silent then
                comp:_Emit(state)
            end
            return comp
        end
        comp.Set = comp.SetValue
        function comp:GetValue()
            return state
        end
        function comp:Toggle()
            return comp:SetValue(not state)
        end

        comp:Connect(row.Activated, function()
            comp:SetValue(not state)
        end)
        comp:_Register(state)
        return comp
    end

    function SectionMethods:CreateSlider(config)
        config = normalize(config, "Slider")
        local comp = newComponent(self, "Frame", "Slider", 60, config)
        comp.Type = "Slider"
        local row = comp.Row
        local page = self.Tab.Page

        local minimum = tonumber(config.Min) or 0
        local maximum = tonumber(config.Max) or 100
        if maximum < minimum then
            minimum, maximum = maximum, minimum
        end
        local step = math.max(tonumber(config.Step) or 1, 0.000001)
        local decimals = tonumber(config.Decimals)
        if decimals == nil then
            decimals = 0
            while decimals < 5 and math.abs(step * 10 ^ decimals - math.floor(step * 10 ^ decimals + 0.5)) > 1e-6 do
                decimals = decimals + 1
            end
        end
        decimals = math.clamp(decimals, 0, 5)
        local suffix = config.Suffix and tostring(config.Suffix) or ""

        local function snap(number)
            number = math.clamp(number, minimum, maximum)
            local snapped = minimum + math.floor((number - minimum) / step + 0.5) * step
            local multiplier = 10 ^ decimals
            return math.clamp(math.floor(snapped * multiplier + 0.5) / multiplier, minimum, maximum)
        end
        local value = snap(tonumber(config.Default) or minimum)

        addTitle(comp, row, config.Name, UDim2.new(1, -95, 0, 24), UDim2.fromOffset(11, 3))
        local valueLabel = makeLabel(row, "", UDim2.fromOffset(80, 24), UDim2.new(1, -91, 0, 3), 11, nil, true)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        comp:Bind(valueLabel, "TextColor3", "SubText")

        -- Tall invisible hit area so the thin track is easy to grab on touch screens.
        local hit = make("TextButton", {
            Name = "Hit",
            Position = UDim2.fromOffset(11, 26),
            Size = UDim2.new(1, -22, 0, 30),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
        }, row)
        local track = make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 9),
            BorderSizePixel = 0,
        }, hit)
        corner(track, 6)
        comp:Bind(track, "BackgroundColor3", "ToggleOff")
        local fill = make("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 }, track)
        corner(fill, 6)
        comp:Bind(fill, "BackgroundColor3", "Accent")
        local knob = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(17, 17),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
        }, track)
        corner(knob, 9)
        comp:Bind(stroke(knob, WHITE, 2, 0), "Color", "Accent")

        local function render()
            local alpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            valueLabel.Text = tostring(value) .. suffix
        end

        local function setValue(newValue, silent)
            local snapped = snap(tonumber(newValue) or minimum)
            local changed = snapped ~= value
            value = snapped
            render()
            if changed and not silent then
                comp:_Emit(value)
            end
        end

        local dragging = false
        local function updateFromX(x)
            local width = track.AbsoluteSize.X
            if width <= 0 then
                return
            end
            local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
            setValue(minimum + (maximum - minimum) * alpha, false)
        end

        comp:Connect(hit.InputBegan, function(input)
            if isPointer(input) then
                dragging = true
                page.ScrollingEnabled = false
                updateFromX(input.Position.X)
            end
        end)
        comp:Connect(UserInputService.InputChanged, function(input)
            if dragging and isMotion(input) then
                updateFromX(input.Position.X)
            end
        end)
        comp:Connect(UserInputService.InputEnded, function(input)
            if dragging and isPointer(input) then
                dragging = false
                page.ScrollingEnabled = true
            end
        end)
        comp._onDestroy = function()
            if dragging then
                page.ScrollingEnabled = true
            end
        end

        function comp:SetValue(newValue, silent)
            setValue(newValue, silent)
            return comp
        end
        comp.Set = comp.SetValue
        function comp:GetValue()
            return value
        end

        render()
        comp:_Register(value)
        return comp
    end

    function SectionMethods:CreateDropdown(config)
        config = normalize(config, "Dropdown")
        local comp = newComponent(self, "Frame", "Dropdown", 42, config)
        comp.Type = "Dropdown"
        local window = comp.Window
        local row = comp.Row
        row.ClipsDescendants = true

        local multi = config.Multi == true
        local maxHeight = tonumber(config.MaxHeight) or 150
        local options = {}
        for _, option in ipairs(config.Options or {}) do
            table.insert(options, option)
        end

        local selected
        if multi then
            selected = {}
            if type(config.Default) == "table" then
                for _, value in ipairs(config.Default) do
                    selected[value] = true
                end
            elseif config.Default ~= nil then
                selected[config.Default] = true
            end
        else
            selected = config.Default
        end

        local expanded = false
        local items = {}
        local itemScope = {}
        local setExpanded

        local header = make("TextButton", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
        }, row)
        addTitle(comp, header, config.Name, UDim2.new(0.4, -8, 1, 0), UDim2.fromOffset(11, 0))

        local box = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.new(0.6, -8, 0, 30),
            BorderSizePixel = 0,
        }, header)
        corner(box, 8)
        comp:Bind(box, "BackgroundColor3", "Card")
        local valueLabel = makeLabel(box, "", UDim2.new(1, -30, 1, 0), UDim2.fromOffset(9, 0), 11, nil, false)
        valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        comp:Bind(valueLabel, "TextColor3", "Text")
        local arrow = makeLabel(box, ">", UDim2.fromOffset(20, 30), UDim2.new(1, -22, 0, 0), 13, nil, true)
        arrow.TextXAlignment = Enum.TextXAlignment.Center
        arrow.Rotation = 90
        comp:Bind(arrow, "TextColor3", "AccentDark")

        local list = make("ScrollingFrame", {
            Name = "Options",
            Position = UDim2.fromOffset(8, 46),
            Size = UDim2.new(1, -16, 0, 0),
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, row)
        corner(list, 8)
        comp:Bind(list, "BackgroundColor3", "Card")
        comp:Bind(list, "ScrollBarImageColor3", "Accent")
        make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, list)
        make("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        }, list)

        local function isSelected(option)
            if multi then
                return selected[option] == true
            end
            return selected == option
        end

        local function getValues()
            local values = {}
            for _, option in ipairs(options) do
                if selected[option] then
                    table.insert(values, option)
                end
            end
            return values
        end

        local function displayText()
            if multi then
                local names = {}
                for _, option in ipairs(getValues()) do
                    table.insert(names, tostring(option))
                end
                if #names > 0 then
                    return table.concat(names, ", ")
                end
                return config.Placeholder and tostring(config.Placeholder) or "None"
            end
            if selected ~= nil then
                return tostring(selected)
            end
            return config.Placeholder and tostring(config.Placeholder) or "Select..."
        end

        local function restyle()
            for _, records in ipairs(items) do
                for _, record in ipairs(records) do
                    applyRecord(record, window.Library.Theme, true)
                end
            end
            valueLabel.Text = displayText()
        end

        local function buildOptions()
            window:_Kill(itemScope)
            itemScope = {}
            items = {}
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for index, option in ipairs(options) do
                local button = make("TextButton", {
                    Name = "Option",
                    Size = UDim2.new(1, 0, 0, 26),
                    Text = tostring(option),
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    LayoutOrder = index,
                }, list)
                corner(button, 7)
                local background = window:_Bind(button, "BackgroundColor3", function(t)
                    return isSelected(option) and t.Accent or t.Panel
                end, itemScope)
                local textColor = window:_Bind(button, "TextColor3", function(t)
                    return isSelected(option) and WHITE or t.Text
                end, itemScope)
                items[index] = { background, textColor }

                comp:Connect(button.Activated, function()
                    if multi then
                        selected[option] = (not selected[option]) or nil
                        restyle()
                        comp:_Emit(getValues())
                    else
                        selected = option
                        restyle()
                        comp:_Emit(selected)
                        setExpanded(false)
                    end
                end)
            end
        end

        setExpanded = function(state)
            expanded = state == true
            local listHeight = math.min(#options * 29 + 8, maxHeight)
            if expanded then
                list.Visible = true
            end
            tween(row, 0.16, { Size = UDim2.new(1, 0, 0, expanded and (46 + listHeight + 6) or 42) })
            tween(list, 0.16, { Size = UDim2.new(1, -16, 0, expanded and listHeight or 0) })
            tween(arrow, 0.16, { Rotation = expanded and -90 or 90 })
            if not expanded then
                task.delay(0.18, function()
                    if not expanded and list.Parent then
                        list.Visible = false
                    end
                end)
            end
        end

        comp:Connect(header.Activated, function()
            setExpanded(not expanded)
        end)

        function comp:SetValue(value, silent)
            if multi then
                selected = {}
                if type(value) == "table" then
                    for _, item in ipairs(value) do
                        selected[item] = true
                    end
                elseif value ~= nil then
                    selected[value] = true
                end
            else
                selected = value
            end
            restyle()
            if not silent then
                comp:_Emit(multi and getValues() or selected)
            end
            return comp
        end
        comp.Set = comp.SetValue
        function comp:GetValue()
            if multi then
                return getValues()
            end
            return selected
        end
        function comp:Refresh(newOptions)
            options = {}
            for _, option in ipairs(newOptions or {}) do
                table.insert(options, option)
            end
            if multi then
                for key in pairs(selected) do
                    if not table.find(options, key) then
                        selected[key] = nil
                    end
                end
            elseif selected ~= nil and not table.find(options, selected) then
                selected = nil
            end
            buildOptions()
            restyle()
            if expanded then
                setExpanded(true)
            end
            return comp
        end

        buildOptions()
        restyle()
        comp:_Register(multi and getValues() or selected)
        return comp
    end

    function SectionMethods:CreateTextbox(config)
        config = normalize(config, "Input")
        local comp = newComponent(self, "Frame", "Textbox", 43, config)
        comp.Type = "Textbox"
        local row = comp.Row
        local numeric = config.Numeric == true
        local lastValid = config.Default ~= nil and tostring(config.Default) or ""

        addTitle(comp, row, config.Name, UDim2.new(0.38, -8, 1, 0), UDim2.fromOffset(11, 0))
        local input = make("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.new(0.6, -8, 0, 29),
            Text = lastValid,
            PlaceholderText = tostring(config.Placeholder or "Enter text..."),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            ClearTextOnFocus = config.ClearOnFocus == true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BorderSizePixel = 0,
        }, row)
        corner(input, 7)
        make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, input)
        comp:Bind(input, "BackgroundColor3", "Card")
        comp:Bind(input, "TextColor3", "Text")
        comp:Bind(input, "PlaceholderColor3", "SubText")
        local inputStroke = stroke(input, BLACK, 1.2, 0.4)
        comp:Bind(inputStroke, "Color", "Stroke")

        comp:Connect(input.Focused, function()
            tween(inputStroke, 0.12, { Color = comp.Window.Library.Theme.Accent, Transparency = 0 })
        end)

        local function currentValue()
            if numeric then
                return tonumber(input.Text) or tonumber(lastValid) or 0
            end
            return input.Text
        end

        comp:Connect(input.FocusLost, function(enterPressed)
            tween(inputStroke, 0.12, { Color = comp.Window.Library.Theme.Stroke, Transparency = 0.4 })
            if numeric then
                local number = tonumber(input.Text)
                if number == nil then
                    input.Text = lastValid
                    return
                end
                lastValid = tostring(number)
                input.Text = lastValid
                comp:_Emit(number, enterPressed)
            else
                lastValid = input.Text
                comp:_Emit(input.Text, enterPressed)
            end
        end)
        if config.Live == true and not numeric then
            comp:Connect(input:GetPropertyChangedSignal("Text"), function()
                comp:_Emit(input.Text, false)
            end)
        end

        function comp:SetValue(value, silent)
            lastValid = tostring(value)
            input.Text = lastValid
            if not silent then
                comp:_Emit(currentValue(), false)
            else
                comp:_SetFlag(currentValue())
            end
            return comp
        end
        comp.Set = comp.SetValue
        function comp:GetValue()
            return currentValue()
        end
        function comp:Focus()
            input:CaptureFocus()
        end

        comp:_Register(currentValue())
        return comp
    end

    function SectionMethods:CreateKeybind(config)
        config = normalize(config, "Keybind")
        local comp = newComponent(self, "Frame", "Keybind", 40, config)
        comp.Type = "Keybind"
        local window = comp.Window
        local row = comp.Row

        local current = config.Default
        if typeof(current) ~= "EnumItem" then
            current = Enum.KeyCode.Unknown
        end
        local listening = false

        local function keyText(key)
            return key == Enum.KeyCode.Unknown and "None" or key.Name
        end

        addTitle(comp, row, config.Name, UDim2.new(1, -110, 1, 0), UDim2.fromOffset(11, 0))
        local keyButton = make("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -9, 0.5, 0),
            Size = UDim2.fromOffset(90, 27),
            Text = keyText(current),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        }, row)
        corner(keyButton, 7)
        comp:Bind(keyButton, "BackgroundColor3", "Card")
        comp:Bind(keyButton, "TextColor3", "Text")

        local function stopListening()
            listening = false
            task.defer(function()
                window._capturing = false
            end)
            keyButton.Text = keyText(current)
        end

        comp:Connect(keyButton.Activated, function()
            if listening then
                stopListening()
                return
            end
            listening = true
            window._capturing = true
            keyButton.Text = "Press key..."
        end)

        comp:Connect(UserInputService.InputBegan, function(input, processed)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Backspace then
                        current = Enum.KeyCode.Unknown
                    elseif input.KeyCode ~= Enum.KeyCode.Escape then
                        current = input.KeyCode
                    end
                    stopListening()
                    comp:_SetFlag(current)
                    safeCall(config.Changed, current)
                end
                return
            end
            if not processed and current ~= Enum.KeyCode.Unknown
                and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == current then
                safeCall(comp.Callback, current)
            end
        end)
        comp._onDestroy = function()
            if listening then
                window._capturing = false
            end
        end

        function comp:SetValue(key, silent)
            if type(key) == "string" then
                local ok, resolved = pcall(function()
                    return Enum.KeyCode[key]
                end)
                key = ok and resolved or nil
            end
            if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
                current = key
                keyButton.Text = keyText(current)
                comp:_SetFlag(current)
                if not silent then
                    safeCall(config.Changed, current)
                end
            end
            return comp
        end
        comp.Set = comp.SetValue
        comp.SetKey = comp.SetValue
        function comp:GetValue()
            return current
        end
        comp.GetKey = comp.GetValue

        comp:_Register(current)
        return comp
    end

    function SectionMethods:CreateLabel(config)
        config = normalize(config, "Label")
        local comp = newComponent(self, "Frame", "Label", 22, config, true)
        comp.Type = "Label"
        local row = comp.Row
        row.AutomaticSize = Enum.AutomaticSize.Y

        local text = makeLabel(row, config.Name, UDim2.new(1, -8, 0, 22), UDim2.fromOffset(4, 0), 12, nil, true)
        text.AutomaticSize = Enum.AutomaticSize.Y
        text.TextWrapped = true
        comp:Bind(text, "TextColor3", "Text")

        function comp:SetText(value)
            text.Text = tostring(value)
            return comp
        end
        comp.SetValue = comp.SetText
        function comp:GetValue()
            return text.Text
        end
        return comp
    end

    function SectionMethods:CreateParagraph(config)
        if type(config) == "string" then
            config = { Title = "Info", Content = config }
        end
        config = copyTable(config or {})
        config.Name = tostring(config.Title or config.Name or "Information")
        local comp = newComponent(self, "Frame", "Paragraph", 0, config)
        comp.Type = "Paragraph"
        local row = comp.Row
        row.AutomaticSize = Enum.AutomaticSize.Y
        corner(row, 9)

        make("UIPadding", {
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        }, row)
        make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, row)

        local title = addTitle(comp, row, config.Name, UDim2.new(1, 0, 0, 18), UDim2.fromOffset(0, 0))
        title.LayoutOrder = 1
        local body = makeLabel(row, tostring(config.Content or config.Text or ""), UDim2.new(1, 0, 0, 0), nil, 11, nil, false)
        body.LayoutOrder = 2
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.TextWrapped = true
        body.TextYAlignment = Enum.TextYAlignment.Top
        comp:Bind(body, "TextColor3", "SubText")

        function comp:SetTitle(value)
            title.Text = tostring(value)
            return comp
        end
        function comp:SetText(value)
            body.Text = tostring(value)
            return comp
        end
        comp.SetValue = comp.SetText
        return comp
    end

    function SectionMethods:CreateDivider()
        local comp = newComponent(self, "Frame", "Divider", 8, { Name = "Divider" }, true)
        comp.Type = "Divider"
        local line = make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 4, 0.5, 0),
            Size = UDim2.new(1, -8, 0, 1),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.3,
        }, comp.Row)
        comp:Bind(line, "BackgroundColor3", "Stroke")
        return comp
    end

    function SectionMethods:CreateColorPicker(config)
        config = normalize(config, "Color")
        local comp = newComponent(self, "Frame", "ColorPicker", 40, config)
        comp.Type = "ColorPicker"
        local row = comp.Row
        row.ClipsDescendants = true
        local page = self.Tab.Page

        local color = typeof(config.Default) == "Color3" and config.Default or Color3.fromRGB(255, 255, 255)
        local hue, sat, val = color:ToHSV()
        local expanded = false

        local header = make("TextButton", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
        }, row)
        addTitle(comp, header, config.Name, UDim2.new(1, -70, 1, 0), UDim2.fromOffset(11, 0))
        local swatch = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(44, 22),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
        }, header)
        corner(swatch, 7)
        stroke(swatch, WHITE, 1.5, 0.4)

        local panel = make("Frame", {
            Name = "Panel",
            Position = UDim2.fromOffset(0, 42),
            Size = UDim2.new(1, 0, 0, 126),
            BackgroundTransparency = 1,
        }, row)

        local svBox = make("TextButton", {
            Name = "SV",
            Position = UDim2.fromOffset(10, 2),
            Size = UDim2.new(1, -20, 0, 70),
            BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
        }, panel)
        corner(svBox, 6)
        local whiteLayer = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, svBox)
        corner(whiteLayer, 6)
        make("UIGradient", { Transparency = NumberSequence.new(0, 1) }, whiteLayer)
        local blackLayer = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK, BorderSizePixel = 0 }, svBox)
        corner(blackLayer, 6)
        make("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90 }, blackLayer)
        local svCursor = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, svBox)
        corner(svCursor, 6)
        stroke(svCursor, WHITE, 2, 0)

        local hueBar = make("TextButton", {
            Name = "Hue",
            Position = UDim2.fromOffset(10, 78),
            Size = UDim2.new(1, -20, 0, 14),
            BackgroundColor3 = WHITE,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
        }, panel)
        corner(hueBar, 7)
        make("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
                ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
                ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
                ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
                ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
            }),
        }, hueBar)
        local hueCursor = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(6, 20),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, hueBar)
        corner(hueCursor, 3)
        stroke(hueCursor, BLACK, 1, 0.3)

        local hexBox = make("TextBox", {
            Name = "Hex",
            Position = UDim2.fromOffset(10, 98),
            Size = UDim2.new(1, -20, 0, 24),
            Text = "",
            PlaceholderText = "#RRGGBB",
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            ClearTextOnFocus = false,
            BorderSizePixel = 0,
        }, panel)
        corner(hexBox, 6)
        comp:Bind(hexBox, "BackgroundColor3", "Card")
        comp:Bind(hexBox, "TextColor3", "Text")
        comp:Bind(hexBox, "PlaceholderColor3", "SubText")

        local function render()
            color = Color3.fromHSV(hue, sat, val)
            swatch.BackgroundColor3 = color
            svBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            svCursor.Position = UDim2.fromScale(sat, 1 - val)
            hueCursor.Position = UDim2.fromScale(hue, 0.5)
            hexBox.Text = "#" .. color:ToHex():upper()
        end

        local function applyColor(newColor, silent)
            hue, sat, val = newColor:ToHSV()
            render()
            if not silent then
                comp:_Emit(color)
            end
        end

        local dragMode = nil
        local function updateSV(position)
            sat = math.clamp((position.X - svBox.AbsolutePosition.X) / math.max(svBox.AbsoluteSize.X, 1), 0, 1)
            val = 1 - math.clamp((position.Y - svBox.AbsolutePosition.Y) / math.max(svBox.AbsoluteSize.Y, 1), 0, 1)
            render()
            comp:_Emit(color)
        end
        local function updateHue(position)
            hue = math.clamp((position.X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 1)
            render()
            comp:_Emit(color)
        end

        comp:Connect(svBox.InputBegan, function(input)
            if isPointer(input) then
                dragMode = "sv"
                page.ScrollingEnabled = false
                updateSV(input.Position)
            end
        end)
        comp:Connect(hueBar.InputBegan, function(input)
            if isPointer(input) then
                dragMode = "hue"
                page.ScrollingEnabled = false
                updateHue(input.Position)
            end
        end)
        comp:Connect(UserInputService.InputChanged, function(input)
            if dragMode and isMotion(input) then
                if dragMode == "sv" then
                    updateSV(input.Position)
                else
                    updateHue(input.Position)
                end
            end
        end)
        comp:Connect(UserInputService.InputEnded, function(input)
            if dragMode and isPointer(input) then
                dragMode = nil
                page.ScrollingEnabled = true
            end
        end)
        comp._onDestroy = function()
            if dragMode then
                page.ScrollingEnabled = true
            end
        end

        comp:Connect(hexBox.FocusLost, function()
            local ok, parsed = pcall(function()
                local text = hexBox.Text:gsub("%s", "")
                if text:sub(1, 1) ~= "#" then
                    text = "#" .. text
                end
                return Color3.fromHex(text)
            end)
            if ok and typeof(parsed) == "Color3" then
                applyColor(parsed, false)
            else
                render()
            end
        end)

        comp:Connect(header.Activated, function()
            expanded = not expanded
            tween(row, 0.16, { Size = UDim2.new(1, 0, 0, expanded and 172 or 40) })
        end)

        function comp:SetValue(newColor, silent)
            if typeof(newColor) == "Color3" then
                applyColor(newColor, silent)
            end
            return comp
        end
        comp.Set = comp.SetValue
        function comp:GetValue()
            return color
        end

        render()
        comp:_Register(color)
        return comp
    end

    -- Rayfield-style aliases: Section:AddButton(...) etc.
    local componentNames = {
        "Button", "Toggle", "Slider", "Dropdown", "Textbox",
        "Keybind", "ColorPicker", "Label", "Paragraph", "Divider",
    }
    for _, suffix in ipairs(componentNames) do
        SectionMethods["Add" .. suffix] = SectionMethods["Create" .. suffix]
    end

    --// Sections ------------------------------------------------------------------------
    function TabMethods:CreateSection(sectionConfig)
        assert(not self._destroyed, "[CSRE-Xploit] Tab has been destroyed")
        local window = self.Window
        local name, collapsed
        if type(sectionConfig) == "table" then
            name = tostring(sectionConfig.Name or sectionConfig.Title or "Section")
            collapsed = sectionConfig.Collapsed == true
        else
            name = tostring(sectionConfig or "Section")
            collapsed = false
        end

        local scope = {}
        local section = setmetatable({
            Tab = self,
            Name = name,
            Scope = scope,
            _count = 0,
            _collapsed = false,
            _destroyed = false,
        }, SectionMethods)

        local frame = make("Frame", {
            Name = "Section",
            Size = UDim2.new(1, -3, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            LayoutOrder = #self.Sections + 1,
        }, self.Page)
        corner(frame, 13)
        window:_Bind(frame, "BackgroundColor3", "Card", scope)
        window:_Bind(stroke(frame, BLACK, 1.2, 0.05), "Color", "Stroke", scope)
        make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, frame)

        local header = make("TextButton", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = 0,
        }, frame)
        local title = makeLabel(header, name, UDim2.new(1, -44, 1, 0), UDim2.fromOffset(11, 0), 13, nil, true)
        title.TextTruncate = Enum.TextTruncate.AtEnd
        window:_Bind(title, "TextColor3", "Text", scope)
        local chevron = makeLabel(header, ">", UDim2.fromOffset(20, 34), UDim2.new(1, -30, 0, 0), 14, nil, true)
        chevron.TextXAlignment = Enum.TextXAlignment.Center
        chevron.Rotation = 90
        window:_Bind(chevron, "TextColor3", "AccentDark", scope)
        local divider = make("Frame", {
            Position = UDim2.new(0, 11, 1, -1),
            Size = UDim2.new(1, -22, 0, 1),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.25,
        }, header)
        window:_Bind(divider, "BackgroundColor3", "Stroke", scope)

        local holder = make("Frame", {
            Name = "Components",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 1,
        }, frame)
        make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, holder)
        make("UIPadding", {
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9),
        }, holder)

        section.Frame = frame
        section.Holder = holder
        table.insert(self.Sections, section)

        function section:SetCollapsed(state)
            self._collapsed = state == true
            holder.Visible = not self._collapsed
            tween(chevron, 0.15, { Rotation = self._collapsed and 0 or 90 })
            return self
        end
        function section:SetName(value)
            title.Text = tostring(value)
            return self
        end
        function section:Destroy()
            if self._destroyed then
                return
            end
            self._destroyed = true
            window:_Kill(scope)
            frame:Destroy()
            for index, item in ipairs(self.Tab.Sections) do
                if item == self then
                    table.remove(self.Tab.Sections, index)
                    break
                end
            end
        end

        header.Activated:Connect(function()
            section:SetCollapsed(not section._collapsed)
        end)
        if collapsed then
            section:SetCollapsed(true)
        end
        return section
    end
    TabMethods.AddSection = TabMethods.CreateSection

    -- Shorthand: Tab:CreateButton(...) etc. use an auto-created default section.
    function TabMethods:_GetDefaultSection()
        if not self.DefaultSection or self.DefaultSection._destroyed then
            self.DefaultSection = self:CreateSection("Controls")
        end
        return self.DefaultSection
    end
    for _, suffix in ipairs(componentNames) do
        for _, prefix in ipairs({ "Create", "Add" }) do
            local methodName = prefix .. suffix
            TabMethods[methodName] = function(self, ...)
                local section = self:_GetDefaultSection()
                return section[methodName](section, ...)
            end
        end
    end

    function TabMethods:Select()
        local window = self.Window
        if window._destroyed or window.ActiveTab == self then
            return self
        end
        window.ActiveTab = self
        for _, other in ipairs(window.Tabs) do
            other.Page.Visible = other == self
            for _, record in ipairs(other._records) do
                applyRecord(record, window.Library.Theme, true)
            end
        end
        self.Page.Position = UDim2.fromOffset(0, 12)
        tween(self.Page, 0.2, { Position = UDim2.fromOffset(0, 0) })
        return self
    end

    function TabMethods:_ApplyCompact(compact)
        self.TextLabel.Visible = not compact
        self.IconHolder.AnchorPoint = compact and Vector2.new(0.5, 0) or Vector2.new(0, 0)
        self.IconHolder.Position = compact and UDim2.new(0.5, 0, 0, 0) or UDim2.fromOffset(8, 0)
    end

    function TabMethods:Destroy()
        if self._destroyed then
            return
        end
        self._destroyed = true
        local window = self.Window
        for _, record in ipairs(self._records) do
            record.Dead = true
        end
        for _, section in ipairs(self.Sections) do
            window:_Kill(section.Scope)
        end
        self.Button:Destroy()
        self.Page:Destroy()
        for index, tab in ipairs(window.Tabs) do
            if tab == self then
                table.remove(window.Tabs, index)
                break
            end
        end
        if window.ActiveTab == self then
            window.ActiveTab = nil
            if window.Tabs[1] then
                window.Tabs[1]:Select()
            end
        end
    end

    --// Window methods -------------------------------------------------------------------
    function WindowMethods:_Bind(instance, property, source, scope)
        local record = { Inst = instance, Prop = property, Source = source, Dead = false }
        table.insert(self._themed, record)
        if scope then
            table.insert(scope, record)
        end
        applyRecord(record, self.Library.Theme, false)
        return record
    end

    function WindowMethods:_Kill(scope)
        if scope then
            for _, record in ipairs(scope) do
                record.Dead = true
            end
        end
    end

    function WindowMethods:_Track(connection)
        table.insert(self._conns, connection)
        return connection
    end

    function WindowMethods:_ApplyTheme(animate)
        local theme = self.Library.Theme
        local alive = {}
        for _, record in ipairs(self._themed) do
            if not record.Dead then
                applyRecord(record, theme, animate)
                table.insert(alive, record)
            end
        end
        self._themed = alive
    end

    function WindowMethods:_ApplyLayout()
        if self._destroyed then
            return
        end
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(900, 650)
        local width = math.clamp(self._reqW, 300, math.max(300, viewport.X - 16))
        local height = math.clamp(self._reqH, 250, math.max(250, viewport.Y - 16))
        self._width, self._height = width, height
        self.Root.Size = self._minimized and UDim2.fromOffset(width, 54) or UDim2.fromOffset(width, height)

        local compact = width < 560
        self.Compact = compact
        local sidebarWidth = compact and 52 or 148
        self.Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -22)
        self.Content.Position = UDim2.new(0, sidebarWidth + 21, 0, 11)
        self.Content.Size = UDim2.new(1, -(sidebarWidth + 32), 1, -22)
        self.SideTitle.Visible = not compact
        for _, tab in ipairs(self.Tabs) do
            tab:_ApplyCompact(compact)
        end
    end

    function WindowMethods:SetTitle(newTitle, newSubtitle)
        self.TitleLabel.Text = tostring(newTitle or self.TitleLabel.Text)
        if newSubtitle ~= nil then
            self.SubtitleLabel.Text = tostring(newSubtitle)
        end
        return self
    end

    function WindowMethods:SetVisible(state)
        state = state ~= false
        self._visible = state
        if state then
            self.Scale.Scale = 0.92
            self.Root.Visible = true
            tween(self.Scale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
        else
            self.Root.Visible = false
        end
        return self
    end

    function WindowMethods:ToggleVisibility()
        self:SetVisible(not self._visible)
        return self._visible
    end

    function WindowMethods:SetToggleKey(key)
        if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
            self._toggleKey = key
        end
        return self
    end

    function WindowMethods:Minimize(state)
        if state == nil then
            state = not self._minimized
        end
        self._minimized = state == true
        self.Body.Visible = not self._minimized
        self.HeaderMask.Visible = not self._minimized
        tween(self.Root, 0.2, {
            Size = self._minimized and UDim2.fromOffset(self._width, 54) or UDim2.fromOffset(self._width, self._height),
        })
        self.MinimizeButton.Text = self._minimized and "+" or "-"
        return self._minimized
    end

    function WindowMethods:SetBackgroundImage(id, transparency, scaleType)
        self.BackgroundImage.Image = assetUri(id)
        self.BackgroundImage.ImageTransparency = math.clamp(tonumber(transparency) or 0.78, 0, 1)
        if scaleType then
            self.BackgroundImage.ScaleType = scaleType
        end
        return self
    end

    function WindowMethods:ClearBackgroundImage()
        self.BackgroundImage.Image = ""
        return self
    end

    function WindowMethods:SetBackgroundColor(color)
        assert(typeof(color) == "Color3", "SetBackgroundColor expects a Color3")
        local direction = luminance(color) < 0.5 and 1 or -1
        self.Library:SetTheme({
            Window = color,
            Panel = shade(color, 0.06 * direction),
            Card = shade(color, 0.12 * direction),
            CardHover = shade(color, 0.2 * direction),
        })
        return self
    end

    function WindowMethods:SetAccentColor(color)
        assert(typeof(color) == "Color3", "SetAccentColor expects a Color3")
        self.Library:SetTheme({
            Accent = color,
            AccentDark = shade(color, -0.25),
            Header = color,
            HeaderDark = shade(color, -0.25),
        })
        return self
    end

    function WindowMethods:SetTheme(theme)
        self.Library:SetTheme(theme)
        return self
    end

    --// Notifications
    function WindowMethods:Notify(notification)
        if self._destroyed then
            return
        end
        if type(notification) == "string" then
            notification = { Content = notification }
        end
        notification = notification or {}

        local kind = tostring(notification.Type or "Info")
        local accentKey = "Accent"
        if kind == "Success" then
            accentKey = "Success"
        elseif kind == "Warning" then
            accentKey = "Warning"
        elseif kind == "Error" or kind == "Danger" then
            accentKey = "Danger"
        end
        local duration = math.clamp(tonumber(notification.Duration) or 4, 1, 30)

        local scope = {}
        self._notifyCount = self._notifyCount + 1

        local slot = make("Frame", {
            Name = "NotificationSlot",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = self._notifyCount,
        }, self.NotificationHolder)

        local card = make("TextButton", {
            Name = "Notification",
            Position = UDim2.new(1, 30, 0, 0),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, slot)
        corner(card, 13)
        self:_Bind(card, "BackgroundColor3", "Card", scope)
        self:_Bind(stroke(card, BLACK, 1.5, 0), "Color", "Stroke", scope)

        local content = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, card)
        make("UIPadding", {
            PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 13),
            PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 10),
        }, content)
        make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, content)

        local heading = makeLabel(content, tostring(notification.Title or "CSRE-Xploit"), UDim2.new(1, 0, 0, 18), nil, 13, nil, true)
        heading.LayoutOrder = 1
        heading.TextTruncate = Enum.TextTruncate.AtEnd
        self:_Bind(heading, "TextColor3", "Text", scope)
        local message = makeLabel(content, tostring(notification.Content or notification.Text or ""), UDim2.new(1, 0, 0, 0), nil, 11, nil, false)
        message.LayoutOrder = 2
        message.AutomaticSize = Enum.AutomaticSize.Y
        message.TextWrapped = true
        message.TextYAlignment = Enum.TextYAlignment.Top
        self:_Bind(message, "TextColor3", "SubText", scope)

        local bar = make("Frame", { Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0 }, card)
        self:_Bind(bar, "BackgroundColor3", accentKey, scope)
        local progress = make("Frame", {
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            BorderSizePixel = 0,
        }, card)
        self:_Bind(progress, "BackgroundColor3", accentKey, scope)

        tween(card, 0.25, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
        tween(progress, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

        local dismissed = false
        local function dismiss()
            if dismissed then
                return
            end
            dismissed = true
            for index, item in ipairs(self._notifications) do
                if item == dismiss then
                    table.remove(self._notifications, index)
                    break
                end
            end
            tween(card, 0.2, { Position = UDim2.new(1, 30, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.24, function()
                self:_Kill(scope)
                slot:Destroy()
            end)
        end

        card.Activated:Connect(dismiss)
        task.delay(duration, dismiss)

        table.insert(self._notifications, dismiss)
        while #self._notifications > 5 do
            self._notifications[1]()
        end

        return { Dismiss = dismiss, Instance = card }
    end

    --// Modal dialog
    function WindowMethods:Dialog(config)
        if self._destroyed then
            return
        end
        config = config or {}
        local scope = {}

        local overlay = make("TextButton", {
            Name = "DialogOverlay",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = BLACK,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 50,
        }, self.Main)
        corner(overlay, 22)
        tween(overlay, 0.18, { BackgroundTransparency = 0.45 })

        local card = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0, math.min(320, self._width - 40), 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
        }, overlay)
        corner(card, 14)
        self:_Bind(card, "BackgroundColor3", "Card", scope)
        self:_Bind(stroke(card, BLACK, 1.5, 0), "Color", "Accent", scope)
        make("UIPadding", {
            PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
        }, card)
        make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, card)

        local title = makeLabel(card, tostring(config.Title or "Notice"), UDim2.new(1, 0, 0, 22), nil, 15, nil, true)
        title.LayoutOrder = 1
        self:_Bind(title, "TextColor3", "Text", scope)
        local body = makeLabel(card, tostring(config.Content or config.Text or ""), UDim2.new(1, 0, 0, 0), nil, 12, nil, false)
        body.LayoutOrder = 2
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.TextWrapped = true
        body.TextYAlignment = Enum.TextYAlignment.Top
        self:_Bind(body, "TextColor3", "SubText", scope)

        local buttonRow = make("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 3,
        }, card)
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, buttonRow)

        local closed = false
        local function close()
            if closed then
                return
            end
            closed = true
            tween(overlay, 0.15, { BackgroundTransparency = 1 })
            task.delay(0.16, function()
                self:_Kill(scope)
                overlay:Destroy()
            end)
        end

        local buttons = config.Buttons
        if type(buttons) ~= "table" or #buttons == 0 then
            buttons = { { Name = "OK", Primary = true } }
        end
        for index, definition in ipairs(buttons) do
            local button = make("TextButton", {
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = tostring(definition.Name or "OK"),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                LayoutOrder = index,
            }, buttonRow)
            corner(button, 9)
            make("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, button)
            if definition.Danger then
                self:_Bind(button, "BackgroundColor3", "Danger", scope)
                button.TextColor3 = WHITE
            elseif definition.Primary then
                self:_Bind(button, "BackgroundColor3", "Accent", scope)
                button.TextColor3 = WHITE
            else
                self:_Bind(button, "BackgroundColor3", "Panel", scope)
                self:_Bind(button, "TextColor3", "Text", scope)
            end
            button.Activated:Connect(function()
                close()
                safeCall(definition.Callback)
            end)
        end

        return { Close = close, Instance = overlay }
    end

    function WindowMethods:RequestClose()
        if self._confirmClose then
            self:Dialog({
                Title = "Close interface?",
                Content = "This will remove the UI. Run the script again to reopen it.",
                Buttons = {
                    { Name = "Cancel" },
                    { Name = "Close", Danger = true, Callback = function() self:Destroy() end },
                },
            })
        else
            self:Destroy()
        end
    end

    --// Tabs
    function WindowMethods:CreateTab(tabConfig, iconText)
        assert(not self._destroyed, "[CSRE-Xploit] Window has been destroyed")
        local name, icon
        if type(tabConfig) == "table" then
            name = tostring(tabConfig.Name or tabConfig.Title or ("Tab " .. (#self.Tabs + 1)))
            icon = tabConfig.Icon
        else
            name = tostring(tabConfig or ("Tab " .. (#self.Tabs + 1)))
            icon = iconText
        end

        local tab = setmetatable({
            Window = self,
            Name = name,
            Sections = {},
            _records = {},
            _destroyed = false,
        }, TabMethods)
        local function isActive()
            return self.ActiveTab == tab
        end

        local button = make("TextButton", {
            Name = "Tab",
            Size = UDim2.new(1, 0, 0, 37),
            BackgroundTransparency = 0.12,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            LayoutOrder = #self.Tabs + 1,
        }, self.TabList)
        corner(button, 10)
        local buttonStroke = stroke(button, BLACK, 1, 0.3)
        table.insert(tab._records, self:_Bind(button, "BackgroundColor3", function(t)
            return isActive() and t.Accent or t.Card
        end))
        table.insert(tab._records, self:_Bind(buttonStroke, "Color", function(t)
            return isActive() and t.AccentDark or t.Stroke
        end))

        local iconHolder = make("Frame", {
            Name = "Icon",
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.fromOffset(25, 37),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, button)
        local iconObject, iconProperty
        if isImageIcon(icon) then
            iconObject = make("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(19, 19),
                BackgroundTransparency = 1,
                Image = assetUri(icon),
            }, iconHolder)
            iconProperty = "ImageColor3"
        else
            local glyph = icon ~= nil and tostring(icon) or firstChar(name):upper()
            iconObject = makeLabel(iconHolder, glyph, UDim2.fromScale(1, 1), nil, 15, nil, true)
            iconObject.TextXAlignment = Enum.TextXAlignment.Center
            iconProperty = "TextColor3"
        end
        table.insert(tab._records, self:_Bind(iconObject, iconProperty, function(t)
            return isActive() and WHITE or t.SubText
        end))

        local label = makeLabel(button, name, UDim2.new(1, -39, 1, 0), UDim2.fromOffset(35, 0), 12, nil, true)
        label.TextTruncate = Enum.TextTruncate.AtEnd
        table.insert(tab._records, self:_Bind(label, "TextColor3", function(t)
            return isActive() and WHITE or t.Text
        end))

        local page = make("ScrollingFrame", {
            Name = "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 2,
        }, self.PageHost)
        self:_Bind(page, "ScrollBarImageColor3", "Accent")
        make("UIListLayout", { Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder }, page)
        make("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 7),
        }, page)

        tab.Button = button
        tab.Page = page
        tab.TextLabel = label
        tab.IconHolder = iconHolder
        table.insert(self.Tabs, tab)

        button.Activated:Connect(function()
            tab:Select()
        end)
        button.MouseEnter:Connect(function()
            if not isActive() then
                tween(button, 0.12, { BackgroundColor3 = self.Library.Theme.CardHover })
            end
        end)
        button.MouseLeave:Connect(function()
            applyRecord(tab._records[1], self.Library.Theme, true)
        end)

        tab:_ApplyCompact(self.Compact)
        if not self.ActiveTab then
            tab:Select()
        end
        return tab
    end
    WindowMethods.AddTab = WindowMethods.CreateTab

    --// Auto-built settings tab
    function WindowMethods:CreateSettingsTab(config)
        config = config or {}
        local library = self.Library
        local tab = self:CreateTab({ Name = config.Name or "Settings", Icon = config.Icon })

        local look = tab:CreateSection("Appearance")
        look:CreateDropdown({
            Name = "Theme",
            Options = library:GetThemeNames(),
            Default = library.ThemeName,
            Callback = function(name)
                library:SetTheme(name)
            end,
        })
        look:CreateColorPicker({
            Name = "Accent color",
            Default = library.Theme.Accent,
            Callback = function(color)
                self:SetAccentColor(color)
            end,
        })
        look:CreateTextbox({
            Name = "Background image ID",
            Placeholder = "Asset ID, press Enter",
            Callback = function(value)
                if value ~= "" then
                    self:SetBackgroundImage(value, self.BackgroundImage.ImageTransparency)
                else
                    self:ClearBackgroundImage()
                end
            end,
        })
        look:CreateSlider({
            Name = "Background visibility",
            Min = 0,
            Max = 100,
            Default = 22,
            Suffix = "%",
            Callback = function(value)
                self.BackgroundImage.ImageTransparency = 1 - value / 100
            end,
        })
        look:CreateKeybind({
            Name = "Toggle UI key",
            Default = self._toggleKey,
            Changed = function(key)
                if key ~= Enum.KeyCode.Unknown then
                    self._toggleKey = key
                end
            end,
        })

        local files = tab:CreateSection("Configuration")
        local nameBox = files:CreateTextbox({ Name = "Config name", Default = "default" })
        local saved
        saved = files:CreateDropdown({
            Name = "Saved configs",
            Options = library:ListConfigs(),
            Placeholder = "None",
            Callback = function(value)
                if value then
                    nameBox:SetValue(value, true)
                end
            end,
        })
        files:CreateButton({
            Name = "Save config",
            Callback = function()
                local ok, err = library:SaveConfig(nameBox:GetValue())
                self:Notify({
                    Title = "Config",
                    Content = ok and "Saved." or tostring(err),
                    Type = ok and "Success" or "Error",
                })
                saved:Refresh(library:ListConfigs())
            end,
        })
        files:CreateButton({
            Name = "Load config",
            Callback = function()
                local ok, err = library:LoadConfig(nameBox:GetValue())
                self:Notify({
                    Title = "Config",
                    Content = ok and "Loaded." or tostring(err),
                    Type = ok and "Success" or "Error",
                })
            end,
        })
        files:CreateButton({
            Name = "Delete config",
            Callback = function()
                local ok, err = library:DeleteConfig(nameBox:GetValue())
                self:Notify({
                    Title = "Config",
                    Content = ok and "Deleted." or tostring(err),
                    Type = ok and "Warning" or "Error",
                })
                saved:Refresh(library:ListConfigs())
            end,
        })

        local about = tab:CreateSection("About")
        about:CreateParagraph({
            Title = library.Name .. " v" .. library.Version,
            Content = "Bubble UI framework. Configs are stored in the executor workspace folder \"" .. library.ConfigFolder .. "\".",
        })
        about:CreateButton({
            Name = "Unload UI",
            Callback = function()
                self:RequestClose()
            end,
        })
        return tab
    end

    function WindowMethods:Destroy()
        if self._destroyed then
            return
        end
        self._destroyed = true
        for _, connection in ipairs(self._conns) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        self._conns = {}
        for _, record in ipairs(self._themed) do
            record.Dead = true
        end
        self._themed = {}
        for _, tab in ipairs(self.Tabs) do
            tab._destroyed = true
        end

        local library = self.Library
        for flag, option in pairs(library.Options) do
            if option.Window == self then
                library.Options[flag] = nil
                library.Flags[flag] = nil
            end
        end
        pcall(function()
            self.Gui:Destroy()
        end)
        for index, item in ipairs(library._windows) do
            if item == self then
                table.remove(library._windows, index)
                break
            end
        end
        safeCall(self.OnDestroy)
    end

    --// Window factory ---------------------------------------------------------------------
    function Library:CreateWindow(config)
        assert(not self._destroyed, "[CSRE-Xploit] Library has been destroyed")
        config = config or {}
        if config.Theme then
            self:SetTheme(config.Theme)
        end

        local title = tostring(config.Title or config.Name or "CSRE-Xploit")
        local subtitle = tostring(config.Subtitle or "Bubble UI Framework")
        local requestedSize = config.Size

        local screenGui = make("ScreenGui", {
            Name = "CSRE_Xploit_UI",
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999,
        })
        if not parentScreenGui(screenGui) then
            screenGui:Destroy()
            error("[CSRE-Xploit] Could not find a valid ScreenGui parent")
        end

        local window = setmetatable({
            Library = self,
            Gui = screenGui,
            Tabs = {},
            ActiveTab = nil,
            Compact = false,
            _themed = {},
            _conns = {},
            _notifications = {},
            _notifyCount = 0,
            _destroyed = false,
            _minimized = false,
            _visible = true,
            _capturing = false,
            _width = 600,
            _height = 400,
            _reqW = tonumber(config.Width) or (typeof(requestedSize) == "UDim2" and requestedSize.X.Offset > 0 and requestedSize.X.Offset) or 700,
            _reqH = tonumber(config.Height) or (typeof(requestedSize) == "UDim2" and requestedSize.Y.Offset > 0 and requestedSize.Y.Offset) or 470,
            _toggleKey = typeof(config.ToggleKey) == "EnumItem" and config.ToggleKey or Enum.KeyCode.RightShift,
            _confirmClose = config.ConfirmClose ~= false,
            OnDestroy = config.OnDestroy,
        }, WindowMethods)
        table.insert(self._windows, window)

        -- Root (draggable, scalable) > Shadow + Main
        local root = make("Frame", {
            Name = "Root",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(600, 400),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, screenGui)
        local uiScale = make("UIScale", { Scale = 0.85 }, root)

        local shadow = make("Frame", {
            Name = "Shadow",
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
        }, root)
        corner(shadow, 22)
        window:_Bind(shadow, "BackgroundColor3", "Shadow")

        local main = make("Frame", {
            Name = "MainWindow",
            Size = UDim2.fromScale(1, 1),
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, root)
        corner(main, 22)
        window:_Bind(main, "BackgroundColor3", "Window")
        window:_Bind(stroke(main, BLACK, 3, 0), "Color", "Stroke")

        -- Header
        local header = make("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 54),
            BackgroundColor3 = WHITE, -- the gradient supplies the actual color
            BorderSizePixel = 0,
        }, main)
        corner(header, 20)
        window:_Bind(make("UIGradient", { Rotation = 0 }, header), "Color", function(t)
            return ColorSequence.new(t.Header, t.HeaderDark)
        end)
        local headerMask = make("Frame", {
            Name = "HeaderBottomMask",
            Position = UDim2.new(0, 0, 1, -18),
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
        }, header)
        window:_Bind(make("UIGradient", { Rotation = 0 }, headerMask), "Color", function(t)
            return ColorSequence.new(t.Header, t.HeaderDark)
        end)

        local logo = make("Frame", {
            Name = "Logo",
            Position = UDim2.fromOffset(13, 10),
            Size = UDim2.fromOffset(34, 34),
            BackgroundColor3 = Color3.fromRGB(225, 251, 255),
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, header)
        corner(logo, 17)
        if isImageIcon(config.Icon) then
            make("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(22, 22),
                BackgroundTransparency = 1,
                Image = assetUri(config.Icon),
            }, logo)
        else
            local logoText = makeLabel(logo, config.Icon and tostring(config.Icon) or firstChar(title):upper(), UDim2.fromScale(1, 1), nil, 18, nil, true)
            logoText.TextXAlignment = Enum.TextXAlignment.Center
            window:_Bind(logoText, "TextColor3", "AccentDark")
        end

        local titleLabel = makeLabel(header, title, UDim2.new(1, -150, 0, 26), UDim2.fromOffset(56, 7), 20, WHITE, true)
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.ZIndex = 3
        local subtitleLabel = makeLabel(header, subtitle, UDim2.new(1, -160, 0, 16), UDim2.fromOffset(58, 31), 10, Color3.fromRGB(225, 250, 255), false)
        subtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        subtitleLabel.ZIndex = 3

        local minimizeButton = make("TextButton", {
            Name = "Minimize",
            Position = UDim2.new(1, -82, 0, 11),
            Size = UDim2.fromOffset(32, 32),
            BackgroundColor3 = WHITE,
            BackgroundTransparency = 0.8,
            Text = "-",
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            TextColor3 = WHITE,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, header)
        corner(minimizeButton, 16)

        local closeButton = make("TextButton", {
            Name = "Close",
            Position = UDim2.new(1, -43, 0, 11),
            Size = UDim2.fromOffset(32, 32),
            Text = "x",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = WHITE,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, header)
        corner(closeButton, 16)
        window:_Bind(closeButton, "BackgroundColor3", "Danger")

        -- Body
        local body = make("Frame", {
            Name = "Body",
            Position = UDim2.fromOffset(0, 54),
            Size = UDim2.new(1, 0, 1, -54),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, main)

        local sidebar = make("Frame", {
            Name = "Sidebar",
            Position = UDim2.fromOffset(11, 11),
            Size = UDim2.new(0, 148, 1, -22),
            BorderSizePixel = 0,
        }, body)
        corner(sidebar, 16)
        window:_Bind(sidebar, "BackgroundColor3", "Panel")
        window:_Bind(stroke(sidebar, BLACK, 1.5, 0), "Color", "Stroke")

        local sideTitle = makeLabel(sidebar, "NAVIGATION", UDim2.new(1, -20, 0, 23), UDim2.fromOffset(12, 8), 10, nil, true)
        window:_Bind(sideTitle, "TextColor3", "SubText")

        local tabList = make("ScrollingFrame", {
            Name = "TabList",
            Position = UDim2.fromOffset(7, 38),
            Size = UDim2.new(1, -14, 1, -47),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, sidebar)
        window:_Bind(tabList, "ScrollBarImageColor3", "Accent")
        make("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)
        make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 5) }, tabList)

        local content = make("Frame", {
            Name = "Content",
            Position = UDim2.new(0, 169, 0, 11),
            Size = UDim2.new(1, -180, 1, -22),
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, body)
        corner(content, 16)
        window:_Bind(content, "BackgroundColor3", "Panel")
        window:_Bind(stroke(content, BLACK, 1.5, 0), "Color", "Stroke")

        local pageHost = make("Frame", {
            Name = "PageHost",
            Position = UDim2.fromOffset(7, 7),
            Size = UDim2.new(1, -14, 1, -14),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, content)

        local backgroundImage = make("ImageLabel", {
            Name = "CustomBackground",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 0.78,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 1,
        }, pageHost)
        corner(backgroundImage, 12)

        -- Notification stack
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(900, 650)
        local notificationHolder = make("Frame", {
            Name = "Notifications",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 60),
            Size = UDim2.fromOffset(math.min(280, viewport.X - 24), 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 100,
        }, screenGui)
        make("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, notificationHolder)

        window.Root = root
        window.Scale = uiScale
        window.Main = main
        window.Header = header
        window.HeaderMask = headerMask
        window.Body = body
        window.Sidebar = sidebar
        window.SideTitle = sideTitle
        window.TabList = tabList
        window.Content = content
        window.PageHost = pageHost
        window.BackgroundImage = backgroundImage
        window.NotificationHolder = notificationHolder
        window.TitleLabel = titleLabel
        window.SubtitleLabel = subtitleLabel
        window.MinimizeButton = minimizeButton
        window.CloseButton = closeButton

        -- Interaction
        makeDraggable(window, header, root, 90, 40, nil)

        minimizeButton.Activated:Connect(function()
            window:Minimize()
        end)
        closeButton.Activated:Connect(function()
            window:RequestClose()
        end)
        minimizeButton.MouseEnter:Connect(function()
            tween(minimizeButton, 0.12, { BackgroundTransparency = 0.6 })
        end)
        minimizeButton.MouseLeave:Connect(function()
            tween(minimizeButton, 0.12, { BackgroundTransparency = 0.8 })
        end)
        closeButton.MouseEnter:Connect(function()
            tween(closeButton, 0.12, { BackgroundColor3 = shade(self.Theme.Danger, 0.15) })
        end)
        closeButton.MouseLeave:Connect(function()
            tween(closeButton, 0.12, { BackgroundColor3 = self.Theme.Danger })
        end)

        window:_Track(UserInputService.InputBegan:Connect(function(input, processed)
            if processed or window._capturing then
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == window._toggleKey then
                window:ToggleVisibility()
            end
        end))

        if camera then
            window:_Track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                window:_ApplyLayout()
            end))
        end

        -- Floating bubble: reopen / hide the window on touch devices (no keyboard needed).
        local showBubble = config.ShowToggleButton
        if showBubble == nil then
            showBubble = UserInputService.TouchEnabled
        end
        if showBubble then
            local bubble = make("TextButton", {
                Name = "ToggleBubble",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 34, 0.35, 0),
                Size = UDim2.fromOffset(46, 46),
                Text = config.Icon and not isImageIcon(config.Icon) and tostring(config.Icon) or firstChar(title):upper(),
                Font = Enum.Font.GothamBold,
                TextSize = 20,
                TextColor3 = WHITE,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                ZIndex = 90,
            }, screenGui)
            corner(bubble, 23)
            window:_Bind(bubble, "BackgroundColor3", "Accent")
            window:_Bind(stroke(bubble, WHITE, 2, 0.35), "Color", "AccentDark")
            window.Bubble = bubble
            makeDraggable(window, bubble, bubble, 46, 46, function()
                window:ToggleVisibility()
            end)
        end

        window:_ApplyLayout()
        tween(uiScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)

        if typeof(config.BackgroundColor) == "Color3" then
            window:SetBackgroundColor(config.BackgroundColor)
        end
        if config.BackgroundImage then
            window:SetBackgroundImage(config.BackgroundImage, config.BackgroundTransparency)
        end
        return window
    end

    function Library:Destroy()
        if self._destroyed then
            return
        end
        self._destroyed = true
        while #self._windows > 0 do
            local window = self._windows[1]
            local before = #self._windows
            window:Destroy()
            if #self._windows == before then
                table.remove(self._windows, 1)
            end
        end
        table.clear(self.Flags)
        table.clear(self.Options)
    end

    --// Demo -------------------------------------------------------------------------------
    function Library:Demo()
        local window = self:CreateWindow({
            Title = "CSRE-Xploit",
            Subtitle = "v" .. self.Version .. "  -  Demo",
            Theme = "Bubble",
        })

        local home = window:CreateTab({ Name = "Main", Icon = "M" })
        local basics = home:CreateSection("Basic controls")
        basics:CreateButton({
            Name = "Show notification",
            Callback = function()
                window:Notify({ Title = "Hello", Content = "Button callback works.", Type = "Success" })
            end,
        })
        basics:CreateToggle({
            Name = "Example ON / OFF",
            Flag = "demo_toggle",
            Callback = function(value)
                print("Toggle =", value)
            end,
        })
        basics:CreateSlider({
            Name = "Example slider",
            Min = 0, Max = 100, Step = 1, Default = 50, Flag = "demo_slider",
            Callback = function(value)
                print("Slider =", value)
            end,
        })
        basics:CreateDropdown({
            Name = "Single dropdown",
            Options = { "Alpha", "Beta", "Gamma" },
            Default = "Alpha",
            Flag = "demo_dropdown",
            Callback = function(value)
                print("Dropdown =", value)
            end,
        })
        basics:CreateDropdown({
            Name = "Multi dropdown",
            Options = { "One", "Two", "Three", "Four" },
            Multi = true,
            Default = { "Two" },
            Flag = "demo_multi",
            Callback = function(values)
                print("Multi =", table.concat(values, ", "))
            end,
        })

        local inputs = home:CreateSection("Inputs")
        inputs:CreateTextbox({
            Name = "Text",
            Placeholder = "Type and press Enter",
            Flag = "demo_text",
            Callback = function(text)
                print("Text =", text)
            end,
        })
        inputs:CreateTextbox({ Name = "Number", Numeric = true, Default = 16, Flag = "demo_number" })
        inputs:CreateKeybind({
            Name = "Action key",
            Default = Enum.KeyCode.F,
            Flag = "demo_key",
            Callback = function()
                window:Notify({ Title = "Keybind", Content = "Action key pressed." })
            end,
        })
        inputs:CreateColorPicker({
            Name = "Color",
            Default = Color3.fromRGB(0, 190, 225),
            Flag = "demo_color",
            Callback = function(color)
                print("Color =", color)
            end,
        })

        local info = home:CreateSection({ Name = "Info (tap header to collapse)" })
        info:CreateLabel("Labels wrap automatically when the text is long enough to need it.")
        info:CreateDivider()
        info:CreateParagraph({
            Title = "Paragraph",
            Content = "Paragraphs grow with their content. Use them for descriptions, changelogs and help text.",
        })
        info:CreateButton({
            Name = "Open confirm dialog",
            Callback = function()
                window:Dialog({
                    Title = "Are you sure?",
                    Content = "Dialogs can have any number of buttons.",
                    Buttons = {
                        { Name = "No" },
                        { Name = "Yes", Primary = true, Callback = function()
                            window:Notify({ Title = "Dialog", Content = "You pressed Yes.", Type = "Info" })
                        end },
                    },
                })
            end,
        })

        window:CreateSettingsTab()
        window:Notify({ Title = "CSRE-Xploit", Content = "Demo loaded. Press RightShift to hide/show.", Duration = 5 })
        return window
    end

    return Library
end)()

--// Public handles
_G.CSRE_Xploit = CSRE_Xploit
env.CSRE_Xploit = CSRE_Xploit

if env.CSRE_DEMO == true then
    CSRE_Xploit:Demo()
end

return CSRE_Xploit
