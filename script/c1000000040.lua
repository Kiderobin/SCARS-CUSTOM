--Radiant Reversal
local s,id=GetID()
function s.initial_effect(c)
	--Negate opponent’s Spell/Trap or monster effect, destroy cards in the column of ID 1000000034, optionally add "Emerald Light" monster from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x4003}
s.listed_names={1000000034}

--Condition: Face-up monster with ID 1000000034 and opponent’s Spell/Trap or monster effect
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(1000000034) end,tp,LOCATION_MZONE,0,1,nil)
		and ep==1-tp and (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or re:IsActiveType(TYPE_MONSTER))
		and Duel.IsChainNegatable(ev)
end

--Filter for "Emerald Light" monsters in GY
function s.thfilter(c)
	return c:IsSetCard(0x4003) and c:IsMonster() and c:IsAbleToHand()
end

--Target: Negate activation, destroy opponent’s cards in ID 1000000034’s column, optional GY recovery
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local tc=Duel.GetFirstMatchingCard(function(c) return c:IsFaceup() and c:IsCode(1000000034) end,tp,LOCATION_MZONE,0,nil)
	if tc and tc:GetSequence() then
		local seq=tc:GetSequence()
		local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(function(c) local cseq=c:GetSequence() if c:IsControler(1-tp) then cseq=4-cseq end return cseq==seq end,nil)
		if #dg>0 then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
			Duel.Hint(HINT_ZONE,tp,1<<(seq+8)) -- Indicate Monster Zone
		end
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

--Operation: Negate, destroy, optionally add to hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local tc=Duel.GetFirstMatchingCard(function(c) return c:IsFaceup() and c:IsCode(1000000034) end,tp,LOCATION_MZONE,0,nil)
		if tc and tc:GetSequence() then
			local seq=tc:GetSequence()
			local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(function(c) local cseq=c:GetSequence() if c:IsControler(1-tp) then cseq=4-cseq end return cseq==seq end,nil)
			if #dg>0 then
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,0) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
