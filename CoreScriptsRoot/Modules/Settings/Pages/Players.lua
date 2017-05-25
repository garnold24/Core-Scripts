 --[[
		Filename: Players.lua
		Written by: Stickmasterluke
		Version 1.0
		Description: Player list inside escape menu, with friend adding functionality.
--]]
-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GuiService = game:GetService("GuiService")
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

----------- UTILITIES --------------
RobloxGui:WaitForChild("Modules"):WaitForChild("TenFootInterface")
local utility = require(RobloxGui.Modules.Settings.Utility)
local reportAbuseMenu = require(RobloxGui.Modules.Settings.Pages.ReportAbuseMenu)
local SocialUtil = require(RobloxGui.Modules:WaitForChild("SocialUtil"))
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()

local enablePortraitModeSuccess, enablePortraitModeValue = pcall(function() return settings():GetFFlag("EnablePortraitMode") end)
local enablePortraitMode = enablePortraitModeSuccess and enablePortraitModeValue

local reportPlayerInMenuSuccess, reportPlayerInMenuValue = pcall(function() return settings():GetFFlag("CoreScriptReportPlayerInMenu") end)
-- The player report flag relies on portrait mode being enabled.
local enableReportPlayer = enablePortraitMode and reportPlayerInMenuSuccess and reportPlayerInMenuValue

local useNewThumbnailApiSuccess, useNewThumbnailApiValue = pcall(function() return settings():GetFFlag("CoreScriptsUseNewUserThumbnailAPI") end)
local useNewUserThumbnailAPI = useNewThumbnailApiSuccess and useNewThumbnailApiValue

------------ Constants -------------------
local FRAME_DEFAULT_TRANSPARENCY = .85
local FRAME_SELECTED_TRANSPARENCY = .65
local REPORT_PLAYER_IMAGE = isTenFootInterface and "rbxasset://textures/ui/Settings/Players/ReportFlagIcon@2x.png" or "rbxasset://textures/ui/Settings/Players/ReportFlagIcon.png"
local ADD_FRIEND_IMAGE = isTenFootInterface and "rbxasset://textures/ui/Settings/Players/AddFriendIcon@2x.png" or "rbxasset://textures/ui/Settings/Players/AddFriendIcon.png"
local FRIEND_IMAGE = isTenFootInterface and "rbxasset://textures/ui/Settings/Players/FriendIcon@2x.png" or "rbxasset://textures/ui/Settings/Players/FriendIcon.png"

local PLAYER_ROW_HEIGHT = 62
local PLAYER_ROW_SPACING = 80

------------ Variables -------------------
local platform = UserInputService:GetPlatform()
local PageInstance = nil
local localPlayer = PlayersService.LocalPlayer
while not localPlayer do
	PlayersService.ChildAdded:wait()
	localPlayer = PlayersService.LocalPlayer
end

----------- CLASS DECLARATION --------------
local function Initialize()
	local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
	local this = settingsPageFactory:CreateNewPage()

	if enablePortraitMode then
		this.PageListLayout.Padding = UDim.new(0, PLAYER_ROW_SPACING - PLAYER_ROW_HEIGHT)
	end

	------ TAB CUSTOMIZATION -------
	this.TabHeader.Name = "PlayersTab"
	this.TabHeader.Icon.Image = isTenFootInterface and "rbxasset://textures/ui/Settings/MenuBarIcons/PlayersTabIcon@2x.png" or "rbxasset://textures/ui/Settings/MenuBarIcons/PlayersTabIcon.png"

	this.TabHeader.Icon.Title.Text = "Players"

	----- FRIENDSHIP FUNCTIONS ------
	local function getFriendStatus(selectedPlayer)
		local success, result = pcall(function()
			-- NOTE: Core script only
			return localPlayer:GetFriendStatus(selectedPlayer)
		end)
		if success then
			return result
		else
			return Enum.FriendStatus.NotFriend
		end
	end

	------ PAGE CUSTOMIZATION -------
	this.Page.Name = "Players"

	local function createFriendStatusTextLabel(status, player)
		if enableReportPlayer and status == nil then
			return nil
		end

		local fakeSelection = Instance.new("Frame")
		fakeSelection.BackgroundTransparency = 1

		local friendLabel = nil
		local friendLabelText = nil
		if not status then
			-- Remove with enableReportPlayer
			friendLabel = Instance.new("TextButton")
			friendLabel.Text = ""
			friendLabel.BackgroundTransparency = 1
			friendLabel.Position = UDim2.new(1,-198,0,7)
			friendLabel.SelectionImageObject = fakeSelection
		elseif status == Enum.FriendStatus.Friend or status == Enum.FriendStatus.FriendRequestSent then
			friendLabel = Instance.new("TextButton")
			friendLabel.BackgroundTransparency = 1
			friendLabel.FontSize = Enum.FontSize.Size24
			friendLabel.Font = Enum.Font.SourceSans
			friendLabel.TextColor3 = Color3.new(1,1,1)
			friendLabel.SelectionImageObject = fakeSelection
			if status == Enum.FriendStatus.Friend then
				friendLabel.Text = "Friend"
			else
				friendLabel.Text = "Request Sent"
			end
		elseif status == Enum.FriendStatus.Unknown or status == Enum.FriendStatus.NotFriend or status == Enum.FriendStatus.FriendRequestReceived then
			local addFriendFunc = function()
				if friendLabel and friendLabelText and friendLabelText.Text ~= "" then
					friendLabel.ImageTransparency = 1
					friendLabelText.Text = ""
					if localPlayer and player then
						localPlayer:RequestFriendship(player)
					end
				end
			end
			friendLabel, friendLabelText = utility:MakeStyledButton("FriendStatus", "Add Friend", UDim2.new(0, 182, 0, 46), addFriendFunc)
			friendLabelText.ZIndex = 3
			friendLabelText.Position = friendLabelText.Position + UDim2.new(0,0,0,1)
		end

		if friendLabel then
			friendLabel.Name = "FriendStatus"
			friendLabel.Size = UDim2.new(0,182,0,46)
			friendLabel.Position = UDim2.new(1,-198,0,7)
			friendLabel.ZIndex = 3
		end
		return friendLabel
	end

	local function createFriendStatusImageLabel(status, player)
		if status == Enum.FriendStatus.Friend or status == Enum.FriendStatus.FriendRequestSent then
			local friendLabel = Instance.new("ImageButton")
			friendLabel.Name = "FriendStatus"
			friendLabel.Size = UDim2.new(0, 46, 0, 46)
			friendLabel.Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png"
			friendLabel.ScaleType = Enum.ScaleType.Slice
			friendLabel.SliceCenter = Rect.new(8,6,46,44)
			friendLabel.AutoButtonColor = false
			friendLabel.BackgroundTransparency = 1
			friendLabel.ZIndex = 2
			local friendImage = Instance.new("ImageLabel")
			friendImage.BackgroundTransparency = 1
			friendImage.Position = UDim2.new(0.5, 0, 0.5, 0)
			friendImage.Size = UDim2.new(0, 28, 0, 28)
			friendImage.AnchorPoint = Vector2.new(0.5, 0.5)
			friendImage.ZIndex = 3
			friendImage.Image = FRIEND_IMAGE
			if status == Enum.FriendStatus.Friend then
				friendImage.ImageTransparency = 0
			else
				friendImage.Image = ADD_FRIEND_IMAGE
				friendImage.ImageTransparency = 0.5
			end
			friendImage.Parent = friendLabel
			return friendLabel
		elseif status == Enum.FriendStatus.Unknown or status == Enum.FriendStatus.NotFriend or status == Enum.FriendStatus.FriendRequestReceived then
			local addFriendButton, addFriendImage = nil
			local addFriendFunc = function()
				if addFriendButton and addFriendImage and addFriendButton.ImageTransparency ~= 1 then
					addFriendButton.ImageTransparency = 1
					addFriendImage.ImageTransparency = 1
					if localPlayer and player then
						localPlayer:RequestFriendship(player)
					end
				end
			end
			addFriendButton, addFriendImage = utility:MakeStyledImageButton("FriendStatus", ADD_FRIEND_IMAGE,
					UDim2.new(0, 46, 0, 46), UDim2.new(0, 28, 0, 28), addFriendFunc)
			addFriendButton.Name = "FriendStatus"
			addFriendButton.Selectable = true
			return addFriendButton
		end
		return nil
	end

	--- Ideally we want to select the first add friend button, but select the first report button instead if none are available.
	local reportSelectionFound = nil
	local friendSelectionFound = nil
	local function friendStatusCreate(playerLabel, player)
		local friendLabelParent = playerLabel
		if enableReportPlayer and playerLabel then
			friendLabelParent = playerLabel:FindFirstChild("RightSideButtons")
		end

		if friendLabelParent then
			-- remove any previous friend status labels
			for _, item in pairs(friendLabelParent:GetChildren()) do
				if item and item.Name == "FriendStatus" then
					if GuiService.SelectedCoreObject == item then
						friendSelectionFound = nil
						GuiService.SelectedCoreObject = nil
					end
					item:Destroy()
				end
			end

			-- create new friend status label
			local status = nil
			if player and player ~= localPlayer and player.UserId > 1 and localPlayer.UserId > 1 then
				status = getFriendStatus(player)
			end

			if enableReportPlayer then
				local friendLabel = nil
				local wasIsPortrait = nil
				utility:OnResized(playerLabel, function(newSize, isPortrait)
					if friendLabel and isPortrait == wasIsPortrait then
						return
					end
					wasIsPortrait = isPortrait
					if friendLabel then
						friendLabel:Destroy()
					end
					if isPortrait then
						friendLabel = createFriendStatusImageLabel(status, player)
					else
						friendLabel = createFriendStatusTextLabel(status, player)
					end

					if friendLabel then
						friendLabel.Name = "FriendStatus"
						friendLabel.LayoutOrder = 2
						friendLabel.Selectable = true
						friendLabel.Parent = friendLabelParent

						if UserInputService.GamepadEnabled and not friendSelectionFound then
							friendSelectionFound = true
							GuiService.SelectedCoreObject = friendLabel
						end
					end
				end)
			else
				local friendLabel = createFriendStatusTextLabel(status, player)
				if friendLabel then
					friendLabel.Name = "FriendStatus"
					friendLabel.Size = UDim2.new(0,182,0,46)
					friendLabel.ZIndex = 3
					friendLabel.LayoutOrder = 2
					friendLabel.Selectable = true
					friendLabel.Parent = friendLabelParent

					local updateHighlight = function()
						if playerLabel then
							playerLabel.ImageTransparency = friendLabel and GuiService.SelectedCoreObject == friendLabel and FRAME_SELECTED_TRANSPARENCY or FRAME_DEFAULT_TRANSPARENCY
						end
					end
					friendLabel.SelectionGained:connect(updateHighlight)
					friendLabel.SelectionLost:connect(updateHighlight)

					if UserInputService.GamepadEnabled and not friendSelectionFound then
						friendSelectionFound = true
						GuiService.SelectedCoreObject = friendLabel
					end
				end
			end

		end
	end

	localPlayer.FriendStatusChanged:connect(function(player, friendStatus)
		if player then
			local playerLabel = this.Page:FindFirstChild("PlayerLabel"..player.Name)
			if playerLabel then
				friendStatusCreate(playerLabel, player)
			end
		end
	end)

	local buttonsContainer = utility:Create("Frame") {
		Name = "ButtonsContainer",
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
		Parent = this.Page,

		Visible = false
	}

	local leaveGameFunc = function()
		this.HubRef:SwitchToPage(this.HubRef.LeaveGamePage, false, 1)
	end
	local leaveButton, leaveLabel = utility:MakeStyledButton("LeaveButton", "Leave Game", UDim2.new(1 / 3, -5, 1, 0), leaveGameFunc)
	leaveButton.AnchorPoint = Vector2.new(0, 0)
	leaveButton.Position = UDim2.new(0, 0, 0, 0)
	leaveLabel.Size = UDim2.new(1, 0, 1, -6)
	leaveButton.Parent = buttonsContainer

	local resetFunc = function()
		this.HubRef:SwitchToPage(this.HubRef.ResetCharacterPage, false, 1)
	end
	local resetButton, resetLabel = utility:MakeStyledButton("ResetButton", "Reset Character", UDim2.new(1 / 3, -5, 1, 0), resetFunc)
	resetButton.AnchorPoint = Vector2.new(0.5, 0)
	resetButton.Position = UDim2.new(0.5, 0, 0, 0)
	resetLabel.Size = UDim2.new(1, 0, 1, -6)
	resetButton.Parent = buttonsContainer

	local resumeGameFunc = function()
		this.HubRef:SetVisibility(false)
	end
	local resumeButton, resumeLabel = utility:MakeStyledButton("ResumeButton", "Resume Game", UDim2.new(1 / 3, -5, 1, 0), resumeGameFunc)
	resumeButton.AnchorPoint = Vector2.new(1, 0)
	resumeButton.Position = UDim2.new(1, 0, 0, 0)
	resumeLabel.Size = UDim2.new(1, 0, 1, -6)
	resumeButton.Parent = buttonsContainer

	if enablePortraitMode then
		utility:OnResized(buttonsContainer, function(newSize, isPortrait)
			if isPortrait or utility:IsSmallTouchScreen() then
				local buttonsFontSize = isPortrait and 18 or 24
				buttonsContainer.Visible = true
				buttonsContainer.Size = UDim2.new(1, 0, 0, isPortrait and 50 or 62)
				resetLabel.TextSize = buttonsFontSize
				leaveLabel.TextSize = buttonsFontSize
				resumeLabel.TextSize = buttonsFontSize
			else
				buttonsContainer.Visible = false
				buttonsContainer.Size = UDim2.new(1, 0, 0, 0)
			end
		end)
	else
		if not utility:IsSmallTouchScreen() then
			buttonsContainer.Visible = false
			buttonsContainer.Size = UDim2.new(1, 0, 0, 0)
		else
			buttonsContainer.Visible = true
		end
	end

	local function reportAbuseButtonCreate(playerLabel, player)
		local rightSideButtons = playerLabel:FindFirstChild("RightSideButtons")
		if rightSideButtons then
			local oldReportButton = rightSideButtons:FindFirstChild("ReportPlayer")
			if oldReportButton then
				if oldReportButton == GuiService.SelectedCoreObject then
					reportSelectionFound = nil
				end
				oldReportButton:Destroy()
			end

			if player and player ~= localPlayer and player.UserId > 1 then
				local reportPlayerFunction = function()
					reportAbuseMenu:ReportPlayer(player)
				end

				local reportButton = utility:MakeStyledImageButton("ReportPlayer", REPORT_PLAYER_IMAGE,
						UDim2.new(0, 46, 0, 46), UDim2.new(0, 28, 0, 28), reportPlayerFunction)
				reportButton.Name = "ReportPlayer"
				reportButton.Position = UDim2.new(1, -260, 0, 7)
				reportButton.LayoutOrder = 1
				reportButton.Selectable = true
				reportButton.Parent = rightSideButtons

				if not reportSelectionFound and not friendSelectionFound and UserInputService.GamepadEnabled then
					reportSelectionFound = true
					GuiService.SelectedCoreObject = reportButton
				end
			end
		end
	end

	local function createPlayerRow(yPosition)
		local frame = Instance.new("ImageLabel")
		frame.Image = "rbxasset://textures/ui/dialog_white.png"
		frame.ScaleType = "Slice"
		frame.SliceCenter = Rect.new(10, 10, 10, 10)
		frame.Size = UDim2.new(1, 0, 0, PLAYER_ROW_HEIGHT)
		frame.Position = UDim2.new(0, 0, 0, yPosition)
		frame.BackgroundTransparency = 1
		frame.ZIndex = 2

		local rightSideButtons = Instance.new("Frame")
		rightSideButtons.Name = "RightSideButtons"
		rightSideButtons.BackgroundTransparency = 1
		rightSideButtons.ZIndex = 2
		rightSideButtons.Position = UDim2.new(0, 0, 0, 0)
		rightSideButtons.Size = UDim2.new(1, -10, 1, 0)
		rightSideButtons.Parent = frame

		-- Selection Highlighting logic:
		local updateHighlight = function(lostSelectionObject)
			if frame then
				if GuiService.SelectedCoreObject and GuiService.SelectedCoreObject ~= lostSelectionObject and GuiService.SelectedCoreObject.Parent == rightSideButtons then
					frame.ImageTransparency = FRAME_SELECTED_TRANSPARENCY
				else
					frame.ImageTransparency = FRAME_DEFAULT_TRANSPARENCY
				end
			end
		end

	 	local fakeSelectionObject = nil
		rightSideButtons.ChildAdded:connect(function(child)
			if child:IsA("GuiObject") then
				if fakeSelectionObject and child ~= fakeSelectionObject then
					fakeSelectionObject:Destroy()
					fakeSelectionObject = nil
				end
				child.SelectionGained:connect(function() updateHighlight(nil) end)
				child.SelectionLost:connect(function() updateHighlight(child) end)
			end
		end)

		if enableReportPlayer then
			fakeSelectionObject = Instance.new("Frame")
			fakeSelectionObject.Selectable = true
			fakeSelectionObject.Size = UDim2.new(0, 100, 0, 100)
			fakeSelectionObject.BackgroundTransparency = 1
			fakeSelectionObject.SelectionImageObject = fakeSelectionObject:Clone()
			fakeSelectionObject.Parent = rightSideButtons
		end

		local rightSideListLayout = Instance.new("UIListLayout")
		rightSideListLayout.Name = "RightSideListLayout"
		rightSideListLayout.FillDirection = Enum.FillDirection.Horizontal
		rightSideListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		rightSideListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		rightSideListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rightSideListLayout.Padding = UDim.new(0, 20)
		rightSideListLayout.Parent = rightSideButtons

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.new(0, 36, 0, 36)
		icon.Position = UDim2.new(0, 12, 0, 12)
		icon.ZIndex = 3
		icon.Parent = frame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.FontSize = Enum.FontSize.Size24
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Position = UDim2.new(0, 60, .5, 0)
		nameLabel.Size = UDim2.new(0, 0, 0, 0)
		nameLabel.ZIndex = 3
		nameLabel.Parent = frame
		
		return frame
	end

	-- Manage cutting off a players name if it is too long when switching into portrait mode.
	local function managePlayerNameCutoff(frame, player)
		local wasIsPortrait = nil
		local reportFlagAddedConnection = nil
		local reportFlagChangedConnection = nil
		local function reportFlagChanged(reportFlag, prop)
			if prop == "AbsolutePosition" and wasIsPortrait then
				local maxPlayerNameSize = reportFlag.AbsolutePosition.X - 20 - frame.NameLabel.AbsolutePosition.X
				frame.NameLabel.Text = player.Name
				local newNameLength = string.len(player.Name)
				while frame.NameLabel.TextBounds.X > maxPlayerNameSize and newNameLength > 0 do
					frame.NameLabel.Text = string.sub(player.Name, 1, newNameLength) .. "..."
					newNameLength = newNameLength - 1
				end
			end
		end
		utility:OnResized(frame.NameLabel, function(newSize, isPortrait)
			if wasIsPortrait ~= nil and wasIsPortrait == isPortrait then
				return
			end
			wasIsPortrait = isPortrait
			if isPortrait then
				if reportFlagAddedConnection == nil then
					reportFlagAddedConnection = frame.RightSideButtons.ChildAdded:connect(function(child)
						if child.Name == "ReportPlayer" then
							reportFlagChangedConnection = child.Changed:connect(function(prop) reportFlagChanged(child, prop) end)
							reportFlagChanged(child, "AbsolutePosition")
						end
					end)
				end
				local reportFlag = frame.RightSideButtons:FindFirstChild("ReportPlayer")
				if reportFlag then
					reportFlagChangedConnection = reportFlag.Changed:connect(function(prop) reportFlagChanged(reportFlag, prop) end)
					reportFlagChanged(reportFlag, "AbsolutePosition")
				end
			else
				frame.NameLabel.Text = player.Name
			end
		end)
	end

	local existingPlayerLabels = {}
	this.Displayed.Event:connect(function(switchedFromGamepadInput)
		local sortedPlayers = PlayersService:GetPlayers()
		table.sort(sortedPlayers, function(item1,item2)
			return item1.Name:lower() < item2.Name:lower()
		end)

		local extraOffset = 20
		if utility:IsSmallTouchScreen() or (enablePortraitMode and utility:IsPortrait()) then
			extraOffset = 85
		end

		friendSelectionFound = nil
		reportSelectionFound = nil

		-- iterate through players to reuse or create labels for players
		for index=1, #sortedPlayers do
			local player = sortedPlayers[index]
			local frame = existingPlayerLabels[index]
			if player then
				-- create label (frame) for this player index if one does not exist
				if not frame or not frame.Parent then
					frame = createPlayerRow((index - 1)*PLAYER_ROW_SPACING + extraOffset)
					frame.Parent = this.Page
					table.insert(existingPlayerLabels, index, frame)
				end
				frame.Name = "PlayerLabel" ..player.Name
				if useNewUserThumbnailAPI then
					-- Immediately assign the image to an image that isn't guaranteed to be generated
					frame.Icon.Image = SocialUtil.GetFallbackPlayerImageUrl(math.max(1, player.UserId), Enum.ThumbnailSize.Size180x180, Enum.ThumbnailType.AvatarThumbnail)
					-- Spawn a function to get the generated image
					spawn(function()
						local imageUrl = SocialUtil.GetPlayerImage(math.max(1, player.UserId), Enum.ThumbnailSize.Size180x180, Enum.ThumbnailType.AvatarThumbnail)
						if frame and frame.Parent and frame.Parent == this.Page then
							frame.Icon.Image = imageUrl
						end
					end)
				else
					frame.Icon.Image = "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&userId="..math.max(1, player.UserId)
				end
				frame.NameLabel.Text = player.Name
				frame.ImageTransparency = FRAME_DEFAULT_TRANSPARENCY

				if enableReportPlayer then
					managePlayerNameCutoff(frame, player)
				end

				friendStatusCreate(frame, player)
				if enableReportPlayer and platform ~= Enum.Platform.XBoxOne and platform ~= Enum.Platform.PS4 then
					reportAbuseButtonCreate(frame, player)
				end
			end
		end

		-- iterate through existing labels in reverse to destroy and remove unused labels
		for index=#existingPlayerLabels, 1, -1 do
			local player = sortedPlayers[index]
			local frame = existingPlayerLabels[index]
			if frame and not player then
				table.remove(existingPlayerLabels, index)
				frame:Destroy()
			end
		end

		if enablePortraitMode then
			utility:OnResized("MenuPlayerListExtraPageSize", function(newSize, isPortrait)
				local extraOffset = 20
				if utility:IsSmallTouchScreen() or utility:IsPortrait() then
					extraOffset = 85
				end
				this.Page.Size = UDim2.new(1,0,0, extraOffset + PLAYER_ROW_SPACING * #sortedPlayers - 5)
			end)
		else
			this.Page.Size = UDim2.new(1,0,0, extraOffset + PLAYER_ROW_SPACING * #sortedPlayers - 5)
		end
	end)

	return this
end

----------- Public Facing API Additions --------------
PageInstance = Initialize()

return PageInstance
