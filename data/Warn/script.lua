local going = false;
function create()
	makeLuaSprite('warn', 'gameAssets/warn/warn', 292, 308);
	addLuaSprite('warn');
	
	runTimer('forceGo', pl(2));
end

function onUpdatePost()
	if not going and mouseClicked() or keyboardJustPressed('ENTER') then
		going = true;
		
		doTweenAlpha('warnOut', 'warn', 0, pl(1.01));
	end
end

local timers = {
	['forceGo'] = function()
		if going then return; end
		going = true;
		
		doTweenAlpha('warnOut', 'warn', 0, pl(1.01));
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

local tweens = {
	['warnOut'] = function()
		toFrame();
	end
};
function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end

function toFrame()
	if Random(1000) == 1 then
		switchState('Rare1');
	else
		switchState('Title');
	end
end