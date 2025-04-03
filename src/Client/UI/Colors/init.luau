export type ColorConfig = {
    Menu: {
        Background: Color3,
        LoseMessage: {
            Background: Color3,
            Foreground: Color3,
        },
        WinMessage: {
            Background: Color3,
            Foreground: Color3,
        },
        BackToMenuPrompt: {
            Background: Color3,
            Foreground: Color3,
        },
        Blur: {
            Background: Color3
        },
        PlayButton: {
            Background: Color3,
            Foreground: Color3,
        }
    },
    Screen: {
        Background: Color3
    },
    Clock: {
        Background: Color3,
        Foreground: Color3
    },
    Minefield: {
        Goal: Color3,
        Background: Color3,
        Foreground: Color3
    },
    Cell: {
        Background: Color3,
        Stroke: Color3,
        Hover: {
            Background: Color3,
        },
        MineCountMap: { Color3 }
    }
}

local colors = {} do
    for _, col in script:GetChildren() do
        table.insert(colors, require(col) :: ColorConfig);
    end
end

local current = require(script.Default) :: ColorConfig;

local roll = function()
    current = colors[math.random(1, #colors)];
end

local get = function()
    return current;
end

return {
    get = get,
    roll = roll
}
