local r = { -- IN THE CODE HE'S REFERRED TO AS GOLDEN FREDDY
	ai = 0,
	
	willSpawn = false,
	forced = false,
	
	tryingSpawn = false,
	
	isWalking = false,
	fell = false,
	
	tryingScare = false,
	
	spawnTime = 0,
	tryTime = 0,
	
	lookTime = 0,
	maxTime = 0
};
local curHour = 12;
function onCreate()
	setVar('goldenEerie', false);
	
	r.willSpawn = getMainVar('curNight') >= 3;
	r.ai = getMainVar('AI');
	r.maxTime = getMainVar('timeLimit') * 3;
end

function updateFunc(e, t, ticks)
	if r.tryingSpawn and not r.isWalking and r.willSpawn then
		r.spawnTime = r.spawnTime + e;
		while r.spawnTime >= 1 do
			r.spawnTime = r.spawnTime - 1;
			
			if getRandomBool() then
				r.tryingSpawn = false;
				fredStartWalk();
			end
		end
	end
	
	if r.isWalking then
		if not getMainVar('inAPanel') then
			r.lookTime = r.lookTime + t;
			
			if not r.fell and r.lookTime >= r.maxTime then
				r.fell = true;
				playAnim('freddyWalk', 'fall');
			end
		else
			r.lookTime = 0;
		end
	end
	
	if r.tryingScare then
		r.tryTime = r.tryTime + e;
		
		while r.tryTime >= 1 do
			r.tryTime = r.tryTime - 1;
			
			if getRandomBool() and getMainVar('scareCooled') then
				doScare();
				
				return;
			end
		end
	end
end

function fredStartWalk()
	setAlpha('freddyWalk', 1);
	playAnim('freddyWalk', 'walk', true);
	
	r.isWalking = true;
	
	setVar('goldenEerie', true);
	if getMainVar('nearPhase') == 0 then
		setMainVar('nearPhase', 1); 
	end
	
	local fredPos = {1476 + 145, 414 - 297};
	setPos('freddyWalk', fredPos[1], fredPos[2]);
	startTween('walkFred', 'freddyWalk', {x = fredPos[1] - 1061, y = fredPos[2] - 12}, pl(23.6154), {ease = 'linear', onComplete = 'fredFinWalk'});
end

function fredFinWalk()
	setVar('goldenEerie', false);
	setAlpha('freddyWalk', 0);
	
	r.isWalking = false;
end

function freddyFallFin()
	setVar('goldenEerie', false);
	setAlpha('freddyWalk', 0);
	
	r.tryingScare = true;
	r.isWalking = false;
end

function doScare()
	setX('fredScare', getMainVar('xCam') - 512);
	
	setMainVar('frozen', true);
	setMainVar('scareCooled', false);
	
	runMainFunc('dropItAll');
	runMainFunc('hitMid');
	
	setAlpha('fredScare', 1);
	playAnim('fredScare', 'scare', true);
	
	r.willSpawn = false;
	r.tryingScare = false;
	
	doSound('scream3', 1, 'scareSfx');
end

function onHour(h)
	curHour = h;
	
	if not r.forced and r.willSpawn and h == 4 then 
		r.tryingSpawn = true;
		r.forced = true; 
	end
end

local timers = {
	['min'] = function()
		if r.willSpawn and getRandomInt(1, 12) <= r.ai and curHour ~= 12 then
			r.tryingSpawn = true;
		end
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
