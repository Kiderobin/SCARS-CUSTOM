local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()
    -- Special Summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Cannot attack the turn it is Special Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetCondition(s.atkcon)
    c:RegisterEffect(e2)
    -- Pay 500 LP to attack
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
    -- Destroy this card if "Toon World" is destroyed
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.descon)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
    -- Special Summon from Graveyard during next Standby Phase if destroyed by battle or card effect
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetCondition(s.regcon)
    e5:SetOperation(s.regop)
    c:RegisterEffect(e5)
    -- Special Summon during Standby Phase
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e6:SetRange(LOCATION_GRAVE)
    e6:SetCondition(s.spcon2)
    e6:SetTarget(s.sptg2)
    e6:SetOperation(s.spop2)
    c:RegisterEffect(e6)
end

-- Special Summon Condition
function s.spfilter(c)
    return c:IsType(TYPE_TOON) and c:IsAbleToRemoveAsCost()
end

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_HAND,0,2,nil)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,2,2,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Attack condition
function s.atkcon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.CheckLPCost(tp,500) then
        Duel.PayLPCost(tp,500)
    else
        Duel.NegateAttack()
    end
end

-- Destroy this card if "Toon World" is destroyed
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsCode,1,nil,15259703) -- Check if "Toon World" is destroyed
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT) -- Destroy this card
end

-- Register for Special Summon if destroyed by battle or card effect
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    -- Register to Special Summon during the next Standby Phase
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount()+1)
    e1:SetCondition(s.spcon2)
    e1:SetTarget(s.sptg2)
    e1:SetOperation(s.spop2)
    e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
    Duel.RegisterEffect(e1,tp)
end

-- Special Summon from Graveyard Condition (next Standby Phase after destruction)
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()==e:GetLabel()
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end
