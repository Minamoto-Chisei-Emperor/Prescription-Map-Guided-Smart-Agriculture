function tf = betterIndividual(a, b)
%BETTERINDIVIDUAL Replacement rule for one-to-one competition.

if dominatesIndividual(a,b)
    tf = true;
elseif dominatesIndividual(b,a)
    tf = false;
else
    % If non-dominated relative to each other, randomly keep diversity.
    tf = rand() < 0.5;
end
end
