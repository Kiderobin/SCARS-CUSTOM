--Emerald Light Swordsman
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand if you control Emerald Sovereign Ritual Dragon or another Emerald Light monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--When Special Summoned, gain 200 ATK for each Emerald Sovereign Ritual Dragon or Emerald Light monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={0x4003}
s.listed_names={1000000000}

--Filter for Special Summon condition and ATK gain
function s.spfilter(c)
	return c:IsFaceup() and (c:IsCode(1000000000) or c:IsSetCard(0x4003))
end

--Condition for Special Summon
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

--Operation for ATK gain effect
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=Duel.GetMatchingGroupCount(s.spfilter,tp,LOCATION_MZONE,0,nil)
		if ct>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*200)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
