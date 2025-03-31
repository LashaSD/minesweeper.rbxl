-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);

local Children = Fusion.Children;

local Root = require(script.Parent.Root);

-- Main
local scope = Fusion.scoped(Fusion);
local Minesweeper = scope:New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,
    Name = "Minesweeper",
    [Children] = Root(scope)
}
