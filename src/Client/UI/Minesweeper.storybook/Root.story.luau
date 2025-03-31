-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);

local Board = require(script.Parent.Parent.Parent.Modules.Minesweeper);

local Root = require(script.Parent.Parent.Root);

return {
    story = function()
        local scope = Fusion.scoped(Fusion);
        local board = Board.Init(10, 10);
        return Root(scope, board);
    end
}
