-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local Board = require(script.Parent.Parent.Modules.Minesweeper);

-- Types
type Scope = Fusion.Scope<typeof(Fusion)>
type Board = Board.Board;

-- Constants
local CELL_PADDING = 0.09

local Colors = {
    Screen = {
        Background = Color3.fromHex("181818")
    },
    Clock = {
        Background = Color3.fromRGB(0, 0, 0),
        Foreground = Color3.fromRGB(255, 255, 255)
    },
    Minefield = {
        Background = Color3.fromHex("252525"),
        Foreground = Color3.fromRGB(0, 255, 0)
    },
    Cell = {
        Background = Color3.fromHex("22586b"),
        Stroke = Color3.fromRGB(255, 255, 255),
        Hover = {
            Background = Color3.fromHex("27667B"),
        }
    }
}

-- Components
local AspectRatio = function(scope: Scope, x: number, y: number?)
    return scope:New "UIAspectRatioConstraint" {
        AspectRatio = if y ~= nil then x / y else x
    }
end

local RoundCorner = function(scope: Scope, scale: number, offset: number)
    return scope:New "UICorner" {
        CornerRadius = UDim.new(scale, offset)
    }
end

local CircularGradientAnim = function(scope: Scope)
    local gradient = scope:New "UIGradient" {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.6, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = -180
    }

    local tween = TweenService:Create(gradient, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 180 });
    tween:Play();

    return gradient;
end

local Cell_Pos = function(board: Board, row: number, col: number)
    return UDim2.fromScale((row - 1) * (1 / board.Rows) + (1 / board.Rows) / 2, (col - 1) * (1 / board.Cols) + (1 / board.Cols) / 2);
end

local Cell_Size = function(board: Board,row: number, col: number)
    return UDim2.fromScale((1 - CELL_PADDING) / board.Rows, (1 - CELL_PADDING) / board.Cols);
end

local Cell_Text = function(board: Board, row: number, col: number)
    if Board.IsDug(board, row, col) then
        return tostring(Board.ComputeValue(board, row, col));
    elseif Board.IsFlagged(board, row, col) then
        -- TODO(!): Add a better flag
        return "🚩";
    end

    return "";
end

local Cell_Init = function(scope: Scope, board: Board, row: number, col: number)
    local style = TweenInfo.new(0.1, Enum.EasingStyle.Quad);

    local size = scope:Value(Cell_Size(board, row, col));
    local sizeAnim = scope:Tween(size, style);

    local outline = scope:Value(0);
    local outlineAnim = scope:Tween(outline, style);

    local color = scope:Value(Colors.Cell.Background);
    local colorAnim = scope:Tween(color, style);

    local elevation = UDim2.fromScale(.015, .015);
    local z = scope:Value(1);

    local animateHoverBegin = function()
        size:set(Cell_Size(board, row, col) + elevation);
        color:set(Colors.Cell.Hover.Background);
        outline:set(1);
        z:set(69)
    end

    local animateHoverEnd = function()
        size:set(Cell_Size(board, row, col));
        color:set(Colors.Cell.Background);
        outline:set(0);
        z:set(1)
    end

    local animateMouseDown = function()
        size:set(Cell_Size(board, row, col) - elevation);
    end

    local animateMouseUp = function()
        size:set(Cell_Size(board, row, col));
    end

    -- TODO(!!): Add different colors based on cell state and their computed value

    return scope:New "TextButton" {
        Text = Cell_Text(board, row, col),
        BackgroundColor3 = colorAnim,
        AnchorPoint = Vector2.new(.5, .5),
        Position = Cell_Pos(board, row, col),
        Size = sizeAnim,
        ZIndex = z,

        [OnEvent "MouseEnter"] = animateHoverBegin,
        [OnEvent "MouseLeave"] = animateHoverEnd,
        [OnEvent "MouseButton1Down"] = animateMouseDown,
        [OnEvent "MouseButton2Down"] = animateMouseDown,

        [OnEvent "MouseButton1Up"] = function(x: number, y: number)
            animateMouseUp();
            Board.Dig(board, row, col);
            -- TODO(!!): Dig the cell
        end,

        [OnEvent "MouseButton2Up"] = function(x: number, y: number)
            animateMouseUp();
            -- TODO(!!): Put a flag
        end,

        [Children] = {
            scope:New "UIStroke" {
                Color = colorAnim,
                Thickness = outlineAnim
            }
        }
    }
end

local Cells = function(scope: Scope, board: Board)
    local cells = {};

    for row = 1, board.Rows do
        for col = 1, board.Cols do
            table.insert(cells, Cell_Init(scope, board, row, col));
        end
    end

    return scope:New "Folder" {
        Name = "Cells",
        [Children] = cells
    }
end

local CellContainer = function(scope: Scope, board: Board)
    return scope:New "Frame" {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(.95, .95),
        BackgroundColor3 = Colors.Minefield.Background,
        [Children] = Cells(scope, board)
    }
end

local Minefield = function(scope: Scope, board: Board)
    local backgroundColor = scope:Computed(function()
        return Colors.Minefield.Background:Lerp(Color3.fromHex("2a6642"), ((board.Rows * board.Cols) - Board.CountIdleCells(board)) / (board.Rows * board.Cols));
    end);

    local colorTween = scope:Tween(backgroundColor, TweenInfo.new(0.05, Enum.EasingStyle.Linear));

    return scope:New "Frame" {
        Name = "Minefield",

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.5, 0.5),

        BackgroundColor3 = colorTween,

        [Children] = {
            AspectRatio(scope, 1),
            RoundCorner(scope, 0.01),
            CellContainer(scope, board),
            CircularGradientAnim(scope)
        }
    }
end

local Clock = function(scope: Scope)
    -- TODO(!!): Properly implement the game clock
    return scope:New "TextLabel" {
        Name = "Clock",

        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.01),
        Size = UDim2.fromScale(0.15, 0.1),

        BackgroundTransparency = 1,

        Text = "00:00",
        TextColor3 = Colors.Clock.Foreground,
        TextScaled = true,

        Font = Enum.Font.RobotoMono,

        [Children] = {
            AspectRatio(scope, 35, 9),
            RoundCorner(scope, 0.1, 0)
        }
    }
end

return function(scope: Scope, board: Board)
    return scope:New "Frame" {
        Name = "Root",
        -- Position = UDim2.fromScale(0, -0.08),
        -- Size = UDim2.fromScale(1, 1.08),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.Screen.Background,
        [Children] = {
            Clock(scope),
            Minefield(scope, board),
        }
    }
end
