local sv = 'FNAF3';
local going = false;
function create()
	setVar('canEsc', false);
	
	makeLuaSprite('card', 'gameAssets/End/badEnd');
	addLuaSprite('card');
	setAlpha('card', 0.00001);
	
	doSound('mb2', 1, 'musicBox', true);
	doTweenAlpha('cardIn', 'card', 1, pl(2));
	runTimer('goForce', pl(15));
	
	setDataFromSave(sv, 'beatGame', true); 
end

function onUpdatePost(e)
	if not going and keyboardJustPressed('ESCAPE') then
		going = true;
		goScreen();
	end
end

function goScreen()
	doTweenAlpha('cardOut', 'card', 0, pl(2));
end

local timers = {
	['goForce'] = function()
		if not going then goScreen(); end
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

local tweens = {
	['cardOut'] = function()
		switchState('title');
	end
};
function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end
