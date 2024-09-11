local r = {
	ai = 0,
	
	tryingSpawn = false,
	didSpawn = false,
	lookingAt = false,
	
	appearCams = {[1] = true, [7] = true, [9] = true, [10] = true};
	
	lookTime = 0,
	maxTime = 0
};
local curHour = 12;
function onCreate()
	r.tryingSpawn = getMainVar('curNight') >= 4;
	r.ai = getMainVar('AI');
	r.maxTime = getMainVar('timeLimit');
end

function updateFunc(e, t)
	if r.lookingAt then
		r.lookTime = r.lookTime + t;
		
		if r.lookTime > r.maxTime then
			despawnBB(false);
			
			setAlpha('bbOffice', 1);
			
			runMainFunc('dropItAll');
			setMainVar('scareCooled', false);
			runTimer('startScareBB', pl(0.5));
		end
	end
end

function enterCams()
	checkLookingAt(getMainVar('actualLooking'));
end

function onChangeCam(i)
	checkLookingAt(i);
end

function onCloseCams()
	if r.lookingAt then
		despawnBB(true);
	end
end

function checkLookingAt(c)
	if r.didSpawn and r.appearCams[c] then
		r.lookingAt = true;
		
		setVis('bbPeek', true);
	elseif r.lookingAt then
		despawnBB(true);
	end
end

function despawnBB(t)
	r.tryingSpawn = t;
	
	r.lookingAt = false;
	r.didSpawn = false;
	
	r.lookTime = 0;
	
	setVis('bbPeek', false);
end

function stopEverything()
	despawnBB(false);
	
	playAnim('bbOffice', 'idle', true);
	setAlpha('bbOffice', 0);
end

function onHour(h)
	curHour = h;
end

local timers = {
	['twen'] = function()
		if r.tryingSpawn and not getMainVar('viewingCams') and getRandomInt(1, 10) <= r.ai and curHour ~= 12 then
			r.tryingSpawn = false;
			r.didSpawn = true;
		end
	end,
	
	['startScareBB'] = function()
		setMainVar('frozen', true);
		runMainFunc('hitMid');
		
		playAnim('bbOffice', 'scare', true);
		doSound('scream3', 1, 'scareSfx');
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
