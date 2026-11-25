-- Lazy-loaded Errors & Diagnostics Tab Module for Miami.lua
-- Upload this file to GitHub Raw and paste its URL into TAB_URLS.Errors in Miami.lua

local ctx = _G.MiamiCtx
local player = ctx.player
local screenGui = ctx.screenGui
local scrollFrame = ctx.scrollFrame
local exportModal = ctx.exportModal
local exportTextBox = ctx.exportTextBox
local pvpState = ctx.pvpState

local function runDiagnostics()
	local res = {}
	local function addCheck(name, ok, detail)
		table.insert(res, { name = name, status = ok, detail = detail or "" })
	end

	local myChar = player.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
	addCheck("UI & ScrollFrame", (screenGui and screenGui.Parent ~= nil and scrollFrame and scrollFrame.Parent ~= nil), "Loaded in PlayerGui")
	addCheck("CurrentCamera", workspace.CurrentCamera ~= nil, workspace.CurrentCamera and workspace.CurrentCamera.CameraType.Name or "Missing")
	addCheck("Local Character", (myHRP ~= nil and myHum ~= nil and myHum.Health > 0), myHum and ("HP: " .. math.floor(myHum.Health)) or "No Character")
	local vu = ctx.getState("virtualUser")
	addCheck("VirtualUser Service", vu ~= nil, vu and "Ready" or "Unavailable")
	addCheck("firetouchinterest", typeof(firetouchinterest) == "function", typeof(firetouchinterest) == "function" and "Supported" or "Missing in Executor")
	addCheck("fireproximityprompt", typeof(fireproximityprompt) == "function", typeof(fireproximityprompt) == "function" and "Supported" or "Missing in Executor")
	local hasClip = typeof(setclipboard) == "function" or typeof(toclipboard) == "function"
	addCheck("Clipboard (Copy)", hasClip, hasClip and "Supported" or "Uses Export Popup")

	local foundGun = nil
	local bp = player:FindFirstChild("Backpack")
	if bp then
		for _, v in ipairs(bp:GetChildren()) do
			if v:IsA("Tool") and v:FindFirstChild("RemoteFunctionShoot") then
				foundGun = v.Name
				break
			end
		end
	end
	if not foundGun and myChar then
		for _, v in ipairs(myChar:GetChildren()) do
			if v:IsA("Tool") and v:FindFirstChild("RemoteFunctionShoot") then
				foundGun = v.Name
				break
			end
		end
	end
	addCheck("Gun (RemoteFunctionShoot)", foundGun ~= nil, foundGun and ("Found: " .. foundGun) or "No tool with RemoteFunctionShoot")

	local tgt = ctx.getState("selectedTargetPlayer")
	if tgt and tgt.Parent then
		local thp = ctx.getRealHealth(tgt)
		addCheck("Selected Target", (thp == nil or thp > 0), tgt.Name .. " (" .. (thp and (math.floor(thp) .. " HP") or "? HP") .. ")")
	else
		addCheck("Selected Target", false, "None selected")
	end

	local loops = ctx.getState("loops") or {}
	local loopsOk = (loops.hud and loops.hud.Connected) and (loops.chase and loops.chase.Connected) and (loops.hunt and loops.hunt.Connected) and (loops.ui and loops.ui.Connected)
	addCheck("Core Loops Running", loopsOk == true, loopsOk and "hud/chase/hunt/ui OK" or "Loop disconnected")

	pvpState.diagResults = res
	return res
end

return function(_filter, nextOrder)
	if #pvpState.diagResults == 0 then
		runDiagnostics()
	end

	local actRow = Instance.new("Frame")
	actRow.Size = UDim2.new(1, 0, 0, 32)
	actRow.BackgroundTransparency = 1
	actRow.LayoutOrder = nextOrder()
	actRow.Parent = scrollFrame

	local checkBtn = Instance.new("TextButton")
	checkBtn.Size = UDim2.new(0.33, -3, 1, 0)
	checkBtn.BackgroundColor3 = Color3.fromRGB(50, 170, 110)
	checkBtn.Text = "Run Checks"
	checkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	checkBtn.Font = Enum.Font.GothamBold
	checkBtn.TextSize = 10
	checkBtn.Parent = actRow
	Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0, 6)
	checkBtn.MouseButton1Click:Connect(function()
		runDiagnostics()
		ctx.renderTab()
	end)

	local copyLogBtn = Instance.new("TextButton")
	copyLogBtn.Size = UDim2.new(0.41, -3, 1, 0)
	copyLogBtn.Position = UDim2.new(0.33, 3, 0, 0)
	copyLogBtn.BackgroundColor3 = Color3.fromRGB(65, 130, 240)
	copyLogBtn.Text = "Copy Log & Checks"
	copyLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	copyLogBtn.Font = Enum.Font.GothamBold
	copyLogBtn.TextSize = 10
	copyLogBtn.Parent = actRow
	Instance.new("UICorner", copyLogBtn).CornerRadius = UDim.new(0, 6)
	copyLogBtn.MouseButton1Click:Connect(function()
		local results = runDiagnostics()
		local out = {"=== DIAGNOSTIC CHECKS ==="}
		for _, r in ipairs(results) do
			table.insert(out, string.format("[%s] %s - %s", r.status and "PASS" or "WARN/FAIL", r.name, r.detail))
		end
		table.insert(out, "")
		table.insert(out, "=== ERROR & WARNING LOGS (" .. tostring(#pvpState.logs) .. ") ===")
		if #pvpState.logs == 0 then
			table.insert(out, "No errors recorded.")
		else
			for _, ln in ipairs(pvpState.logs) do
				table.insert(out, ln)
			end
		end
		local fullText = table.concat(out, "\n")
		local copied = false
		pcall(function()
			if typeof(setclipboard) == "function" then
				setclipboard(fullText)
				copied = true
			elseif typeof(toclipboard) == "function" then
				toclipboard(fullText)
				copied = true
			end
		end)
		if copied then
			copyLogBtn.Text = "Copied!"
			task.delay(1.5, function()
				if copyLogBtn and copyLogBtn.Parent then copyLogBtn.Text = "Copy Log & Checks" end
			end)
		else
			exportTextBox.Text = fullText
			exportTextBox.Size = UDim2.new(1, -10, 0, math.max(300, #out * 16))
			exportModal.Visible = true
		end
	end)

	local clearLogBtn = Instance.new("TextButton")
	clearLogBtn.Size = UDim2.new(0.26, -3, 1, 0)
	clearLogBtn.Position = UDim2.new(0.74, 3, 0, 0)
	clearLogBtn.BackgroundColor3 = Color3.fromRGB(185, 65, 65)
	clearLogBtn.Text = "Clear"
	clearLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	clearLogBtn.Font = Enum.Font.GothamBold
	clearLogBtn.TextSize = 10
	clearLogBtn.Parent = actRow
	Instance.new("UICorner", clearLogBtn).CornerRadius = UDim.new(0, 6)
	clearLogBtn.MouseButton1Click:Connect(function()
		pvpState.logs = {}
		ctx.renderTab()
	end)

	local diagHdr = Instance.new("TextLabel")
	diagHdr.Size = UDim2.new(1, 0, 0, 20)
	diagHdr.BackgroundTransparency = 1
	diagHdr.Text = "  SYSTEM DIAGNOSTICS CHECKS"
	diagHdr.TextColor3 = Color3.fromRGB(115, 220, 155)
	diagHdr.Font = Enum.Font.GothamBold
	diagHdr.TextSize = 11
	diagHdr.TextXAlignment = Enum.TextXAlignment.Left
	diagHdr.LayoutOrder = nextOrder()
	diagHdr.Parent = scrollFrame

	for _, r in ipairs(pvpState.diagResults) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 28)
		row.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
		row.LayoutOrder = nextOrder()
		row.Parent = scrollFrame
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

		local badge = Instance.new("TextLabel")
		badge.Size = UDim2.new(0, 44, 0, 20)
		badge.Position = UDim2.new(0, 6, 0.5, -10)
		badge.BackgroundColor3 = r.status and Color3.fromRGB(40, 165, 95) or Color3.fromRGB(205, 130, 45)
		badge.Text = r.status and "PASS" or "WARN"
		badge.TextColor3 = Color3.fromRGB(255, 255, 255)
		badge.Font = Enum.Font.GothamBold
		badge.TextSize = 9
		badge.Parent = row
		Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -58, 1, 0)
		lbl.Position = UDim2.new(0, 56, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = r.name .. ": " .. r.detail
		lbl.TextColor3 = Color3.fromRGB(225, 230, 245)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 10
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row
	end

	local errHdr = Instance.new("TextLabel")
	errHdr.Size = UDim2.new(1, 0, 0, 20)
	errHdr.BackgroundTransparency = 1
	errHdr.Text = "  ERROR & WARNING LOGS (" .. tostring(#pvpState.logs) .. ")"
	errHdr.TextColor3 = Color3.fromRGB(255, 125, 125)
	errHdr.Font = Enum.Font.GothamBold
	errHdr.TextSize = 11
	errHdr.TextXAlignment = Enum.TextXAlignment.Left
	errHdr.LayoutOrder = nextOrder()
	errHdr.Parent = scrollFrame

	if #pvpState.logs == 0 then
		local okRow = Instance.new("TextLabel")
		okRow.Size = UDim2.new(1, 0, 0, 28)
		okRow.BackgroundColor3 = Color3.fromRGB(24, 30, 28)
		okRow.Text = "  No errors or warnings recorded."
		okRow.TextColor3 = Color3.fromRGB(120, 225, 155)
		okRow.Font = Enum.Font.Gotham
		okRow.TextSize = 10
		okRow.TextXAlignment = Enum.TextXAlignment.Left
		okRow.LayoutOrder = nextOrder()
		okRow.Parent = scrollFrame
		Instance.new("UICorner", okRow).CornerRadius = UDim.new(0, 6)
	else
		for _, ln in ipairs(pvpState.logs) do
			local logRow = Instance.new("TextLabel")
			logRow.Size = UDim2.new(1, 0, 0, 32)
			logRow.BackgroundColor3 = Color3.fromRGB(32, 22, 26)
			logRow.Text = "  " .. ln
			logRow.TextColor3 = Color3.fromRGB(255, 165, 165)
			logRow.Font = Enum.Font.Gotham
			logRow.TextSize = 9
			logRow.TextWrapped = true
			logRow.TextXAlignment = Enum.TextXAlignment.Left
			logRow.LayoutOrder = nextOrder()
			logRow.Parent = scrollFrame
			Instance.new("UICorner", logRow).CornerRadius = UDim.new(0, 6)
		end
	end
end
