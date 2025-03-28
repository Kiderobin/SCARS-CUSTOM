--Amethyst Purple Crystal Magician Girl
--Scripted by ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
    -- Search banished zone for a Ritual Monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.thcon)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- Quick Effect: Ritual Summon by banishing from Graveyard
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.qritg)
    e2:SetOperation(s.qriop)
    c:RegisterEffect(e2)
end

-- Search condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp) and Duel.GetDrawCount(tp)>0
end

-- Search cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    Duel.Hint(HINT_CARD,0,id)
    -- Prevent the draw by setting draw count to 0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DRAW_COUNT)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetValue(0)
    e1:SetReset(RESET_PHASE+PHASE_DRAW)
    Duel.RegisterEffect(e1,tp)
end

-- Search target
function s.thfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsMonster() and c:IsAbleToHand() and c:IsFaceup()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Quick Effect: Ritual Summon target
function s.qritfilter(c,e,tp,m,level)
    return c:IsType(TYPE_RITUAL) and c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
        and m:CheckWithSumEqual(Card.GetRitualLevel,level,1,99,c)
end

function s.qritg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mg=Duel.GetMatchingGroup(function(c) return c:IsMonster() and c:IsAbleToRemove() end, tp, LOCATION_GRAVE, 0, nil)
    if chk==0 then return Duel.IsExistingMatchingCard(s.qritfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,8) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

-- Quick Effect: Ritual Summon operation
function s.qriop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(function(c) return c:IsMonster() and c:IsAbleToRemove() end, tp, LOCATION_GRAVE, 0, nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,s.qritfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,8)
    local tc=tg:GetFirst()
    if tc then
        local level=tc:GetLevel()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        -- Ensure SelectWithSumEqual is called with the correct parameters
        local mat=mg:SelectWithSumEqual(tp,Card.GetLevel,level,1,99)
        if #mat>0 then
            tc:SetMaterial(mat)
            Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
            Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end
