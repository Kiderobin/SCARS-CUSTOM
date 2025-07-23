--Emerald Light, Shine Bright!
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Emerald Light" monster from hand or Deck, then optionally from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0x4003}

--Special Summon limit to "Emerald Light" monsters
function s.splimit(e,c)
	return not c:IsSetCard(0x4003)
end

--Filter for Special Summon from hand or Deck
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x4003) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Filter for Special Summon from Graveyard
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x4003) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

--Target for Special Summon effect
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operation for Special Summon effect
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	--Apply summon restriction
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Special Summon from hand or Deck
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g1>0 then
		if Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)>0 then
			--Optional Special Summon from Graveyard
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
				and Duel.SelectYesNo(tp,0) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				if #g2>0 then
					Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
