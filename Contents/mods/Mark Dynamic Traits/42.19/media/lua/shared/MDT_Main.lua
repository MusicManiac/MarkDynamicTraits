MarkDynamicTraits = MarkDynamicTraits or {}
---@type table<string, boolean>
MarkDynamicTraits.registeredTraits = MarkDynamicTraits.registeredTraits or {}

local DYNAMIC_TRAIT_SUFFIX = " [~]"
local traitNamesDecorated = false
---@alias MDTNameMethod fun(self: CharacterTraitDefinition): string
---@type table<string, MDTNameMethod>
local originalMethods = {}

---Resolves a trait or returns an existing trait definition unchanged.
---@param trait CharacterTrait|CharacterTraitDefinition
---@return CharacterTraitDefinition|nil
local function resolveTraitDefinition(trait)
	if not trait then
		return nil
	end
	if instanceof(trait, "CharacterTraitDefinition") then
		return trait
	end
	if instanceof(trait, "CharacterTrait") then
		return CharacterTraitDefinition.getCharacterTraitDefinition(trait)
	end
	return nil
end

---Returns a trait name using the original method saved before MDT decoration.
---@param trait CharacterTrait|CharacterTraitDefinition
---@param methodName "getUIName"|"getLabel"
---@return string|nil
local function getUndecoratedName(trait, methodName)
	local definition = resolveTraitDefinition(trait)
	if not definition then
		return nil
	end

	local method = originalMethods[methodName] or definition[methodName]
	return method and method(definition) or nil
end

---Returns the trait's translated UI name without the MDT suffix.
---@param trait CharacterTrait|CharacterTraitDefinition
---@return string|nil
function MarkDynamicTraits.getUndecoratedUIName(trait)
	return getUndecoratedName(trait, "getUIName")
end

---Returns the trait's translated label without the MDT suffix.
---@param trait CharacterTrait|CharacterTraitDefinition
---@return string|nil
function MarkDynamicTraits.getUndecoratedLabel(trait)
	return getUndecoratedName(trait, "getLabel")
end

---Registers a trait to have its displayed names marked as dynamic.
---@param characterTrait CharacterTrait
---@return boolean
function MarkDynamicTraits.registerTrait(characterTrait)
	if not characterTrait then
		return false
	end

	MarkDynamicTraits.registeredTraits[characterTrait:getName()] = true
	return true
end

---Returns whether the supplied trait definition is registered as dynamic.
---@param definition CharacterTraitDefinition
---@return boolean
function MarkDynamicTraits.isRegistered(definition)
	if not definition then
		return false
	end

	return MarkDynamicTraits.registeredTraits[definition:getType():getName()] == true
end

---Wraps a trait-definition name method with MDT's conditional suffix behavior.
---@param methods table<string, MDTNameMethod>|nil
---@param methodName "getUIName"|"getLabel"
---@return boolean
local function decorateMethod(methods, methodName)
	local originalMethod = methods and methods[methodName]
	if not originalMethod then
		return false
	end
	originalMethods[methodName] = originalMethod

	---Returns the original name with the MDT suffix when this trait is registered.
	---@param self CharacterTraitDefinition
	---@return string
	local function decoratedMethod(self)
		local name = originalMethod(self)
		if MarkDynamicTraits.isRegistered(self) then
			return name .. DYNAMIC_TRAIT_SUFFIX
		end

		return name
	end

	methods[methodName] = decoratedMethod
	return true
end

---Installs the name decorators once trait definitions are available.
---@return nil
local function decorateTraitNames()
	if traitNamesDecorated then
		return
	end

	local traitDefinitions = CharacterTraitDefinition.getTraits()
	if traitDefinitions:isEmpty() then
		return
	end

	local metatable = getmetatable(traitDefinitions:get(0))
	local methods = metatable and metatable.__index
	local uiNameDecorated = decorateMethod(methods, "getUIName")
	local labelDecorated = decorateMethod(methods, "getLabel")
	traitNamesDecorated = uiNameDecorated and labelDecorated
end

Events.OnMainMenuEnter.Remove(decorateTraitNames)
Events.OnMainMenuEnter.Add(decorateTraitNames)

return MarkDynamicTraits
