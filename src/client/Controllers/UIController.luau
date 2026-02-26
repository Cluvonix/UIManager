local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenUtil = require(ReplicatedStorage.Shared.Utils.UIUtils.TweenUtil)
local UIController = {}





function UIController.init()
    TweenUtil.Tween(guiOrTarget, "HoverIn", { Scale = 1.05} )
end

return UIController