-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);

return {
    name = "Minesweeper",
    storyRoots = {
        script.Parent
    },
    packages = {
        Fusion = Fusion
    },
}
