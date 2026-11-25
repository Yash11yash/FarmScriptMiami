-- Lazy-loaded PVP Tab Module for Miami.lua
-- Upload this file to GitHub Raw and paste its URL into TAB_URLS.PVP in Miami.lua

local ctx = _G.MiamiCtx
local Players = ctx.Players
local player = ctx.player
local scrollFrame = ctx.scrollFrame
local pvpState = ctx.pvpState
local liveUpdaters = ctx.liveUpdaters

local function addCheckbox(nextOrder, title, sub, isChecked, onToggle)
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
	local selTarget = ctx.getState("selectedTargetPlayer")
	local isChasing = ctx.getState("isAutoChasing")
	local isAutoFire = ctx.getState("isAutoFire")
	local chaseDist = ctx.getState("chaseDistance")

	-- 1. Live Target & Damage Display Card
	local dmgCard = Instance.new("Frame")
	dmgCard.Size = UDim2.new(1, 0, 0, 82)
	dmgCard.BackgroundColor3 = Color3.fromRGB(24, 26, 38)
	dmgCard.LayoutOrder = nextOrder()
	dmgCard.Parent = scrollFrame
	Instance.new("UICorner", dmgCard).CornerRadius = UDim.new(0, 8)
	local dmgStroke = Instance.new("UIStroke", dmgCard)
	dmgStroke.Color = (selTarget and Color3.fromRGB(235, 85, 95)) or Color3.fromRGB(52, 58, 80)
	dmgStroke.Thickness = 1.2

	local pvpTgtLbl = Instance.new("TextLabel")
	pvpTgtLbl.Size = UDim2.new(1, -70, 0, 18)
	pvpTgtLbl.Position = UDim2.new(0, 10, 0, 6)
	pvpTgtLbl.BackgroundTransparency = 1
	pvpTgtLbl.TextColor3 = Color3.fromRGB(245, 248, 255)
	pvpTgtLbl.Font = Enum.Font.GothamBold
	pvpTgtLbl.TextSize = 12
	pvpTgtLbl.TextTruncate = Enum.TextTruncate.AtEnd
	pvpTgtLbl.TextXAlignment = Enum.TextXAlignment.Left
	pvpTgtLbl.Parent = dmgCard

	local pvpClearBtn = Instance.new("TextButton")
	pvpClearBtn.Size = UDim2.new(0, 52, 0, 20)
	pvpClearBtn.Position = UDim2.new(1, -60, 0, 5)
	pvpClearBtn.BackgroundColor3 = Color3.fromRGB(48, 52, 68)
	pvpClearBtn.Text = "Clear"
	pvpClearBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
	pvpClearBtn.Font = Enum.Font.GothamBold
	pvpClearBtn.TextSize = 10
	pvpClearBtn.Parent = dmgCard
	Instance.new("UICorner", pvpClearBtn).CornerRadius = UDim.new(0, 5)
	pvpClearBtn.MouseButton1Click:Connect(function()
		ctx.setState("isAutoChasing", false)
		ctx.setState("isPvpChaseDamage", false)
		ctx.setState("isAutoHunt", false)
		ctx.resetHuntState(false)
		ctx.renderTab()
	end)

	local pvpDmgLbl = Instance.new("TextLabel")
	pvpDmgLbl.Size = UDim2.new(1, -20, 0, 16)
	pvpDmgLbl.Position = UDim2.new(0, 10, 0, 26)
	pvpDmgLbl.BackgroundTransparency = 1
	pvpDmgLbl.Font = Enum.Font.GothamBold
	pvpDmgLbl.TextSize = 11
	pvpDmgLbl.TextTruncate = Enum.TextTruncate.AtEnd
	pvpDmgLbl.TextXAlignment = Enum.TextXAlignment.Left
	pvpDmgLbl.Parent = dmgCard

	local pvpSubLbl = Instance.new("TextLabel")
	pvpSubLbl.Size = UDim2.new(1, -20, 0, 14)
	pvpSubLbl.Position = UDim2.new(0, 10, 0, 44)
	pvpSubLbl.BackgroundTransparency = 1
	pvpSubLbl.Font = Enum.Font.Gotham
	pvpSubLbl.TextSize = 10
	pvpSubLbl.TextTruncate = Enum.TextTruncate.AtEnd
	pvpSubLbl.TextXAlignment = Enum.TextXAlignment.Left
	pvpSubLbl.Parent = dmgCard

	local pvpHpBg = Instance.new("Frame")
	pvpHpBg.Size = UDim2.new(1, -20, 0, 6)
	pvpHpBg.Position = UDim2.new(0, 10, 0, 65)
	pvpHpBg.BackgroundColor3 = Color3.fromRGB(38, 42, 56)
	pvpHpBg.BorderSizePixel = 0
	pvpHpBg.ClipsDescendants = true
	pvpHpBg.Parent = dmgCard
	Instance.new("UICorner", pvpHpBg).CornerRadius = UDim.new(1, 0)

	local pvpHpFill = Instance.new("Frame")
	pvpHpFill.Size = UDim2.new(0, 0, 1, 0)
	pvpHpFill.BackgroundColor3 = Color3.fromRGB(65, 220, 115)
	pvpHpFill.BorderSizePixel = 0
	pvpHpFill.Parent = pvpHpBg
	Instance.new("UICorner", pvpHpFill).CornerRadius = UDim.new(1, 0)

	local function syncPvpDmgCard()
		local nowClock = os.clock()
		local curTgt = ctx.getState("selectedTargetPlayer")
		local tgtDmg = ctx.getState("currentTargetDamage") or 0
		local totDmg = ctx.getState("totalDamageDealt") or 0
		local kills = ctx.getState("sessionKills") or 0
		if curTgt and curTgt.Parent then
			local hp, maxHp = ctx.getRealHealth(curTgt)
			local maxVal = math.max(maxHp or 100, 1)
			local hpStr = hp and (math.floor(hp) .. "/" .. math.floor(maxVal) .. " HP") or "? HP"
			local dist = ctx.getDistanceStuds(curTgt)
			pvpTgtLbl.Text = "Target: " .. curTgt.Name .. " (" .. hpStr .. ")"
			if hp then
				local r = math.clamp(hp / maxVal, 0, 1)
				pvpHpFill.Size = UDim2.new(r, 0, 1, 0)
				pvpHpFill.BackgroundColor3 = Color3.fromHSV(r * 0.33, 0.85, 0.95)
			else
				pvpHpFill.Size = UDim2.new(0, 0, 1, 0)
			end
			if pvpState.showDamage then
				local recentHit = (nowClock - pvpState.lastHitAt) < 1.2 and pvpState.lastHitDamage > 0
				pvpDmgLbl.Text = string.format("Target DMG Taken: %d  |  Last Hit: -%d", math.floor(tgtDmg), math.floor(pvpState.lastHitDamage))
				pvpDmgLbl.TextColor3 = recentHit and Color3.fromRGB(255, 210, 75) or Color3.fromRGB(255, 115, 115)
			else
				pvpDmgLbl.Text = "Show Damage: [OFF]"
				pvpDmgLbl.TextColor3 = Color3.fromRGB(150, 155, 175)
			end
			pvpSubLbl.Text = string.format("Dist: %s | Session DMG: %d | Kills: %d", dist and (dist .. "m") or "?", math.floor(totDmg), kills)
			pvpSubLbl.TextColor3 = Color3.fromRGB(165, 175, 200)
		else
			pvpTgtLbl.Text = "Target: None (Pick player below)"
			pvpDmgLbl.Text = pvpState.showDamage and string.format("Session DMG: %d  |  Kills: %d", math.floor(totDmg), kills) or "Show Damage: [OFF]"
			pvpDmgLbl.TextColor3 = Color3.fromRGB(160, 170, 195)
			pvpSubLbl.Text = "Enable checkboxes below to Follow, Equip Slot & Attack"
			pvpSubLbl.TextColor3 = Color3.fromRGB(140, 148, 170)
			pvpHpFill.Size = UDim2.new(0, 0, 1, 0)
		end
	end
	syncPvpDmgCard()
	table.insert(liveUpdaters, function()
		if pvpDmgLbl and pvpDmgLbl.Parent then syncPvpDmgCard() end
	end)

	-- 2. Checkboxes
	addCheckbox(nextOrder,
		"Follow Target (" .. pvpState.followMode .. ")",
		selTarget and ("Following: " .. selTarget.Name .. " | Dist: " .. tostring(chaseDist)) or "Select a player below to follow",
		isChasing,
		function() ctx.setState("isAutoChasing", not isChasing) end
	)

	local followModeBar = Instance.new("Frame")
	followModeBar.Size = UDim2.new(1, 0, 0, 30)
	followModeBar.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
	followModeBar.LayoutOrder = nextOrder()
	followModeBar.Parent = scrollFrame
	Instance.new("UICorner", followModeBar).CornerRadius = UDim.new(0, 7)

	for idx, mName in ipairs({"Behind", "Stable", "Circle", "Chase"}) do
		local active = (pvpState.followMode == mName)
		local mb = Instance.new("TextButton")
		mb.Size = UDim2.new(0.25, -4, 1, -6)
		mb.Position = UDim2.new((idx - 1) * 0.25, 2, 0, 3)
		mb.BackgroundColor3 = active and Color3.fromRGB(65, 130, 240) or Color3.fromRGB(36, 40, 56)
		mb.Text = mName
		mb.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 185, 210)
		mb.Font = Enum.Font.GothamBold
		mb.TextSize = 10
		mb.Parent = followModeBar
		Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 5)
		mb.MouseButton1Click:Connect(function()
			pvpState.followMode = mName
			ctx.renderTab()
		end)
	end

	local distBar = Instance.new("Frame")
	distBar.Size = UDim2.new(1, 0, 0, 28)
	distBar.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
	distBar.LayoutOrder = nextOrder()
	distBar.Parent = scrollFrame
	Instance.new("UICorner", distBar).CornerRadius = UDim.new(0, 7)

	for idx, dVal in ipairs({1.5, 5, 10, 15, 20}) do
		local active = (math.abs(chaseDist - dVal) < 0.2)
		local db = Instance.new("TextButton")
		db.Size = UDim2.new(0.2, -3, 1, -6)
		db.Position = UDim2.new((idx - 1) * 0.2, 2, 0, 3)
		db.BackgroundColor3 = active and Color3.fromRGB(50, 175, 110) or Color3.fromRGB(36, 40, 56)
		db.Text = tostring(dVal) .. "m"
		db.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 185, 210)
		db.Font = Enum.Font.GothamBold
		db.TextSize = 10
		db.Parent = distBar
		Instance.new("UICorner", db).CornerRadius = UDim.new(0, 5)
		db.MouseButton1Click:Connect(function()
			ctx.setState("chaseDistance", dVal)
			ctx.renderTab()
		end)
	end

	addCheckbox(nextOrder,
		"Equip Tool (Slot " .. tostring(pvpState.slotIndex) .. ")",
		pvpState.slot1ToolName and ("Active Slot " .. tostring(pvpState.slotIndex) .. ": " .. pvpState.slot1ToolName) or ("Auto equips Slot " .. tostring(pvpState.slotIndex) .. " tool"),
		pvpState.equipSlot1,
		function()
			pvpState.equipSlot1 = not pvpState.equipSlot1
			if not pvpState.equipSlot1 then pvpState.slot1ToolName = nil end
		end
	)

	local slotBar = Instance.new("Frame")
	slotBar.Size = UDim2.new(1, 0, 0, 30)
	slotBar.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
	slotBar.LayoutOrder = nextOrder()
	slotBar.Parent = scrollFrame
	Instance.new("UICorner", slotBar).CornerRadius = UDim.new(0, 7)

	for sIdx = 1, 8 do
		local active = (pvpState.slotIndex == sIdx)
		local sb = Instance.new("TextButton")
		sb.Size = UDim2.new(0.125, -3, 1, -6)
		sb.Position = UDim2.new((sIdx - 1) * 0.125, 2, 0, 3)
		sb.BackgroundColor3 = active and Color3.fromRGB(45, 185, 105) or Color3.fromRGB(36, 40, 56)
		sb.Text = tostring(sIdx)
		sb.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 185, 210)
		sb.Font = Enum.Font.GothamBold
		sb.TextSize = 10
		sb.Parent = slotBar
		Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 5)
		sb.MouseButton1Click:Connect(function()
			pvpState.slotIndex = sIdx
			pvpState.slot1ToolName = nil
			pvpState.lastEquipTick = 0
			ctx.renderTab()
		end)
	end

	addCheckbox(nextOrder,
		"Fast Attack on Target",
		"Fast swing/fire (0.08s + 4x anim + touch hit)",
		isAutoFire,
		function()
			local nextVal = not isAutoFire
			ctx.setState("isAutoFire", nextVal)
			if nextVal then ctx.setState("isSkipAnim", true) end
		end
	)

	addCheckbox(nextOrder,
		"Auto Hit (Nearby AoE)",
		"Standing auto-hit on any player within 25m (No TP)",
		pvpState.autoHit50,
		function() pvpState.autoHit50 = not pvpState.autoHit50 end
	)

	addCheckbox(nextOrder,
		"Show Damage (Target HP & Popups)",
		"Shows live damage taken & floating -HP hits",
		pvpState.showDamage,
		function() pvpState.showDamage = not pvpState.showDamage end
	)

	local pvpListHdr = Instance.new("TextLabel")
	pvpListHdr.Size = UDim2.new(1, 0, 0, 20)
	pvpListHdr.BackgroundTransparency = 1
	pvpListHdr.Text = "  SELECT TARGET PLAYER"
	pvpListHdr.TextColor3 = Color3.fromRGB(255, 115, 125)
	pvpListHdr.Font = Enum.Font.GothamBold
	pvpListHdr.TextSize = 11
	pvpListHdr.TextXAlignment = Enum.TextXAlignment.Left
	pvpListHdr.LayoutOrder = nextOrder()
	pvpListHdr.Parent = scrollFrame

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
