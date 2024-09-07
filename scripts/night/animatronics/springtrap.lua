local r = {
	ai = 0,
	cam = 0,
	
	hyper = false,
	
	moveCount = 0,
	totTurns = 0,
	aggro = 0,
	
	action = 0,
	
	isVisible = false,
	
	totTrails = 0,
	
	moveTree = { -- move tree go wild
		[1] = {35, 50},
		[2] = {5, 4, 25, 15},
		[3] = {4, 25},
		[4] = {2, 3},
		[5] = {6, 2, 4, 13},
		[6] = {5, 7},
		[7] = {8, 6, 12},
		[8] = {9, 7, 5},
		[9] = {10, 8, 11},
		[10] = {9, 14},
		[11] = {35, 9},
		[12] = {35, 7},
		[13] = {25, 13},
		[14] = {200, 10},
		[15] = {200, 2}
	};
};
local curHour = 12;
local curNight = 1;
function onCreate()
	luaDebugMode = true;
	
	setVar('springEerie', false);
	setVar('springCam', r.cam);
	
	curNight = getMainVar('curNight');
	
	if curNight == 1 then return; end
	
	r.ai = getMainVar('AI');
	r.hyper = getMainVar('cheats').hyper;
	
	spawnSP();
	
	runTimer('springResetAggro', pl(15), 0);
	runTimer('spawnTrail', pl(3), 0);
end

function spawnSP()
	local spawnCam = 10 - Random(5);
	--local spawnCam = 3;
	r.cam = spawnCam;
	setCamProp('cameraProps', spawnCam, 'spIn', true);
	setVar('springCam', spawnCam);
	
	debugPrint('spring is in cam: ' .. spawnCam);
end

function setSpringCam(c)
	if r.cam > 0 and r.cam < 16 then 
		setCamProp(getProp(r.cam), r.cam, 'spIn', false);
	end
	
	if c > 0 and c < 16 then
		setCamProp(getProp(c), c, 'spIn', true);
	end
	
	debugPrint('spring is in cam: ' .. c);
	
	r.cam = c;
	setVar('springCam', c);
end

function updateFunc(e, t)
	if curNight == 1 then return; end
	
	if curHour == 12 then
		r.aggro = 0;
	else
		local vent = getMainVar('systems').vent;
		if curHour >= 4 or vent.offNum > 10 or vent.prog <= -10 or getMainVar('breatheNum') > 0 or getMainVar('frozen') then 
			r.aggro = 1;
		end
	end
end

local phaseCheck = {
	[25] = function()
		setAlpha('springWindow', 1);
		r.isVisible = true;
	end
};
local curCamFunc = {
	[1] = function(a)
		if getMainVar('viewingAPanel') then return 0; else
			if a == 2 then return 35;
			else return 40; end
		end
	end,
	[2] = function(a)
		if a == 4 then return (picRand == '1' and 25 or 15);
		else return r.moveTree[2][a - 1]; end
	end,
	[3] = function(a)
		if a == 2 then return 4;
		else return 25; end
	end,
	[4] = function(a)
		if a == 2 then return 2;
		else return 3; end
	end,
	[5] = function(a)
		if a == 4 then return (picRand == '1' and 4 or 13);
		else return r.moveTree[5][a - 1]; end
	end,
	[6] = function(a)
		if a == 2 then return 7;
		else return 5; end
	end,
	[7] = function(a)
		return r.moveTree[7][a - 1];
	end,
	[8] = function(a)
		return r.moveTree[8][a - 1];
	end,
	[9] = function(a)
		return r.moveTree[9][a - 1];
	end,
	[10] = function(a)
		if a == 4 then return 14;
		else return 9; end
	end,
	
	[11] = function(a)
		return (getMainVar('curSealed') == 11 and 9 or 35);
	end,
	[12] = function(a)
		return (getMainVar('curSealed') == 12 and 7 or 35);
	end,
	[13] = function(a)
		return (getMainVar('curSealed') == 13 and 5 or 25);
	end,
	[14] = function(a)
		return (getMainVar('curSealed') == 14 and 10 or 200);
	end,
	[15] = function(a)
		return (getMainVar('curSealed') == 15 and 2 or 200);
	end
};
local onCam = {
	[25] = function()
		if getMainVar('viewingAPanel') then
			setAlpha('springWindow', 1);
			r.isVisible = true;
		end
	end
};
function makeMove()
	local action = getRandomInt(1, 3 + r.aggro);
	r.action = action;
	
	if action == 1 then
		r.totTurns = r.totTurns + 1;
	else
		if r.cam > 15 then
			r.action = action;
		else
			local toRun = curCamFunc[r.cam];
			if toRun then 
				local newCam = toRun(action);
				if newCam == 0 then
					r.action = action;
				else
					setSpringCam(newCam);
					local new = onCam[newCam];
					if new then new(); end
				end
			else
				r.action = action;
			end
		end
		
		r.totTurns = 0;
		
		if not r.isVisible then
			springRandSound();
			springStatic();
		end
	end
end

function checkPhase()
	local ph = phaseCheck[r.cam];
	if ph then ph(); end
end

function enterCams()
	checkPhase();
end

function enterSys()
	checkPhase();
end

function onHour(h)
	curHour = h;
end

function subTrail() r.totTrails = r.totTrails - 1; end

function springRandSound()
	doSound('walk/' .. getRandomInt(1, 7), 1, 'walkSnd');
end

function getProp(n)
	if n > 10 then return 'ventProps'; end
	return 'cameraProps';
end

local timers = {
	['sec'] = function()
		if curNight == 1 then return; end
		
		r.moveCount = r.moveCount + (r.hyper and 2 or 1);
		
		if r.moveCount > (10 - r.ai - r.aggro) + Random(15) - r.totTurns then
			r.moveCount = 0;
			
			makeMove();
		end
	end,
	
	['spawnTrail'] = function()
		if r.totTrails < 3 and r.cam > 0 and r.cam < 16 then
			runMainFunc('addTrailOnCam', {r.cam});
			r.totTrails = r.totTrails + 1;
		end
	end,
	
	['springResetAggro'] = function()
		if Random(5) < r.ai then
			r.aggro = 1;
		else
			r.aggro = 0;
		end
	end,
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
