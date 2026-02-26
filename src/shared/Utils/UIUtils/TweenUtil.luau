--!strict
local TweenService = game:GetService("TweenService")

local TweenUtils = {}

type TweenConfig = {
	info: TweenInfo?,
	goals: { [string]: any }?,
}

type FinalConfig = {
	info: TweenInfo,
	goals: { [string]: any },
}

type PresetName = "HoverIn" | "HoverOut" | "PressIn" | "PressOut" | "Pop"

TweenUtils.Presets = {
	-- Hover
	HoverIn = {
		info = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		goals = { Scale = 1.05 },
	},
	HoverOut = {
		info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		goals = { Scale = 1.00 },
	},

	-- Press
	PressIn = {
		info = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		goals = { Scale = 0.97 },
	},
	PressOut = {
		info = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		goals = { Scale = 1.00 },
	},

	-- Pop (nice for confirmations, badges, etc.)
	Pop = {
		info = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		goals = { Scale = 1.08 },
	},
}

TweenUtils.Variants = {
	-- Speed
	Fast = { info = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) },
	Slow = { info = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) },

	-- Strength (scale)
	Subtle = { goals = { Scale = 1.03 } },
	Strong = { goals = { Scale = 1.10 } },

	-- Different feel
	Soft = { info = TweenInfo.new(0.20, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) },
	Snappy = { info = TweenInfo.new(0.12, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out) },
}

local activeTweens = {} :: { [Instance]: Tween }

local function GetOrCreateUIScale(gui: GuiObject): UIScale
	local existing = gui:FindFirstChildOfClass("UIScale")
	if existing then
		return existing :: UIScale
	end

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = gui
	return uiScale
end

local function formatOverride(override: any): TweenConfig?
	if not override then return nil end
	if type(override) == "string" then
		return (TweenUtils.Variants :: { [string]: TweenConfig })[override]
	end
	if type(override) == "table" then
		local tableOverride = override :: { [string]: any }
		if tableOverride.info ~= nil or tableOverride.goals ~= nil then
			return tableOverride :: TweenConfig
		end
		return { goals = tableOverride }
	end
	if typeof(override) == "TweenInfo" then
		return { info = override }
	end
	error("TweenUI: invalid override type ".. tostring(override))
end

local function deepMerge(target: { [string]: any }, source: { [string]: any })
	for key, value in pairs(source) do
		local existing = target[key]
		if type(existing) == "table" and type(value) == "table" then
			deepMerge(existing :: { [string]: any }, value :: { [string]: any })
		else
			target[key] = value
		end
	end
end

local function mergeTables(...): FinalConfig
	local result: FinalConfig = { info = TweenInfo.new(), goals = {} }

	for _, config in ipairs({ ... }) do
		local typedConfig = config :: TweenConfig
		if typedConfig.info ~= nil then
			result.info = typedConfig.info
		end
		if typedConfig.goals ~= nil then
			deepMerge(result.goals, typedConfig.goals :: { [string]: any })
		end
	end

	return result
end

function TweenUtils.Tween(guiOrTarget: Instance, presetName: PresetName, ...: (string | {[string]: any} | TweenInfo)): Tween
	local preset = TweenUtils.Presets[presetName] 
	assert(preset, ("TweenUI: Unknown preset " .. presetName))

	local formattedOverrides = {}
	for _, override in ipairs({...}) do
		local resolved = formatOverride(override)
		if resolved then
			table.insert(formattedOverrides, resolved)
		end
	end

	local finalConfig = mergeTables(preset, unpack(formattedOverrides))
	local target = (guiOrTarget :: Instance) :: Instance
	if finalConfig.goals.Scale then
		assert(guiOrTarget:IsA("GuiObject"), "TweenUI: Scale goals require a GuiObject target")
		local uiScale = GetOrCreateUIScale(guiOrTarget :: GuiObject)
		target = uiScale
	else
		target = guiOrTarget
	end

	local tween = TweenService:Create(target, finalConfig.info, finalConfig.goals)
	activeTweens[target] = tween
	tween:Play()

	tween.Completed:Connect(function()
		if activeTweens[target] == tween then
			activeTweens[target] = nil
		end
	end)

	return tween
end

function TweenUtils.Cancel(guiOrTarget: Instance)
	local tween = activeTweens[guiOrTarget]
	if tween then
		tween:Cancel()
		activeTweens[guiOrTarget] = nil
	end
	if guiOrTarget:IsA("GuiObject") then
		local uiScale = guiOrTarget:FindFirstChildOfClass("UIScale")
		if uiScale then
			local scaleTween = activeTweens[uiScale]
			if scaleTween then
				scaleTween:Cancel()
				activeTweens[uiScale] = nil
			end
		end
	end
end

return TweenUtils
