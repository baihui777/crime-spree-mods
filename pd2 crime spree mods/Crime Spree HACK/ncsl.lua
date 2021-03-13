function CrimeSpreeTweakData:init(tweak_data)
	self.unlock_level = 60
	self.base_difficulty = "overkill_145"
	self.base_difficulty_index = 5
	self.starting_levels = {
		0,
		550000,
		20000000
	}
	self.allow_highscore_continue = true
	self.initial_cost = 1
	self.cost_per_level = 0
	self.randomization_cost = 1
	self.randomization_multiplier = 1
	self.catchup_bonus = 50
	self.winning_streak = 50
	self.continue_cost = {1, 0}
	self.protection_threshold = 16
	self.announce_modifier_stinger = "stinger_feedback_positive"
	self:init_missions(tweak_data)
	self:init_rewards(tweak_data)
	self:init_achievements(tweak_data)
	self:init_modifiers(tweak_data)
	self:init_gage_assets(tweak_data)
	self:init_gui(tweak_data)
end

function CrimeSpreeTweakData:init_achievements(tweak_data)
	self.achievements = {}
	self.achievements.levels = {
		{level = 50, id = "cee_1"},
		{level = 100, id = "cee_2"},
		{level = 250, id = "cee_3"}
	}
end