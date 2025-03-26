--Emerald Lights
--Created by ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
    aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    --condition
    return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.cffilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.GetFlagEffect(tp,id)==0
end
function s.cffilter(c)
    return c:IsCode(1000000000) -- Checks for "Emerald Sovereign Ritual Dragon"
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)
    -- opd register
    Duel.RegisterFlagEffect(tp,id,0,0,0)
    -- Select and reveal "Emerald Sovereign Ritual Dragon"
    local g=Duel.SelectMatchingCard(tp,s.cffilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    local tc=g:GetFirst()
    if tc then
        -- Add the Ritual Spell with ID 1000000001 from outside the deck
        local spell=Duel.CreateToken(tp,1000000001)
        if spell then
            Duel.SendtoHand(spell,nil,REASON_RULE)
            Duel.ConfirmCards(1-tp,spell)
        end
    end
end
