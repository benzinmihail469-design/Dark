-- Шаг 1: загружаем исходник
local url = "https://raw.githubusercontent.com/benzinmihail469-design/Rararara/main/Esp.lua"

local success, source = pcall(function()
    return game:HttpGet(url, true)
end)

if not success or not source or #source == 0 then
    warn("[MacLib] Не удалось загрузить скрипт. Проверь интернет и ссылку.")
    return
end

-- Шаг 2: проверяем, что это не HTML-страница
if source:sub(1, 15):find("<!DOCTYPE") or source:find("404: Not Found") then
    warn("[MacLib] Ссылка ведёт на HTML. Нужна raw-ссылка (raw.githubusercontent.com).")
    return
end

-- Шаг 3: компилируем
local chunk, compileError = loadstring(source)

if not chunk then
    warn("[MacLib] Ошибка компиляции: " .. tostring(compileError))
    return
end

-- Шаг 4: выполняем и получаем MacLib
local ok, MacLib = pcall(chunk)

if not ok then
    warn("[MacLib] Ошибка выполнения: " .. tostring(MacLib))
    return
end

if type(MacLib) ~= "table" then
    warn("[MacLib] Скрипт не вернул таблицу. Тип: " .. type(MacLib))
    return
end

print("[MacLib] ✅ Загружено успешно!")

-- Шаг 5: теперь можно использовать MacLib
local Window = MacLib:Window({
    Title = "My Script",
    Subtitle = "v1.0.0",
    Size = UDim2.fromOffset(868, 650),
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
    ShowUserInfo = true,
})

local TabGroup = Window:TabGroup()
local MainTab = TabGroup:Tab({
    Name = "Main",
    Image = "rbxassetid://18821914323"
})

local Section = MainTab:Section({
    Side = "Left",
    Name = "Combat",
    Icon = "rbxassetid://18821914323",
})

Section:Button({
    Name = "Test",
    Callback = function()
        Window:Notify({
            Title = "OK",
            Description = "Работает!",
            Lifetime = 3
        })
    end,
})

MainTab:Select()
