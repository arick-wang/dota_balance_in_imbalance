IMBALevelRewards = class({})

CustomGameEventManager:RegisterListener("IMBALevelReward_Announce", function(...) return IMBALevelRewards:AnnounceIMBALevel(...) end)
CustomGameEventManager:RegisterListener("IMBALevelReward_HeroEffect", function(...) return IMBALevelRewards:ChangeHeroEffect(...) end)
CustomGameEventManager:RegisterListener("IMBALevelReward_CourierEffect", function(...) return IMBALevelRewards:ChangeCourierEffect(...) end)
CustomGameEventManager:RegisterListener("IMBALevelReward_WardEffect", function(...) return IMBALevelRewards:ChangeWardEffect(...) end)
CustomGameEventManager:RegisterListener("IMBALevelReward_MaelStromEffect", function(...) return IMBALevelRewards:ChangeMaelStromEffect(...) end)
CustomGameEventManager:RegisterListener("IMBALevelReward_MaelStromColor", function(...) return IMBALevelRewards:ChangeMaelStromColor(...) end)

function IMBALevelRewards:LoadAllPlayersLevel()
	for i=0, 23 do
		if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
			local function SetLevel(res)
				local result = res.Body
				local player_table = {}
				for str in string.gmatch(result, "%S+") do
					player_table[#player_table + 1] = str
				end
				player_table2 = {['imba_level'] = player_table[1], ['is_vip'] = player_table[2], ['hero_pfx'] = player_table[3], ['courier_pfx'] = player_table[4], ['ward_pfx'] = player_table[5], ['maelstrom_pfx'] = player_table[6], ['maelstrom_color'] = player_table[7], ['shiva_pfx'] = player_table[8], ['sheep_pfx'] = player_table[9], ['radiance_pfx'] = player_table[10], ['blink_pfx'] = player_table[11], ['win_streak'] = player_table[12], ['win'] = player_table[13], ['lose'] = player_table[14], ['penalize'] = player_table[15]}
				CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(i), player_table2)
				local announce_table = {['times'] = tonumber(player_table[12]) + 2}
				CustomNetTables:SetTableValue("imba_level_rewards", "player_announce_"..tostring(i), announce_table)
				--PrintTable(player_table2)
			end
			IMBA:SendHTTPRequest("imba_get_player_level.php", {["steamid_64"] = tostring(PlayerResource:GetSteamID(i))}, -40, SetLevel)
		end
	end
end

function IMBALevelRewards:AnnounceIMBALevel(unused, kv)
	local pID = kv.PlayerID
	local text = kv.txt
	local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_announce_"..tostring(pID))
	player_table['times'] = player_table['times'] - 1
	if player_table['times'] >= 0 then
		GameRules:SendCustomMessage(text, 0, 0)
		CustomNetTables:SetTableValue("imba_level_rewards", "player_announce_"..tostring(pID), player_table)
	end
end

function IMBALevelRewards:ChangeHeroEffect(unused, kv)
	local pfxType = kv.type
	local pfxID = kv.id
	local pID = kv.PlayerID
	local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[pID + 1]
	if hero then
		local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
		player_table['hero_pfx'] = pfxID
		CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
		if pfxType == "disable" then
			if hero.imba_level_pfx then
				ParticleManager:DestroyParticle(hero.imba_level_pfx, true)
				ParticleManager:ReleaseParticleIndex(hero.imba_level_pfx)
				hero.imba_level_pfx = nil
			end
		else
			local color = HEXConvertToRGB(pfxType)
			color = Vector(color[1], color[2], color[3])
			if hero.imba_level_pfx then
				ParticleManager:SetParticleControl(hero.imba_level_pfx, 15, color)
			else
				local pfx_name = "particles/imba_level_particle/ti8_hero_effect.vpcf"
				local steamid = tonumber(tostring(PlayerResource:GetSteamID(pID)))
				if steamid == 76561198097609945 or steamid == 76561198100269546 or steamid == 76561198361355161 then
					pfx_name = "particles/imba_level_particle/ti7_hero_effect.vpcf"
				end
				hero.imba_level_pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, hero)
				ParticleManager:SetParticleControl(hero.imba_level_pfx, 15, color)
			end
		end
	end
end

function IMBALevelRewards:ChangeCourierEffect(unused, kv)
	local pfxType = kv.type
	local pfxID = kv.id
	local pID = kv.PlayerID
	local courier = CDOTA_PlayerResource.IMBA_PLAYER_COURIER[pID + 1]
	if courier then
		local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
		player_table['courier_pfx'] = pfxID
		CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
		if pfxType == "disable" then
			if courier.imba_level_pfx then
				ParticleManager:DestroyParticle(courier.imba_level_pfx, true)
				ParticleManager:ReleaseParticleIndex(courier.imba_level_pfx)
				courier.imba_level_pfx = nil
			end
		else
			if courier.imba_level_pfx then
				ParticleManager:DestroyParticle(courier.imba_level_pfx, true)
				ParticleManager:ReleaseParticleIndex(courier.imba_level_pfx)
				courier.imba_level_pfx = ParticleManager:CreateParticle(pfxType, PATTACH_ABSORIGIN_FOLLOW, courier)
			else
				courier.imba_level_pfx = ParticleManager:CreateParticle(pfxType, PATTACH_ABSORIGIN_FOLLOW, courier)
			end
		end
	end
end

function IMBALevelRewards:ChangeWardEffect(unused, kv)
	local pfxID = kv.id
	local pID = kv.PlayerID
	local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
	player_table['ward_pfx'] = pfxID
	CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
end

function IMBALevelRewards:ChangeMaelStromEffect(unused, kv)
	local pfxID = kv.id
	local pID = kv.PlayerID
	local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
	player_table['maelstrom_pfx'] = pfxID
	CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
	local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[pID + 1]
	if hero then
		local unit = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false)
		for i=1, #unit do
			if unit[i].GetUnitName and unit[i]:GetPlayerOwnerID() == pID then
				local buff = unit[i]:FindAllModifiersByName("modifier_imba_maelstrom_passive")
				local buff2 = unit[i]:FindAllModifiersByName("modifier_imba_mjollnir_passive")
				for j=1, #buff do
					buff[j]:OnCreated()
				end
				for k=1, #buff2 do
					buff2[k]:OnCreated()
				end
			end
		end
	end
end

function IMBALevelRewards:ChangeMaelStromColor(unused, kv)
	local pfxID = kv.id
	local pID = kv.PlayerID
	local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
	player_table['maelstrom_color'] = pfxID
	CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
	if kv.color then
		local color_table = HEXConvertToRGB(kv.color)
		local color = Vector(color_table[1], color_table[2], color_table[3])
		CustomNetTables:SetTableValue("imba_item_color", "maelstrom_color"..tostring(pID), {r = color_table[1], g = color_table[2], b = color_table[3]})
	else
		CustomNetTables:SetTableValue("imba_item_color", "maelstrom_color"..tostring(pID), {default = "default"})
	end
	local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[pID + 1]
	if hero then
		local unit = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false)
		for i=1, #unit do
			if unit[i].GetUnitName and unit[i]:GetPlayerOwnerID() == pID then
				local buff = unit[i]:FindAllModifiersByName("modifier_imba_maelstrom_unique")
				local buff2 = unit[i]:FindAllModifiersByName("modifier_imba_mjollnir_unique")
				for j=1, #buff do
					buff[j]:OnCreated()
				end
				for k=1, #buff2 do
					buff2[k]:OnCreated()
				end
			end
		end
	end
end