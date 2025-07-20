--Emerald Light Protection
local s,id=GetID()
function s.initial_effect(c)
	--Activate as a Continuous Trap
	c:EnableReviveLimit()
	--Protect Emerald Sovereign Ritual Dragon and Emerald Light monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.reptg)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
s.listed_series={0x4003}
s.listed_names={1000000000}

--Filter for protected monsters
function s.repfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and (c:IsCode(1000000000) or c:IsSetCard(0x4003)) and c:IsReason(REASON_EFFECT)
		and c:GetPreviousControler()==tp
end

--Filter for monsters to destroy instead
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4003) and c:IsDestructable()
end

--Condition and target for replacement effect
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	return true
end

--Operation to destroy a card instead
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
	end
end
