--[[
    Rayfield UI Library - Local Implementation
    Created by: MELLISAEFFENDY
    Description: Fast, modern UI library for Roblox scripts
    
    Features:
    ⚡ Ultra-fast performance
    🎨 Modern design
    📱 Mobile-friendly
    🔧 Easy to use API
]]

local Rayfield = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create main GUI
function Rayfield:CreateWindow(Config)
    local WindowConfig = Config or {}
    
    -- Main ScreenGui
    local RayfieldGui = Instance.new("ScreenGui")
    RayfieldGui.Name = "RayfieldUI"
    RayfieldGui.Parent = PlayerGui
    RayfieldGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RayfieldGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = RayfieldGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Corner radius
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Stroke
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 162, 255)
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, -100, 1, 0)
    TitleText.Position = UDim2.new(0, 20, 0, 0)
    TitleText.Text = WindowConfig.Name or "Rayfield UI"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    CloseButton.BorderSizePixel = 0
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        RayfieldGui:Destroy()
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.Size = UDim2.new(0, 120, 1, -60)
    TabContainer.Position = UDim2.new(0, 10, 0, 55)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Size = UDim2.new(1, -150, 1, -70)
    ContentContainer.Position = UDim2.new(0, 140, 0, 60)
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer
    
    -- Window object
    local Window = {
        GUI = RayfieldGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        CurrentTab = nil,
        Tabs = {}
    }
    
    function Window:CreateTab(Config)
        local TabConfig = Config or {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.Text = TabConfig.Name or "Tab"
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextScaled = true
        TabButton.Font = Enum.Font.Gotham
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        -- Tab Content Frame
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent"
        TabContent.Parent = ContentContainer
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
        TabContent.Visible = false
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        
        -- Tab object
        local Tab = {
            Button = TabButton,
            Content = TabContent,
            Elements = {}
        }
        
        -- Tab click handler
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            -- Show current tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = Tab
        end)
        
        -- Auto-select first tab
        if #Window.Tabs == 0 then
            TabButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Tab functions
        function Tab:CreateButton(Config)
            local ButtonConfig = Config or {}
            
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Parent = TabContent
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Button.BorderSizePixel = 0
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.Text = ButtonConfig.Name or "Button"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextScaled = true
            Button.Font = Enum.Font.Gotham
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                if ButtonConfig.Callback then
                    ButtonConfig.Callback()
                end
            end)
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return Button
        end
        
        function Tab:CreateToggle(Config)
            local ToggleConfig = Config or {}
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = TabContent
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Size = UDim2.new(1, -80, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
            ToggleLabel.Text = ToggleConfig.Name or "Toggle"
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextScaled = true
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = ToggleFrame
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Size = UDim2.new(0, 50, 0, 25)
            ToggleButton.Position = UDim2.new(1, -65, 0.5, -12.5)
            ToggleButton.Text = ""
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(0, 12)
            ToggleBtnCorner.Parent = ToggleButton
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "ToggleIndicator"
            ToggleIndicator.Parent = ToggleButton
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Size = UDim2.new(0, 21, 0, 21)
            ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(0, 10)
            IndicatorCorner.Parent = ToggleIndicator
            
            local isToggled = ToggleConfig.Default or false
            
            local function updateToggle()
                if isToggled then
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                    ToggleIndicator.Position = UDim2.new(1, -23, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                else
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                    ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                end
                
                if ToggleConfig.Callback then
                    ToggleConfig.Callback(isToggled)
                end
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                updateToggle()
            end)
            
            updateToggle()
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    isToggled = value
                    updateToggle()
                end
            }
        end
        
        function Tab:CreateDropdown(Config)
            local DropdownConfig = Config or {}
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "DropdownFrame"
            DropdownFrame.Parent = TabContent
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = DropdownFrame
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Size = UDim2.new(1, 0, 1, 0)
            DropdownButton.Text = DropdownConfig.Name or "Dropdown"
            DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownButton.TextScaled = true
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            DropdownButton.TextXOffset = 15
            
            local DropdownArrow = Instance.new("TextLabel")
            DropdownArrow.Name = "DropdownArrow"
            DropdownArrow.Parent = DropdownFrame
            DropdownArrow.BackgroundTransparency = 1
            DropdownArrow.Size = UDim2.new(0, 30, 1, 0)
            DropdownArrow.Position = UDim2.new(1, -30, 0, 0)
            DropdownArrow.Text = "▼"
            DropdownArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownArrow.TextScaled = true
            DropdownArrow.Font = Enum.Font.Gotham
            
            local DropdownList = Instance.new("Frame")
            DropdownList.Name = "DropdownList"
            DropdownList.Parent = DropdownFrame
            DropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            DropdownList.BorderSizePixel = 0
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 1, 5)
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 6)
            ListCorner.Parent = DropdownList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropdownList
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            local selectedValue = DropdownConfig.Default
            
            if selectedValue then
                DropdownButton.Text = selectedValue
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    DropdownList.Visible = true
                    DropdownArrow.Text = "▲"
                    
                    -- Create options
                    for _, option in pairs(DropdownConfig.Options or {}) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = "OptionButton"
                        OptionButton.Parent = DropdownList
                        OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Size = UDim2.new(1, 0, 0, 30)
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        OptionButton.TextScaled = true
                        OptionButton.Font = Enum.Font.Gotham
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            selectedValue = option
                            DropdownButton.Text = option
                            
                            if DropdownConfig.Callback then
                                DropdownConfig.Callback(option)
                            end
                            
                            -- Close dropdown
                            isOpen = false
                            DropdownList.Visible = false
                            DropdownArrow.Text = "▼"
                            
                            -- Clear options
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child:Destroy()
                                end
                            end
                        end)
                    end
                    
                    -- Update list size
                    DropdownList.Size = UDim2.new(1, 0, 0, #(DropdownConfig.Options or {}) * 30)
                else
                    DropdownList.Visible = false
                    DropdownArrow.Text = "▼"
                    
                    -- Clear options
                    for _, child in pairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                end
            end)
            
            -- Update canvas size
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            
            return {
                Set = function(value)
                    selectedValue = value
                    DropdownButton.Text = value
                    if DropdownConfig.Callback then
                        DropdownConfig.Callback(value)
                    end
                end
            }
        end
        
        return Tab
    end
    
    return Window
end

-- Notification system
function Rayfield:Notify(Config)
    local NotifyConfig = Config or {}
    
    local NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "RayfieldNotification"
    NotifyGui.Parent = PlayerGui
    NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "NotifyFrame"
    NotifyFrame.Parent = NotifyGui
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Size = UDim2.new(0, 300, 0, 80)
    NotifyFrame.Position = UDim2.new(1, 0, 0, 50)
    
    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 8)
    NotifyCorner.Parent = NotifyFrame
    
    local NotifyStroke = Instance.new("UIStroke")
    NotifyStroke.Color = Color3.fromRGB(0, 162, 255)
    NotifyStroke.Thickness = 2
    NotifyStroke.Parent = NotifyFrame
    
    local NotifyTitle = Instance.new("TextLabel")
    NotifyTitle.Name = "NotifyTitle"
    NotifyTitle.Parent = NotifyFrame
    NotifyTitle.BackgroundTransparency = 1
    NotifyTitle.Size = UDim2.new(1, -20, 0, 25)
    NotifyTitle.Position = UDim2.new(0, 10, 0, 5)
    NotifyTitle.Text = NotifyConfig.Title or "Notification"
    NotifyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyTitle.TextScaled = true
    NotifyTitle.Font = Enum.Font.GothamBold
    NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local NotifyContent = Instance.new("TextLabel")
    NotifyContent.Name = "NotifyContent"
    NotifyContent.Parent = NotifyFrame
    NotifyContent.BackgroundTransparency = 1
    NotifyContent.Size = UDim2.new(1, -20, 0, 40)
    NotifyContent.Position = UDim2.new(0, 10, 0, 30)
    NotifyContent.Text = NotifyConfig.Content or ""
    NotifyContent.TextColor3 = Color3.fromRGB(200, 200, 200)
    NotifyContent.TextScaled = true
    NotifyContent.Font = Enum.Font.Gotham
    NotifyContent.TextXAlignment = Enum.TextXAlignment.Left
    NotifyContent.TextWrapped = true
    
    -- Slide in animation
    local slideIn = TweenService:Create(NotifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -320, 0, 50)
    })
    slideIn:Play()
    
    -- Auto-close after duration
    local duration = NotifyConfig.Duration or 5
    wait(duration)
    
    -- Slide out animation
    local slideOut = TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, 0, 0, 50)
    })
    slideOut:Play()
    
    slideOut.Completed:Connect(function()
        NotifyGui:Destroy()
    end)
end

return Rayfield
