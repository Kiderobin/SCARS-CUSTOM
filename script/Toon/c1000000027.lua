-- TESRD
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
    -- Destroy instead of "Toon World"
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetTarget(s.reptg)
    e4:SetValue(s.repval)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
    -- Destroy if "Toon World" is not on the field
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_LEAVE_FIELD)
    e5:SetCondition(s.descon)
    e5:SetOperation(s.desop)
    c:RegisterEffect(e5)
    -- Special Summon from Graveyard
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e6:SetRange(LOCATION_GRAVE)
    e6:SetCondition(s.spcon2)
    e6:SetTarget(s.sptg2)
    e6:SetOperation(s.spop2)
    c:RegisterEffect(e6)
end

function s.spfilter(c)
    return c:IsType(TYPE_TOON) and c:IsAbleToRemoveAsCost()
end

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_HAND,0,2,nil) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,2,2,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

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

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and e:GetHandler():IsAbleToGrave() end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsCode(15259703) and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and not c:IsReason(REASON_REPLACE)
end

function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end
