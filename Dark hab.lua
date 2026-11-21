--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
repeat task.wait() until game:IsLoaded()

local success, NeverloseUI = pcall(function()
    return loadstring(game:HttpGet("https://script.roscripts.io/Ci0HsqM"))()
end)

if not success or not NeverloseUI then
    warn("Failed to load NeverloseUI.")
    return
end

local Window
local function SafeCall(callback)
    local ok, result = pcall(callback)
    if not ok then
        warn("[NeverloseUI] " .. tostring(result))
    end
    return ok, result
end

SafeCall(function()
    NeverloseUI:AddTheme({
        Name = "Ocean Blue",
        Accent = Color3.fromRGB(55, 145, 255),
        Background = Color3.fromRGB(18, 21, 29),
        Secondary = Color3.fromRGB(25, 30, 42),
        Text = Color3.fromRGB(235, 242, 255),
        Border = Color3.fromRGB(45, 65, 95)
    })
end)

local created, result = SafeCall(function()
    return NeverloseUI:CreateWindow({
        Title = "Example Hub",
        Subtitle = "Blue Edition",
        Theme = "Ocean Blue",
        ToggleKeybind = Enum.KeyCode.RightShift,
        ConfigEnabled = true,
        AutoSave = true,
        AutoLoad = true,
        DraggableToggle = true
    })
end)

if not created or not result then
    warn("Failed to create the interface.")
    return
end

Window = result

local function AddTab(name, icon)
    local ok, tab = SafeCall(function()
        return Window:AddTab({
            Name = name,
            Icon = icon
        })
    end)

    if ok then
        return tab
    end

    return nil
end

local function AddSection(tab, name)
    if not tab then
        return nil
    end

    local ok, section = SafeCall(function()
        return tab:AddSection({
            Name = name
        })
    end)

    if ok then
        return section
    end

    return nil
end

local HomeTab = AddTab("Home", "house")
local SettingsTab = AddTab("Settings", "settings")

local MainSection = AddSection(HomeTab, "Main")

if MainSection then
    SafeCall(function()
        MainSection:AddParagraph({
            Title = "Welcome",
            Content = "Welcome to Example Hub."
        })
    end)

    SafeCall(function()
        MainSection:AddButton({
            Name = "Show Notification",
            Callback = function()
                SafeCall(function()
                    NeverloseUI:Notify({
                        Title = "Example Hub",
                        Content = "The interface is working.",
                        Duration = 3
                    })
                end)
            end
        })
    end)

    SafeCall(function()
        MainSection:AddToggle({
            Name = "Example Toggle",
            Default = false,
            Callback = function(value)
                print("Example Toggle:", value)
            end
        })
    end)

    SafeCall(function()
        MainSection:AddSlider({
            Name = "Example Slider",
            Min = 0,
            Max = 100,
            Default = 50,
            Callback = function(value)
                print("Slider Value:", value)
            end
        })
    end)

    SafeCall(function()
        MainSection:AddDropdown({
            Name = "Example Dropdown",
            Options = {"Option A", "Option B", "Option C"},
            Default = "Option A",
            Callback = function(value)
                print("Selected Option:", value)
            end
        })
    end)
end

local SettingsSection = AddSection(SettingsTab, "Settings")

if SettingsSection then
    SafeCall(function()
        SettingsSection:AddToggle({
            Name = "Example Setting",
            Default = true,
            Callback = function(value)
                print("Setting Enabled:", value)
            end
        })
    end)

    SafeCall(function()
        SettingsSection:AddButton({
            Name = "Unload Interface",
            Callback = function()
                SafeCall(function()
                    NeverloseUI:Unload()
                end)
            end
        })
    end)
end

SafeCall(function()
    NeverloseUI:Notify({
        Title = "Example Hub",
        Content = "Interface loaded.",
        Duration = 3
    })
end)
