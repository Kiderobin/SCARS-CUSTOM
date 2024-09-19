-- Black Ritual Seizer Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- XYZ Summon
    Xyz.AddProcedure(c,nil,8,2)
    c:EnableReviveLimit()
    -- Take control of opponent's Ritual monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- Description for the first effect
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.controlcon)
    e1:SetCost(s.controlcost)
    e1:SetTarget(s.controltg)
    e1:SetOperation(s.controlop)
    c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    -- Attach Ritual monsters as Xyz material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)) -- Description for the second effect
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.mattg)
    e2:SetOperation(s.matop)
    c:RegisterEffect(e2)
    -- Destroy all Ritual Monsters when destroyed
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2)) -- Description for the third effect
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
    -- Gain ATK/DEF for each Ritual monster attached
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
end

function s.controlcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_RITUAL)
end

function s.controlcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.controltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_RITUAL) end
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,1)
end

function s.controlop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_MZONE,1,1,nil,TYPE_RITUAL)
    if #g>0 then
        Duel.GetControl(g,tp)
    end
end

function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_RITUAL) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,1)
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE,0,1,1,nil,TYPE_RITUAL)
    if #g>0 then
        Duel.Overlay(e:GetHandler(),g)
    end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_RITUAL) end
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_RITUAL)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_RITUAL)
    Duel.Destroy(g,REASON_EFFECT)
end

function s.atkval(e,c)
    local count=0
    local og=c:GetOverlayGroup()
    for tc in aux.Next(og) do
        if tc:IsType(TYPE_RITUAL) then
            count=count+1
        end
    end
    return count*500
end
