local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local FILE_NAME = "Continuously_MobileConfig.json"
local config = {
    macroData = {},
    autoRun = false
}
local isRecording = false
local startTime = 0

-- ฟังก์ชัน บันทึก และ โหลดข้อมูลอัตโนมัติ
local function saveConfig()
    if writefile then
        writefile(FILE_NAME, HttpService:JSONEncode(config))
    end
end

local function loadConfig()
    if readfile and isfile and isfile(FILE_NAME) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(FILE_NAME))
        end)
        if success and type(result) == "table" then
            config = result
            if not config.macroData then config.macroData = {} end
        end
    end
end

loadConfig()

-- สร้าง Interface UI (สีดำ อ่านง่าย)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ContinuouslyMainUI"
ScreenGui.Parent = game.CoreGui

-- ปุ่มเปิด/ปิด เมนูหลัก (Continuously)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.Size = UDim2.new(0, 130, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Continuously"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(120, 120, 120)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleBtn

-- หน้าต่างเมนูหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 270, 0, 270)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Active = true
MainFrame.Draggable = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(60, 60, 60)
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

-- หัวข้อ
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "Continuously Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- [โหมด 1] ปุ่มสวิตช์โหมดอัด
local RecordBtn = Instance.new("TextButton")
RecordBtn.Parent = MainFrame
RecordBtn.Position = UDim2.new(0.08, 0, 0.2, 0)
RecordBtn.Size = UDim2.new(0.84, 0, 0, 38)
RecordBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RecordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RecordBtn.Text = "โหมด 1: บันทึกการกด (OFF)"
RecordBtn.Font = Enum.Font.SourceSansSemibold
RecordBtn.TextSize = 15

local RecCorner = Instance.new("UICorner")
RecCorner.CornerRadius = UDim.new(0, 6)
RecCorner.Parent = RecordBtn

-- [โหมด 2] ปุ่มลบการจำ
local ClearBtn = Instance.new("TextButton")
ClearBtn.Parent = MainFrame
ClearBtn.Position = UDim2.new(0.08, 0, 0.4, 0)
ClearBtn.Size = UDim2.new(0.84, 0, 0, 38)
ClearBtn.BackgroundColor3 = Color3.fromRGB(130, 35, 35)
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Text = "โหมด 2: ลบความจำมาโคร"
ClearBtn.Font = Enum.Font.SourceSansSemibold
ClearBtn.TextSize = 15

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

-- [โหมด 3] สวิตช์เปิด/ปิด รันมาโครอัตโนมัติ
local PlayBtn = Instance.new("TextButton")
PlayBtn.Parent = MainFrame
PlayBtn.Position = UDim2.new(0.08, 0, 0.6, 0)
PlayBtn.Size = UDim2.new(0.84, 0, 0, 42)
PlayBtn.Font = Enum.Font.SourceSansBold
PlayBtn.TextSize = 15

local PlayCorner = Instance.new("UICorner")
PlayCorner.CornerRadius = UDim.new(0, 6)
PlayCorner.Parent = PlayBtn

-- เปิด / ปิด หน้าต่างเมนู
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ฟังก์ชันอัปเดตปุ่มโหมด 3
local function updatePlayButton()
    if config.autoRun then
        PlayBtn.Text = "โหมด 3: มาโครทำงานอยู่ (ON)"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
        PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        PlayBtn.Text = "โหมด 3: มาโครปิดอยู่ (OFF)"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        PlayBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end
updatePlayButton()

-- ระบบดักจับจุดแตะ และเซฟลงไฟล์ทันที (Auto-Save Per Touch)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isRecording and not gameProcessed then
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local touchPos = input.Position
            local delayTime = tick() - startTime
            table.insert(config.macroData, {x = touchPos.X, y = touchPos.Y, delay = delayTime})
            startTime = tick()
            saveConfig() -- บันทึกทันที ป้องกันข้อมูลหายเวลาเกมหลุด/รีแมพ
        end
    end
end)

-- [ทำงานโหมด 1]
RecordBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then
        startTime = tick()
        RecordBtn.Text = "โหมด 1: กำลังจำ... (ON)"
        RecordBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        RecordBtn.Text = "โหมด 1: บันทึกการกด (OFF)"
        RecordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- [ทำงานโหมด 2]
ClearBtn.MouseButton1Click:Connect(function()
    config.macroData = {}
    saveConfig()
    ClearBtn.Text = "ลบข้อมูลเรียบร้อย!"
    task.wait(1)
    ClearBtn.Text = "โหมด 2: ลบความจำมาโคร"
end)

-- [ทำงานโหมด 3] สวิตช์ ON/OFF (เปิดค้างไว้ จะรันข้ามเซสชัน)
PlayBtn.MouseButton1Click:Connect(function()
    config.autoRun = not config.autoRun
    saveConfig()
    updatePlayButton()
end)

-- ตัวรันลูปมาโครเบื้องหลัง (Auto-Loop Mode 3)
task.spawn(function()
    while true do
        task.wait(0.1)
        if config.autoRun and not isRecording and #config.macroData > 0 then
            for _, touch in ipairs(config.macroData) do
                if not config.autoRun or isRecording then break end
                task.wait(touch.delay)
                VirtualInputManager:SendTouchEvent(0, 0, Vector2.new(touch.x, touch.y))
                task.wait(0.05)
                VirtualInputManager:SendTouchEvent(0, 2, Vector2.new(touch.x, touch.y))
            end
        end
    end
end)
