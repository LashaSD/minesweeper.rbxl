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
local Minesweeper = require(script.Parent.Minesweeper);

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
    }
end

local PlayBtn = function(scope: Scope, clicked, color, gradient)
    return scope:New "TextButton" {
        Text = "Play",
        TextColor3 = color,
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

local PlayBtnContainer = function(scope: Scope, gameStarted)
    local posGoal = scope:Value(UDim2.fromScale(.5, 5));
    local pos = scope:Spring(posGoal);

    local defaultSize = UDim2.fromScale(.4, .15);

    local tweenStyle = TweenInfo.new(.3, Enum.EasingStyle.Quad);
    local gradientOffset = scope:Value(Vector2.new(-1, 0));
    local hoverLock = scope:Value(false);
    local hoverAnim = scope:Tween(gradientOffset, tweenStyle);
    local hoverGradient = Gradient(scope, 0, hoverAnim);

    local colorGoal = scope:Computed(function(use, scope)
        return if use(gradientOffset) == Vector2.new(-1, 0) then Color3.new(0, 0, 0) else Color3.new(255, 255, 255);
    end);
    local color = scope:Tween(colorGoal, tweenStyle);

    local clicked = scope:Value(false);

    local clickedGoal = Vector2.new(0, -1);
    local clickedGradientGoal = scope:Computed(function(use, scope)
        return if use(clicked) then Vector2.new(0, -1) else Vector2.new(0, 1)
    end);
    local clickedStyle = TweenInfo.new(.15, Enum.EasingStyle.Quad)
    local clickedAnim = scope:Tween(clickedGradientGoal, clickedStyle);

    local clickObserver = scope:Observer(clickedAnim);
    local disconnect
    disconnect = clickObserver:onChange(function()
        -- on start
        hoverLock:set(true);
        if peek(clickedAnim) == clickedGoal then
            gameStarted:set(true);
            disconnect();
        end
    end);

    posGoal:set(UDim2.fromScale(.5, .35));
    return scope:New "Frame" {
        AnchorPoint = Vector2.new(.5, .5),
        Size = defaultSize,
        Position = pos,
        BackgroundColor3 = Color3.new(0, 0, 0),
        [OnEvent "MouseEnter"] = function()
            if not peek(hoverLock) then
                gradientOffset:set(Vector2.new(1, 0));
            end
        end,
        [OnEvent "MouseLeave"] = function()
            if not peek(hoverLock) then
                gradientOffset:set(Vector2.new(-1, 0));
            end
        end,
        [Children] = {
            scope:New "Frame" {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.new(255, 255, 255),
                [Children] = {
                    PlayBtn(scope, clicked, color, Gradient(scope, -90, clickedAnim)),
                    hoverGradient,
                }
            },
            Gradient(scope, -90, clickedAnim)
        }
    }
end

return function(scope: Scope)
    local gameStarted = scope:Value(false);
    local child = scope:Computed(function(use, scope)
        if not use(gameStarted) then
            return PlayBtnContainer(scope, gameStarted);
        else
            -- TODO(!!): Remove hardcoded values
            local board = Board.Init(10, 10);
            return Minesweeper(scope, board);
        end
    end);

    return scope:New "Frame" {
        Name = "Root",
        -- Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, -0.08),
        Size = UDim2.fromScale(1, 1.08),
        BackgroundColor3 = Color3.fromHex("181818"),
        [Children] = child
    }
end
