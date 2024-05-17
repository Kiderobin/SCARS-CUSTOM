local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Ritual Spell and 1 Ritual monster to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PREDRAW)
    e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.thcon)
	e4:SetCost(s.thcost)
    e4:SetTarget(s.sptgt)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsRitualMonster() or c:IsRitualSpell())
end
function s.rescon(sg)
	return sg:FilterCount(Card.IsRitualMonster,nil)==1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<2 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #rg>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,rg)
	end
end
function s.sptgt(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    local dt=Duel.GetDrawCount(tp)
    if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    _replace_count=_replace_count+1
    if _replace_count<=_replace_max and c:IsRelateToEffect(e) then
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
            
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0 and (Duel.GetTurnCount()>1 or Duel.IsDuelType(DUEL_1ST_TURN_DRAW))
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
