-- Xyz Recycle

local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- Attach from Graveyard
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATTACH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.target)
    e2:SetOperation(s.activate)
    c:RegisterEffect(e2)
end

function s.filter(c,rank)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToChangeControler() and c:GetLevel()==rank
end

function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        local xyz=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
        return xyz:GetCount()>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,xyz:GetFirst():GetRank())
    end
    Duel.SetOperationInfo(0,CATEGORY_ATTACH,nil,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if not xyz then return end
    local rank=xyz:GetRank()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,rank)
    if g:GetCount()>0 then
        Duel.Overlay(xyz,g)
    end
end