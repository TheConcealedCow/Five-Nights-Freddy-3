function create()
	doSound('long glitched2');
	
	makeLuaSprite('white1');
	makeGraphic('white1', 1, 1, 'ffffff');
	scaleObject('white1', 1024, 50);
	addLuaSprite('white1');
	setAlpha('white1', 0);
	
	makeLuaSprite('white2');
	makeGraphic('white2', 1, 1, 'ffffff');
	scaleObject('white2', 1024, 22);
	addLuaSprite('white2');
	setAlpha('white2', 0);
	
	makeLuaSprite('lines', 'gameAssets/EndBit/scanLines');
	addLuaSprite('lines');
	
	runTimer('lineJump1', pl(0.25), 0);
	runTimer('lineJump2', pl(0.15), 0);
	
	runTimer('toCutscene', pl(5));
end

local timers = {
	['lineJump1'] = function()
		if getRandomBool(25) then
			setY('white1', 37 + (37 * Random(20)));
			setAlpha('white1', 1);
		end
	end,
	['lineJump2'] = function()
		if getRandomBool(25) then
			setY('white2', 37 + (37 * Random(20)));
			setAlpha('white2', 1);
		end
	end,
	
	['toCutscene'] = function()
		switchState('Cutscenes');
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
