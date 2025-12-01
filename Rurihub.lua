local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- 📱 スマホ/タブレット用ドラッグ関数
local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==== 起動時「るりるりhub」表示 ====
local preTitle = Instance.new("TextLabel")
preTitle.Size = UDim2.new(0,400,0,100)
preTitle.Position = UDim2.new(0.5,-200,0.4,-50)
preTitle.Text = "るりるりhub"
preTitle.Font = Enum.Font.GothamBold
preTitle.TextSize = 50
preTitle.BackgroundTransparency = 1
preTitle.TextStrokeTransparency = 0.5
preTitle.TextColor3 = Color3.fromHSV(0,1,1)
preTitle.Parent = playerGui

local hue = 0
local startTime = tick()
while tick() - startTime < 1 do
    RunService.RenderStepped:Wait()
    hue = (hue + 0.05) % 1
    preTitle.TextColor3 = Color3.fromHSV(hue,1,1)
end
preTitle:Destroy()

-- ==== ScreenGui ====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FunBoardUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ==== メインボード開閉ボタン ====
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,50,0,50)
toggleBtn.Position = UDim2.new(0,10,0,10)
toggleBtn.Text = "☰"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 30
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Parent = screenGui

-- ==== メインボード ====
local board = Instance.new("Frame")
board.Size = UDim2.new(0,300,0,500)
board.Position = UDim2.new(0,10,0,70)
board.BackgroundColor3 = Color3.fromRGB(30,30,30)
board.BorderSizePixel = 2
board.Visible = true
board.Parent = screenGui

makeDraggable(board) -- 📱ドラッグ可能

local boardOpenPos = UDim2.new(0,10,0,70)
local boardClosedPos = UDim2.new(0,-310,0,70)
toggleBtn.MouseButton1Click:Connect(function()
    local targetPos = (board.Position == boardOpenPos) and boardClosedPos or boardOpenPos
    TweenService:Create(board, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end)

-- ボードタイトル
local boardTitle = Instance.new("TextLabel")
boardTitle.Size = UDim2.new(1,0,0,30)
boardTitle.BackgroundTransparency = 1
boardTitle.Font = Enum.Font.GothamBold
boardTitle.TextSize = 24
boardTitle.Text = "るりるりhub"
boardTitle.Parent = board
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.02) % 1
    boardTitle.TextColor3 = Color3.fromHSV(hue,1,1)
end)

-- ==== ScrollingFrame ====
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,-30)
scrollFrame.Position = UDim2.new(0,0,0,30)
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.ScrollBarThickness = 10
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = board

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,5)

-- ==== ボタン作成関数 ====
local function createBoardButton(text, color, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,40)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(0,255,0)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = parent or scrollFrame
    return btn
end

-- ==== 回転・逆さま ====
local reverseBtn = createBoardButton("逆さま ON/OFF")
local spinBtn = createBoardButton("高速回転 ON/OFF")
local reverseActive, spinning = false, false
local spinSpeed, spinAngle = 10,0

reverseBtn.MouseButton1Click:Connect(function()
    reverseActive = not reverseActive
    reverseBtn.BackgroundColor3 = reverseActive and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
end)
spinBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    spinBtn.BackgroundColor3 = spinning and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
end)

-- 回転速度
local spinSpeedBtn = createBoardButton("回転速度: "..spinSpeed)
local speeds = {10,20,30,40,50}
local speedIndex = 1
spinSpeedBtn.MouseButton1Click:Connect(function()
    speedIndex = speedIndex + 1
    if speedIndex > #speeds then speedIndex = 1 end
    spinSpeed = speeds[speedIndex]
    spinSpeedBtn.Text = "回転速度: "..spinSpeed
end)

-- 透明Script
local loadCustomBtn = createBoardButton("透明Script", Color3.fromRGB(255,170,0))
loadCustomBtn.MouseButton1Click:Connect(function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invisible-FE-19153"))()
    end)
    if success then
        print("自作スクリプト読み込み成功")
    else
        warn("自作スクリプト読み込み失敗:", err)
    end
end)

-- テレポート
local teleportEnabled = false
local teleportBtn = createBoardButton("Teleport OFF", Color3.fromRGB(0,170,255))
teleportBtn.MouseButton1Click:Connect(function()
    teleportEnabled = not teleportEnabled
    teleportBtn.Text = teleportEnabled and "Teleport ON" or "Teleport OFF"
end)
mouse.Button1Down:Connect(function()
    if teleportEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local mousePos = mouse.Hit + Vector3.new(0,3,0)
        hrp.CFrame = CFrame.new(mousePos.Position)
    end
end)

-- ==== 追従UI ====
local targetPlayer = nil
local followToggleBtn = createBoardButton("ターゲットUI開閉", Color3.fromRGB(0,170,255))
local followBoard = nil

followToggleBtn.MouseButton1Click:Connect(function()
    if followBoard and followBoard.Parent then
        followBoard.Visible = not followBoard.Visible
        return
    end

    followBoard = Instance.new("Frame")
    followBoard.Size = UDim2.new(0,250,0,300)
    followBoard.Position = UDim2.new(0, 320, 0, 70)
    followBoard.BackgroundColor3 = Color3.fromRGB(40,40,40)
    followBoard.BorderSizePixel = 2
    followBoard.Parent = screenGui

    makeDraggable(followBoard) -- 📱追従UIもドラッグ可能

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Text = "追従ターゲット"
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = followBoard

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,-30)
    scroll.Position = UDim2.new(0,0,0,30)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 10
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = followBoard

    local layout = Instance.new("UIListLayout")
    layout.Parent = scroll
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,5)

    local function updateFollowButtons()
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local stopBtn = createBoardButton("追跡オフ", Color3.fromRGB(200,50,50), scroll)
        stopBtn.Size = UDim2.new(1,0,0,30)
        stopBtn.MouseButton1Click:Connect(function()
            targetPlayer = nil
            print("追跡ターゲット解除")
        end)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local btn = createBoardButton(p.Name, Color3.fromRGB(0,150,255), scroll)
                btn.Size = UDim2.new(1,0,0,30)
                btn.MouseButton1Click:Connect(function()
                    targetPlayer = p
                    print("追従ターゲット:", p.Name)
                end)
            end
        end
    end

    Players.PlayerAdded:Connect(updateFollowButtons)
    Players.PlayerRemoving:Connect(updateFollowButtons)
    updateFollowButtons()
end)

-- ==== 回転処理 + リスポーン対応 ====
local function setupCharacter(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    RunService.RenderStepped:Connect(function()
        if hrp then
            local cf = CFrame.new(hrp.Position)
            if reverseActive then cf = cf * CFrame.Angles(math.rad(180),0,0) end
            if spinning then
                spinAngle = spinAngle + math.rad(spinSpeed)
                cf = cf * CFrame.Angles(0,spinAngle,0)
            else spinAngle = 0 end
            hrp.CFrame = cf
        end
    end)
end
if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-- ==== 背中追従 ====
RunService.RenderStepped:Connect(function()
    if targetPlayer and targetPlayer.Character and player.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = player.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            local offset = CFrame.new(0,0,3)
            myHRP.CFrame = targetHRP.CFrame * offset
        end
    end
end)
