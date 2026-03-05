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
	local guiScaleX = guiSize.X / screenSize.X
	local guiScaleY = guiSize.Y / screenSize.Y
	local anchor = gui.AnchorPoint

	local anchorAbsX = guiPos.X + (guiSize.X * anchor.X)
	local anchorAbsY = guiPos.Y + (guiSize.Y * anchor.Y)
	local currentAnchorScaleX = anchorAbsX / screenSize.X
	local currentAnchorScaleY = anchorAbsY / screenSize.Y

	local chosenDirection = direction
	if not chosenDirection then
		local topDistance = guiPos.Y
		local bottomDistance = screenSize.Y - (guiPos.Y + guiSize.Y)
		local leftDistance = guiPos.X
		local rightDistance = screenSize.X - (guiPos.X + guiSize.X)

		chosenDirection = "top"
		local shortestDistance = topDistance

		if bottomDistance < shortestDistance then
			shortestDistance = bottomDistance
			chosenDirection = "bottom"
		end
		if leftDistance < shortestDistance then
			shortestDistance = leftDistance
			chosenDirection = "left"
		end
		if rightDistance < shortestDistance then
			chosenDirection = "right"
		end
	end

	if chosenDirection == "top" then
		return UDim2.fromScale(currentAnchorScaleX, -(1 - anchor.Y) * guiScaleY)
	elseif chosenDirection == "bottom" then
		return UDim2.fromScale(currentAnchorScaleX, 1 + anchor.Y * guiScaleY)
	elseif chosenDirection == "left" then
		return UDim2.fromScale(-(1 - anchor.X) * guiScaleX, currentAnchorScaleY)
	elseif chosenDirection == "right" then
		return UDim2.fromScale(1 + anchor.X * guiScaleX, currentAnchorScaleY)
	else
		return UDim2.fromScale(currentAnchorScaleX, 1 + anchor.Y * guiScaleY)
	end
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
		if not exceptions or not exceptions[panel.Name] then
			captureDefault(panel)
			TweenUI.Tween(panel, "Pop", { Goal = { Position = getDefaultPosition(panel) } })
			panel.Visible = false
		end
	end
end

function UIManager.ShowHUD(uiName: string)
	for _, panel in UIRegristry.HUD:GetChildren() do
		if panel.Name ~= uiName then
			TweenUI.Tween(panel, "Pop", { Goal = { Position = getDefaultPosition(panel) } })
			panel.Visible = true
		end
	end
end

return UIManager
