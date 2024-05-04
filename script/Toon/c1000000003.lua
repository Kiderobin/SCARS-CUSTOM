--Toon World Defender
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,15270885,38369349)
	
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(function(e) return Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) and Duel.IsBattlePhase() end)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttackPos))
	c:RegisterEffect(e1)

end
