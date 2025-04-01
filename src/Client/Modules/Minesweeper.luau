--!native
export type Board = {
    Rows: number,
    Cols: number,
    Grid: { { number } }
}

local CellState = {
    Idle = 0,
    Dug = 1,
    Mine = 2,
    Flagged = 3,
    Flagged_Mine = 4
}

local Board = {}

function Board.IsMine(board: Board, row: number, col: number)
    return board.Grid[row][col] == CellState.Mine or board.Grid[row][col] == CellState.Flagged_Mine;
end

function Board.IsDug(board: Board, row: number, col: number)
    return board.Grid[row][col] == CellState.Dug;
end

function Board.IsArmedMine(board: Board, row: number, col: number)
    return board.Grid[row][col] == CellState.Mine;
end

function Board.IsFlagged(board: Board, row: number, col: number)
    return board.Grid[row][col] == CellState.Flagged or board.Grid[row][col] == CellState.Flagged_Mine;
end

function Board.MarkAsMine(board: Board, row: number, col: number)
    assert(board.Grid[row][col] == CellState.Idle);

    board.Grid[row][col] = CellState.Mine;
end

--[=[
    @return explosion: boolean -- if the cell exploded
    > doesn't check for flag
]=]
function Board.Dig(board: Board, row: number, col: number): boolean
    if Board.IsArmedMine(board, row, col) then
        -- TODO(!!): Add a game over event
        return true;
    end

    if Board.CountCells(board, CellState.Dug) == 0 then
        -- TODO(!!): Remove the hardcoded value
        -- TODO(!!): Start the game clock
        Board.Populate(board, 10);
    end

    if board.Grid[row][col] == CellState.Idle then
        board.Grid[row][col] = CellState.Dug;
    end

    -- TODO(!!): If there are any neighboring `0` cells dig them too.
    -- TODO(!!): Add some kind of signal to recompute some values.

    return false;
end

function Board.Flag(board: Board, row: number, col: number)
    if board.Grid[row][col] == CellState.Mine then
        board.Grid[row][col] = CellState.Flagged_Mine;
    else
        board.Grid[row][col] = CellState.Flagged;
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

function Board.Init(rows: number, cols: number)
    local grid = {};
    for row = 1, rows do
        grid[row] = {};
        for col = 1, cols do
            grid[row][col] = CellState.Idle;
        end
    end

    return {
        Rows = rows,
        Cols = cols,
        Grid = grid
    }
end

function Board.Populate(board: Board, mines: number)
    local availableCells = {};

    for row = 1, board.Rows do
        for col = 1, board.Cols do
            if board.Grid[row][col] == CellState.Idle then
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

function Board.CountMines(board: Board)
    local mines = 0;

    for row = 1, board.Rows do
        for col = 1, board.Cols do
            if Board.IsMine(board, row, col) then
                mines += 1;
            end
        end
    end

    return mines;
end

function Board.CountCells(board: Board, ...: number)
    local cnt = 0;
    local checkTbl = table.pack(...);

    for row = 1, board.Rows do
        for col = 1, board.Cols do
            local ok = true;
            for _, state in checkTbl do
                if board.Grid[row][col] ~= state then
                    ok = false;
                end
            end

            if ok then
                cnt += 1
            end
        end
    end

    return cnt;
end

function Board.CountIdleCells(board: Board)
    local idles = 0;

    for row = 1, board.Rows do
        for col = 1, board.Cols do
            if board.Grid[row][col] == CellState.Idle then
                idles += 1;
            end
        end
    end

    return idles;
end

return Board;
