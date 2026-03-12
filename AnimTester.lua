-- ========== ОБЪЕДИНЁННЫЙ СКРИПТ (ТЕСТЕР + ЛОГГЕР) ==========
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

------------------------------------------
-- 1. ТВОЙ ТЕСТЕР АНИМАЦИЙ
------------------------------------------

-- ХРАНИЛИЩЕ
local FAVORITES = {}
local MAX_FAV = 50
local currentTrack = nil
local gui, favScrolling

-- Запуск анимации
local function playAnimation(id)
    if currentTrack then pcall(function() currentTrack:Stop() end) end
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    local track = hum:LoadAnimation(anim)
    track:Play()
    currentTrack = track
    if syn and syn.toast then syn.toast("✅", id, 1) end
end

local function stopAnimation()
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
        if syn and syn.toast then syn.toast("⏹️", "Стоп", 1) end
    end
end

-- Добавление в избранное
local function addToFavorites(name, id)
    local cleanId = id:match("%d+")
    if not cleanId then
        if syn and syn.toast then syn.toast("❌", "Неверный ID", 1) end
        return false
    end
    if name == "" then name = "Анимация" end
    if #FAVORITES >= MAX_FAV then
        if syn and syn.toast then syn.toast("❌", "Лимит 50", 1) end
        return false
    end
    for _, v in ipairs(FAVORITES) do
        if v.id == cleanId then
            if syn and syn.toast then syn.toast("⚠️", "Уже есть", 1) end
            return false
        end
    end
    table.insert(FAVORITES, {name = name, id = cleanId})
    if syn and syn.toast then syn.toast("❤️", name .. " (" .. #FAVORITES .. "/50)", 1) end
    if favScrolling then updateFavoritesList() end
    return true
end

-- Удаление
local function removeFromFavorites(index)
    if FAVORITES[index] then
        local name = FAVORITES[index].name
        table.remove(FAVORITES, index)
        if syn and syn.toast then syn.toast("🗑️", name, 1) end
        if favScrolling then updateFavoritesList() end
    end
end

-- Обновление списка
local function updateFavoritesList()
    if not favScrolling then return end
    favScrolling:ClearAllChildren()
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    header.Text = "  ❤️ ИЗБРАННОЕ (" .. #FAVORITES .. "/50)"
    header.TextColor3 = Color3.fromRGB(255, 200, 100)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 10
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = favScrolling
    
    if #FAVORITES == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 25)
        empty.BackgroundTransparency = 1
        empty.Text = "  Пусто"
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 10
        empty.TextXAlignment = Enum.TextXAlignment.Left
        empty.Parent = favScrolling
        return
    end
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = favScrolling
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for i, anim in ipairs(FAVORITES) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 24)
        row.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        row.BorderSizePixel = 1
        row.BorderColor3 = Color3.fromRGB(60, 60, 70)
        row.Parent = favScrolling
        
        local nameBtn = Instance.new("TextButton")
        nameBtn.Size = UDim2.new(0.5, -5, 1, 0)
        nameBtn.Position = UDim2.new(0, 5, 0, 0)
        nameBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        nameBtn.Text = "  " .. anim.name
        nameBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
        nameBtn.Font = Enum.Font.Gotham
        nameBtn.TextSize = 10
        nameBtn.TextXAlignment = Enum.TextXAlignment.Left
        nameBtn.Parent = row
        nameBtn.MouseButton1Click:Connect(function() playAnimation(anim.id) end)
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0.15, -5, 1, 0)
        copyBtn.Position = UDim2.new(0.5, 0, 0, 0)
        copyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        copyBtn.Text = "📋"
        copyBtn.TextColor3 = Color3.new(1, 1, 1)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 12
        copyBtn.Parent = row
        copyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(anim.id)
                if syn and syn.toast then syn.toast("📋", "ID скопирован", 1) end
            end
        end)
        
        local deleteBtn = Instance.new("TextButton")
        deleteBtn.Size = UDim2.new(0.15, -5, 1, 0)
        deleteBtn.Position = UDim2.new(0.65, 0, 0, 0)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        deleteBtn.Text = "✕"
        deleteBtn.TextColor3 = Color3.new(1, 1, 1)
        deleteBtn.Font = Enum.Font.GothamBold
        deleteBtn.TextSize = 12
        deleteBtn.Parent = row
        deleteBtn.MouseButton1Click:Connect(function() removeFromFavorites(i) end)
        
        local idLabel = Instance.new("TextLabel")
        idLabel.Size = UDim2.new(0.2, -5, 1, 0)
        idLabel.Position = UDim2.new(0.8, 0, 0, 0)
        idLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        idLabel.Text = anim.id
        idLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        idLabel.Font = Enum.Font.Code
        idLabel.TextSize = 8
        idLabel.TextXAlignment = Enum.TextXAlignment.Center
        idLabel.Parent = row
    end
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА ТЕСТЕРА
gui = Instance.new("ScreenGui")
gui.Name = "AnimTester"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Иконка сворачивания
local toggleIcon = Instance.new("TextButton")
toggleIcon.Size = UDim2.new(0, 40, 0, 40)
toggleIcon.Position = UDim2.new(0, 10, 0, 40)
toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
toggleIcon.Text = "🎮"
toggleIcon.TextColor3 = Color3.new(1, 1, 1)
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.TextSize = 24
toggleIcon.Draggable = true
toggleIcon.Visible = false
toggleIcon.Parent = gui

-- Основное окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 220)
main.Position = UDim2.new(0, 10, 0, 40)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(100, 200, 255)
main.Active = true
main.Draggable = true
main.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.Text = "🎬 ТЕСТЕР АНИМАЦИЙ"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = main

-- Кнопка минус
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
minimizeBtn.Position = UDim2.new(1, -45, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Parent = title
minimizeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    toggleIcon.Visible = true
    toggleIcon.Position = main.Position
end)

toggleIcon.MouseButton1Click:Connect(function()
    main.Visible = true
    toggleIcon.Visible = false
    main.Position = toggleIcon.Position
end)

-- Кнопка сердечко
local heartBtn = Instance.new("TextButton")
heartBtn.Size = UDim2.new(0, 25, 0, 25)
heartBtn.Position = UDim2.new(1, -25, 0, 2)
heartBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
heartBtn.Text = "❤️"
heartBtn.TextColor3 = Color3.new(1, 1, 1)
heartBtn.Font = Enum.Font.GothamBold
heartBtn.TextSize = 14
heartBtn.Parent = title

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(0, 2, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = title
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Секция тестирования
local testSection = Instance.new("Frame")
testSection.Size = UDim2.new(1, -10, 0, 90)
testSection.Position = UDim2.new(0, 5, 0, 35)
testSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
testSection.BorderSizePixel = 1
testSection.BorderColor3 = Color3.fromRGB(80, 80, 100)
testSection.Parent = main

local testLabel = Instance.new("TextLabel")
testLabel.Size = UDim2.new(1, 0, 0, 20)
testLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
testLabel.Text = "  🎯 ТЕСТИРОВАНИЕ"
testLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
testLabel.Font = Enum.Font.GothamBold
testLabel.TextSize = 11
testLabel.TextXAlignment = Enum.TextXAlignment.Left
testLabel.Parent = testSection

local idInput = Instance.new("TextBox")
idInput.Size = UDim2.new(1, -30, 0, 25)
idInput.Position = UDim2.new(0, 5, 0, 25)
idInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
idInput.PlaceholderText = "Введи ID анимации"
idInput.Text = ""
idInput.TextColor3 = Color3.fromRGB(255, 255, 255)
idInput.Font = Enum.Font.Code
idInput.TextSize = 11
idInput.BorderSizePixel = 1
idInput.BorderColor3 = Color3.fromRGB(200, 200, 0)
idInput.ClearTextOnFocus = false
idInput.Parent = testSection

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 20, 0, 20)
clearBtn.Position = UDim2.new(1, -25, 0, 27)
clearBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
clearBtn.Text = "✕"
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 12
clearBtn.BorderSizePixel = 1
clearBtn.BorderColor3 = Color3.fromRGB(150, 150, 150)
clearBtn.Parent = testSection
clearBtn.MouseButton1Click:Connect(function() idInput.Text = "" end)

local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(0.5, -5, 0, 25)
playBtn.Position = UDim2.new(0, 5, 0, 55)
playBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
playBtn.Text = "▶ ЗАПУСТИТЬ"
playBtn.TextColor3 = Color3.new(1, 1, 1)
playBtn.Font = Enum.Font.GothamBold
playBtn.TextSize = 11
playBtn.BorderSizePixel = 1
playBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
playBtn.Parent = testSection
playBtn.MouseButton1Click:Connect(function()
    local id = idInput.Text:match("%d+")
    if id then playAnimation(id)
    else if syn and syn.toast then syn.toast("❌", "Введи ID", 1) end end
end)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.5, -5, 0, 25)
stopBtn.Position = UDim2.new(0.5, 0, 0, 55)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopBtn.Text = "⏹ СТОП"
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 11
stopBtn.BorderSizePixel = 1
stopBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Parent = testSection
stopBtn.MouseButton1Click:Connect(stopAnimation)

-- Секция добавления
local addSection = Instance.new("Frame")
addSection.Size = UDim2.new(1, -10, 0, 70)
addSection.Position = UDim2.new(0, 5, 0, 130)
addSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
addSection.BorderSizePixel = 1
addSection.BorderColor3 = Color3.fromRGB(80, 80, 100)
addSection.Parent = main

local addLabel = Instance.new("TextLabel")
addLabel.Size = UDim2.new(1, 0, 0, 20)
addLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
addLabel.Text = "  ➕ ДОБАВИТЬ В ИЗБРАННОЕ"
addLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
addLabel.Font = Enum.Font.GothamBold
addLabel.TextSize = 11
addLabel.TextXAlignment = Enum.TextXAlignment.Left
addLabel.Parent = addSection

local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(0.5, -5, 0, 25)
nameInput.Position = UDim2.new(0, 5, 0, 25)
nameInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
nameInput.PlaceholderText = "Название"
nameInput.Text = ""
nameInput.TextColor3 = Color3.fromRGB(255, 255, 200)
nameInput.Font = Enum.Font.Gotham
nameInput.TextSize = 11
nameInput.BorderSizePixel = 1
nameInput.BorderColor3 = Color3.fromRGB(100, 200, 100)
nameInput.ClearTextOnFocus = false
nameInput.Parent = addSection

local idAddInput = Instance.new("TextBox")
idAddInput.Size = UDim2.new(0.5, -5, 0, 25)
idAddInput.Position = UDim2.new(0.5, 0, 0, 25)
idAddInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
idAddInput.PlaceholderText = "ID"
idAddInput.Text = ""
idAddInput.TextColor3 = Color3.fromRGB(200, 255, 200)
idAddInput.Font = Enum.Font.Code
idAddInput.TextSize = 11
idAddInput.BorderSizePixel = 1
idAddInput.BorderColor3 = Color3.fromRGB(100, 200, 100)
idAddInput.ClearTextOnFocus = false
idAddInput.Parent = addSection

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, -10, 0, 20)
addBtn.Position = UDim2.new(0, 5, 0, 45)
addBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
addBtn.Text = "❤️ ДОБАВИТЬ"
addBtn.TextColor3 = Color3.new(1, 1, 1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 10
addBtn.BorderSizePixel = 1
addBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
addBtn.Parent = addSection

addBtn.MouseButton1Click:Connect(function()
    addToFavorites(nameInput.Text, idAddInput.Text)
    nameInput.Text = ""
    idAddInput.Text = ""
end)

-- Окно избранного
local favFrame = Instance.new("Frame")
favFrame.Size = UDim2.new(0, 250, 0, 350)
favFrame.Position = UDim2.new(0, 300, 0, 40)
favFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
favFrame.BorderSizePixel = 2
favFrame.BorderColor3 = Color3.fromRGB(255, 100, 200)
favFrame.Active = true
favFrame.Draggable = true
favFrame.Visible = false
favFrame.Parent = gui

local favTitle = Instance.new("TextLabel")
favTitle.Size = UDim2.new(1, -25, 0, 25)
favTitle.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
favTitle.Text = "❤️ ИЗБРАННОЕ"
favTitle.TextColor3 = Color3.new(1, 1, 1)
favTitle.Font = Enum.Font.GothamBold
favTitle.TextSize = 11
favTitle.TextXAlignment = Enum.TextXAlignment.Left
favTitle.Parent = favFrame

local closeFav = Instance.new("TextButton")
closeFav.Size = UDim2.new(0, 18, 0, 18)
closeFav.Position = UDim2.new(1, -20, 0, 3)
closeFav.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeFav.Text = "✕"
closeFav.TextColor3 = Color3.new(1, 1, 1)
closeFav.Font = Enum.Font.GothamBold
closeFav.TextSize = 11
closeFav.Parent = favTitle
closeFav.MouseButton1Click:Connect(function() favFrame.Visible = false end)

local favControls = Instance.new("Frame")
favControls.Size = UDim2.new(1, -10, 0, 30)
favControls.Position = UDim2.new(0, 5, 0, 30)
favControls.BackgroundTransparency = 1
favControls.Parent = favFrame

local copyNote = Instance.new("TextButton")
copyNote.Size = UDim2.new(0.6, -5, 0, 22)
copyNote.Position = UDim2.new(0, 0, 0, 0)
copyNote.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
copyNote.Text = "📋 КОПИРОВАТЬ"
copyNote.TextColor3 = Color3.new(1, 1, 1)
copyNote.Font = Enum.Font.GothamBold
copyNote.TextSize = 9
copyNote.BorderSizePixel = 1
copyNote.BorderColor3 = Color3.fromRGB(255, 255, 255)
copyNote.Parent = favControls
copyNote.MouseButton1Click:Connect(function()
    local txt = "-- АНИМАЦИИ\nlocal FAV = {\n"
    for _, a in ipairs(FAVORITES) do
        txt = txt .. '    {name="' .. a.name .. '", id="' .. a.id .. '"},\n'
    end
    txt = txt .. "}\n"
    if setclipboard then setclipboard(txt) end
    if syn and syn.toast then syn.toast("📋", "Список скопирован", 1) end
end)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.4, -5, 0, 22)
refreshBtn.Position = UDim2.new(0.6, 5, 0, 0)
refreshBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
refreshBtn.Text = "🔄 ОБНОВИТЬ"
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 9
refreshBtn.BorderSizePixel = 1
refreshBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Parent = favControls
refreshBtn.MouseButton1Click:Connect(updateFavoritesList)

favScrolling = Instance.new("ScrollingFrame")
favScrolling.Size = UDim2.new(1, -10, 0, 260)
favScrolling.Position = UDim2.new(0, 5, 0, 65)
favScrolling.BackgroundTransparency = 1
favScrolling.ScrollBarThickness = 6
favScrolling.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
favScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
favScrolling.Parent = favFrame

heartBtn.MouseButton1Click:Connect(function()
    favFrame.Visible = not favFrame.Visible
    if favFrame.Visible then updateFavoritesList() end
end)

updateFavoritesList()

------------------------------------------
-- 2. ЛОГГЕР АНИМАЦИЙ (WaveStorag)
------------------------------------------

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Thx for using🤑",
    Text = "Made by WaveStorag",
    Duration = 15,
    Icon = "rbxassetid://17395172104"
})

local gui2 = Instance.new("ScreenGui")
gui2.Name = "AnimationLogger"
gui2.Parent = PlayerGui

local frame2 = Instance.new("Frame")
frame2.Size = UDim2.new(0.315, 0, 0.4, 0)
frame2.Position = UDim2.new(0.350, 0, 0.3, 0)
frame2.BackgroundColor3 = Color3.new(0, 0, 0)
frame2.BorderSizePixel = 0
frame2.Parent = gui2
frame2.Draggable = true
frame2.Active = true

local topBar2 = Instance.new("Frame")
topBar2.Size = UDim2.new(1.0017, 0, 0, 30)
topBar2.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
topBar2.BorderSizePixel = 0
topBar2.Parent = frame2

local titleLabel2 = Instance.new("TextLabel")
titleLabel2.Size = UDim2.new(1, -365, 1, 0)
titleLabel2.Position = UDim2.new(0, 0, 0, 0)
titleLabel2.BackgroundTransparency = 1
titleLabel2.Text = "Animation Logger"
titleLabel2.Font = Enum.Font.SourceSans
titleLabel2.TextColor3 = Color3.new(1, 1, 1)
titleLabel2.TextSize = 20
titleLabel2.Parent = topBar2

local scrollFrame2 = Instance.new("ScrollingFrame")
scrollFrame2.Size = UDim2.new(1, 0, 1, -30)
scrollFrame2.Position = UDim2.new(0, 0, 0, 30)
scrollFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame2.ScrollBarThickness = 10
scrollFrame2.Parent = frame2
scrollFrame2.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)

local logLayout2 = Instance.new("UIListLayout")
logLayout2.Parent = scrollFrame2
logLayout2.SortOrder = Enum.SortOrder.LayoutOrder

local loggedAnimations2 = {}
local isCopyingAsLinkEnabled2 = false
local originalColor2 = Color3.new(0.2, 0.2, 0.2)
local toggleColor2 = Color3.new(0, 1, 0)

local function logAnimation2(animationName, animationId)
    if loggedAnimations2[animationId] then
        return
    end
    
    loggedAnimations2[animationId] = true
    
    local numericId = tonumber(animationId:match("%d+"))

    local logEntry = Instance.new("TextButton")
    logEntry.Size = UDim2.new(1, -10, 0, 60)
    logEntry.BackgroundColor3 = originalColor2
    local linkStatus = isCopyingAsLinkEnabled2 and "Enabled" or "Disabled"
    logEntry.Text = string.format("%s\nAnimation ID: %d\nCopy as link: %s", animationName, numericId, linkStatus)
    logEntry.TextWrapped = true
    logEntry.Font = Enum.Font.SourceSans
    logEntry.TextColor3 = Color3.new(1, 1, 1)
    logEntry.TextSize = 22
    logEntry.Parent = scrollFrame2

    logEntry.MouseButton1Click:Connect(function()
        if isCopyingAsLinkEnabled2 then
            local link = "https://www.roblox.com/library/" .. numericId
            setclipboard(link)
        else
            setclipboard(tostring(numericId))
        end
    end)

    scrollFrame2.CanvasSize = UDim2.new(0, 0, 0, logLayout2.AbsoluteContentSize.Y)
end

logLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame2.CanvasSize = UDim2.new(0, 0, 0, logLayout2.AbsoluteContentSize.Y)
end)

local function onAnimationPlayed2(animationTrack)
    local animation = animationTrack.Animation
    if animation then
        local animationId = animation.AnimationId
        local animationName = animation.Name or "Unknown Animation"
        logAnimation2(animationName, animationId)
    end
end

local function trackPlayerAnimations2()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.AnimationPlayed:Connect(onAnimationPlayed2)
end

trackPlayerAnimations2()

local xButton2 = Instance.new("TextButton")
xButton2.Size = UDim2.new(0, 30, 0, 30)
xButton2.Position = UDim2.new(1, -30, 0, 0)
xButton2.BackgroundColor3 = Color3.new(1, 0, 0)
xButton2.Text = "X"
xButton2.TextColor3 = Color3.new(1, 1, 1)
xButton2.TextSize = 24
xButton2.Font = Enum.Font.SourceSans
xButton2.BackgroundTransparency = 1
xButton2.Parent = topBar2

xButton2.MouseButton1Click:Connect(function()
    gui2:Destroy()
end)

local minimizeButton2 = Instance.new("TextButton")
minimizeButton2.Size = UDim2.new(0, 30, 0, 30)
minimizeButton2.Position = UDim2.new(1, -60, 0, 0)
minimizeButton2.BackgroundColor3 = Color3.new(0, 0, 1)
minimizeButton2.Text = "–"
minimizeButton2.TextColor3 = Color3.new(1, 1, 1)
minimizeButton2.TextSize = 24
minimizeButton2.Font = Enum.Font.SourceSans
minimizeButton2.BackgroundTransparency = 1
minimizeButton2.Parent = topBar2

local additionalGUI2 = Instance.new("Frame")
additionalGUI2.Size = UDim2.new(0.5, 0, 1, 0)
additionalGUI2.Position = UDim2.new(-0.53, 0, 0, 0)
additionalGUI2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
additionalGUI2.BorderSizePixel = 0
additionalGUI2.Visible = false
additionalGUI2.Parent = frame2

local settingsTopBar2 = Instance.new("Frame")
settingsTopBar2.Size = UDim2.new(1, 0, 0, 30)
settingsTopBar2.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
settingsTopBar2.BorderSizePixel = 0
settingsTopBar2.Parent = additionalGUI2

local settingsLabel2 = Instance.new("TextLabel")
settingsLabel2.Size = UDim2.new(1, 0, 0, 30)
settingsLabel2.Position = UDim2.new(0, 0, 0, 0)
settingsLabel2.BackgroundTransparency = 1
settingsLabel2.Text = "Settings"
settingsLabel2.Font = Enum.Font.SourceSans
settingsLabel2.TextColor3 = Color3.new(1, 1, 1)
settingsLabel2.TextSize = 20
settingsLabel2.Parent = additionalGUI2

local clearButton2 = Instance.new("TextButton")
clearButton2.Size = UDim2.new(0.95, 0, 0, 30)
clearButton2.Position = UDim2.new(0.023, 0, 0, 40)
clearButton2.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
clearButton2.Text = "Clear All"
clearButton2.TextColor3 = Color3.new(1, 1, 1)
clearButton2.TextSize = 18
clearButton2.Font = Enum.Font.SourceSans
clearButton2.Parent = additionalGUI2

local optionalSettingToggle2 = Instance.new("TextButton")
optionalSettingToggle2.Size = UDim2.new(0.95, 0, 0, 30)
optionalSettingToggle2.Position = UDim2.new(0.023, 0, 0, 80)
optionalSettingToggle2.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
optionalSettingToggle2.Text = "Copy as link"
optionalSettingToggle2.TextColor3 = Color3.new(1, 1, 1)
optionalSettingToggle2.TextSize = 18
optionalSettingToggle2.Font = Enum.Font.SourceSans
optionalSettingToggle2.Parent = additionalGUI2

local toggleButton2 = Instance.new("ImageButton")
toggleButton2.Size = UDim2.new(0, 30, 0, 30)
toggleButton2.Position = UDim2.new(0.002, 0, 0, 0)
toggleButton2.BackgroundTransparency = 1
toggleButton2.Image = "rbxassetid://11932591062"
toggleButton2.Parent = topBar2

toggleButton2.MouseButton1Click:Connect(function()
    additionalGUI2.Visible = not additionalGUI2.Visible
end)

local isMinimized2 = false
local originalSize2 = frame2.Size
local originalTitlePosition2 = titleLabel2.Position

minimizeButton2.MouseButton1Click:Connect(function()
    isMinimized2 = not isMinimized2
    if isMinimized2 then
        minimizeButton2.Text = "+"
        frame2.Size = UDim2.new(originalSize2.X.Scale, originalSize2.X.Offset, 0, 30)
        scrollFrame2.Visible = false
        additionalGUI2.Visible = false
        toggleButton2.Visible = false
        titleLabel2.Position = UDim2.new(originalTitlePosition2.X.Scale, originalTitlePosition2.X.Offset - 20, originalTitlePosition2.Y.Scale, originalTitlePosition2.Y.Offset)
    else
        minimizeButton2.Text = "–"
        frame2.Size = originalSize2
        scrollFrame2.Visible = true
        toggleButton2.Visible = true
        titleLabel2.Position = originalTitlePosition2
    end
end)

clearButton2.MouseButton1Click:Connect(function()
    for _, child in ipairs(scrollFrame2:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    loggedAnimations2 = {}
    scrollFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

local function toggleOptionalSetting2()
    isCopyingAsLinkEnabled2 = not isCopyingAsLinkEnabled2
    optionalSettingToggle2.BackgroundColor3 = isCopyingAsLinkEnabled2 and toggleColor2 or originalColor2
    print("Copying as link " .. (isCopyingAsLinkEnabled2 and "enabled" or "disabled"))
end

optionalSettingToggle2.MouseButton1Click:Connect(toggleOptionalSetting2)

print("✅ ОБА СКРИПТА ЗАПУЩЕНЫ")
print("📌 Тестер анимаций и Логгер работают одновременно")