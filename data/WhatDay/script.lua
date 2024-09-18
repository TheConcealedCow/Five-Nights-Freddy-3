local curNight = 1;
local sv = 'FNAF3';
function create()
	doSound('startday');
	
	curNight = getDataFromSave(sv, 'night', 1);
	
	makeAnimatedLuaSprite('day', 'gameAssets/WhatDay/day', 512 - 100, 374 - 52);
	addAnimationByPrefix('day', 'day', curNight, 0);
	addLuaSprite('day');
	
	for i, y in pairs({334, 406}) do
		local t = 'line' .. i;
		makeAnimatedLuaSprite(t, 'gameAssets/WhatDay/fadeLine', 0, y);
		addAnimationByPrefix(t, 'line', 'Fade', 45, false);
		addOffset(t, 'line', 0, 15);
		playAnim(t, 'line', true);
		hideOnFin(t);
		addLuaSprite(t);
		setBlendMode(t, 'add');
	end
	
	makeAnimatedLuaSprite('blip', 'gameAssets/Title/blip');
	addAnimationByPrefix('blip', 'blip', 'Blip', 45, false);
	addOffset('blip', 'line', 0, 15);
	playAnim('blip', 'line', true);
	hideOnFin('blip');
	addLuaSprite('blip');
	
	makeLuaSprite('blackGo');
	makeGraphic('blackGo', 1, 1, '000000');
	scaleObject('blackGo', 1024, 768);
	addLuaSprite('blackGo');
	setAlpha('blackGo', 0);
	
	makeLuaSprite('wait', 'gameAssets/Wait/dots', 972 - 15, 739 - 2);
	addLuaSprite('wait');
	setAlpha('wait', 0.00001);
	
	runTimer('goLoad', pl(2.66666666));
end

local timers = {
	['goLoad'] = function()
		doTweenAlpha('blackFade', 'blackGo', 1, pl(1.01));
	end,
	
	['go'] = function()
		switchState('Night');
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

local tweens = {
	['blackFade'] = function()
		if getRandomInt(1, 1000) == 1 then
			switchState('Rare3');
		else
			removeLuaSprite('day');
			
			setAlpha('wait', 1);
			runTimer('go', pl(0.1));
		end
	end
};
function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end