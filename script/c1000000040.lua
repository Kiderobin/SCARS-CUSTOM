--Radiant Reversal
local s,id=GetID()
function s.initial_effect(c)
	--Negate opponent’s Spell/Trap or monster effect, destroy cards in that column, optionally add "Emerald Light" monster from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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

--Condition: Face-up card with ID 1000000034 and opponent’s Spell/Trap or monster effect
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(1000000034) end,tp,LOCATION_ONFIELD,0,1,nil)
		and ep==1-tp and (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or re:IsActiveType(TYPE_MONSTER))
		and Duel.IsChainNegatable(ev)
end

--Filter for "Emerald Light" monsters in GY
function s.thfilter(c)
	return c:IsSetCard(0x4003) and c:IsMonster() and c:IsAbleToHand()
end

--Target: Negate activation, destroy column, optional GY recovery
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local zone=re:GetHandler():GetColumn()
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(Card.IsInColumn,nil,zone)
	if #dg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

--Operation: Negate, destroy, add to hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local tc=re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then
			local zone=tc:GetColumn()
			local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(Card.IsInColumn,nil,zone)
			if #dg>0 then
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end