local StarterPlayer = game:GetService("StarterPlayer")

local TweenUI = require(StarterPlayer.StarterPlayerScripts.Client.UI.Animation.TweenUI)

local BindHover = {}

function BindHover.Bind(element: GuiObject): () -> ()
    local conns = {
        element.MouseEnter:Connect(function()
            TweenUI.Tween(element, "HoverIn")
        end),
        element.MouseLeave:Connect(function()
            TweenUI.Tween(element, "HoverOut")
        end),
    }
    return function()
        for _, c in conns do
            c:Disconnect()
        end
    end
end

return BindHover