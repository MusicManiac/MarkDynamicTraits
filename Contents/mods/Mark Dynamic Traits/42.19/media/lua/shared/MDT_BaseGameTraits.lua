if not getActivatedMods():contains("MarkDynamicTraits") then
	return
end

local MarkDynamicTraits = require "MDT_Main"

local function registerBaseGameTraits()
	MarkDynamicTraits.registerTrait(CharacterTrait.HERBALIST)

	MarkDynamicTraits.registerTrait(CharacterTrait.EMACIATED)
	MarkDynamicTraits.registerTrait(CharacterTrait.VERY_UNDERWEIGHT)
	MarkDynamicTraits.registerTrait(CharacterTrait.UNDERWEIGHT)
	MarkDynamicTraits.registerTrait(CharacterTrait.OVERWEIGHT)
	MarkDynamicTraits.registerTrait(CharacterTrait.OBESE)

	MarkDynamicTraits.registerTrait(CharacterTrait.UNFIT)
	MarkDynamicTraits.registerTrait(CharacterTrait.OUT_OF_SHAPE)
	MarkDynamicTraits.registerTrait(CharacterTrait.FIT)
	MarkDynamicTraits.registerTrait(CharacterTrait.ATHLETIC)

	MarkDynamicTraits.registerTrait(CharacterTrait.WEAK)
	MarkDynamicTraits.registerTrait(CharacterTrait.FEEBLE)
	MarkDynamicTraits.registerTrait(CharacterTrait.STOUT)
	MarkDynamicTraits.registerTrait(CharacterTrait.STRONG)
end

Events.OnMainMenuEnter.Remove(registerBaseGameTraits)
Events.OnMainMenuEnter.Add(registerBaseGameTraits)