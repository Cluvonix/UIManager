local StarterPlayer = game:GetService("StarterPlayer")

local BindHover = require(script.Parent.BindHover)
local TweenUI = require(StarterPlayer.StarterPlayerScripts.Client.UI.Animation.TweenUI)

local BindButton = {}

function BindButton.Bind(button: GuiButton): () -> ()
    local disconnectHover = BindHover.Bind(button)
    local conns = {
        button.MouseButton1Down:Connect(function()
            TweenUI.Tween(button, "PressIn")
        end),
        button.MouseButton1Up:Connect(function()
            TweenUI.Tween(button, "PressOut")
        end),
    }
    return function()
        disconnectHover()
        for _, c in conns do
            c:Disconnect()
        end
    end
end

return BindButton