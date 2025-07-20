--Emerald Light Ward
local s,id=GetID()
function s.initial_effect(c)
	--Protect Emerald Sovereign Ritual Dragon and Emerald Light monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end

function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x4003) or c:IsCode(1000000000)) and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4003) and c:IsDestructable()
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,0))
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
	end
end
