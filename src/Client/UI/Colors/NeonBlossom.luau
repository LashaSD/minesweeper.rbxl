return {
    Menu = {
        Background = Color3.fromHex("2A3335"), -- Deep muted teal
        LoseMessage = {
            Background = Color3.fromHex("FFCFEF"), -- Soft neon pink
            Foreground = Color3.fromHex("2A3335"), -- Dark contrast
        },
        WinMessage = {
            Background = Color3.fromHex("FFCFEF"),
            Foreground = Color3.fromHex("2A3335"),
        },
        BackToMenuPrompt = {
            Background = Color3.fromHex("0A5EB0"), -- Bright cyan-blue
            Foreground = Color3.fromHex("FFCFEF"),
        },
        Blur = {
            Background = Color3.fromHex("0A97B0"), -- Softer cyan overlay
        },
        PlayButton = {
            Background = Color3.fromHex("0A97B0"), -- Vivid teal
            Foreground = Color3.fromHex("2A3335"),
        }
    },
    Screen = {
        Background = Color3.fromHex("2A3335")
    },
    Clock = {
        Background = Color3.fromHex("0A5EB0"),
        Foreground = Color3.fromHex("FFCFEF")
    },
    Minefield = {
        Goal = Color3.fromHex("0A97B0"),
        Background = Color3.fromHex("2A3335"),
        Foreground = Color3.fromHex("FFCFEF")
    },
    Cell = {
        Background = Color3.fromHex("0A5EB0"),
        Stroke = Color3.fromHex("FFCFEF"),
        Hover = {
            Background = Color3.fromHex("0A97B0"),
        },
        MineCountMap = {
            [0] = Color3.fromHex("2A3335"),
            [1] = Color3.fromHex("FFCFEF"),
            [2] = Color3.fromHex("0A97B0"),
            [3] = Color3.fromHex("D500F9"), -- Neon purple
            [4] = Color3.fromHex("2979FF"),
            [5] = Color3.fromHex("FF1744"),
            [6] = Color3.fromHex("00E5FF"),
            [7] = Color3.fromHex("EEEEEE"),
            [8] = Color3.fromHex("B0BEC5")
        }
    }
}

