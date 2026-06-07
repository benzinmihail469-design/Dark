-- 1. Сначала вставляешь весь код библиотеки выше, присвоив его переменной:
-- (Допустим, код выше выполнен, и у нас есть объект ModernLib)

-- 2. Создаем твое новое красивое окно
local MyUI = ModernLib:CreateWindow("⚡ BRAINROT HUB v2.0")

-- 3. Добавляем кнопки в один клик!
MyUI:CreateButton("🤖 Включить Perfect Hits (Авто-удар)", function()
    print("Perfect Hits активирован!")
    -- Сюда пишешь свой скрипт автоматизации
end)

MyUI:CreateButton("🔥 Собрать Brainrot предметы", function()
    print("Предметы собираются...")
    -- Твой код на сбор лута
end)

MyUI:CreateButton("💨 Скорость х2", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 32
end)
