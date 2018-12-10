
-- Adds [stack_amount] stacks to a modifier
function AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
	if unit:HasModifier(modifier) then
		if refresh then
			ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		end
		unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
	else
		ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		unit:SetModifierStackCount(modifier, ability, stack_amount)
	end
end

-- Adds [stack_amount] stacks to a lua-based modifier
function AddStacksLua(ability, caster, unit, modifier, stack_amount, refresh)
	if unit:HasModifier(modifier) then
		if refresh then
			unit:AddNewModifier(caster, ability, modifier, {})
		end
		unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
	else
		unit:AddNewModifier(caster, ability, modifier, {})
		unit:SetModifierStackCount(modifier, ability, stack_amount)
	end
end

-- Removes [stack_amount] stacks from a modifier
function RemoveStacks(ability, unit, modifier, stack_amount)
	if unit:HasModifier(modifier) then
		if unit:GetModifierStackCount(modifier, ability) > stack_amount then
			unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, ability) - stack_amount)
		else
			unit:RemoveModifierByName(modifier)
		end
	end
end

-- Switches one skill with another
function SwitchAbilities(hero, added_ability_name, removed_ability_name, keep_level, keep_cooldown)
	local removed_ability = hero:FindAbilityByName(removed_ability_name)
	local level = removed_ability:GetLevel()
	local cooldown = removed_ability:GetCooldownTimeRemaining()
	hero:RemoveAbility(removed_ability_name)
	hero:AddAbility(added_ability_name)
	local added_ability = hero:FindAbilityByName(added_ability_name)
	
	if keep_level then
		added_ability:SetLevel(level)
	end
	
	if keep_cooldown then
		added_ability:StartCooldown(cooldown)
	end
end

-- Removes unwanted passive modifiers from illusions upon their creation
function IllusionPassiveRemover( keys )
	local target = keys.target
	local modifier = keys.modifier

	if target:IsIllusion() or not target:GetPlayerOwner() then
		target:RemoveModifierByName(modifier)
	end
end

function ApplyDataDrivenModifierWhenPossible( caster, target, ability, modifier_name)
	Timers:CreateTimer(0, function()
		if target:IsOutOfGame() or target:IsInvulnerable() then
			return 0.1
		else
			ability:ApplyDataDrivenModifier(caster, target, modifier_name, {})
		end			
	end)
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	A helper method that switches the removed_item item to one with the inputted name.
================================================================================================================= ]]
function SwapToItem(caster, removed_item, added_item)
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = caster:GetItemInSlot(i)
		if current_item == nil then
			caster:AddItem(CreateItem("item_imba_dummy", caster, caster))
		end
	end
	
	caster:RemoveItem(removed_item)
	caster:AddItem(CreateItem(added_item, caster, caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_imba_dummy" then
				caster:RemoveItem(current_item)
			end
		end
	end
end



function DebugPrint(...)
	--local spew = Convars:GetInt('barebones_spew') or -1
	--if spew == -1 and BAREBONES_DEBUG_SPEW then
	--spew = 1
	--end

	--if spew == 1 then
	--print(...)
	--end
end

function DebugPrintTable(...)
	--local spew = Convars:GetInt('barebones_spew') or -1
	--if spew == -1 and BAREBONES_DEBUG_SPEW then
	--spew = 1
	--end

	--if spew == 1 then
	--PrintTable(...)
	--end
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
	table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
	-- Ignore FDesc
	if v ~= 'FDesc' then
		local value = t[v]

		if type(value) == "table" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..":")
		PrintTable (value, indent + 2, done)
		elseif type(value) == "userdata" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
		else
		if t.FDesc and t.FDesc[v] then
			print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
		else
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		end
		end
	end
	end
end

key = ""
function GoodPrintTable(table , level)
	level = level or 1
	local indent = ""
	for i = 1, level do
		indent = indent.."  "
	end

	if key ~= "" then
		print(indent..key.." ".."=".." ".."{")
	else
		print(indent .. "{")
	end

	key = ""
	for k,v in pairs(table) do
		if type(v) == "table" then
			key = k
			PrintTable(v, level + 1)
		else
			local content = string.format("%s%s = %s", indent .. "  ",tostring(k), tostring(v))
			print(content)  
		end
	end
	print(indent .. "}")
end


-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

-- Returns a random value from a non-array table
function RandomFromTable(table)
	if #table == 0 then return nil end
	return table[RandomInt(1,#table)]
end

-------------------------------------------------------------------------------------------------
-- IMBA: custom utility functions
-------------------------------------------------------------------------------------------------

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	A helper method that switches the removed_item item to one with the inputted name.
================================================================================================================= ]]
function SwapToItem(caster, removed_item, added_item)
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = caster:GetItemInSlot(i)
		if current_item == nil then
			caster:AddItem(CreateItem("item_imba_dummy", caster, caster))
		end
	end
	
	caster:RemoveItem(removed_item)
	caster:AddItem(CreateItem(added_item, caster, caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_imba_dummy" then
				caster:RemoveItem(current_item)
			end
		end
	end
end

-- 100% kills a unit. Activates death-preventing modifiers, then removes them. Does not killsteal from Reaper's Scythe.
function TrueKill(caster, target, ability)
	
	-- Shallow Grave is peskier
	target:RemoveModifierByName("modifier_imba_shallow_grave")

	-- Extremely specific blademail interaction because fuck everything
	if caster:HasModifier("modifier_item_blade_mail_reflect") then
		target:RemoveModifierByName("modifier_imba_purification_passive")
	end

	-- Deals lethal damage in order to trigger death-preventing abilities... Except for Reincarnation
	if not ( target:HasModifier("modifier_imba_reincarnation") or target:HasModifier("modifier_imba_reincarnation_scepter") ) then
		target:Kill(ability, caster)
	end

	-- Removes the relevant modifiers
	target:RemoveModifierByName("modifier_invulnerable")
	target:RemoveModifierByName("modifier_imba_shallow_grave")
	target:RemoveModifierByName("modifier_aphotic_shield")
	target:RemoveModifierByName("modifier_imba_spiked_carapace")
	target:RemoveModifierByName("modifier_borrowed_time")
	target:RemoveModifierByName("modifier_imba_centaur_return")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_unique")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_active")
	target:RemoveModifierByName("modifier_item_crimson_guard_unique")
	target:RemoveModifierByName("modifier_item_crimson_guard_active")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_unique")
	target:RemoveModifierByName("modifier_item_vanguard_unique")
	target:RemoveModifierByName("modifier_item_imba_initiate_robe_stacks")
	target:RemoveModifierByName("modifier_imba_cheese_death_prevention")
	target:RemoveModifierByName("modifier_item_imba_rapier_cursed_unique")
	target:RemoveModifierByName("modifier_imba_reincarnation_scepter_aura")
	target:RemoveModifierByName("modifier_imba_vampiric_aura_effect")
	


	-- Kills the target
	target:Kill(ability, caster)
end

-- Checks if a unit is near units of a certain class not on its team
function IsNearEnemyClass(unit, radius, class)
	local class_units = Entities:FindAllByClassnameWithin(class, unit:GetAbsOrigin(), radius)

	for _,found_unit in pairs(class_units) do
		if found_unit:GetTeam() ~= unit:GetTeam() then
			return true
		end
	end
	
	return false
end

-- Checks if a unit is near units of a certain class on the same team
function IsNearFriendlyClass(unit, radius, class)
	local class_units = Entities:FindAllByClassnameWithin(class, unit:GetAbsOrigin(), radius)

	for _,found_unit in pairs(class_units) do
		if found_unit:GetTeam() == unit:GetTeam() then
			return true
		end
	end
	
	return false
end

function IsNearFriendlyEntityPoint(pos, radius, class)
	local class_units = Entities:FindAllByNameWithin(class, pos, radius)

	if #class_units > 0 then
		return true
	end
	
	return false
end

-- Returns if this unit is a fountain or not
function IsFountain( unit )
	if unit:GetName() == "ent_dota_fountain_bad" or unit:GetName() == "ent_dota_fountain_good" then
		return true
	end
	
	return false
end

-- Returns true if the target is hard disabled
function IsHardDisabled( unit )
	if unit:IsStunned() or unit:IsHexed() or unit:IsNightmared() or unit:IsOutOfGame() or unit:HasModifier("modifier_axe_berserkers_call") then
		return true
	end

	return false
end

-- Precaches an unit, or, if something else is being precached, enters it into the precache queue
function PrecacheUnitWithQueue( unit_name )
	
	Timers:CreateTimer(0, function()

		-- If something else is being precached, wait two seconds
		if UNIT_BEING_PRECACHED then
			return 2

		-- Otherwise, start precaching and block other calls from doing so
		else
			UNIT_BEING_PRECACHED = true
			PrecacheUnitByNameAsync(unit_name, function(...) end)

			-- Release the queue after one second
			Timers:CreateTimer(2, function()
				UNIT_BEING_PRECACHED = false
			end)
		end
	end)
end

-- Simulates attack speed cap removal to a single unit through BAT manipulation
function IncreaseAttackSpeedCap(unit, new_cap)

	-- Fetch original BAT if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit:GetBaseAttackTime()
	end

	-- Get current attack speed, limited to new_cap
	local buffs = unit:FindAllModifiers()
	local as = 0
	for _, buff in pairs(buffs) do
		if buff.GetModifierAttackSpeedBonus_Constant then
			as = as + buff:GetModifierAttackSpeedBonus_Constant()
		end
	end
	if unit:IsHero() then
		local agi_as = GameRules:GetGameModeEntity():GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, unit)
		as = as + agi_as * unit:GetAgility()
	end
	local current_as = math.min(as, new_cap)

	-- Should we reduce BAT?
	if current_as > MAXIMUM_ATTACK_SPEED then
		local new_bat = MAXIMUM_ATTACK_SPEED / current_as * unit:GetDefaultBAT()
		unit:SetBaseAttackTime(new_bat)
	else
		RevertAttackSpeedCap(unit)
	end
end

-- Returns a unit's attack speed cap
function RevertAttackSpeedCap( unit )

	-- Return to original BAT
	unit:SetBaseAttackTime(unit:GetDefaultBAT())

end

-- Sets a creature's max health to [health]
function SetCreatureHealth(unit, health, update_current_health)

	unit:SetBaseMaxHealth(health)
	unit:SetMaxHealth(health)

	if update_current_health then
		unit:SetHealth(health)
	end
end

function RemoveWearables( hero )

	-- Setup variables
	Timers:CreateTimer(0.1, function()
		hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
		local model = hero:FirstMoveChild()
		while model ~= nil do
			if model:GetClassname() == "dota_item_wearable" then
				model:AddEffects(EF_NODRAW) -- Set model hidden
				table.insert(hero.hiddenWearables, model)
			end
			model = model:NextMovePeer()
		end
	end)
end

function ShowWearables( event )
  local hero = event.caster

  for i,v in pairs(hero.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

function GetBaseRangedProjectileName( unit )
	local unit_name = unit:GetUnitName()
	unit_name = string.gsub(unit_name, "dota", "imba")
	local unit_table = unit:IsHero() and GameRules.HeroKV[unit_name] or GameRules.UnitKV[unit_name]
	return unit_table and unit_table["ProjectileModel"] or ""
end

function IsUninterruptableForcedMovement( unit )
	
	-- List of uninterruptable movement modifiers
	local modifier_list = {
		"modifier_spirit_breaker_charge_of_darkness",
		"modifier_magnataur_skewer_movement",
		"modifier_invoker_deafening_blast_knockback",
		"modifier_knockback",
		"modifier_item_forcestaff_active",
		"modifier_shredder_timber_chain",
		"modifier_batrider_flaming_lasso",
		"modifier_imba_leap_self_root",
		"modifier_faceless_void_chronosphere_freeze",
		"modifier_storm_spirit_ball_lightning",
		"modifier_morphling_waveform"
	}

	-- Iterate through the list
	for _,modifier_name in pairs(modifier_list) do
		if unit:HasModifier(modifier_name) then
			return true
		end
	end

	return false
end


-- Safely modify BAT while storing the unit's original value
function ModifyBAT(unit, modify_percent, modify_flat)

	-- Fetch base BAT if necessary
	if not unit.unmodified_bat then
		unit.unmodified_bat = unit:GetBaseAttackTime()
	end

	-- Create the current BAT variable if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit.unmodified_bat
	end

	-- Create the percent modifier variable if necessary
	if not unit.percent_bat_modifier then
		unit.percent_bat_modifier = 1
	end

	-- Create the flat modifier variable if necessary
	if not unit.flat_bat_modifier then
		unit.flat_bat_modifier = 0
	end

	-- Update BAT percent modifiers
	unit.percent_bat_modifier = unit.percent_bat_modifier * (100 + modify_percent) / 100

	-- Update BAT flat modifiers
	unit.flat_bat_modifier = unit.flat_bat_modifier + modify_flat

	-- Unmodified BAT special exceptions
	if unit:GetUnitName() == "npc_dota_hero_alchemist" then
		return nil
	end
	
	-- Update modifier BAT
	unit.current_modified_bat = (unit.unmodified_bat + unit.flat_bat_modifier) * unit.percent_bat_modifier

	-- Update unit's BAT
	unit:SetBaseAttackTime(unit.current_modified_bat)

end

-- Override all BAT modifiers and return the unit to its base value
function RevertBAT( unit )

	-- Fetch base BAT if necessary
	if not unit.unmodified_bat then
		unit.unmodified_bat = unit:GetBaseAttackTime()
	end

	-- Create the current BAT variable if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit.unmodified_bat
	end

	-- Create the percent modifier variable if necessary
	if not unit.percent_bat_modifier then
		unit.percent_bat_modifier = 1
	end

	-- Create the flat modifier variable if necessary
	if not unit.flat_bat_modifier then
		unit.flat_bat_modifier = 0
	end

	-- Reset variables
	unit.percent_bat_modifier = 1
	unit.flat_bat_modifier = 0

	-- Reset BAT
	unit:SetBaseAttackTime(unit.unmodified_bat)

end

-- Detect hero-creeps with an inventory, like warlock golems or lone druid's bear
function IsHeroCreep( unit )
	return (unit:IsConsideredHero() and unit:IsCreep())
end

-- Changes the time of the day temporarily, memorizing the original time of the day to return to
function SetTimeOfDayTemp(time, duration)

	-- Store the original time of the day, if necessary
	local game_entity = GameRules:GetGameModeEntity()
	if not game_entity.tod_original_time then
		game_entity.tod_original_time = GameRules:GetTimeOfDay()
	end

	-- Initialize the time modification states, if necessary
	if not game_entity.tod_future_seconds then
		game_entity.tod_future_seconds = {}

		-- Start loop function
		Timers:CreateTimer(1, function()
			SetTimeOfDayTempLoop()
		end)
	end

	-- Store future time modification states
	for i = 1, duration do
		game_entity.tod_future_seconds[i] = time
	end

	-- Set the time of the day
	GameRules:SetTimeOfDay(time)
end

-- Auxiliary function to the one above
function SetTimeOfDayTempLoop()

	-- If there are no future time modification states, stop looping
	local game_entity = GameRules:GetGameModeEntity()
	if not game_entity.tod_future_seconds then
		return nil

	-- Else, move states one second forward
	elseif #game_entity.tod_future_seconds > 1 then
		for i = 1, (#game_entity.tod_future_seconds - 1) do
			game_entity.tod_future_seconds[i] = game_entity.tod_future_seconds[i + 1]
		end
		game_entity.tod_future_seconds[#game_entity.tod_future_seconds] = nil

		-- Keep the loop going
		GameRules:SetTimeOfDay(game_entity.tod_future_seconds[1])
		Timers:CreateTimer(1, function()
			SetTimeOfDayTempLoop()
		end)

	-- Else, the duration is over; restore the original time of the day, and exit the loop
	else
		game_entity.tod_future_seconds = nil
		Timers:CreateTimer(1, function()
			GameRules:SetTimeOfDay(game_entity.tod_original_time)
			game_entity.tod_original_time = nil
		end)
	end
end

-- Initialize Physics library on this target
function InitializePhysicsParameters(unit)

	if not IsPhysicsUnit(unit) then
		Physics:Unit(unit)
		unit:SetPhysicsVelocityMax(600)
		unit:PreventDI()
	end
end

-- Check if an unit is near the enemy fountain
function IsNearEnemyFountain(location, team, distance)

	local fountain_loc
	if team == DOTA_TEAM_GOODGUYS then
		fountain_loc = Vector(7472, 6912, 512)
	else
		fountain_loc = Vector(-7456, -6938, 528)
	end

	if (fountain_loc - location):Length2D() <= distance then
		return true
	end

	return false
end

-- Reaper's Scythe kill credit redirection
function TriggerNecrolyteReaperScytheDeath(target, caster)

	-- Find the Reaper's Scythe ability
	local ability = caster:FindAbilityByName("imba_necrolyte_reapers_scythe")
	if not ability then return nil end

	-- Attempt to kill the target
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = target:GetHealth(), damage_type = DAMAGE_TYPE_PURE})
end

function GetRandomPosition2D(vPosition, fRadius)
	local newPos = vPosition + Vector(1,0,0) * math.random(0-fRadius, fRadius)
	return RotatePosition(vPosition, QAngle(0,math.random(-360,360),0), newPos)
end

function CDOTA_Modifier_Lua:CheckMotionControllers()
	local parent = self:GetParent()
	local modifier_priority = self:GetMotionControllerPriority()
	local is_motion_controller = false
	local motion_controller_priority
	local found_modifier_handler

	local non_imba_motion_controllers ={
	"modifier_morphling_waveform",
	"modifier_morphling_adaptive_strike",
	"modifier_ember_spirit_fire_remnant",
	"modifier_monkey_king_bounce_leap",
	"modifier_batrider_flaming_lasso",
	"modifier_earth_spirit_boulder_smash",
	"modifier_earth_spirit_geomagnetic_grip",
	"modifier_tiny_toss",
	"modifier_tusk_walrus_punch_air_time",
	"modifier_rattletrap_hookshot",
	"modifier_rattletrap_cog_push",
	"modifier_beastmaster_prima_roar_push",
	"modifier_brewmaster_storm_cyclone",
	"modifier_dark_seer_vacuum",
	"modifier_eul_cyclone",
	"modifier_earth_spirit_rolling_boulder_caster",
	"modifier_huskar_life_break_charge",
	"modifier_invoker_deafening_blast_knockback",
	"modifier_invoker_tornado",
	"modifier_item_forcestaff_active",
	"modifier_rattletrap_hookshot",
	"modifier_phoenix_icarus_dive",
	"modifier_shredder_timber_chain",
	"modifier_slark_pounce",
	"modifier_spirit_breaker_charge_of_darkness",
	"modifier_tusk_walrus_punch_air_time",
	"modifier_earthshaker_enchant_totem_leap"
	}

	-- Fetch all modifiers
	local modifiers = parent:FindAllModifiers()	

	for _,modifier in pairs(modifiers) do		
		-- Ignore the modifier that is using this function
		if self ~= modifier then			

			-- Check if this modifier is assigned as a motion controller
			if modifier.IsMotionController then
				if modifier:IsMotionController() then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- Get the motion controller priority
					motion_controller_priority = modifier:GetMotionControllerPriority()
					if modifier.IsStunDebuff and modifier:IsStunDebuff() then
						motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST + 1
					end
					-- Stop iteration					
					break
				end
			end

			-- If not, check on the list
			for _,non_imba_motion_controller in pairs(non_imba_motion_controllers) do				
				if modifier:GetName() == non_imba_motion_controller then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- We assume that vanilla controllers are the highest priority
					motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST

					-- Stop iteration					
					break
				end
			end
		end
	end

	-- If this is a motion controller, check its priority level
	if is_motion_controller and motion_controller_priority then

		-- If the priority of the modifier that was found is higher, override
		if motion_controller_priority > modifier_priority then			
			return false

		-- If they have the same priority levels, check which of them is older and remove it
		elseif motion_controller_priority == modifier_priority then			
			if found_modifier_handler:GetCreationTime() >= self:GetCreationTime() then				
				return false
			else				
				found_modifier_handler:Destroy()
				return true
			end

		-- If the modifier that was found is a lower priority, destroy it instead
		else			
			parent:InterruptMotionControllers(true)
			found_modifier_handler:Destroy()
			return true
		end
	else
		-- If no motion controllers were found, apply
		return true
	end
end

-- Finds units only on the outer layer of a ring
function FindUnitsInRing(teamNumber, position, cacheUnit, ring_radius, ring_width, teamFilter, typeFilter, flagFilter, order, canGrowCache)
	-- First checks all of the units in a radius
	local all_units	= FindUnitsInRadius(teamNumber, position, cacheUnit, ring_radius, teamFilter, typeFilter, flagFilter, order, canGrowCache)
	
	-- Then builds a table composed of the units that are in the outer ring, but not in the inner one.
	local outer_ring_units	=	{}

	for _,unit in pairs(all_units) do
		-- Custom function, checks if the unit is far enough away from the inner radius
		if CalculateDistance(unit:GetAbsOrigin(), position) >= ring_radius - ring_width then
			table.insert(outer_ring_units, unit)
		end
	end

	return outer_ring_units
end

-- Cleave-like cone search - returns the units in front of the caster in a cone.
function FindUnitsInCone(teamNumber, vDirection, vPosition, startRadius, endRadius, flLength, hCacheUnit, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
	local enemies = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, endRadius + flLength, targetTeam, targetUnit, targetFlags, findOrder, bCache )
	local unitTable = {}
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			if enemy ~= nil then
				local vToPotentialTarget = enemy:GetOrigin() - vPosition
				local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
				local enemy_distance_from_caster = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )
				
				-- Author of this "increase over distance": Fudge, pretty proud of this :D 
				
				-- Calculate how much the width of the check can be higher than the starting point
				local max_increased_radius_from_distance = endRadius - startRadius
				
				-- Calculate how close the enemy is to the caster, in comparison to the total distance
				local pct_distance = enemy_distance_from_caster / flLength
				
				-- Calculate how much the width should be higher due to the distance of the enemy to the caster.
				local radius_increase_from_distance = max_increased_radius_from_distance * pct_distance
				
				if ( flSideAmount < startRadius + radius_increase_from_distance ) and ( enemy_distance_from_caster > 0.0 ) and ( enemy_distance_from_caster < flLength ) then
					table.insert(unitTable, enemy)
				end
			end
		end
	end
	return unitTable
end

function CDOTABaseAbility:HasFireSoulActive()
	return self:GetCaster():HasModifier("modifier_imba_fiery_soul_active")
end

function CDOTA_BaseNPC:GetCastRangeBonus()
	local caster = self
	local range = 0
	local buffs = caster:FindAllModifiers()
	local range_unique = {}
	--lua buffs
	for _, buff in pairs(buffs) do
		if buff.GetModifierCastRangeBonus then
			table.insert(range_unique, buff:GetModifierCastRangeBonus())
		end
		if buff.GetModifierCastRangeBonusStacking then
			range = range + buff:GetModifierCastRangeBonusStacking()
		end
	end
	table.sort(range_unique)
	if #range_unique > 0 then
		range = range + range_unique[#range_unique]
	end
	--lua buffs

	--Talent buff(Must be named as "special_bonus_cast_range_XXX" and special value as "value")
	for i=0, 23 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetLevel() > 0 and string.find(ability:GetAbilityName(), "special_bonus_cast_range") then
			range = range + ability:GetSpecialValueFor("value")
		end
	end
	--Talent buff(Must be named as "special_bonus_cast_range_XXX" and special value as "value")
	return range
end

function CDOTA_BaseNPC:GetCooldownReduction()
	local caster = self
	local cdr = 0
	local buffs = caster:FindAllModifiers()
	local cdr_unique = {}
	--lua buffs
	for _, buff in pairs(buffs) do
		if buff.GetModifierPercentageCooldown then
			table.insert(cdr_unique, buff:GetModifierPercentageCooldown())
		end
		if buff.GetModifierPercentageCooldownStacking then
			cdr = cdr + buff:GetModifierPercentageCooldownStacking()
		end
	end

	for i=0, 23 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetLevel() > 0 and string.find(ability:GetAbilityName(), "special_bonus_cooldown_reduction") then
			cdr = cdr + ability:GetSpecialValueFor("value")
		end
	end

	table.sort(cdr_unique)
	if #cdr_unique > 0 then
		cdr = cdr + (cdr_unique[#cdr_unique] - cdr_unique[#cdr_unique] * (cdr / 100))
	end
	--lua buffs

	return math.min(cdr, 100)
end

function CDOTA_BaseNPC:GetIncomingHealAmp()
	local caster = self
	local buffs = caster:FindAllModifiers()
	local heal = 0
	for _, buff in pairs(buffs) do
		if buff.GetIMBAModifierIncomingHealAmp_Percentage and type(buff:GetIMBAModifierIncomingHealAmp_Percentage()) == "number" then
			heal = heal + buff:GetIMBAModifierIncomingHealAmp_Percentage()
		end
	end

	return heal
end

function CDOTA_BaseNPC_Hero:GetRespawnTimeChangeNormal()
	local caster = self
	local buffs = caster:FindAllModifiers()
	local respawn = 0
	local respawn_unique = {}
	for _, buff in pairs(buffs) do
		if buff.GetModifierStackingRespawnTime and type(buff:GetModifierStackingRespawnTime()) == "number" then
			respawn = respawn + buff:GetModifierStackingRespawnTime()
		end
		if buff.GetModifierConstantRespawnTime and type(buff:GetModifierConstantRespawnTime()) == "number" then
			respawn_unique[#respawn_unique + 1] = buff:GetModifierConstantRespawnTime()
		end
	end
	table.sort(respawn_unique)
	if #respawn_unique > 0 then
		respawn = respawn + respawn_unique[#respawn_unique]
	end

	for i=0, 23 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetLevel() > 0 and string.find(ability:GetAbilityName(), "special_bonus_respawn_reduction") then
			respawn = respawn - ability:GetSpecialValueFor("value")
		end
	end
	return respawn
end

function IsInTable(value, table)
	for i=0, #table do
		if table[i] == value then
			return true
		end
	end
	return false
end

function IsEnemy(unit1, unit2)
	if unit1:GetTeamNumber() == unit2:GetTeamNumber() then
		return false
	else
		return true
	end
end

function CDOTA_BaseNPC:TriggerStandardTargetSpell(ability)
	if IsEnemy(self, ability:GetCaster()) then
		self:TriggerSpellReflect(ability)
		return self:TriggerSpellAbsorb(ability)
	end
	return false
end

function CDOTA_BaseNPC:AddNewModifierWhenPossible(hCaster, hAbility, pszScriptName, hModifierTable)
	Timers:CreateTimer(0.1, function()
		if not self:IsAlive() or (IsEnemy(self, hCaster) and self:IsInvulnerable()) then
			return 0.1
		else
			self:AddNewModifier(hCaster, hAbility, pszScriptName, hModifierTable)
		end			
	end)
end

function CDOTA_BaseNPC:AddNewEarthSpiritModifier(hCaster, hAbility, pszScriptName, hModifierTable)
	local temps = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local enemies = {}
	for _, temp in pairs(temps) do
		if temp:HasModifier("modifier_imba_magnetize_debuff") then
			enemies[#enemies + 1] = temp
		end
	end
	if not IsInTable(self, enemies) then
		table.insert(enemies, self)
	end
	local buffs = {}
	for _, enemy in pairs(enemies) do
		buffs[#buffs + 1] = enemy:AddNewModifier(hCaster, hAbility, pszScriptName, hModifierTable)
	end
	return buffs
end

function CDOTA_BaseNPC_Hero:GetIMBARespawnTime()
	
	local victim_respawn = self
	
	local respawn_time = 0

	respawn_time = victim_respawn:GetLevel() * HERO_LEVEL_RESPAWN_MULTIPLY

	respawn_time = respawn_time * (HERO_RESPAWN_TIME_MULTIPLIER / 100)

	respawn_time = respawn_time + victim_respawn:GetRespawnTimeChangeNormal()

	respawn_time = (math.max(respawn_time, 1))

	return respawn_time
end

function IsHeroDamage(attacker, damage)
	if damage > 0 then
		if attacker:GetName() == "npc_dota_roshan" or attacker:IsControllableByAnyPlayer() or attacker:GetName() == "npc_dota_shadowshaman_serpentward" then
			return true
		else
			return false
		end
	end
end

function CDOTA_BaseNPC:GetDefaultBAT()
	local BAT = 0
	if self:IsHero() then
		BAT = HeroKV[self:GetName()]['AttackRate'] or HeroKVBase[self:GetName()]['AttackRate']
	else
		BAT = UnitKV[self:GetName()]['AttackRate'] or UnitKVBase[self:GetName()]['AttackRate']
	end
	return BAT
end

function CDOTA_BaseNPC:AddModifierStacks(hCaster, hAbility, sModifierName, tModifierTable, iStacks, bStatusResis, bRefresh)
	local buff = nil
	if self:HasModifier(sModifierName) then
		buff = self:FindModifierByName(sModifierName)
		buff:SetStackCount(buff:GetStackCount() + iStacks)
		if bRefresh then
			buff:SetDuration(buff:GetDuration(), true)
		end
	else
		buff = self:AddNewModifier(hCaster, hAbility, sModifierName, tModifierTable)
		if buff then
			buff:SetStackCount(buff:GetStackCount() + iStacks)
		end
	end
	return buff
end

function FindStoneRemnant(pos, radius)
	local stones = Entities:FindAllInSphere(pos, radius)
	local stone = nil
	for _, sto in pairs(stones) do
		if (string.find(sto:GetName(), "npc_")) and sto:HasModifier("modifier_imba_stone_remnant_status") then
			stone = sto
			break
		end
	end
	return stone
end

function CDOTA_BaseNPC:GetMoveSpeedIncrease()
	local buffs = self:FindAllModifiers()
	local baseSpeed = self:GetBaseMoveSpeed()
	local agiSpeed = (GameRules:GetGameModeEntity():GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT, self) * self:GetAgility()) * baseSpeed
	local constant = 0
	local percentage = 0
	local pct_u_1 = {}
	local pct_u_2 = {}
	local pct_boots = {}
	local con_u_2 = {}
	for i=1, #buffs do
		local buff = buffs[i]
		if buff.GetModifierMoveSpeedBonus_Constant then
			constant = constant + buff:GetModifierMoveSpeedBonus_Constant()
		end
		if buff.GetModifierMoveSpeedBonus_Percentage then
			percentage = percentage + buff:GetModifierMoveSpeedBonus_Percentage()
		end
		if buff.GetModifierMoveSpeedBonus_Percentage_Unique then
			pct_u_1[#pct_u_1 + 1] = buff:GetModifierMoveSpeedBonus_Percentage_Unique()
		end
		if buff.GetModifierMoveSpeedBonus_Percentage_Unique_2 then
			pct_u_2[#pct_u_2 + 1] = buff:GetModifierMoveSpeedBonus_Percentage_Unique_2()
		end
		if buff.GetModifierMoveSpeedBonus_Special_Boots then
			pct_boots[#pct_boots + 1] = buff:GetModifierMoveSpeedBonus_Special_Boots()
		end
		if buff.GetModifierMoveSpeedBonus_Special_Boots_2 then
			con_u_2[#con_u_2 + 1] = buff:GetModifierMoveSpeedBonus_Special_Boots_2()
		end
	end
	for i=0, 5 do
		local item = self:GetItemInSlot(i)
		if item and (item:GetName() == "item_boots" or item:GetName() == "item_phase_boots" or item:GetName() == "item_travel_boots" or item:GetName() == "item_travel_boots_2" or item:GetName() == "item_power_treads" or item:GetName() == "item_imba_power_treads_2" or item:GetName() == "item_tranquil_boots") then
			pct_u_1[#pct_u_1 + 1] = item:GetSpecialValueFor("bonus_movement_speed")
		end
	end
	local sort = table.sort
	sort(pct_u_1)
	sort(pct_u_2)
	sort(pct_boots)
	sort(con_u_2)
	percentage = #pct_u_1 > 0 and percentage + pct_u_1[#pct_u_1] or percentage
	percentage = #pct_u_2 > 0 and percentage + pct_u_2[#pct_u_2] or percentage
	percentage = #pct_boots > 0 and percentage + pct_boots[#pct_boots] or percentage
	constant = #con_u_2 > 0 and constant + con_u_2[#con_u_2] or constant
	local speed_con = baseSpeed + constant
	return (constant + agiSpeed + speed_con * (percentage / 100))
end
