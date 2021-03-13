local NewTable = {}
for _, k in ipairs({"loud", "stealth"}) do
	for _, v in ipairs(tweak_data.crime_spree.modifiers[k]) do
		table.insert(NewTable, v.id)
	end
end

local OldFunc1 = CrimeSpreeManager._setup_modifiers
function CrimeSpreeManager:_setup_modifiers()
	local OldExtraFunc1, OldExtraFunc2 = _G.ModifierEnemyHealthAndDamage.new, managers.modifiers.add_modifier
	function _G.ModifierEnemyHealthAndDamage:new()
		return
	end
	function managers.modifiers:add_modifier(modifier, ...)
		if modifier then
			return OldExtraFunc2(self, modifier, ...)
		end
	end
	OldFunc1(self)
	_G.ModifierEnemyHealthAndDamage.new, managers.modifiers.add_modifier = OldExtraFunc1, OldExtraFunc2
	if self:is_active() then
		return managers.modifiers:add_modifier(_G["ModifierEnemyHealthAndDamage"]:new(self:get_modifier_stack_data("ModifierEnemyHealthAndDamage")), "crime_spree")
	end
end

local OldFunc2 = CrimeSpreeManager.get_modifier_stack_data
function CrimeSpreeManager:get_modifier_stack_data(modifier_type)
	if modifier_type ~= "ModifierEnemyHealthAndDamage" then
		return OldFunc2(self, modifier_type)
	end
	local score = self._global.spree_level or 0
	local server_score = self._global.peer_spree_levels and self._global.peer_spree_levels[1] or 0
	local stack = math.max(math.floor((self:_is_host() and score or server_score) / tweak_data.crime_spree.modifier_levels.forced), 0)
	local modifiers = self:is_active() and self:server_active_modifiers() or self:active_modifiers()
	for _, active_data in ipairs(modifiers) do
		if active_data.id == tweak_data.crime_spree.modifiers.forced[1].id then
			if stack > active_data.level then
				if Network:is_server() then
					if active_data.level == 0 then
						self:send_crime_spree_modifier(nil, {id = active_data.id, level = stack}, true)
					else
						self:send_crime_spree_modifier(nil, {level = active_data.level + 1, SFM = stack}, true)
					end
				end
				active_data.level = stack
			end
			break
		end
	end
	local stack_data = OldFunc2(self, modifier_type)
	for key, _ in pairs(tweak_data.crime_spree.modifiers.forced[1].data) do
		stack_data[key] = tweak_data.crime_spree.modifiers.forced[1].data[key][1] * stack
	end
	return stack_data
end

function CrimeSpreeManager:active_modifiers()
	if not self._global.modifiers then
		self._global.modifiers = {}
	end
	if not self._global.modifiers.SFM then
		local score = self._global.spree_level or 0
		if score >= math.max(tweak_data.crime_spree.modifier_levels.loud * #tweak_data.crime_spree.modifiers.loud, tweak_data.crime_spree.modifier_levels.stealth * #tweak_data.crime_spree.modifiers.stealth) then
			self._global.modifiers = {}
			for i, modifier in ipairs(tweak_data.crime_spree.modifiers.loud) do
				table.insert(self._global.modifiers, {id = modifier.id, level = math.max(i-2, 1) * tweak_data.crime_spree.modifier_levels.loud})
			end
			for i, modifier in ipairs(tweak_data.crime_spree.modifiers.stealth) do
				table.insert(self._global.modifiers, {id = modifier.id, level = math.max(i-2, 1) * tweak_data.crime_spree.modifier_levels.stealth})
			end
		else
			local Checker = {}
			for k, v in ipairs(self._global.modifiers) do
				if table.contains(NewTable, v.id) and not Checker[v.id] then
					Checker[v.id] = true
				else
					table.insert(Checker, 1, k)
				end
			end
			for _, v in ipairs(Checker) do
				table.remove(self._global.modifiers, v)
			end
		end
		table.insert(self._global.modifiers, {id = tweak_data.crime_spree.modifiers.forced[1].id, level = math.floor(score / tweak_data.crime_spree.modifier_levels.forced)})
		self._global.modifiers.SFM = true
	end
	return self._global.modifiers
end

local OldFunc3 = CrimeSpreeManager.server_active_modifiers
function CrimeSpreeManager:server_active_modifiers()
	if self:_is_host() or self._global.server_modifiers and #self._global.server_modifiers ~= 0 then
		return OldFunc3(self)
	end
	local server_score = self._global.peer_spree_levels and self._global.peer_spree_levels[1] or 0
	self._global.server_modifiers = {{id = tweak_data.crime_spree.modifiers.forced[1].id, level = math.floor(server_score / tweak_data.crime_spree.modifier_levels.forced)}}
	return self._global.server_modifiers
end

local OldFunc4 = CrimeSpreeManager.modifiers_to_select
function CrimeSpreeManager:modifiers_to_select(table_name, ...)
	if table_name ~= "forced" then
		return OldFunc4(self, table_name, ...)
	end
	return 0
end

local OldFunc5 = CrimeSpreeManager.select_modifier
function CrimeSpreeManager:select_modifier(...)
	local OldExtraFunc = table.insert
	function table.insert(tbl, value)
		return OldExtraFunc(tbl, #tbl, value)
	end
	OldFunc5(self, ...)
	table.insert = OldExtraFunc
end

local OldFunc6 = CrimeSpreeManager.send_crime_spree_modifier
function CrimeSpreeManager:send_crime_spree_modifier(peer, modifier_data, ...)
	if not modifier_data then
		return
	end
	if type(modifier_data.SFM) == "number" then
		for i = modifier_data.level, (modifier_data.SFM - 1) do
			OldFunc6(self, peer, {id = tweak_data.crime_spree.repeating_modifiers.forced[1].id .. "SFM_" .. tostring(i), level = i}, ...)
		end
		return OldFunc6(self, peer, {id = tweak_data.crime_spree.repeating_modifiers.forced[1].id .. "SFM_" .. tostring(modifier_data.SFM), level = modifier_data.SFM}, ...)
	end
	if table.contains(NewTable, modifier_data.id) then
		return OldFunc6(self, peer, modifier_data, ...)
	end
	if modifier_data.id == tweak_data.crime_spree.modifiers.forced[1].id then
		if modifier_data.level ~= 0 then
			OldFunc6(self, peer, {id = modifier_data.id, level = 1}, ...)
			return self:send_crime_spree_modifier(peer, {level = 2, SFM = modifier_data.level}, ...)
		end
	end
end

local OldFunc7 = CrimeSpreeManager.set_server_modifier
function CrimeSpreeManager:set_server_modifier(modifier_id, ...)
	if not self._global.server_modifiers then
		local server_score = self._global.peer_spree_levels and self._global.peer_spree_levels[1] or 0
		self._global.server_modifiers = {{id = tweak_data.crime_spree.modifiers.forced[1].id, level = math.floor(server_score / tweak_data.crime_spree.modifier_levels.forced)}}
	end
	if table.contains(NewTable, modifier_id) then
		local OldExtraFunc = table.insert
		function table.insert(tbl, value)
			return OldExtraFunc(tbl, #tbl, value)
		end
		OldFunc7(self, modifier_id, ...)
		table.insert = OldExtraFunc
	end
end