local TweenUtils = {}

TweenUtils.TweenPresets = {
	["Hover"] = {
		Time = 0.2,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
	},
    ["Click"] = {
        Time = 0.1,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out,
    },
}

TweenUtils.Varients = {
	Fast = { info = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) },
	Slow = { info = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) },
	Subtle = { goals = { Scale = 1.03 } },
	Strong = { goals = { Scale = 1.08 } },
}

function TweenUtils.HoverTween() end

return TweenUtils
