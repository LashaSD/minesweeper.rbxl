return {
    Menu = {
        Background = Color3.fromRGB(18, 18, 18), -- Deep charcoal, softer than pure black
        LoseMessage = {
            Background = Color3.fromRGB(245, 245, 245), -- Soft white for readability
            Foreground = Color3.fromRGB(30, 30, 30), -- Dark gray instead of pure black
        },
        WinMessage = {
            Background = Color3.fromRGB(245, 245, 245),
            Foreground = Color3.fromRGB(30, 30, 30),
        },
        BackToMenuPrompt = {
            Background = Color3.fromRGB(30, 30, 30),
            Foreground = Color3.fromRGB(245, 245, 245),
        },
        Blur = {
            Background = Color3.fromRGB(25, 25, 25), -- Soft dimming effect
        },
        PlayButton = {
            Background = Color3.fromRGB(240, 240, 240),
            Foreground = Color3.fromRGB(40, 40, 40),
        }
    },
    Screen = {
        Background = Color3.fromRGB(15, 15, 15) -- Slightly dark, but easy on the eyes
    },
    Clock = {
        Background = Color3.fromRGB(10, 10, 10), -- Slightly deeper black
        Foreground = Color3.fromRGB(230, 230, 230) -- Light gray for less strain
    },
    Minefield = {
        Goal = Color3.fromRGB(60, 60, 60), -- Darker than cells, but not too harsh
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(245, 245, 245)
    },
    Cell = {
        Background = Color3.fromRGB(50, 50, 50), -- Balanced neutral gray
        Stroke = Color3.fromRGB(220, 220, 220),
        Hover = {
            Background = Color3.fromRGB(70, 70, 70), -- Light hover effect
        },
        MineCountMap = {
            [0] = Color3.fromRGB(50, 50, 50),
            [1] = Color3.fromRGB(173, 216, 230), -- Soft blue
            [2] = Color3.fromRGB(144, 238, 144), -- Soft green
            [3] = Color3.fromRGB(255, 182, 193), -- Soft red (not harsh)
            [4] = Color3.fromRGB(100, 149, 237), -- Soft deep blue
            [5] = Color3.fromRGB(186, 85, 211), -- Soft purple
            [6] = Color3.fromRGB(72, 209, 204), -- Teal tone
            [7] = Color3.fromRGB(211, 211, 211), -- Light gray
            [8] = Color3.fromRGB(169, 169, 169) -- Darker gray
        }
    }
}

