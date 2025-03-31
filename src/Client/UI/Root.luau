-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

-- Vars
local Colors = {
    Screen = {
        Background = Color3.fromHex("181818")
    }
}

-- Components
local HelloWorld = function(scope)
    return scope:New "TextLabel" {
        Text = "Hello, World!",

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        Size = UDim2.fromScale(1, 1),
        TextScaled = true,

        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Colors.Screen.Background,
    }
end

return function(scope)
    return scope:New "Frame" {
        Name = "Root",
        Position = UDim2.fromScale(0, -0.08),
        Size = UDim2.fromScale(1, 1.08),
        BackgroundColor3 = Color3.fromHex("181818"),
        [Children] = HelloWorld(scope)
    }
end
