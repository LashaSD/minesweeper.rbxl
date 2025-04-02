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
local UI = scope:New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,
    Name = "Minesweeper",
    IgnoreGuiInset = true,
    [Children] = Root(scope)
}
