--Varis, King Of The Pumpkin Patch
--Created By ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_FIELD)
e1:SetCode(EFFECT_SPSUMMON_PROC)
e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
e1:SetRange(LOCATION_HAND)
e1:SetCondition(s.spcon)
c:RegisterEffect(e1)

s.listed_names={96163807}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,96163807),tp,LOCATION_ONFIELD,0,1,nil)
end