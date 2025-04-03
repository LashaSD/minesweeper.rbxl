--!native
-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;

-- Imports
local Fusion = require(Packages.Fusion);
local peek = Fusion.peek;

local CellState = require(script.CellStateEnum);
local GameResult = require(script.GameResultEnum);

-- Types
type Scope = Fusion.Scope<typeof(Fusion)>

export type Board = {
    Rows: number,
    Cols: number,
    Grid: { { Fusion.Value<number> } }
}

type GameData = {
    Scope: Scope,
    DugCells: Fusion.Value<number>,
    GameResult: Fusion.Value<number>,
    InitialMines: number
}

-- Vars
--- Enum
local GameTbl: { [Board]: GameData } = {};

local Board = {}

function Board.IsAvailable(board: Board, row: number, col: number)
    return peek(board.Grid[row][col]) >= CellState.Idle;
end

function Board.IsMine(board: Board, row: number, col: number)
    return peek(board.Grid[row][col]) == CellState.Mine or peek(board.Grid[row][col]) == CellState.Flagged_Mine or peek(board.Grid[row][col]) == CellState.Exploded_Mine;
end

function Board.IsDug(board: Board, row: number, col: number)
    return peek(board.Grid[row][col]) == CellState.Dug;
end

function Board.IsArmedMine(board: Board, row: number, col: number)
    return peek(board.Grid[row][col]) == CellState.Mine;
end

function Board.IsFlagged(board: Board, row: number, col: number)
    return peek(board.Grid[row][col]) == CellState.Flagged or peek(board.Grid[row][col]) == CellState.Flagged_Mine;
end

function Board.MarkAsMine(board: Board, row: number, col: number)
    assert(peek(board.Grid[row][col]));

    board.Grid[row][col]:set(CellState.Mine);
end

function Board.Explode(board: Board)
    for row = 1, board.Rows do
        for col = 1, board.Cols do
            if Board.IsMine(board, row, col) then
                board.Grid[row][col]:set(CellState.Exploded_Mine);
            elseif peek(board.Grid[row][col]) == CellState.Dug then
                board.Grid[row][col]:set(CellState.Exploded_Dug);
            else
                board.Grid[row][col]:set(CellState.Exploded);
            end
        end
    end
end

function Board.Dig(board: Board, row: number, col: number)
    if Board.IsArmedMine(board, row, col) then
        Board.Explode(board);
        GameTbl[board].GameResult:set(GameResult.Lose);
        return
    end

    if Board.IsFlagged(board, row, col) then return end

    local dugCells = GameTbl[board].DugCells;
    local dugCellsValue = peek(dugCells);
    dugCells:set(dugCellsValue + 1);

    board.Grid[row][col]:set(CellState.Dug);

    if dugCellsValue == 0 then
        Board.Populate(board, GameTbl[board].InitialMines);
    end

    if Board.ComputeValue(board, row, col) == 0 or dugCellsValue == 0 then
        Board.BFS_Zero_Pop(board, row, col);
    end

    if (peek(dugCells) + Board.CountMines(board)) == (board.Rows * board.Cols) then
        GameTbl[board].GameResult:set(GameResult.Win);
    end

    return false;
end

function Board.BFS_Zero_Pop(board: Board, row: number, col: number)
    local tryAndDig = function(i: number, j: number)
        local withinRange = not (i < 1 or i > board.Rows or j < 1 or j > board.Cols);

        if withinRange then
            local isIdle = peek(board.Grid[i][j]) == CellState.Idle;
            if isIdle then
                Board.Dig(board, i, j);
            end
        end
    end

    tryAndDig(row,   col-1);
    tryAndDig(row-1, col-1);
    tryAndDig(row-1, col  );
    tryAndDig(row-1, col+1);
    tryAndDig(row,   col+1);
    tryAndDig(row+1, col+1);
    tryAndDig(row+1, col  );
    tryAndDig(row+1, col-1);
end

function Board.Flag(board: Board, row: number, col: number)
    if peek(board.Grid[row][col]) == CellState.Mine then
        board.Grid[row][col]:set(CellState.Flagged_Mine);
    elseif peek(board.Grid[row][col]) == CellState.Idle or peek(board.Grid[row][col]) == CellState.Mine then
        board.Grid[row][col]:set(CellState.Flagged);
    end
end

function Board.Unflag(board: Board, row: number, col: number)
    if peek(board.Grid[row][col]) == CellState.Flagged_Mine then
        board.Grid[row][col]:set(CellState.Mine);
    elseif peek(board.Grid[row][col]) == CellState.Flagged then
        board.Grid[row][col]:set(CellState.Idle);
    end
end

function Board.ComputeValue(board: Board, row: number, col: number)
    local value = function(i: number, j: number)
        if i < 1 or i > board.Rows or j < 1 or j > board.Cols then return 0 end
        return if Board.IsMine(board, i, j) then 1 else 0;
    end

    local v = 0
    + value(row, col-1)
    + value(row-1, col-1)
    + value(row-1, col)
    + value(row-1, col+1)
    + value(row, col+1)
    + value(row+1, col+1)
    + value(row+1, col)
    + value(row+1, col-1)

    return v;
end

function Board.Init(rows: number, cols: number, mines: number, gameResult: Fusion.Value<number>): Board
    local scope = Fusion.scoped(Fusion);
    local grid = {};
    for row = 1, rows do
        grid[row] = {};
        for col = 1, cols do
            grid[row][col] = scope:Value(CellState.Idle);
        end
    end

    local board = {
        Rows = rows,
        Cols = cols,
        Grid = grid
    }

    gameResult:set(0);
    GameTbl[board] = {
        Scope = scope,
        DugCells = scope:Value(0),
        GameResult = gameResult,
        InitialMines = mines
    }

    return board;
end

function Board.DugCells(board: Board)
    assert(GameTbl[board] ~= nil, `board was not initialized`);
    return GameTbl[board].DugCells;
end

function Board.ObserveCell(board: Board, row: number, col: number)
    assert(GameTbl[board] ~= nil, `board was not initialized`);
    local scope = GameTbl[board].Scope;

    return scope:Observer(board.Grid[row][col]);
end

function Board.ObserveGameResult(board: Board)
    assert(GameTbl[board] ~= nil, `board was not initialized`);
    local scope = GameTbl[board].Scope;

    return scope:Observer(GameTbl[board].GameResult);
end

function Board.Deinit(board: Board)
    if GameTbl[board] == nil then return end

    GameTbl[board].Scope:doCleanup();
    GameTbl[board] = nil;
end

function Board.Populate(board: Board, mines: number)
    local availableCells = {};

    local value = function(row: number, col: number)
        if row < 1 or row > board.Rows or col < 1 or col > board.Cols then return 0 end
        return if peek(board.Grid[row][col]) == CellState.Idle then 0 else 1
    end

    local ok = function(row: number, col: number)
        local cnt = value(row, col)
        + value(row, col-1)
        + value(row-1, col-1)
        + value(row-1, col)
        + value(row-1, col+1)
        + value(row, col+1)
        + value(row+1, col+1)
        + value(row+1, col)
        + value(row+1, col-1)

        return cnt == 0;
    end

    for row = 1, board.Rows do
        for col = 1, board.Cols do
            if ok(row, col) then
                table.insert(availableCells, {row, col});
            end
        end
    end

    while mines > 0 do
        local randIdx = math.random(1, #availableCells);
        Board.MarkAsMine(board, availableCells[randIdx][1], availableCells[randIdx][2]);

        availableCells[randIdx], availableCells[#availableCells] = availableCells[#availableCells], availableCells[randIdx];
        availableCells[#availableCells] = nil;

        mines -= 1;
    end
end

function Board.CountCells(board: Board, state: number | (number) -> boolean)
    local cnt = 0;

    for row = 1, board.Rows do
        for col = 1, board.Cols do
            if typeof(state) == "number" then
                if peek(board.Grid[row][col]) == state then
                    cnt += 1;
                end
            elseif state(peek(board.Grid[row][col])) then
                cnt += 1;
            end
        end
    end

    return cnt;
end

function Board.CountMines(board: Board)
    return Board.CountCells(board, function(state: number) return state == CellState.Mine or state == CellState.Flagged_Mine end);
end

function Board.CountIdleCells(board: Board)
    return Board.CountCells(board, CellState.Idle);
end

return Board;
