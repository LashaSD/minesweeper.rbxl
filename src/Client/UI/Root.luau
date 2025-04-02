-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Paths
local Packages = ReplicatedStorage.Game.Common.Packages;
local Modules = script.Parent.Parent.Modules;

-- Imports
local Fusion = require(Packages.Fusion);
local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek;

local Board = require(Modules.Minesweeper);
local GameResult = require(Modules.Minesweeper.GameResultEnum);

local Minesweeper = require(script.Parent.Minesweeper);

-- Constants
local FORCED_EASY_MODE = false;

-- Types
type Scope = Fusion.Scope<typeof(Fusion)>;

local Gradient = function(scope: Scope, rotation: number, offset)
    return scope:New "UIGradient" {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.1, 0),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Offset = offset,
        Rotation = rotation
    } :: UIGradient
end

local BlurGradient = function(scope: Scope, rotation: number, offset)
    local goal = scope:Value(1);
    local anim = scope:Tween(goal, TweenInfo.new(.5, Enum.EasingStyle.Linear));

    local sequence = scope:Computed(function(use)
        return NumberSequence.new({
            NumberSequenceKeypoint.new(0, use(anim)),
            NumberSequenceKeypoint.new(0.1, use(anim)),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(0.9, use(anim)),
            NumberSequenceKeypoint.new(1, use(anim))
        })
    end)

    goal:set(.1);
    return scope:New "UIGradient" {
        Transparency = sequence,
        Offset = offset,
        Rotation = rotation
    } :: UIGradient
end

local InverseGradientBtn = function(scope: Scope, text: string, textCol: Color3 | Fusion.UsedAs<Color3>, clicked: Fusion.Value<boolean>, gradient: UIGradient)
    return scope:New "TextButton" {
        Text = text,
        TextColor3 = textCol,
        Font = Enum.Font.RobotoMono,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        TextScaled = true,
        [OnEvent "MouseButton1Down"] = function()
            clicked:set(true)
        end,
        [Children] = gradient
    }
end

local InverseGradientBtnContainer = function(scope: Scope, text: string, promptTriggered, color: Color3?, colorInverse: Color3?)
    if color == nil or colorInverse == nil then
        color = Color3.fromRGB(255, 255, 255);
        colorInverse = Color3.fromRGB(0, 0, 0);
    end

    assert(color ~= nil, `never`);
    assert(colorInverse ~= nil, `never`);

    local hoverGradientBegin = Vector2.new(-1, 0);
    local hoverGradientEnd = Vector2.new(1, 0);

    local clickedGradientBegin = Vector2.new(0, 1);
    local clickedGradientEnd = Vector2.new(0, -1);

    local tweenStyle = TweenInfo.new(.3, Enum.EasingStyle.Quad);
    local hoverGradientGoal = scope:Value(Vector2.new(-1, 0));
    local hoverAnim = scope:Tween(hoverGradientGoal, tweenStyle);
    local hoverGradient = Gradient(scope, 0, hoverAnim);

    local txtColor, txtColAnim do
        txtColor = scope:Computed(function(use, scope)
            return if use(hoverGradientGoal) == hoverGradientBegin then colorInverse else color;
        end);

        txtColAnim = scope:Tween(txtColor, tweenStyle);
    end

    local clicked, clickedGradient do
        clicked = scope:Value(false);

        local clickedGradientGoal = scope:Computed(function(use, scope)
            return if use(clicked) then clickedGradientEnd else clickedGradientBegin
        end);
        local clickedStyle = TweenInfo.new(.3, Enum.EasingStyle.Quad)
        clickedGradient = scope:Tween(clickedGradientGoal, clickedStyle);
    end

    local disconnect do
        local observer = scope:Observer(clickedGradient);
        disconnect = observer:onChange(function()
            if peek(clickedGradient) == clickedGradientEnd then
                promptTriggered:set(true);
                disconnect();
            end
        end);
    end

    return scope:New "Frame" {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = colorInverse,
        [OnEvent "MouseEnter"] = function()
            if not peek(clicked) then
                hoverGradientGoal:set(hoverGradientEnd);
            end
        end,
        [OnEvent "MouseLeave"] = function()
            if not peek(clicked) then
                hoverGradientGoal:set(hoverGradientBegin);
            end
        end,
        [Children] = {
            scope:New "Frame" {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = color,
                [Children] = {
                    InverseGradientBtn(scope, text, txtColAnim, clicked, Gradient(scope, -90, clickedGradient)),
                    hoverGradient,
                }
            },
            Gradient(scope, -90, clickedGradient)
        }
    }
end

local LoseMessage = function(scope: Scope)
    return scope:New "TextLabel" {
        Text = "Game Over",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextScaled = true,
        Font = Enum.Font.RobotoMono,
        Name = "GameOverMessage",
        AnchorPoint = Vector2.new(.5, .5),
        Size = UDim2.fromScale(.5, .15),
        Position = UDim2.fromScale(.5, .25),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 3
    }
end

local WinMessage = function(scope: Scope)
    return scope:New "TextLabel" {
        Text = "You Won",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextScaled = true,
        Font = Enum.Font.RobotoMono,
        Name = "YouWonMessage",
        AnchorPoint = Vector2.new(.5, .5),
        Size = UDim2.fromScale(.5, .15),
        Position = UDim2.fromScale(.5, .25),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 3
    }
end

local MenuPrompt = function(scope: Scope, gameStarted, gameResult)
    local trigger = scope:Value(false);

    local disconnect do
        disconnect = scope:Observer(trigger):onChange(function()
            gameStarted:set(false);
            gameResult:set(GameResult.Uninitialized);
            disconnect();
        end)
    end

    return scope:New "Frame" {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .75),
        Size = UDim2.fromScale(.5, .15),
        BackgroundTransparency = 1,
        ZIndex = 3,
        [Children] = {
            InverseGradientBtnContainer(scope, "Menu", trigger, Color3.fromHex("000000"), Color3.fromHex("FFFFFF"));
        }
    }
end

local EndgameBlur = function(scope: Scope)
    return scope:New "Frame" {
        Name = "Blur",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromHex("202020"),
        ZIndex = 2,
        [Children] = BlurGradient(scope, 0, Vector2.new(0, 0))
    }
end

local PlayGamePrompt = function(scope: Scope, gameStarted: Fusion.Value<boolean>)
    local pos = scope:Value(UDim2.fromScale(.5, 5));
    local posSpring = scope:Spring(pos);

    pos:set(UDim2.fromScale(.5, .35));
    return scope:New "Frame" {
        AnchorPoint = Vector2.new(.5, .5),
        Position = posSpring,
        Size = UDim2.fromScale(.4, .15),
        BackgroundTransparency = 1,
        [Children] = {
            InverseGradientBtnContainer(scope, "Play", gameStarted);
        }
    }
end

return function(scope: Scope)
    local gameStarted = scope:Value(false);
    local gameResult = scope:Value(GameResult.Uninitialized);
    local gameScope = Fusion.scoped(Fusion);
    local board = nil;
    local minesweeperUI: Instance? = nil;

    local children = scope:Computed(function(use, scope)
        local tbl = {};

        if use(gameResult) > GameResult.Uninitialized then
            table.insert(tbl, EndgameBlur(scope));

            if use(gameResult) == GameResult.Lose then
                table.insert(tbl, LoseMessage(scope));
            elseif use(gameResult) == GameResult.Win then
                table.insert(tbl, WinMessage(scope));
            end

            table.insert(tbl, MenuPrompt(scope, gameStarted, gameResult));
            if minesweeperUI ~= nil then
                table.insert(tbl, minesweeperUI);
            end
        elseif use(gameStarted) and use(gameResult) == GameResult.Uninitialized then
            gameScope = Fusion.scoped(Fusion);

            if board ~= nil then
                Board.Deinit(board);
            end

            if FORCED_EASY_MODE then
                local rows = 5;
                local cols = 5;
                board = Board.Init(rows, cols, 2, gameResult);
            else
                local rows = math.random(10, 18);
                local cols = math.random(10, 18);
                local mineDensity = math.random(10, 25) / 100;
                board = Board.Init(rows, cols, math.ceil(rows * cols * mineDensity), gameResult);
            end

            minesweeperUI = Minesweeper(gameScope, board);
            if minesweeperUI ~= nil then
                table.insert(tbl, minesweeperUI);
            end
        elseif not use(gameStarted) and use(gameResult) == GameResult.Uninitialized then
            if gameScope ~= nil then
                gameScope:doCleanup();
            end

            if minesweeperUI ~= nil then
                minesweeperUI:Destroy();
            end

            table.insert(tbl, PlayGamePrompt(scope, gameStarted));
        end

        return tbl;
    end);

    return scope:New "Frame" {
        Name = "Root",
        Position = UDim2.fromScale(0, -0.08),
        Size = UDim2.fromScale(1, 1.08),
        BackgroundColor3 = Color3.fromHex("101010"),
        [Children] = children
    }
end
