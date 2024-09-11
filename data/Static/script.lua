function create()
	doSound('stare', 1, 'staticSnd', true);
	
	makeAnimatedLuaSprite('static', 'gameAssets/Title/static');
	addAnimationByPrefix('static', 'static', 'Static', 30);
	playAnim('static', 'static', true);
	addLuaSprite('static');
	
	makeLuaSprite('flash');
	makeGraphic('flash', 1, 1, 'fffffe');
	scaleObject('flash', 1024, 768);
	addLuaSprite('flash');
	doTweenAlpha('flashOut', 'flash', 0, pl(0.85));
	
	runTimer('toOver', pl(5));
end

local timers = {
	['toOver'] = function()
		switchState('gameOver');
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
