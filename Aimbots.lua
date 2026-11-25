-- Lazy-loaded Aimbots Tab Module for Miami.lua
-- Upload this file to GitHub Raw and paste its URL into TAB_URLS.Aimbots in Miami.lua

local ctx = _G.MiamiCtx
local Players = ctx.Players
local player = ctx.player
local scrollFrame = ctx.scrollFrame
local pvpState = ctx.pvpState
local liveUpdaters = ctx.liveUpdaters

local function addAimCheckbox(nextOrder, title, sub, isChecked, onToggle)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundColor3 = isChecked and Color3.fromRGB(28, 38, 34) or Color3.fromRGB(24, 26, 36)
	row.Text = ""
	row.AutoButtonColor = false
	row.LayoutOrder = nextOrder()
	row.Parent = scrollFrame
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke", row)
	st.Color = isChecked and Color3.fromRGB(55, 200, 115) or Color3.fromRGB(48, 52, 70)
	st.Thickness = 1.1

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 22, 0, 22)
	box.Position = UDim2.new(0, 10, 0.5, -11)
	box.BackgroundColor3 = isChecked and Color3.fromRGB(45, 195, 105) or Color3.fromRGB(36, 40, 54)
	box.BorderSizePixel = 0
	box.Parent = row
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

	local mark = Instance.new("TextLabel")
	mark.Size = UDim2.new(1, 0, 1, 0)
	mark.BackgroundTransparency = 1
	mark.Text = isChecked and "X" or ""
	mark.TextColor3 = Color3.fromRGB(255, 255, 255)
	mark.Font = Enum.Font.GothamBold
	mark.TextSize = 13
	mark.Parent = box

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -48, 0, 17)
	tLbl.Position = UDim2.new(0, 40, 0, 5)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = Color3.fromRGB(240, 244, 255)
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 11
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Parent = row

	local sLbl = Instance.new("TextLabel")
	sLbl.Size = UDim2.new(1, -48, 0, 14)
	sLbl.Position = UDim2.new(0, 40, 0, 22)
	sLbl.BackgroundTransparency = 1
	sLbl.Text = sub
	sLbl.TextColor3 = Color3.fromRGB(155, 165, 188)
	sLbl.Font = Enum.Font.Gotham
	sLbl.TextSize = 10
	sLbl.TextTruncate = Enum.TextTruncate.AtEnd
	sLbl.TextXAlignment = Enum.TextXAlignment.Left
	sLbl.Parent = row

	row.MouseButton1Click:Connect(function()
		onToggle()
		ctx.renderTab()
	end)
end

return function(filter, nextOrder, createPlayerCard)
	local isAimbot = ctx.getState("isAimbot")
	local isAutoFire = ctx.getState("isAutoFire")
	local aimSmooth = ctx.getState("aimSmoothness") or 18

	local statusCard = Instance.new("Frame")
	statusCard.Size = UDim2.new(1, 0, 0, 56)
	statusCard.BackgroundColor3 = Color3.fromRGB(24, 26, 38)
	statusCard.LayoutOrder = nextOrder()
	statusCard.Parent = scrollFrame
	Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 8)
	local stStroke = Instance.new("UIStroke", statusCard)
	stStroke.Color = (isAimbot or pvpState.aimbotGun or pvpState.noScope) and Color3.fromRGB(65, 200, 125) or Color3.fromRGB(52, 58, 80)
	stStroke.Thickness = 1.2

	local aimTgtLbl = Instance.new("TextLabel")
	aimTgtLbl.Size = UDim2.new(1, -20, 0, 18)
	aimTgtLbl.Position = UDim2.new(0, 10, 0, 6)
	aimTgtLbl.BackgroundTransparency = 1
	aimTgtLbl.TextColor3 = Color3.fromRGB(245, 248, 255)
	aimTgtLbl.Font = Enum.Font.GothamBold
	aimTgtLbl.TextSize = 12
	aimTgtLbl.TextTruncate = Enum.TextTruncate.AtEnd
	aimTgtLbl.TextXAlignment = Enum.TextXAlignment.Left
	aimTgtLbl.Parent = statusCard

	local aimSubLbl = Instance.new("TextLabel")
	aimSubLbl.Size = UDim2.new(1, -20, 0, 16)
	aimSubLbl.Position = UDim2.new(0, 10, 0, 28)
	aimSubLbl.BackgroundTransparency = 1
	aimSubLbl.Font = Enum.Font.Gotham
	aimSubLbl.TextSize = 10
	aimSubLbl.TextTruncate = Enum.TextTruncate.AtEnd
	aimSubLbl.TextXAlignment = Enum.TextXAlignment.Left
	aimSubLbl.Parent = statusCard

	local function syncAimCard()
		local sel = ctx.getState("selectedTargetPlayer")
		local tgtDmg = ctx.getState("currentTargetDamage") or 0
		local sm = ctx.getState("aimSmoothness") or 18
		if sel and sel.Parent then
			local hp = ctx.getRealHealth(sel)
			aimTgtLbl.Text = string.format("Target: %s (%s) | DMG:%d", sel.Name, hp and (math.floor(hp) .. " HP") or "?", math.floor(tgtDmg))
			aimSubLbl.Text = string.format("Gun: %s | Smooth: %d | LastHit: -%d", pvpState.gunToolName or "Auto", sm, math.floor(pvpState.lastHitDamage))
			aimSubLbl.TextColor3 = Color3.fromRGB(165, 220, 185)
		else
			aimTgtLbl.Text = "Aimbot Target: None (Pick player below)"
			aimSubLbl.Text = "Gun: " .. (pvpState.gunToolName or "None") .. " | Smooth: " .. tostring(sm)
			aimSubLbl.TextColor3 = Color3.fromRGB(150, 160, 185)
		end
	end
	syncAimCard()
	table.insert(liveUpdaters, function()
		if aimTgtLbl and aimTgtLbl.Parent then syncAimCard() end
	end)

	addAimCheckbox(nextOrder, "Aimbot (Chest Camera Steer)", "Smoothly steers camera toward target chest", isAimbot, function()
		ctx.setState("isAimbot", not isAimbot)
	end)

	local smoothBar = Instance.new("Frame")
	smoothBar.Size = UDim2.new(1, 0, 0, 28)
	smoothBar.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
	smoothBar.LayoutOrder = nextOrder()
	smoothBar.Parent = scrollFrame
	Instance.new("UICorner", smoothBar).CornerRadius = UDim.new(0, 7)

	for idx, item in ipairs({{lbl = "Soft (10)", val = 10}, {lbl = "Med (18)", val = 18}, {lbl = "Fast (28)", val = 28}}) do
		local active = (aimSmooth == item.val)
		local sb = Instance.new("TextButton")
		sb.Size = UDim2.new(0.333, -3, 1, -6)
		sb.Position = UDim2.new((idx - 1) * 0.333, 2, 0, 3)
		sb.BackgroundColor3 = active and Color3.fromRGB(65, 130, 240) or Color3.fromRGB(36, 40, 56)
		sb.Text = item.lbl
		sb.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 185, 210)
		sb.Font = Enum.Font.GothamBold
		sb.TextSize = 10
		sb.Parent = smoothBar
		Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 5)
		sb.MouseButton1Click:Connect(function()
			ctx.setState("aimSmoothness", item.val)
			ctx.renderTab()
		end)
	end

	addAimCheckbox(nextOrder, "Aimbot Gun (RemoteFunctionShoot)", pvpState.gunToolName and ("Gun: " .. pvpState.gunToolName) or "Auto detects Gun tool with RemoteFunctionShoot", pvpState.aimbotGun, function()
		pvpState.aimbotGun = not pvpState.aimbotGun
		if pvpState.aimbotGun then
			pvpState.gunToolName = nil
			local bp = player:FindFirstChild("Backpack")
			if bp then
				for _, v in ipairs(bp:GetChildren()) do
					if v:IsA("Tool") and v:FindFirstChild("RemoteFunctionShoot") then pvpState.gunToolName = v.Name end
				end
			end
			if player.Character then
				for _, v in ipairs(player.Character:GetChildren()) do
					if v:IsA("Tool") and v:FindFirstChild("RemoteFunctionShoot") then pvpState.gunToolName = v.Name end
				end
			end
		else
			pvpState.gunToolName = nil
		end
	end)

	addAimCheckbox(nextOrder, "No Scope (Direct Gun Fire)", "Hipfire directly at target chest without scoping", pvpState.noScope, function()
		pvpState.noScope = not pvpState.noScope
	end)

	addAimCheckbox(nextOrder, "Fast Attack on Target", "Fast swing/fire (0.08s + 4x anim + touch hit)", isAutoFire, function()
		local nv = not isAutoFire
		ctx.setState("isAutoFire", nv)
		if nv then ctx.setState("isSkipAnim", true) end
	end)

	addAimCheckbox(nextOrder, "Auto Hit (Nearby AoE 25m)", "Standing auto-hit on any nearby player (No TP)", pvpState.autoHit50, function()
		pvpState.autoHit50 = not pvpState.autoHit50
	end)

	local aimListHdr = Instance.new("TextLabel")
	aimListHdr.Size = UDim2.new(1, 0, 0, 20)
	aimListHdr.BackgroundTransparency = 1
	aimListHdr.Text = "  SELECT AIMBOT TARGET"
	aimListHdr.TextColor3 = Color3.fromRGB(115, 185, 255)
	aimListHdr.Font = Enum.Font.GothamBold
	aimListHdr.TextSize = 11
	aimListHdr.TextXAlignment = Enum.TextXAlignment.Left
	aimListHdr.LayoutOrder = nextOrder()
	aimListHdr.Parent = scrollFrame

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local infoStr = ctx.getPlayerDetails(plr)
			local fullSearchStr = string.lower(plr.Name .. " " .. infoStr)
			if filter == "" or string.find(fullSearchStr, filter, 1, true) then
				createPlayerCard(plr, true)
			end
		end
	end
end
