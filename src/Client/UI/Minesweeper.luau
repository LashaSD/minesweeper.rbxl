-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;
local Modules = script.Parent.Parent.Modules;

-- Imports
local Fusion = require(Packages.Fusion);

local peek = Fusion.peek;
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local Board = require(Modules.Minesweeper);
local CellState = require(Modules.Minesweeper.CellStateEnum);

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
        Goal = Color3.fromHex("2a6642"),
        Background = Color3.fromHex("252525"),
        Foreground = Color3.fromRGB(0, 255, 0)
    },
    Cell = {
        Background = Color3.fromHex("22586b"),
        Foreground = Color3.fromHex("181818"),
        Stroke = Color3.fromRGB(255, 255, 255),
        Hover = {
            Background = Color3.fromHex("27667B"),
        },
        DugMap = {
            [0] = Color3.fromHex("22586b"),
            [1] = Color3.fromHex("00FFFF"),
            [2] = Color3.fromHex("00FF00"),
            [3] = Color3.fromHex("FF1744"),
            [4] = Color3.fromHex("2979FF"),
            [5] = Color3.fromHex("D500F9"),
            [6] = Color3.fromHex("00E5FF"),
            [7] = Color3.fromHex("EEEEEE"),
            [8] = Color3.fromHex("B0BEC5")
        }
    }
}

-- Components
local AspectRatio = function(scope: Scope, x: number, y: number?)
    return scope:New "UIAspectRatioConstraint" {
        AspectRatio = if y ~= nil then x / y else x
    }
end

local RoundCorner = function(scope: Scope, radius)
    return scope:New "UICorner" {
        CornerRadius = radius
    }
end

local CenteredText = function(scope: Scope, state, size: Vector2, color: Color3)
    return scope:New "TextLabel" {
        AnchorPoint = Vector2.new(.5, .5),
        Size = UDim2.fromScale(size.X, size.Y),
        Position = UDim2.fromScale(.5, .5),
        Font = Enum.Font.RobotoMono,
        BackgroundTransparency = 1,
        Text = state,
        TextScaled = true
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

local Cell_Init = function(scope: Scope, board: Board, row: number, col: number)
    local style = TweenInfo.new(0.1, Enum.EasingStyle.Quad);

    local size = scope:Value(UDim2.fromScale(.01, .01));
    local sizeAnim = scope:Tween(size, style);

    local outline = scope:Value(0);
    local outlineAnim = scope:Tween(outline, style);

    local color = scope:Value(Colors.Cell.Background);
    local colorAnim = scope:Tween(color, style);

    local transparency = scope:Value(0);
    local transparencyAnim = scope:Tween(transparency, style);

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

    local safe = function(callback)
        return function(...)
            if Board.IsAvailable(board, row, col) and not Board.IsDug(board, row, col) then
                callback(...);
            end
        end
    end

    local observer = Board.ObserveCell(board, row, col);
    local state = board.Grid[row][col];

    local disconnect
    disconnect = observer:onChange(function()
        local stateValue = peek(state);
        if stateValue == CellState.Disabled then
            color:set(Colors.Cell.Background);
            disconnect();
        elseif stateValue == CellState.Dug then
            -- some new kind of animation and text value
            local cellValue = Board.ComputeValue(board, row, col);
            if cellValue == 0 then
                transparency:set(1);
            end
            color:set(Colors.Cell.DugMap[Board.ComputeValue(board, row, col)]);
        end
    end)

    local text = scope:Computed(function(use)
        if use(state) == CellState.Dug then
            local cellValue = Board.ComputeValue(board, row, col);
            return if cellValue > 0 then tostring(cellValue) else "";
        elseif use(state) == CellState.Flagged or use(state) == CellState.Flagged_Mine then
            return "🚩";
        end

        return "";
    end)

    local corner = scope:Value(UDim.new(.5, 0));
    local cornerAnim = scope:Tween(corner, style);

    size:set(Cell_Size(board, row, col));
    corner:set(UDim.new(0, 0));
    return scope:New "TextButton" {
        Text = text,
        TextColor3 = Colors.Cell.Foreground,
        Font = Enum.Font.RobotoMono,
        BackgroundColor3 = colorAnim,
        BackgroundTransparency = transparencyAnim,
        AnchorPoint = Vector2.new(.5, .5),
        Position = Cell_Pos(board, row, col),
        Size = sizeAnim,
        ZIndex = z,

        [OnEvent "MouseEnter"] = safe(animateHoverBegin),
        [OnEvent "MouseLeave"] = safe(animateHoverEnd),
        [OnEvent "MouseButton1Down"] = safe(animateMouseDown),
        [OnEvent "MouseButton2Down"] = safe(animateMouseDown),

        [OnEvent "MouseButton1Up"] = safe(function(x: number, y: number)
            animateMouseUp();
            Board.Dig(board, row, col);
            -- TODO(!!): Dig the cell
        end),

        [OnEvent "MouseButton2Up"] = safe(function(x: number, y: number)
            animateMouseUp();
            if Board.IsFlagged(board, row, col) then
                Board.Unflag(board, row, col);
            else
                Board.Flag(board, row, col);
            end
        end),

        [Children] = {
            scope:New "UIStroke" {
                Color = colorAnim,
                Thickness = outlineAnim
            },
            CenteredText(scope, text, Vector2.new(.8, .8), Colors.Cell.Foreground),
            RoundCorner(scope, cornerAnim)
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
    local backgroundColor = scope:Computed(function(use, scope)
        return Colors.Minefield.Background:Lerp(Colors.Minefield.Goal, use(Board.DugCells(board)) / (board.Rows * board.Cols));
    end);

    return scope:New "Frame" {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(.95, .95),
        BackgroundColor3 = backgroundColor,
        [Children] = Cells(scope, board)
    }
end

local Minefield = function(scope: Scope, board: Board)
    local backgroundColor = scope:Computed(function(use, scope)
        return Colors.Minefield.Background:Lerp(Colors.Minefield.Goal, use(Board.DugCells(board)) / (board.Rows * board.Cols));
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
            RoundCorner(scope, UDim.new(0.01, 0)),
            CellContainer(scope, board),
            CircularGradientAnim(scope)
        }
    }
end

local Clock = function(scope: Scope)
    -- TODO(!!): Properly implement the game clock
    local pos = scope:Value(UDim2.fromScale(.5, -1));
    local posAnim = scope:Tween(pos, TweenInfo.new(.5, Enum.EasingStyle.Quad));


    pos:set(UDim2.fromScale(.5, .01));
    return scope:New "TextLabel" {
        Name = "Clock",

        AnchorPoint = Vector2.new(0.5, 0),
        Position = posAnim,
        Size = UDim2.fromScale(0.15, 0.1),

        BackgroundTransparency = 1,

        Text = "00:00",
        TextColor3 = Colors.Clock.Foreground,
        TextScaled = true,

        Font = Enum.Font.RobotoMono,

        [Children] = {
            AspectRatio(scope, 35, 9),
            RoundCorner(scope, UDim.new(0.1, 0))
        }
    }
end

return function(scope: Scope, board: Board)
    return scope:New "Frame" {
        Name = "Minesweeper",
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
