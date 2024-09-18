function create()
	doSound('crazy garble', 1, 'staticSnd', true);
	
	setVar('canEsc', false);
	
	makeLuaSprite('screen', 'gameAssets/Rare/3');
	addLuaSprite('screen');
	
	runTimer('today', pl(5));
end

local timers = {
	['today'] = function()
		switchState('WhatDay');
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
