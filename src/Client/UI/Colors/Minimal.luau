return {
    Menu = {
        Background = Color3.fromRGB(20, 20, 20), -- Deep black-gray
        LoseMessage = {
            Background = Color3.fromRGB(255, 255, 255), -- White
            Foreground = Color3.fromRGB(0, 0, 0), -- Black
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
            Background = Color3.fromRGB(30, 30, 30), -- Subtle dark gray for contrast
        },
        PlayButton = {
            Background = Color3.fromRGB(255, 255, 255),
            Foreground = Color3.fromRGB(0, 0, 0),
        }
    },
    Screen = {
        Background = Color3.fromRGB(15, 15, 15) -- Slightly deeper black for depth
    },
    Clock = {
        Background = Color3.fromRGB(0, 0, 0),
        Foreground = Color3.fromRGB(255, 255, 255)
    },
    Minefield = {
        Goal = Color3.fromRGB(50, 50, 50), -- Neutral gray to distinguish
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(255, 255, 255)
    },
    Mine = { Background = Color3.fromRGB(50, 50, 50) },
    Cell = {
        Background = Color3.fromRGB(40, 40, 40), -- Medium dark gray
        Stroke = Color3.fromRGB(255, 255, 255),
        Hover = {
            Background = Color3.fromRGB(60, 60, 60), -- Slightly lighter hover effect
        },
        MineCountMap = {
            [0] = Color3.fromRGB(40, 40, 40),
            [1] = Color3.fromRGB(200, 200, 200), -- Subtle grayish-white for numbers
            [2] = Color3.fromRGB(150, 150, 150),
            [3] = Color3.fromRGB(100, 100, 100),
            [4] = Color3.fromRGB(80, 80, 80),
            [5] = Color3.fromRGB(60, 60, 60),
            [6] = Color3.fromRGB(50, 50, 50),
            [7] = Color3.fromRGB(30, 30, 30),
            [8] = Color3.fromRGB(20, 20, 20)
        }
    }
}

