return {
    Menu = {
        Background = Color3.fromHex("222831"), -- Dark slate
        LoseMessage = {
            Background = Color3.fromHex("00ADB5"), -- Vibrant cyan
            Foreground = Color3.fromHex("222831"), -- Dark for contrast
        },
        WinMessage = {
            Background = Color3.fromHex("EEEEEE"), -- Bright white
            Foreground = Color3.fromHex("222831"), -- High contrast readability
        },
        BackToMenuPrompt = {
            Background = Color3.fromHex("393E46"), -- Muted dark gray
            Foreground = Color3.fromHex("EEEEEE"), -- Light text for clarity
        },
        Blur = {
            Background = Color3.fromHex("222831") -- Dark background for subtle blur
        },
        PlayButton = {
            Background = Color3.fromHex("00ADB5"), -- Eye-catching cyan
            Foreground = Color3.fromHex("222831"),
        }
    },
    Screen = {
        Background = Color3.fromHex("222831") -- Deep dark gray for depth
    },
    Clock = {
        Background = Color3.fromHex("393E46"),
        Foreground = Color3.fromHex("00ADB5") -- Neon-like cyan for modern feel
    },
    Minefield = {
        Goal = Color3.fromHex("00ADB5"), -- Cyan highlight for target
        Background = Color3.fromHex("222831"),
        Foreground = Color3.fromHex("393E46")
    },
    Cell = {
        Background = Color3.fromHex("393E46"),
        Stroke = Color3.fromHex("EEEEEE"), -- Crisp white for clean lines
        Hover = {
            Background = Color3.fromHex("00ADB5"), -- Subtle hover effect with cyan
        },
        MineCountMap = {
            [0] = Color3.fromHex("393E46"),
            [1] = Color3.fromHex("00ADB5"),
            [2] = Color3.fromHex("EEEEEE"),
            [3] = Color3.fromHex("00ADB5"),
            [4] = Color3.fromHex("222831"),
            [5] = Color3.fromHex("393E46"),
            [6] = Color3.fromHex("EEEEEE"),
            [7] = Color3.fromHex("00ADB5"),
            [8] = Color3.fromHex("EEEEEE")
        }
    }
}

