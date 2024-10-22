--Soulcalled, Queen
local s, id = GetID()
function s.initial_effect(c)
    -- Cannot be Normal Summoned
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e1)

    -- Register Soul Counter
    c:EnableCounterPermit(0x239b)
    c:SetCounterLimit(0x239b, 12)

    -- Add card to hand when destroyed or banished
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.retcon)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)

    -- Destroy a Spell/Trap when a monster with setcode 0x1317 is Summoned and add a counter
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_COUNTER)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    local e4 = e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

function s.retcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_EFFECT + REASON_BATTLE)
end

function s.rettg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, nil, 2000000001) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE + LOCATION_DECK)
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, 1, nil, 2000000001)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsSetCard, 1, nil, 0x1317)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil, TYPE_SPELL + TYPE_TRAP) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil, TYPE_SPELL + TYPE_TRAP)
    if #g > 0 then
        if Duel.Destroy(g, REASON_EFFECT) ~= 0 then
            e:GetHandler():AddCounter(0x239b, 1)
        end
    end
end
