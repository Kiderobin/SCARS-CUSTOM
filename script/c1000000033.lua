-- Counter Trap Card Script

local s,id=GetID()
function s.initial_effect(c)
    -- Activate effect
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cfilter(c,tp)
    return c:IsCode(1000000000) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Destroy 1 card your opponent controls
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g1>0 then
        Duel.HintSelection(g1)
        Duel.Destroy(g1,REASON_EFFECT)
    end

    -- Shuffle 1 Ritual Monster or Ritual Spell from GY into the Deck and draw 1 card
    if Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g2>0 and Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

function s.tdfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsAbleToDeck()
end