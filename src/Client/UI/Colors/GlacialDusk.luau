return {
    Menu = {
        Background = Color3.fromRGB(18, 18, 18), -- Deep charcoal, softer than pure black
        LoseMessage = {
            Background = Color3.fromRGB(40, 40, 40), -- Soft dark gray, not too harsh
            Foreground = Color3.fromRGB(200, 200, 200), -- Muted light gray for contrast
        },
        WinMessage = {
            Background = Color3.fromRGB(40, 40, 40),
            Foreground = Color3.fromRGB(200, 200, 200),
        },
        BackToMenuPrompt = {
            Background = Color3.fromRGB(30, 30, 30),
            Foreground = Color3.fromRGB(200, 200, 200),
        },
        Blur = {
            Background = Color3.fromRGB(25, 25, 25), -- Soft dimming effect
        },
        PlayButton = {
            Background = Color3.fromRGB(50, 50, 50), -- Darker than before, blends well
            Foreground = Color3.fromRGB(180, 180, 180), -- Softer contrast than black/white
        }
    },
    Screen = {
        Background = Color3.fromRGB(15, 15, 15) -- Slightly dark, but easy on the eyes
    },
    Clock = {
        Background = Color3.fromRGB(10, 10, 10), -- Slightly deeper black
        Foreground = Color3.fromRGB(190, 190, 190) -- Muted light gray
    },
    Minefield = {
        Goal = Color3.fromRGB(60, 60, 60), -- Darker than cells, but not too harsh
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(200, 200, 200)
    },
    Mine = { Background = Color3.fromRGB(100, 100, 100) },
    Cell = {
        Background = Color3.fromRGB(50, 50, 50), -- Balanced neutral gray
        Stroke = Color3.fromRGB(170, 170, 170), -- Softer outline
        Hover = {
            Background = Color3.fromRGB(70, 70, 70), -- Light hover effect
        },
        MineCountMap = {
            [0] = Color3.fromRGB(50, 50, 50),
            [1] = Color3.fromRGB(130, 190, 220), -- Soft blue (less saturated)
            [2] = Color3.fromRGB(120, 200, 140), -- Muted green
            [3] = Color3.fromRGB(220, 120, 130), -- Soft red
            [4] = Color3.fromRGB(90, 130, 200), -- Muted blue
            [5] = Color3.fromRGB(160, 110, 200), -- Soft purple
            [6] = Color3.fromRGB(70, 180, 180), -- Softer teal
            [7] = Color3.fromRGB(160, 160, 160), -- Softer gray
            [8] = Color3.fromRGB(140, 140, 140) -- Even darker gray
        }
    }
}
