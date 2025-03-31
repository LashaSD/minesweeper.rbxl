-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);

local Root = require(script.Parent.Parent.Root);

return {
    story = function()
        local scope = Fusion.scoped(Fusion);
        return Root(scope);
    end
}
