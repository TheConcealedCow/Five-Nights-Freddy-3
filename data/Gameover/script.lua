function create()
	makeLuaSprite('gameOver', 'gameAssets/Gameover/gameover');
	addLuaSprite('gameOver');
	
	makeAnimatedLuaSprite('static', 'gameAssets/Title/static');
	addAnimationByPrefix('static', 'static', 'Static', 30);
	playAnim('static', 'static', true);
	addLuaSprite('static');
	setAlpha('static', clAlph(227));
	
	makeAnimatedLuaSprite('line', 'gameAssets/Gameover/line', 0, 376 - 15);
	addAnimationByPrefix('line', 'line', 'Line', 12, false);
	playAnim('line', 'line', true);
	addLuaSprite('line');
	setBlendMode('line', 'add');
	hideOnFin('line');
	
	runTimer('forceGo', pl(5));
end

function goAway()
	if getRandomInt(1, 1000) == 1 then
		switchState('Rare2');
	else
		switchState('Title');
	end
end

function onUpdatePost()
	if mouseClicked() then
		goAway();
	end
end

local timers = {
	['forceGo'] = function()
		goAway();
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
