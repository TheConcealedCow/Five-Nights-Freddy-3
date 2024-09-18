function create()
	doSound('crazy garble', 1, 'staticSnd', true);
	
	setVar('canEsc', false);
	
	makeLuaSprite('screen', 'gameAssets/Rare/1');
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
