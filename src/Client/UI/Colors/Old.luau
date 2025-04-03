return {
    Menu = {
        Background = Color3.fromHex("101010"),
        LoseMessage = {
            Background = Color3.fromRGB(255, 255, 255),
            Foreground = Color3.fromRGB(0, 0, 0),
        },
        WinMessage = {
            Background = Color3.fromRGB(255, 255, 255),
            Foreground = Color3.fromRGB(0, 0, 0),
        },
        BackToMenuPrompt = {
            Background = Color3.fromRGB(0, 0, 0),
            Foreground = Color3.fromRGB(255, 255, 255),
        },
        Blur = {
            Background = Color3.fromRGB(20, 20, 20)
        },
        PlayButton = {
            Background = Color3.fromRGB(255, 255, 255),
            Foreground = Color3.fromRGB(0, 0, 0),
        }
    },
    Screen = {
        Background = Color3.fromHex("101010")
    },
    Clock = {
        Background = Color3.fromRGB(0, 0, 0),
        Foreground = Color3.fromRGB(255, 255, 255)
    },
    Minefield = {
        Goal = Color3.fromHex("2a6642"),
        Background = Color3.fromHex("252525"),
        Foreground = Color3.fromHex("252525")
    },
    Mine = { Background = Color3.fromHex("30709F") },
    Cell = {
        Background = Color3.fromHex("22586b"),
        Stroke = Color3.fromRGB(255, 255, 255),
        Hover = {
            Background = Color3.fromHex("27667B"),
        },
        MineCountMap = {
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
