local s,id=GetID()
function s.initial_effect(c)
    --atkup
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.val)
    c:RegisterEffect(e1)
end
s.listed_names={1000000004}
function s.val(e,c)
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,1000000004),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
        return 500
    else
        return 0
    end
end
