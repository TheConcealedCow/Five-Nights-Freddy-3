function create()
	doSound('crazy garble', 1, 'staticSnd', true);
	
	makeLuaSprite('screen', 'gameAssets/Rare/2');
	addLuaSprite('screen');
	
	runTimer('toTitle', pl(5));
end

local timers = {
	['toTitle'] = function()
		switchState('Title');
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
