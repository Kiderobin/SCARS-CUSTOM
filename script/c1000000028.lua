-- Black Ritual Seizer Dragon
-- Created by ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
    -- XYZ Summon
    Xyz.AddProcedure(c,nil,8,2)
    c:EnableReviveLimit()
    -- Take control of opponent's Ritual monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.controlcon)
    e1:SetCost(s.controlcost)
    e1:SetTarget(s.controltg)
    e1:SetOperation(s.controlop)
    c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
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
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_RITUAL),1,0,0)
end

function s.controlop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_MZONE,1,1,nil,TYPE_RITUAL)
    if #g>0 then
        Duel.GetControl(g,tp)
    end
end
