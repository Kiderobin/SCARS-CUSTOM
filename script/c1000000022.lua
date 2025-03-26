-- Obsidian Black Magician Girl
-- Created By ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz summon procedure (Level 4, requires 2 materials)
    Xyz.AddProcedure(c, nil, 4, 2)  -- Fix: 2 materials of Level 4
    c:EnableReviveLimit()

    -- Detach 2 materials to return a Ritual Spell and Ritual Monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- Description for the effect
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.thfilter1(c,tp)
    return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
        and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil,c)
end

function s.thfilter2(c,spell)
    return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and s.isfit(c,spell)
end

function s.isfit(c,spell)
    return (spell.fit_monster and c:IsCode(table.unpack(spell.fit_monster))) or spell:ListsCode(c:GetCode())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_GRAVE,0,1,nil,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    if #g1>0 then
        local spell=g1:GetFirst()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil,spell)
        if #g2>0 then
            g1:Merge(g2)
            Duel.SendtoHand(g1,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g1)
        end
    end
end
