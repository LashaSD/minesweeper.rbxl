local colors = {} do
    for _, col in script:GetChildren() do
        table.insert(colors, require(col));
    end
end

local current = require(script.Default);

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
