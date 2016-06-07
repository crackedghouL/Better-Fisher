-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

ProfileEditor = {}
ProfileEditor.Visible = false
ProfileEditor.CurrentProfile = Profile()
ProfileEditor.AvailablesProfilesSelectedIndex = 0
ProfileEditor.AvailablesProfiles = {}
ProfileEditor.CurrentProfileSaveName = "Unamed"
ProfileEditor.WindowName = ""
ProfileEditor.CurrentMeshConnect = {}
ProfileEditor.MeshConnectEnabled = false
ProfileEditor.LastPosition = Vector3(0, 0, 0)

-----------------------------------------------------------------------------
-- ProfileEditor Functions
-----------------------------------------------------------------------------

function ProfileEditor.DrawProfileEditor()
	local selfPlayer = GetSelfPlayer()

	if ProfileEditor.MeshConnectEnabled and ProfileEditor.LastPosition.Distance3DFromMe > 200 then
		ProfileEditor.CurrentMeshConnect[#ProfileEditor.CurrentMeshConnect + 1] = {X = selfPlayer.Position.X, Y = selfPlayer.Position.Y, Z = selfPlayer.Position.Z}
		ProfileEditor.LastPosition = selfPlayer.Position
		if Bot.EnableDebug and Bot.EnableDebugProfileEditor then
			print("Connect Node: "..selfPlayer.Position)
		end
	end

	if Bot.Running then
		ProfileEditor.WindowName = "Profile"
	elseif not Bot.Running then
		ProfileEditor.WindowName = "Profile Editor"
	end

	if ProfileEditor.Visible then
		_, ProfileEditor.Visible = ImGui.Begin(ProfileEditor.WindowName, ProfileEditor.Visible, ImVec2(300, 400), -1.0, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoResize)

		if not Bot.Running then
			_, ProfileEditor.CurrentProfileSaveName = ImGui.InputText("##id_guid_profile_save_name", ProfileEditor.CurrentProfileSaveName)
			ImGui.SameLine()
			if ImGui.Button("Save") then
				ProfileEditor.SaveProfile(ProfileEditor.CurrentProfileSaveName)
			end

			_, ProfileEditor.AvailablesProfilesSelectedIndex = ImGui.Combo("##id_guid_profile_load_combo", ProfileEditor.AvailablesProfilesSelectedIndex, ProfileEditor.AvailablesProfiles)
			ImGui.SameLine()
			if ImGui.Button("Load") then
				ProfileEditor.LoadProfile(ProfileEditor.AvailablesProfiles[ProfileEditor.AvailablesProfilesSelectedIndex])
			end

			if ImGui.Button("Clear profile", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				Navigation.ClearMesh()
				ProfileEditor.CurrentProfile = Profile()
				ProfileEditor.CurrentProfileSaveName = "Unamed"
			end

			if ImGui.CollapsingHeader("Mesher", "id_gui_profile_editor_mesh", true, true) then
				if not Navigator.MeshConnectEnabled then
					_, Navigation.MesherEnabled = ImGui.Checkbox("Enable mesher##profile_enable_mesher", Navigation.MesherEnabled)
					ImGui.SameLine();
				end
				_,Navigation.RenderMesh = ImGui.Checkbox("Draw geometry##id_guid_profile_draw_mesher", Navigation.RenderMesh)
				if ImGui.Button("Build navigation", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					if ProfileEditor.CurrentProfile:HasFishSpot() then
						Navigation.BuildNavigation()
					else
						print("Can't build navigation, cause the fishing spot is missing")
					end
				end

				if ImGui.Button("Add Mesh Connect##id_guid_profile_add_connect", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					if not Navigator.MeshConnectEnabled then
						Navigation.MesherEnabled = false
						ProfileEditor.MeshConnectEnabled = true
						ProfileEditor.CurrentMeshConnect = {}
						ProfileEditor.CurrentMeshConnect[#ProfileEditor.CurrentMeshConnect + 1] = {X=selfPlayer.Position.X, Y=selfPlayer.Position.Y, Z=selfPlayer.Position.Z}
						ProfileEditor.LastPosition = selfPlayer.Position
						ProfileEditor.CurrentProfile.MeshConnects[#ProfileEditor.CurrentProfile.MeshConnects + 1] = ProfileEditor.CurrentMeshConnect
					end
				end
				ImGui.Columns(3)
				for key, value in pairs(ProfileEditor.CurrentProfile.MeshConnects) do
					if ProfileEditor.MeshConnectEnabled and key == table.length(ProfileEditor.CurrentProfile.MeshConnects) then
						ImGui.Text("Running...")
						ImGui.NextColumn()
						local dispDistance = Vector3(value[1].X,value[1].Y,value[1].Z)
						ImGui.Text(math.floor(dispDistance.Distance3DFromMe) / 100)
						ImGui.NextColumn()
						if ImGui.Button("Set End##id_guid_profile_end_connect") then
							-- , ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
							value[#value + 1] = {X=selfPlayer.Position.X, Y=selfPlayer.Position.Y, Z=selfPlayer.Position.Z}
							ProfileEditor.MeshConnectEnabled = false
						end
						ImGui.NextColumn()
					else
						if ImGui.SmallButton("Delete") then
							table.remove(ProfileEditor.CurrentProfile.MeshConnects,key)
						else
							ImGui.NextColumn()
							local dispDistance = Vector3(value[1].X,value[1].Y,value[1].Z)
							ImGui.Text(math.floor(dispDistance.Distance3DFromMe) / 100)
							ImGui.NextColumn()
							dispDistance = Vector3(value[#value].X,value[#value].Y,value[#value].Z)
							ImGui.Text(math.floor(dispDistance.Distance3DFromMe) / 100)
							ImGui.NextColumn()
						end
					end
				end
            	ImGui.Columns(1)
			end

			if ImGui.CollapsingHeader("Fishing spot", "id_gui_profile_editor_fishing_spot", true, false) then
				if ProfileEditor.CurrentProfile:HasFishSpot() then
					ImGui.Text("Distance: " .. math.floor(ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe) / 100)
				else
					ImGui.Text("Distance: Not set")
				end

				if ImGui.Button("Set" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
					local selfPlayer = GetSelfPlayer()
					if selfPlayer then
						ProfileEditor.CurrentProfile.FishSpotPosition.X = selfPlayer.Position.X
						ProfileEditor.CurrentProfile.FishSpotPosition.Y = selfPlayer.Position.Y
						ProfileEditor.CurrentProfile.FishSpotPosition.Z = selfPlayer.Position.Z
						ProfileEditor.CurrentProfile.FishSpotRotation = selfPlayer.Rotation
					end
				end
				ImGui.SameLine()
				if ImGui.Button("Clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					ProfileEditor.CurrentProfile.FishSpotPosition.X = 0
					ProfileEditor.CurrentProfile.FishSpotPosition.Y = 0
					ProfileEditor.CurrentProfile.FishSpotPosition.Z = 0
					ProfileEditor.CurrentProfile.FishSpotRotation = 0
				end
			end

			if ImGui.CollapsingHeader("Trade Manager NPC", "id_gui_profile_editor_trademanager", true, false) then
				if string.len(ProfileEditor.CurrentProfile.TradeManagerNpcName) > 0 then
					ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.TradeManagerNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetTradeManagerPosition().Distance3DFromMe / 100) .. " y)")
				else
					ImGui.Text("Name: Not set")
				end
				if ImGui.Button("Set" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
					local npcs = GetNpcs()
					if table.length(npcs) > 0 then
						local TradeManagerNpc = npcs[1]
						ProfileEditor.CurrentProfile.TradeManagerNpcName = TradeManagerNpc.Name
						ProfileEditor.CurrentProfile.TradeManagerNpcPosition.X = TradeManagerNpc.Position.X
						ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Y = TradeManagerNpc.Position.Y
						ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Z = TradeManagerNpc.Position.Z
						ProfileEditor.CurrentProfile.TradeManagerNpcSize = TradeManagerNpc.BodySize
					end
				end
				ImGui.SameLine()
				if ImGui.Button("Clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					ProfileEditor.CurrentProfile.TradeManagerNpcName = ""
					ProfileEditor.CurrentProfile.TradeManagerNpcPosition.X = 0
					ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Y = 0
					ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Z = 0
					ProfileEditor.CurrentProfile.TradeManagerNpcSize = 0
				end
			end

			if ImGui.CollapsingHeader("Vendor NPC", "id_guid_profile_editor_vendor", true, false) then
				if string.len(ProfileEditor.CurrentProfile.VendorNpcName) > 0 then
					ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.VendorNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetVendorPosition().Distance3DFromMe / 100) .. "y)")
				else
					ImGui.Text("Name: Not set")
				end

				if ImGui.Button("Set" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
					local npcs = GetNpcs()
					if table.length(npcs) > 0 then
						local VendorNpc = npcs[1]
						ProfileEditor.CurrentProfile.VendorNpcName = VendorNpc.Name
						ProfileEditor.CurrentProfile.VendorNpcPosition.X = VendorNpc.Position.X
						ProfileEditor.CurrentProfile.VendorNpcPosition.Y = VendorNpc.Position.Y
						ProfileEditor.CurrentProfile.VendorNpcPosition.Z = VendorNpc.Position.Z
						ProfileEditor.CurrentProfile.VendorNpcSize = VendorNpc.BodySize
					end
				end
				ImGui.SameLine()
				if ImGui.Button("Clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					ProfileEditor.CurrentProfile.VendorNpcName = ""
					ProfileEditor.CurrentProfile.VendorNpcPosition.X = 0
					ProfileEditor.CurrentProfile.VendorNpcPosition.Y = 0
					ProfileEditor.CurrentProfile.VendorNpcPosition.Z = 0
					ProfileEditor.CurrentProfile.VendorNpcSize = 0
				end
			end

			if ImGui.CollapsingHeader("Repair NPC", "id_gui_profile_editor_repair", true, false) then
				if string.len(ProfileEditor.CurrentProfile.RepairNpcName) > 0 then
					ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.RepairNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetRepairPosition().Distance3DFromMe / 100) .. "y)")
				else
					ImGui.Text("Name: Not set")
				end

				if ImGui.Button("Set" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
					local npcs = GetNpcs()
					if table.length(npcs) > 0 then
						local RepairNpc = npcs[1]
						ProfileEditor.CurrentProfile.RepairNpcName = RepairNpc.Name
						ProfileEditor.CurrentProfile.RepairNpcPosition.X = RepairNpc.Position.X
						ProfileEditor.CurrentProfile.RepairNpcPosition.Y = RepairNpc.Position.Y
						ProfileEditor.CurrentProfile.RepairNpcPosition.Z = RepairNpc.Position.Z
						ProfileEditor.CurrentProfile.RepairNpcSize = RepairNpc.BodySize
					end
				end
				ImGui.SameLine()
				if ImGui.Button("Clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					ProfileEditor.CurrentProfile.RepairNpcName = ""
					ProfileEditor.CurrentProfile.RepairNpcPosition.X = 0
					ProfileEditor.CurrentProfile.RepairNpcPosition.Y = 0
					ProfileEditor.CurrentProfile.RepairNpcPosition.Z = 0
					ProfileEditor.CurrentProfile.RepairNpcSize = 0
				end
			end

			if ImGui.CollapsingHeader("Warehouse NPC", "id_guid_profile_editor_warehouse", true, false) then
				if string.len(ProfileEditor.CurrentProfile.WarehouseNpcName) > 0 then
					ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.WarehouseNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetWarehousePosition().Distance3DFromMe / 100) .. " y)")
				else
					ImGui.Text("Warehouse: Not set")
				end

				if ImGui.Button("Set" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2.08, 20)) then
					local npcs = GetNpcs()
					if table.length(npcs) > 0 then
						local WarehouseNpc = npcs[1]
						ProfileEditor.CurrentProfile.WarehouseNpcName = WarehouseNpc.Name
						ProfileEditor.CurrentProfile.WarehouseNpcPosition.X = WarehouseNpc.Position.X
						ProfileEditor.CurrentProfile.WarehouseNpcPosition.Y = WarehouseNpc.Position.Y
						ProfileEditor.CurrentProfile.WarehouseNpcPosition.Z = WarehouseNpc.Position.Z
						ProfileEditor.CurrentProfile.WarehouseNpcSize = WarehouseNpc.BodySize
					end
				end
				ImGui.SameLine()
				if ImGui.Button("Clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					ProfileEditor.CurrentProfile.WarehouseNpcName = ""
					ProfileEditor.CurrentProfile.WarehouseNpcPosition.X = 0
					ProfileEditor.CurrentProfile.WarehouseNpcPosition.Y = 0
					ProfileEditor.CurrentProfile.WarehouseNpcPosition.Z = 0
					ProfileEditor.CurrentProfile.WarehouseNpcSize = 0
				end
			end
		elseif Bot.Running then
			ImGui.Text("Profile: " .. Bot.Settings.LastProfileName)
			ImGui.Spacing()
			ImGui.Separator()
			if string.len(ProfileEditor.CurrentProfile.TradeManagerNpcName) > 0 then
				ImGui.Text("Trader: " .. ProfileEditor.CurrentProfile.TradeManagerNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetTradeManagerPosition().Distance3DFromMe / 100) .. " y)")
			else
				ImGui.Text("Trader: Not set")
			end
			ImGui.Spacing()
			if string.len(ProfileEditor.CurrentProfile.VendorNpcName) > 0 then
				ImGui.Text("Vendor: " .. ProfileEditor.CurrentProfile.VendorNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetVendorPosition().Distance3DFromMe / 100) .. "y)")
			else
				ImGui.Text("Vendor: Not set")
			end
			ImGui.Spacing()
			if string.len(ProfileEditor.CurrentProfile.RepairNpcName) > 0 then
				ImGui.Text("Repair: " .. ProfileEditor.CurrentProfile.RepairNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetRepairPosition().Distance3DFromMe / 100) .. "y)")
			else
				ImGui.Text("Repair: Not set")
			end
			ImGui.Spacing()
			if string.len(ProfileEditor.CurrentProfile.WarehouseNpcName) > 0 then
				ImGui.Text("Warehouse: " .. ProfileEditor.CurrentProfile.WarehouseNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetWarehousePosition().Distance3DFromMe / 100) .. " y)")
			else
				ImGui.Text("Warehouse: Not set")
			end
		end
		ImGui.End()
	end
end

function ProfileEditor.RefreshAvailableProfiles()
	ProfileEditor.AvailablesProfiles = { }
	for k,v in pairs(Pyx.FileSystem.GetFiles("Profiles\\*.json")) do
		v = string.gsub(v, ".json", "")
		table.insert(ProfileEditor.AvailablesProfiles, v)
	end
end

function ProfileEditor.SaveProfile(name)
	local profileFilename = "\\Profiles\\" .. name .. ".json"
	local meshFilename = "\\Profiles\\" .. name .. ".mesh"
	local objFilename = "\\Profiles\\" .. name .. ".obj"

	--Navigation.ExportWavefrontObject(objFilename)

	print("Save mesh: " .. meshFilename)
	if not Navigation.SaveMesh(meshFilename) then
		print("Unable to save .mesh !")
		return
	end

	Bot.Settings.LastProfileName = name

	local json = JSON:new()
	Pyx.FileSystem.WriteFile(profileFilename, json:encode_pretty(ProfileEditor.CurrentProfile))
	ProfileEditor.RefreshAvailableProfiles()
end

function ProfileEditor.LoadProfile(name)
	local profileFilename = "\\Profiles\\" .. name .. ".json"
	local meshFilename = "\\Profiles\\" .. name .. ".mesh"

	print("Load mesh: " .. meshFilename)
	if not Navigation.LoadMesh(meshFilename) then
		print("Unable to load .mesh !")
		return
	end

	Bot.Settings.LastProfileName = name
	ProfileEditor.CurrentProfileSaveName = name

	ProfileEditor.AttackableMonstersSelectedIndex = 0
	ProfileEditor.AttackableMonstersComboSelectedIndex = 0

	local json = JSON:new()
	ProfileEditor.CurrentProfile = Profile()
	table.merge(ProfileEditor.CurrentProfile, json:decode(Pyx.FileSystem.ReadFile(profileFilename)))
end

function ProfileEditor.OnDrawGuiCallback()
	ProfileEditor.DrawProfileEditor()
end

function ProfileEditor.OnRender3D()
	if Navigation.RenderMesh then
		if ProfileEditor.CurrentProfile:HasFishSpot() then
			Renderer.Draw3DTrianglesList(GetInvertedTriangleList(ProfileEditor.CurrentProfile.FishSpotPosition.X, ProfileEditor.CurrentProfile.FishSpotPosition.Y + 100, ProfileEditor.CurrentProfile.FishSpotPosition.Z, 20, 50, 0xAAFF0000, 0xAAFF00FF))
		end

		for key,value in pairs(ProfileEditor.CurrentProfile.MeshConnects) do
			for k,v in pairs(value) do
				Renderer.Draw3DTrianglesList(GetInvertedTriangleList(v.X, v.Y + 25, v.Z, 25, 38, 0xAAFF0000, 0xAAFF00FF))
			end
		end
	end
end

ProfileEditor.RefreshAvailableProfiles()

if table.length(ProfileEditor.AvailablesProfiles) > 0 then
	ProfileEditor.AvailablesProfilesSelectedIndex = 1
end