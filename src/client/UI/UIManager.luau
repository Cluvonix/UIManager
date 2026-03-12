--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local TweenUI = require(StarterPlayer.StarterPlayerScripts.Client.UI.Animation.TweenUI)
local UIRegristry = require(script.Parent.UIRegristry)
local UIManager = {}

local screens = {}
local activeScreen = nil
local defaults = setmetatable({}, { __mode = "k" })

--#region Default Capture
local function captureDefault(gui: GuiObject)
	if defaults[gui] then
		return
	end
	defaults[gui] = {
		Position = gui.Position,
		Size = gui.Size,
		AnchorPoint = gui.AnchorPoint,
	}
end

local function getDefaultPosition(gui: GuiObject): UDim2
	captureDefault(gui)
	return defaults[gui].Position
end

local function getDefaultSize(gui: GuiObject): UDim2
	captureDefault(gui)
	return defaults[gui].Size
end

local function getDefaultAnchorPoint(gui: GuiObject): Vector2
	captureDefault(gui)
	return defaults[gui].AnchorPoint
end
--#endregion

type OffScreenDirection = "top" | "bottom" | "left" | "right"

local function getOffScreenPosition(gui: GuiObject, direction: OffScreenDirection?): UDim2
	local camera = workspace.CurrentCamera
	if not camera then
		return UDim2.fromScale(0.5, 1.2)
	end

	local screenSize = camera.ViewportSize
	if screenSize.X <= 0 or screenSize.Y <= 0 then
		return UDim2.fromScale(0.5, 1.2)
	end

	local guiPos = gui.AbsolutePosition
	local guiSize = gui.AbsoluteSize
	local currentPosition = gui.Position
	local anchor = gui.AnchorPoint

	local currentAnchorAbsX = guiPos.X + (guiSize.X * anchor.X)
	local currentAnchorAbsY = guiPos.Y + (guiSize.Y * anchor.Y)

	local chosenDirection = direction
	if not chosenDirection then
		local topDistance = guiPos.Y
		local bottomDistance = screenSize.Y - (guiPos.Y + guiSize.Y)
		local leftDistance = guiPos.X
		local rightDistance = screenSize.X - (guiPos.X + guiSize.X)

		local verticalDistance = math.min(topDistance, bottomDistance)
		local horizontalDistance = math.min(leftDistance, rightDistance)

		if horizontalDistance < verticalDistance then
			if leftDistance <= rightDistance then
				chosenDirection = "left"
			else
				chosenDirection = "right"
			end
		else
			if topDistance <= bottomDistance then
				chosenDirection = "top"
			else
				chosenDirection = "bottom"
			end
		end
	end

	if chosenDirection == "top" then
		local targetAnchorAbsY = -((1 - anchor.Y) * guiSize.Y) - 1
		local deltaY = targetAnchorAbsY - currentAnchorAbsY
		return UDim2.new(
			currentPosition.X.Scale,
			currentPosition.X.Offset,
			currentPosition.Y.Scale,
			currentPosition.Y.Offset + deltaY
		)
	elseif chosenDirection == "bottom" then
		local targetAnchorAbsY = screenSize.Y + (anchor.Y * guiSize.Y) + 1
		local deltaY = targetAnchorAbsY - currentAnchorAbsY
		return UDim2.new(
			currentPosition.X.Scale,
			currentPosition.X.Offset,
			currentPosition.Y.Scale,
			currentPosition.Y.Offset + deltaY
		)
	elseif chosenDirection == "left" then
		local targetAnchorAbsX = -((1 - anchor.X) * guiSize.X) - 1
		local deltaX = targetAnchorAbsX - currentAnchorAbsX
		return UDim2.new(
			currentPosition.X.Scale,
			currentPosition.X.Offset + deltaX,
			currentPosition.Y.Scale,
			currentPosition.Y.Offset
		)
	elseif chosenDirection == "right" then
		local targetAnchorAbsX = screenSize.X + (anchor.X * guiSize.X) + 1
		local deltaX = targetAnchorAbsX - currentAnchorAbsX
		return UDim2.new(
			currentPosition.X.Scale,
			currentPosition.X.Offset + deltaX,
			currentPosition.Y.Scale,
			currentPosition.Y.Offset
		)
	end

	local fallbackAnchorAbsY = screenSize.Y + (anchor.Y * guiSize.Y) + 1
	local fallbackDeltaY = fallbackAnchorAbsY - currentAnchorAbsY
	return UDim2.new(
		currentPosition.X.Scale,
		currentPosition.X.Offset,
		currentPosition.Y.Scale,
		currentPosition.Y.Offset + fallbackDeltaY
	)
end

function UIManager.CloseAllOtherThan(uiName: string)
	for name, ui in pairs(UIRegristry) do
		if name ~= uiName then
			UIManager.Close(name)
		end
	end
end

function UIManager.Open(uiName: string)
	local ui = UIRegristry[uiName]
	if ui then
		ui.Enabled = true
	else
		warn("UI not found: " .. uiName)
	end
end

function UIManager.Close(uiName: string)
	local ui = UIRegristry[uiName]
	if ui then
		ui.Enabled = false
	else
		warn("UI not found: " .. uiName)
	end
end

function UIManager.Toggle(uiName: string)
	local ui = UIRegristry[uiName]
	if ui then
		if ui.Enabled then
			UIManager.Close(uiName)
		else
			UIManager.Open(uiName)
		end
	else
		warn("UI not found: " .. uiName)
	end
end

function UIManager.HideHUD(exceptions: { [string]: any }?)
	for _, panel in UIRegristry.HUD:GetChildren() do
		if panel:IsA("Frame") and (not exceptions or not exceptions[panel.Name]) then
			captureDefault(panel)
			local tween = TweenUI.Tween(panel, "Back", { Position = getOffScreenPosition(panel) })
			tween.Completed:Connect(function()
				panel.Visible = false
			end)
		end
	end
end

function UIManager.ShowHUD(uiName: string)
	for _, panel in UIRegristry.HUD:GetChildren() do
		if panel:IsA("Frame") and panel.Name ~= uiName then
			local tween = TweenUI.Tween(panel, "Back", { Position = getDefaultPosition(panel) })
			tween.Completed:Connect(function()
				panel.Visible = true
			end)
		end
	end
end

return UIManager
