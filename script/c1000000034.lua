-- Emerald Light Swordsman
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from hand if you control Emerald Sovereign Ritual Dragon or another Emerald Light monster
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
end

function s.spfilter(c)
    return c:IsFaceup() and (c:IsCode(1000000000) or c:IsSetCard(0x4003))
end

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
