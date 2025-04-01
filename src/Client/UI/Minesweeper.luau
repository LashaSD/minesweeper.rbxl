-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");

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
local function Shake(duration: number, intensity: number, shakeOffset)
    local startTime = tick()

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if tick() - startTime > duration then
            shakeOffset:set(UDim2.fromOffset(0, 0))
            connection:Disconnect()
            return
        end

        local xOffset = (math.random() * 2 - 1) * intensity
        local yOffset = (math.random() * 2 - 1) * intensity
        shakeOffset:set(UDim2.fromOffset(xOffset, yOffset))
    end)
end

local function Pop(size, defaultSize: UDim2, goalSize: UDim2, waitTime: number)
    size:set(goalSize) -- Shrink to 80%
    task.wait(waitTime) -- Wait briefly
    size:set(defaultSize) -- Return to normal
end

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

    local shakeOffset = scope:Value(UDim2.fromOffset(0, 0));
    local pos = scope:Computed(function(use, scope)
        return Cell_Pos(board, row, col) + use(shakeOffset);
    end);

    local disconnect
    disconnect = observer:onChange(function()
        local stateValue = peek(state);
        if stateValue == CellState.Exploded then
            if peek(color) == Colors.Cell.Hover.Background then
                color:set(Colors.Cell.Background);
            end
            Shake(.3, 5, shakeOffset)
            disconnect();
        elseif stateValue == CellState.Dug then
            -- some new kind of animation and text value
            local cellValue = Board.ComputeValue(board, row, col);
            if cellValue == 0 then
                transparency:set(1);
            end
            color:set(Colors.Cell.DugMap[Board.ComputeValue(board, row, col)]);
            Pop(size, Cell_Size(board, row, col), Cell_Size(board, row, col) - elevation, .05);
        end
    end)

    local text = scope:Computed(function(use)
        if use(transparency) == 1 then return "" end
        if use(state) == CellState.Dug or use(state) == CellState.Exploded_Dug then
            local cellValue = Board.ComputeValue(board, row, col);
            return if cellValue > 0 then tostring(cellValue) else "";
        elseif use(state) == CellState.Flagged or use(state) == CellState.Flagged_Mine then
            return "🚩";
        elseif use(state) == CellState.Exploded_Mine then
            return "M"
        end

        return "";
    end)

    local corner = scope:Value(UDim.new(.5, 0));
    local cornerAnim = scope:Tween(corner, style);

    size:set(Cell_Size(board, row, col));
    corner:set(UDim.new(0, 0));

    return scope:New "TextButton" {
        -- Text = text,
        -- TextColor3 = Colors.Cell.Foreground,
        -- Font = Enum.Font.RobotoMono,
        BackgroundColor3 = colorAnim,
        BackgroundTransparency = transparencyAnim,
        AnchorPoint = Vector2.new(.5, .5),
        Position = pos,
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

    local maxx = math.max(board.Rows, board.Cols);
    local lerp = function(a: number, b: number, t: number)
        return a + (b - a) * t;
    end
    -- maps range [10, 18] to [.5, .75]
    local size = lerp(.5, .75, (maxx - 10) / 8);

    local colorTween = scope:Tween(backgroundColor, TweenInfo.new(0.05, Enum.EasingStyle.Linear));

    return scope:New "Frame" {
        Name = "Minefield",

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(size, size),

        BackgroundColor3 = colorTween,

        [Children] = {
            AspectRatio(scope, board.Rows, board.Cols),
            RoundCorner(scope, UDim.new(0.01, 0)),
            CellContainer(scope, board),
            CircularGradientAnim(scope)
        }
    }
end

local ClockValue = function(clock)
    return task.spawn(function()
        local elapsed = 1;
        local totalElapsed = 0;
        while true do
            local diff = 1 - elapsed;
            elapsed = task.wait(1 - diff)
            totalElapsed += elapsed;
            clock:set(totalElapsed);
        end
    end)
end

local Clock = function(scope: Scope, board: Board)
    local pos = scope:Value(UDim2.fromScale(.5, -1));
    local posAnim = scope:Tween(pos, TweenInfo.new(.5, Enum.EasingStyle.Quad));

    local clockValue = scope:Value(0);
    local clockThread = ClockValue(clockValue);
    table.insert(scope, function()
        task.cancel(clockThread);
    end)

    local disconnect
    disconnect = Board.ObserveGameResult(board):onChange(function()
        disconnect();
        task.cancel(clockThread);
    end)

    local text = scope:Computed(function(use)
        local totalSeconds = use(clockValue);
        local minutes = math.floor(totalSeconds / 60);
        local seconds = totalSeconds % 60;
        return string.format("%02d:%02d", minutes, seconds);
    end)

    pos:set(UDim2.fromScale(.5, .01));
    return scope:New "TextLabel" {
        Name = "Clock",

        AnchorPoint = Vector2.new(0.5, 0),
        Position = posAnim,
        Size = UDim2.fromScale(0.15, 0.1),

        BackgroundTransparency = 1,

        Text = text,
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
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.Screen.Background,
        [Children] = {
            Clock(scope, board),
            Minefield(scope, board),
        }
    }
end
