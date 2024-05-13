--Ritual Sparrow
--Created By ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
	--ritual level
	Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
end