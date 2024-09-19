--Djinn Juggler of Rituals
local s,id=GetID()
function s.initial_effect(c)
    --Can be used for a Ritual Summon while it is in the GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCondition(s.con)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --Grants an effect if it is used for a Ritual Summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.condition)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.con(e)
    return true
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_RITUAL
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    for rc in eg:Iter() do
        if rc:GetFlagEffect(id)==0 then
            --Return 1 banished monster to the deck as an ignition effect
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,0))
            e1:SetCategory(CATEGORY_TODECK)
            e1:SetType(EFFECT_TYPE_IGNITION)
            e1:SetRange(LOCATION_MZONE)
            e1:SetCountLimit(1)
            e1:SetTarget(s.target)
            e1:SetOperation(s.returnop)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            rc:RegisterEffect(e1,true)
            rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
        end
    end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_REMOVED)
end
function s.returnop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
