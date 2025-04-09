local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local COLOR = {
    GREEN = Color3.fromRGB(0, 255, 0),
    ATM = Color3.fromRGB(173, 216, 230),
    REGISTER = Color3.fromRGB(0, 0, 139),
    GOLD = Color3.fromRGB(255, 215, 0),
    RED = Color3.fromRGB(255, 0, 0)
}

local ATM_INDEXES = {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
local CAMERA_PATHS = {
    [workspace.Map.Security.Cameras:GetChildren()[3]] = true,
    [workspace.Map.Security.Cameras.Camera_BOTTOM] = true,
    [workspace.Map.Security.Cameras:GetChildren()[2]] = true
}

local function createESP(part, text, color)
    local highlight = Instance.new("BoxHandleAdornment")
    highlight.Name = "ESPHighlight"
    highlight.Adornee = part
    highlight.AlwaysOnTop = true
    highlight.ZIndex = 1
    highlight.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
    highlight.Color3 = color
    highlight.Transparency = 0.9
    highlight.Parent = part

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPInfo"
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 24
    label.Parent = billboard
end

local function processCamera(cam)
    if CAMERA_PATHS[cam] then
        createESP(cam.PrimaryPart, "⚠", COLOR.RED)
    end
end

local function processATM(atmRoot)
    if atmRoot:FindFirstChild("ATM") then
        local atmModel = atmRoot.ATM
        if atmModel:FindFirstChild("Parts") then
            local parts = atmModel.Parts
            if parts:FindFirstChild("Main") and parts.Main:FindFirstChild("atm") then
                createESP(parts.Main.atm, "·", COLOR.ATM)
            end
        end
    end

    for _, index in ipairs(ATM_INDEXES) do
        local child = atmRoot:GetChildren()[index]
        if child and child:IsA("Model") then
            if child:FindFirstChild("Parts") then
                local parts = child.Parts
                if parts:FindFirstChild("Main") and parts.Main:FindFirstChild("atm") then
                    createESP(parts.Main.atm, "·", COLOR.ATM)
                end
            end
        end
    end
end

local function processRegister(register)
    createESP(register.PrimaryPart, "·", COLOR.REGISTER)
end

local function processSafe(safe)
    createESP(safe.PrimaryPart, "·", COLOR.GOLD)
end

local function findTargets(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "ArmoryDealer" then
            local dealerMan = child:FindFirstChild("DealerMan")
            if dealerMan and dealerMan:IsA("Model") then
                createESP(dealerMan.PrimaryPart, "·", COLOR.GREEN)
            end
        elseif child.Name == "DealerMan" then
            createESP(child.PrimaryPart, "·", COLOR.GREEN)
        elseif child.Name == "ATMz" then
            processATM(child)
        elseif child.Name:find("Register_") then
            processRegister(child)
        elseif child.Name:find("Safe_") then
            processSafe(child)
        elseif CAMERA_PATHS[child] then
            processCamera(child)
        end
        findTargets(child)
    end
end

local function main()
    local map = workspace:WaitForChild("Map")
    local shopz = map:WaitForChild("Shopz")
    local security = map:WaitForChild("Security")
    
    findTargets(map)
    findTargets(shopz)
    findTargets(security)
    
    map.DescendantAdded:Connect(function(newChild)
        if newChild.Name == "DealerMan" and newChild:IsA("Model") then
            createESP(newChild.PrimaryPart, "·", COLOR.GREEN)
        elseif newChild.Name == "ATMz" then
            processATM(newChild)
        elseif newChild.Name:find("Register_") then
            processRegister(newChild)
        elseif newChild.Name:find("Safe_") then
            processSafe(newChild)
        elseif CAMERA_PATHS[newChild] then
            processCamera(newChild)
        end
    end)
end

main()
