--!native
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

local CELL_ELEVATION = UDim2.fromScale(.25, .25);

local Colorschemes = require(script.Parent.Colors);
local Colors = Colorschemes.get();

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
    size:set(goalSize);
    task.wait(waitTime);
    size:set(defaultSize);
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

local CenteredText = function(scope: Scope, text: Fusion.Value<string>, size: Vector2)
    return scope:New "TextLabel" {
        AnchorPoint = Vector2.new(.5, .5),
        Size = UDim2.fromScale(size.X, size.Y),
        Position = UDim2.fromScale(.5, .5),
        Font = Enum.Font.RobotoMono,
        BackgroundTransparency = 1,
        Text = text,
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

--- returns what the color of the state should be when the cell is unanimated / static
local Cell_Static_Color = function(board: Board, row: number, col: number)
    local stateValue = peek(board.Grid[row][col]);
    if stateValue == CellState.Exploded_Mine then
        return Colors.Mine.Background;
    elseif stateValue == CellState.Dug then
        return Colors.Cell.MineCountMap[Board.NeighboringMines(board, row, col)];
    end

    return Colors.Cell.Background;
end

local Cell_Icon = function(
    scope: Scope,
    board: Board,
    row: number,
    col: number,
    size: Fusion.Value<UDim2>,
    color: Fusion.Value<Color3>
)
    local state = board.Grid[row][col];
    local text = scope:Value("");

    local style = TweenInfo.new(0.1, Enum.EasingStyle.Quad);

    size:set(UDim2.fromScale(.01, .01));
    local sizeAnim = scope:Tween(size, style);
    size:set(UDim2.fromScale(1, 1));

    local colorAnim = scope:Tween(color, style);

    local transparency = scope:Value(0);
    local transparencyAnim = scope:Tween(transparency, style);

    local observer = Board.ObserveCell(board, row, col);

    local shakeOffset = scope:Value(UDim2.fromOffset(0, 0));
    local pos = scope:Computed(function(use, scope)
        return UDim2.fromScale(.5, .5) + use(shakeOffset);
    end);

    local disconnect
    disconnect = observer:onChange(function()
        local stateValue = peek(state);
        if stateValue == CellState.Exploded or stateValue == CellState.Exploded_Mine then
            if peek(color) == Colors.Cell.Hover.Background then
                color:set(Colors.Cell.Background);
            end

            if stateValue == CellState.Exploded_Mine then
                color:set(Colors.Mine.Background);
            end

            Shake(.3, 5, shakeOffset)
            disconnect();
        elseif stateValue == CellState.Dug then
            -- some new kind of animation and text value
            local cellValue = Board.NeighboringMines(board, row, col);
            if cellValue == 0 then
                transparency:set(1);
            end
            color:set(Colors.Cell.MineCountMap[Board.NeighboringMines(board, row, col)]);
            Pop(size, UDim2.fromScale(1, 1), UDim2.fromScale(1, 1) - CELL_ELEVATION, .05);
        end
    end)

    local textLabel = scope:New "Frame" {
        AnchorPoint = Vector2.new(.5, .5),
        Size = sizeAnim,
        Position = pos,
        BackgroundColor3 = colorAnim,
        BackgroundTransparency = transparencyAnim,
        [Children] = CenteredText(scope, text, Vector2.new(.9, .9))
    }

    return scope:Computed(function(use)
        if use(state) == CellState.Dug or use(state) == CellState.Exploded_Dug then
            local cellValue = Board.NeighboringMines(board, row, col);
            text:set(if cellValue > 0 then tostring(cellValue) else "");
            return textLabel;
        elseif use(state) == CellState.Flagged or use(state) == CellState.Flagged_Mine then
            text:set("🚩");
            return textLabel;
        elseif use(state) == CellState.Exploded_Mine then
            text:set("M");
            return textLabel;
        end

        text:set("");
        return textLabel;
    end);
end

local Cell_Init = function(scope: Scope, board: Board, row: number, col: number)
    local state = board.Grid[row][col];

    local defaultSize = UDim2.fromScale(1, 1);
    local size = scope:Value(UDim2.fromScale(.01, .01));

    local color = scope:Value(Colors.Cell.Background);
    local z = scope:Value(1);

    local ok = function()
        local available = Board.IsAvailable(board, row, col);
        local isDug = Board.IsDug(board, row, col);
        local mines = Board.NeighboringMines(board, row, col);
        local flags = Board.NeighboringFlags(board, row, col);
        local digables = Board.CountNeighborIf(board, row, col, CellState.Idle) + Board.CountNeighborIf(board, row, col, CellState.Mine);

        local ok = available;
        if isDug then
            ok = ok and (mines == flags and digables > 0);
        end

        return ok
    end

    local hovering = scope:Value(false);
    local animateHoverBegin = function()
        hovering:set(true);
        size:set(defaultSize + CELL_ELEVATION);
        color:set(Colors.Cell.Hover.Background);
        z:set(69);
    end

    local animateHoverEnd = function()
        if peek(hovering) then
            hovering:set(false);
            size:set(defaultSize);
            color:set(Cell_Static_Color(board, row, col));
            z:set(1);
        end
    end

    local clicked = scope:Value(false);
    local animateMouseDown = function()
        clicked:set(true);
        size:set(defaultSize - CELL_ELEVATION);
    end

    local animateMouseUp = function()
        if peek(clicked) then
            clicked:set(false);
            size:set(defaultSize);
        end
    end

    local wrapOk = function(callback: () -> ())
        return function()
            if ok() then
                callback();
            end
        end
    end

    return scope:New "TextButton" {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(.5, .5),
        Position = Cell_Pos(board, row, col),
        Size = Cell_Size(board, row, col),
        ZIndex = z,

        [OnEvent "MouseEnter"] = wrapOk(animateHoverBegin),
        [OnEvent "MouseLeave"] = animateHoverEnd,
        [OnEvent "MouseButton1Down"] = wrapOk(animateMouseDown),
        [OnEvent "MouseButton1Up"] = wrapOk(function()
            animateMouseUp();
            if peek(state) == CellState.Idle or peek(state) == CellState.Mine then
                Board.Dig(board, row, col);
            elseif peek(state) == CellState.Dug then
                Board.Dig_Breadth(board, row, col);
            end
        end),
        [OnEvent "MouseButton2Down"] = wrapOk(animateMouseDown),
        [OnEvent "MouseButton2Up"] = wrapOk(function()
            animateMouseUp();
            if Board.IsFlagged(board, row, col) then
                Board.Unflag(board, row, col);
            else
                Board.Flag(board, row, col);
            end
        end),

        [Children] = Cell_Icon(scope, board, row, col, size, color)
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
        BackgroundColor3 = Colors.Minefield.Foreground,
        [Children] = Cells(scope, board)
    }
end

local Minefield = function(scope: Scope, board: Board)
    local maxx = math.max(board.Rows, board.Cols);
    local lerp = function(a: number, b: number, t: number)
        return a + (b - a) * t;
    end
    -- maps range [10, 18] to [.5, .75]
    local size = lerp(.5, .85, (maxx - 10) / 8);

    return scope:New "Frame" {
        Name = "Minefield",

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(size, size),

        BackgroundColor3 = Colors.Minefield.Background,

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
        local totalElapsed = 0;
        while true do
            local elapsed = task.wait(1)
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
    Colors = Colorschemes.get();
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
