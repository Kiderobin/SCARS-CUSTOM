--Opal Crystal Magician Girl
--Created By ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
    -- Give up draw to recover a Ritual material
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.thcon)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

-- Condition to activate during the Draw Phase
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp) and Duel.GetDrawCount(tp)>0
end

-- Cost: Reveal this card and give up the normal draw
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    Duel.Hint(HINT_CARD,0,id)
    -- Prevent the draw by setting draw count to 0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DRAW_COUNT)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetValue(0)
    e1:SetReset(RESET_PHASE+PHASE_DRAW)
    Duel.RegisterEffect(e1,tp)
end

-- Target a monster in the Graveyard that was used as Ritual material
function s.thfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsReason(REASON_RITUAL)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

-- Add the targeted monster to the hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
