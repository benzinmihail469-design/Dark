-- ============================================================================
-- 1. ЗАГРУЗКА БИБЛИОТЕКИ (LOADER)
-- ============================================================================
local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()
​-- ============================================================================
-- 2. СОЗДАНИЕ ГЛАВНОГО ОКНА (WINDOW)
-- ============================================================================
local Window = MacLib:Window({
Title = "Rararara Hub",
Subtitle = "v2.5 • ESP & Visuals",
Size = UDim2.fromOffset(868, 650),
DragStyle = 1, -- 1 = перетаскивание за иконку сверху, 2 = за всё окно
DisabledWindowControls = {},
ShowUserInfo = true,
Keybind = Enum.KeyCode.RightControl, -- клавиша скрытия/показа меню
AcrylicBlur = true,
})
​-- ============================================================================
-- 3. ГЛОБАЛЬНЫЕ НАСТРОЙКИ (ИКОНКА ШЕСТЕРЁНКИ В ШАПКЕ САЙДБАРА)
-- ============================================================================
Window:GlobalSetting({
Name = "UI Blur",
Default = Window:GetAcrylicBlurState(),
Callback = function(state)
Window:SetAcrylicBlurState(state)
end,
})
​Window:GlobalSetting({
Name = "Notifications",
Default = Window:GetNotificationsState(),
Callback = function(state)
Window:SetNotificationsState(state)
end,
})
​Window:GlobalSetting({
Name = "Show User Info",
Default = Window:GetUserInfoState(),
Callback = function(state)
Window:SetUserInfoState(state)
end,
})
​-- ============================================================================
-- 4. СОЗДАНИЕ ГРУППЫ ВКЛАДОК И ВКЛАДОК (TABGROUP & TAB)
-- ============================================================================
local MainTabGroup = Window:TabGroup()
​local VisualsTab = MainTabGroup:Tab({
Name = "ESP & Visuals",
Image = "rbxassetid://10723346959" -- иконка вкладки
})
​local CombatTab = MainTabGroup:Tab({
Name = "Combat",
Image = "rbxassetid://10734974297"
})
​-- ============================================================================
-- 5. СОЗДАНИЕ СВОРАЧИВАЕМЫХ СЕКЦИЙ (SECTION)
-- ============================================================================
local LeftSection = VisualsTab:Section({
Side = "Left", -- "Left" или "Right"
Name = "Player ESP",
Icon = "rbxassetid://10723346959"
})
​local RightSection = VisualsTab:Section({
Side = "Right",
Name = "Color Palette",
Icon = "rbxassetid://10734950309"
})
​-- ============================================================================
-- 6. ВЫЗОВ ФУНКЦИИ ЦВЕТА (COLOR / COLORPICKER) — ОБНОВЛЁННАЯ ПАЛИТРА С ИКОНКАМИ
-- ============================================================================
-- Вариант 1: Через короткий вызов :Color(...)
local BoxColor = RightSection:Color({
Name = "Box ESP Color",
Icon = "rbxassetid://10734950309", -- кастомная иконка слева на карточке
Default = Color3.fromRGB(0, 210, 255),
Rainbow = false, -- можно включить радугу сразу (true/false)
Callback = function(color)
print("Выбран цвет Box ESP:", color)
end,
})
​-- Вариант 2: С прозрачностью (Alpha) через :Colorpicker(...) или :Color(...)
local ChamsColor = RightSection:Colorpicker({
Name = "Chams Fill & Alpha",
Icon = "rbxassetid://10723346959",
Default = Color3.fromRGB(255, 65, 85),
Alpha = 0.25, -- от 0 (непрозрачный) до 1 (полностью прозрачный)
Callback = function(color, alpha)
print("Цвет Chams:", color, "Прозрачность:", alpha)
end,
})
​-- Методы управления цветом из кода:
-- BoxColor:SetColor(Color3.fromRGB(55, 225, 125), true)
-- BoxColor:GetColor()
-- ChamsColor:SetAlpha(0.5, true)
-- ChamsColor:GetAlpha()
-- BoxColor:SetRainbow(true)
-- BoxColor:UpdateName("New Color Name")
-- BoxColor:UpdateIcon("rbxassetid://10734974297")
-- BoxColor:SetVisibility(true)
​-- ============================================================================
-- 7. ВЫЗОВ ОСТАЛЬНЫХ ЭЛЕМЕНТОВ БИБЛИОТЕКИ
-- ============================================================================
​-- [TOGGLE] Переключатель
local EspToggle = LeftSection:Toggle({
Name = "Enable Player ESP",
Default = true,
Callback = function(state)
print("ESP включён:", state)
end,
})
-- Методы: EspToggle:UpdateState(false), EspToggle:GetState(), EspToggle:UpdateName("...")
​-- [SLIDER] Ползунок
local DistanceSlider = LeftSection:Slider({
Name = "Max ESP Distance",
Default = 1500,
Minimum = 100,
Maximum = 5000,
DisplayMethod = "Value", -- "Value", "Percent", "Degrees", "Tenths", "Hundredths", "Round"
Callback = function(value)
print("Дистанция ESP:", value)
end,
})
-- Методы: DistanceSlider:UpdateValue(2000), DistanceSlider:GetValue()
​-- [DROPDOWN] Одиночный выпадающий список
local ModeDropdown = LeftSection:Dropdown({
Name = "Box Style",
Search = false,
Multi = false,
Required = true,
Options = {"2D Corner", "2D Box", "3D Box", "Highlight"},
Default = 1,
Callback = function(selected)
print("Выбран режим:", selected)
end,
})
​-- [MULTI-DROPDOWN] Множественный выпадающий список с поиском
local ElementsDropdown = LeftSection:Dropdown({
Name = "ESP Elements",
Search = true,
Multi = true,
Required = false,
Options = {"Box", "Name", "HealthBar", "Tracers", "Distance"},
Default = {"Box", "Name", "HealthBar"},
Callback = function(selectedTable)
for optionName, isSelected in pairs(selectedTable) do
print(optionName, isSelected)
end
end,
})
-- Методы: ModeDropdown:UpdateSelection("3D Box"), ModeDropdown:InsertOptions({"Skeleton"}), ModeDropdown:ClearOptions()
​-- [KEYBIND] Бинд клавиши (поддерживает ПК и мобильную клавиатуру)
local EspKeybind = LeftSection:Keybind({
Name = "Toggle ESP Keybind",
Default = Enum.KeyCode.V,
Callback = function(key)
EspToggle:Toggle()
end,
onBinded = function(newKey)
Window:Notify({
Title = "Keybind",
Description = "Новая клавиша: " .. tostring(newKey and newKey.Name or "None"),
Lifetime = 3
})
end,
})
​-- [INPUT] Текстовое поле ввода
local ConfigInput = LeftSection:Input({
Name = "Config Name",
Placeholder = "Введите название...",
Default = "LegitCfg",
AcceptedCharacters = "All", -- "All", "Numeric", "Alphabetic"
Callback = function(text)
print("Введён текст (Enter/FocusLost):", text)
end,
onChanged = function(text)
print("Текст изменён:", text)
end,
})
​-- [BUTTON] Кнопка с иконкой
RightSection:Button({
Name = "Apply & Notify",
Icon = "rbxassetid://10709790644",
Callback = function()
Window:Notify({
Title = "Rararara Hub",
Description = "Настройки цветов успешно применены!",
Style = "Confirm", -- "None", "Confirm", "Cancel"
Lifetime = 4
})
end,
})
​-- [DIALOG] Модальное диалоговое окно
RightSection:Button({
Name = "Reset All Settings",
Icon = "rbxassetid://10734941499",
Callback = function()
Window:Dialog({
Title = "Сброс настроек",
Description = "Вы уверены, что хотите сбросить цвета и настройки ESP по умолчанию?",
Buttons = {
{
Name = "Подтвердить",
Callback = function()
BoxColor:SetColor(Color3.fromRGB(0, 210, 255), true)
ChamsColor:SetColor(Color3.fromRGB(255, 65, 85), true)
ChamsColor:SetAlpha(0.25, true)
end,
},
{
Name = "Отмена"
}
}
})
end,
})
​-- [DIVIDER / HEADER / PARAGRAPH / LABEL / SUBLABEL] Текстовые элементы и разделители
RightSection:Divider()
​RightSection:Header({
Text = "Информация"
})
​RightSection:Paragraph({
Header = "Управление палитрой",
Body = "Нажми на карточку цвета, чтобы открыть 2D HSV-палитру, выбрать готовый оттенок из Quick Palette или включить режим Rainbow."
})
​RightSection:Label({
Text = "Статус: Все модули активны"
})
​RightSection:SubLabel({
Text = "Поддерживается управление мышью и сенсорным экраном"
})
​-- Активируем первую вкладку при запуске
VisualsTab:Select()
