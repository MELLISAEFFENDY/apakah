--[[
    Simple UI Library for Roblox Scripts
    Created by: MELLISAEFFENDY
    Description: Lightweight UI library as replacement for OrionLib
    Version: 1.0
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SimpleUI = {}
SimpleUI.Flags = {}
SimpleUI.Connections = {}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protection for executors
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = game.CoreGui
end

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos

    dragHandle = dragHandle or frame

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Main UI Creation Functions
function SimpleUI:MakeWindow(config)
    config = config or {}
    config.Name = config.Name or "Simple UI"
    config.Size = config.Size or UDim2.new(0, 500, 0, 400)
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- Main Frame
    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -250, 0.5, -200),
        Size = config.Size,
        Active = true,
        Draggable = false
    })
    
    -- Corner Radius
    CreateInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 10)
    })
    
    -- Drop Shadow
    CreateInstance("UIStroke", {
        Parent = MainFrame,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        Transparency = 0.5
    })
    
    -- Title Bar
    local TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    CreateInstance("UICorner", {
        Parent = TitleBar,
        CornerRadius = UDim.new(0, 10)
    })
    
    -- Title Text
    local TitleText = CreateInstance("TextLabel", {
        Name = "TitleText",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = config.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Close Button
    local CloseButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = TitleBar,
        BackgroundColor3 = Color3.fromRGB(255, 100, 100),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -35, 0, 5),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    
    CreateInstance("UICorner", {
        Parent = CloseButton,
        CornerRadius = UDim.new(0, 5)
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Container
    local TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40)
    })
    
    local TabList = CreateInstance("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    CreateInstance("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })
    
    -- Content Container
    local ContentContainer = CreateInstance("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40)
    })
    
    -- Make draggable
    MakeDraggable(MainFrame, TitleBar)
    
    function Window:MakeTab(config)
        config = config or {}
        config.Name = config.Name or "Tab"
        
        local Tab = {}
        Tab.Elements = {}
        
        -- Tab Button
        local TabButton = CreateInstance("TextButton", {
            Name = "TabButton",
            Parent = TabContainer,
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 35),
            Font = Enum.Font.Gotham,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14
        })
        
        CreateInstance("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 5)
        })
        
        -- Tab Content
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = "TabContent",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        
        local ContentList = CreateInstance("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        CreateInstance("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Update canvas size when content changes
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            -- Show current tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = Tab
        end)
        
        Tab.Content = TabContent
        Tab.Button = TabButton
        Tab.List = ContentList
        
        -- If this is the first tab, make it active
        if #Window.Tabs == 0 then
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = Tab
        end
        
        table.insert(Window.Tabs, Tab)
        
        function Tab:AddSection(config)
            config = config or {}
            config.Name = config.Name or "Section"
            
            local Section = {}
            
            local SectionFrame = CreateInstance("Frame", {
                Name = "SectionFrame",
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25)
            })
            
            local SectionLabel = CreateInstance("TextLabel", {
                Name = "SectionLabel",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            return Section
        end
        
        function Tab:AddToggle(config)
            config = config or {}
            config.Name = config.Name or "Toggle"
            config.Default = config.Default or false
            config.Callback = config.Callback or function() end
            
            local Toggle = {Value = config.Default}
            
            local ToggleFrame = CreateInstance("Frame", {
                Name = "ToggleFrame",
                Parent = TabContent,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40)
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleFrame,
                CornerRadius = UDim.new(0, 8)
            })
            
            local ToggleLabel = CreateInstance("TextLabel", {
                Name = "ToggleLabel",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ToggleButton = CreateInstance("TextButton", {
                Name = "ToggleButton",
                Parent = ToggleFrame,
                BackgroundColor3 = config.Default and Color3.fromRGB(60, 120, 200) or Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -45, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20),
                Text = ""
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleButton,
                CornerRadius = UDim.new(0, 10)
            })
            
            local ToggleCircle = CreateInstance("Frame", {
                Name = "ToggleCircle",
                Parent = ToggleButton,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = config.Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleCircle,
                CornerRadius = UDim.new(0, 8)
            })
            
            function Toggle:Set(value)
                Toggle.Value = value
                local color = value and Color3.fromRGB(60, 120, 200) or Color3.fromRGB(60, 60, 60)
                local position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = position}):Play()
                
                config.Callback(value)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                Toggle:Set(not Toggle.Value)
            end)
            
            if config.Flag then
                SimpleUI.Flags[config.Flag] = Toggle
            end
            
            return Toggle
        end
        
        function Tab:AddButton(config)
            config = config or {}
            config.Name = config.Name or "Button"
            config.Callback = config.Callback or function() end
            
            local ButtonFrame = CreateInstance("TextButton", {
                Name = "ButtonFrame",
                Parent = TabContent,
                BackgroundColor3 = Color3.fromRGB(60, 120, 200),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                Font = Enum.Font.GothamBold,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14
            })
            
            CreateInstance("UICorner", {
                Parent = ButtonFrame,
                CornerRadius = UDim.new(0, 8)
            })
            
            ButtonFrame.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 140, 220)}):Play()
                wait(0.1)
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 120, 200)}):Play()
                config.Callback()
            end)
            
            return ButtonFrame
        end
        
        function Tab:AddLabel(text)
            local LabelFrame = CreateInstance("TextLabel", {
                Name = "LabelFrame",
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.Gotham,
                Text = text or "Label",
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            return LabelFrame
        end
        
        return Tab
    end
    
    function Window:Init()
        -- Initialize window
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

function SimpleUI:MakeNotification(config)
    config = config or {}
    config.Name = config.Name or "Notification"
    config.Content = config.Content or "Content"
    config.Time = config.Time or 5
    
    local NotificationFrame = CreateInstance("Frame", {
        Name = "NotificationFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 0, 50),
        Size = UDim2.new(0, 300, 0, 80)
    })
    
    CreateInstance("UICorner", {
        Parent = NotificationFrame,
        CornerRadius = UDim.new(0, 10)
    })
    
    CreateInstance("UIStroke", {
        Parent = NotificationFrame,
        Color = Color3.fromRGB(60, 120, 200),
        Thickness = 2
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "TitleLabel",
        Parent = NotificationFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = config.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ContentLabel = CreateInstance("TextLabel", {
        Name = "ContentLabel",
        Parent = NotificationFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 35),
        Font = Enum.Font.Gotham,
        Text = config.Content,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    -- Animate in
    TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, -320, 0, 50)}):Play()
    
    -- Animate out after time
    game:GetService("Debris"):AddItem(NotificationFrame, config.Time)
    wait(config.Time - 0.5)
    TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, 20, 0, 50)}):Play()
end

function SimpleUI:Destroy()
    ScreenGui:Destroy()
end

return SimpleUI
