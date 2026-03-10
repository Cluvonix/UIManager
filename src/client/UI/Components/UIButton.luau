local StarterPlayer = game:GetService("StarterPlayer")
local BindButton = require(StarterPlayer.StarterPlayerScripts.Client.UI.Hooks.BindButton)
local UIButton = {}

function UIButton.Bind(button: GuiButton): () -> ()
    return BindButton.Bind(button)
end

function UIButton.BindWithCallback(button: GuiButton, onClick: () -> ()): () -> ()
    local disconnectBind = BindButton.Bind(button)
    local conn = button.MouseButton1Up:Connect(onClick)
    return function()
        disconnectBind()
        conn:Disconnect()
    end
end

return UIButton