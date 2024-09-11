function create()
	doSound('Desolate_Underworld2', 1, 'bgMus', true);
	
	makeLuaSprite('demo', 'gameAssets/DemoEnd/demoEnd', 144 + 55, 298);
	addLuaSprite('demo');
	
	makeLuaSprite('blackFade');
	makeGraphic('blackFade', 1, 1, '000000');
	scaleObject('blackFade', 1024, 768);
	addLuaSprite('blackFade');
	doTweenAlpha('blackIn', 'blackFade', 0, pl(1.01));
end

local active = false;
local went = false;
function goAway()
	if went then return; end
	went = true;
	
	doTweenAlpha('blackOut', 'blackFade', 1, pl(1.01));
end

function onUpdatePost()
	if active and mouseClicked() then
		goAway();
	end
end

local timers = {
	['toTitle'] = function()
		goAway();
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

local tweens = {
	['blackIn'] = function()
		active = true;
		runTimer('toTitle', pl(10));
	end,
	['blackOut'] = function()
		switchState('Title');
	end
};
function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end
