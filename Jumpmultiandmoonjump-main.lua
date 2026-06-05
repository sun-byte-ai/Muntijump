local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local jumpCount = 0
local MAX_JUMPS = 2 
local isDoubleJumpEnabled = true
local isMoonGravityEnabled = false
local canJumpAgain = true
local currentSpeed = 16 

-- Lưu lại trọng lực gốc của game
local ORIGINAL_GRAVITY = Workspace.Gravity
local MOON_GRAVITY = 35 

-- Tạo GUI Tổng
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MultiHackGUI_" .. math.random(1000, 9999)
local success, parent = pcall(function() return CoreGui end)
ScreenGui.Parent = (success and parent) or LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------
-- 🔴 MỚI: NÚT BẤM HÌNH TRÒN CỐ ĐỊNH (GÓC TRÁI)
---------------------------------------------------------
local ToggleGuiButton = Instance.new("TextButton")
ToggleGuiButton.Size = UDim2.new(0, 45, 0, 45) -- Kích thước hình tròn nhỏ gọn
ToggleGuiButton.Position = UDim2.new(0, 15, 0.4, 0) -- Cố định ở rìa trái màn hình
ToggleGuiButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255) -- Màu xanh dương nổi bật
ToggleGuiButton.BorderSizePixel = 0
ToggleGuiButton.Text = "MENU"
ToggleGuiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiButton.TextSize = 10
ToggleGuiButton.Font = Enum.Font.SourceSansBold
ToggleGuiButton.Active = true
ToggleGuiButton.Draggable = false -- KHÔNG CHO KÉO THẢ (Khóa vị trí)
ToggleGuiButton.Parent = ScreenGui

local RoundCorner = Instance.new("UICorner")
RoundCorner.CornerRadius = UDim.new(1, 0) -- Biến nút thành hình tròn hoàn hảo
RoundCorner.Parent = ToggleGuiButton

---------------------------------------------------------
-- KHUNG GIAO DIỆN CHÍNH (MENU)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 220)
MainFrame.Position = UDim2.new(0, 70, 0.3, 0) -- Xuất hiện ngay cạnh nút tròn
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Khung menu vẫn kéo đi chỗ khác được nếu muốn
MainFrame.Visible = true -- Trạng thái mặc định là hiện
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Logic xử lý ẩn/hiện khi bấm nút tròn
ToggleGuiButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    -- Đổi màu nút tròn nhẹ để biết trạng thái
    if MainFrame.Visible then
        ToggleGuiButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255) -- Xanh dương khi menu hiện
    else
        ToggleGuiButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Màu xám khi menu ẩn
    end
end)

-- Tiêu đề menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "MENU TIỆN ÍCH"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

---------------------------------------------------------
-- 1. NÚT BẬT/TẮT MULTI JUMP
---------------------------------------------------------
local DJButton = Instance.new("TextButton")
DJButton.Size = UDim2.new(0, 140, 0, 30)
DJButton.Position = UDim2.new(0, 10, 0, 35)
DJButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
DJButton.Text = "Multi Jump: BẬT"
DJButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DJButton.TextSize = 12
DJButton.Font = Enum.Font.SourceSansBold
DJButton.Parent = MainFrame

local DJCorner = Instance.new("UICorner")
DJCorner.CornerRadius = UDim.new(0, 5)
DJCorner.Parent = DJButton

DJButton.MouseButton1Click:Connect(function()
    isDoubleJumpEnabled = not isDoubleJumpEnabled
    if isDoubleJumpEnabled then
        DJButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        DJButton.Text = "Multi Jump: BẬT"
    else
        DJButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        DJButton.Text = "Multi Jump: TẮT"
    end
end)

---------------------------------------------------------
-- 2. Ô NHẬP SỐ LẦN NHẢY
---------------------------------------------------------
local JumpInput = Instance.new("TextBox")
JumpInput.Size = UDim2.new(0, 140, 0, 30)
JumpInput.Position = UDim2.new(0, 10, 0, 70)
JumpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
JumpInput.Text = "Số lần nhảy: 2"
JumpInput.PlaceholderText = "Nhập số lần nhảy..."
JumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpInput.TextSize = 12
JumpInput.Font = Enum.Font.SourceSans
JumpInput.ClearTextOnFocus = true
JumpInput.Parent = MainFrame

local JumpCorner = Instance.new("UICorner")
JumpCorner.CornerRadius = UDim.new(0, 5)
JumpCorner.Parent = JumpInput

JumpInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = JumpInput.Text
        local num = tonumber(text)
        if num and num >= 1 then
            MAX_JUMPS = math.floor(num)
            JumpInput.Text = "Số lần nhảy: " .. MAX_JUMPS
        else
            JumpInput.Text = "Số lần nhảy: " .. MAX_JUMPS
        end
    end
end)

---------------------------------------------------------
-- 3. NÚT BẬT/TẮT MOON GRAVITY
---------------------------------------------------------
local MGButton = Instance.new("TextButton")
MGButton.Size = UDim2.new(0, 140, 0, 30)
MGButton.Position = UDim2.new(0, 10, 0, 110)
MGButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
MGButton.Text = "Moon Gravity: TẮT"
MGButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MGButton.TextSize = 12
MGButton.Font = Enum.Font.SourceSansBold
MGButton.Parent = MainFrame

local MGCorner = Instance.new("UICorner")
MGCorner.CornerRadius = UDim.new(0, 5)
MGCorner.Parent = MGButton

MGButton.MouseButton1Click:Connect(function()
    isMoonGravityEnabled = not isMoonGravityEnabled
    if isMoonGravityEnabled then
        MGButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        MGButton.Text = "Moon Gravity: BẬT"
        Workspace.Gravity = MOON_GRAVITY
    else
        MGButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        MGButton.Text = "Moon Gravity: TẮT"
        Workspace.Gravity = ORIGINAL_GRAVITY
    end
end)

---------------------------------------------------------
-- 4. Ô NHẬP TỐC ĐỘ
---------------------------------------------------------
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 140, 0, 30)
SpeedInput.Position = UDim2.new(0, 10, 0, 150)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.Text = "Tốc độ: 16"
SpeedInput.PlaceholderText = "Nhập tốc độ..."
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 12
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.ClearTextOnFocus = true
SpeedInput.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 5)
SpeedCorner.Parent = SpeedInput

-- Dòng ghi chú tốc độ gốc bên dưới nút speed
local DefaultSpeedLabel = Instance.new("TextLabel")
DefaultSpeedLabel.Size = UDim2.new(0, 140, 0, 20)
DefaultSpeedLabel.Position = UDim2.new(0, 10, 0, 185)
DefaultSpeedLabel.BackgroundTransparency = 1
DefaultSpeedLabel.Text = "*Tốc độ gốc là 16"
DefaultSpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
DefaultSpeedLabel.TextSize = 11
DefaultSpeedLabel.Font = Enum.Font.SourceSansItalic
DefaultSpeedLabel.TextXAlignment = Enum.TextXAlignment.Center
DefaultSpeedLabel.Parent = MainFrame

local function applySpeed(humanoid)
    if humanoid then
        humanoid.WalkSpeed = currentSpeed
    end
end

SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = SpeedInput.Text
        local num = tonumber(text)
        if num and num >= 0 then
            currentSpeed = num
            SpeedInput.Text = "Tốc độ: " .. num
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                applySpeed(humanoid)
            end
        else
            SpeedInput.Text = "Tốc độ: " .. currentSpeed
        end
    end
end)

---------------------------------------------------------
-- LOGIC HỆ THỐNG
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if not isDoubleJumpEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local currentState = humanoid:GetState()

    if currentState == Enum.HumanoidStateType.Freefall and jumpCount < (MAX_JUMPS - 1) and canJumpAgain then
        canJumpAgain = false
        jumpCount = jumpCount + 1
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.18)
        canJumpAgain = true
    end
end)

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    applySpeed(humanoid)
    
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= currentSpeed then
            humanoid.WalkSpeed = currentSpeed
        end
    end)

    humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Landed or 
           newState == Enum.HumanoidStateType.Running or 
           newState == Enum.HumanoidStateType.None then
            jumpCount = 0
            canJumpAgain = true
        end
    end)
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

LocalPlayer.OnTeleport:Connect(function()
    Workspace.Gravity = ORIGINAL_GRAVITY
end)
