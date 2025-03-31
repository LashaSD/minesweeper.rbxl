-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);
local Children = Fusion.Children;

local Minesweeper = require(script.Parent.Parent.Modules.Minesweeper);

local Root = require(script.Parent.Root);

-- Main
local scope = Fusion.scoped(Fusion);
local board = Minesweeper.Init(10, 10);

local MinesweeperUI = scope:New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,
    Name = "Minesweeper",
    [Children] = Root(scope, board)
}
