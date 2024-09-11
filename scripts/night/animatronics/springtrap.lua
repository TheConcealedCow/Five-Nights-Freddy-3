local r = {
	ai = 0,
	cam = 0,
	
	hyper = false,
	
	moveCount = 0,
	totTurns = 0,
	aggro = 0,
	
	action = 0,
	
	isVisible = false,
	
	movedFrozen = false,
	gotMovePhase = false,
	
	totTrails = 0,
	
	goingTo = 0,
	goingTime = 0,
	
	ranPast = false,
	peeked = false,
	
	gotMoveTime = 0,
	tryGotTime = 0,
	
	moveTree = { -- move tree go wild // 25 is phase 1, 30 is phase 2, 35 is phase 3, 40 is phase 4
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
	
	local spawnCam = 10 - Random(5);
	setSpringCam(spawnCam);
	
	runTimer('springResetAggro', pl(15), 0);
	runTimer('spawnTrail', pl(3), 0);
end

local leaveCam = {
	[25] = function()
		setAlpha('springWindow', 0);
		r.isVisible = false;
	end,
	[40] = function()
		setAlpha('springHead', 0);
		r.isVisible = false;
	end
};
function setSpringCam(c)
	if r.cam > 0 and r.cam < 16 then 
		setCamProp(getProp(r.cam), r.cam, 'spIn', false);
	end
	
	if c > 0 and c < 16 then
		setCamProp(getProp(c), c, 'spIn', true);
	end
	
	r.cam = c;
	setVar('springCam', c);
	checkEerie();
end

local onCam = {
	[25] = function()
		if getMainVar('inAPanel') then
			setAlpha('springWindow', 1);
			r.isVisible = true;
		end
	end,
	[30] = function()
		r.goingTo = 0;
		r.goingTime = 0;
		
		if not r.ranPast then
			r.ranPast = true;
			
			setAlpha('springWalk', 1);
			playAnim('springWalk', 'run', true);
			
			local runPos = getPos('springWalk');
			startTween('springRunBy', 'springWalk', {x = runPos[1] - 425, y = runPos[2] - 10}, pl(0.810844278184427), {ease = 'linear', onComplete = 'springFinRun'});
		end
	end,
	[40] = function()
		if getMainVar('inAPanel') then
			setAlpha('springHead', 1);
			r.isVisible = true;
		end
	end
};

local upCam = {
	[1] = function()
		if getMainVar('inAPanel') and r.action == 2 then
			setSpringCam(35);
		end
	end,
	[25] = function()
		if r.gotMovePhase and getMainVar('inAPanel') then -- move to phase 2
			r.gotMovePhase = false;
			setSpringCam(30);
			leaveCam[25]();
			onCam[30]();
			
			return;
		end
		
		if getMainVar('blackout').alph > 250 then -- move to phase 2
			runMainFunc('springBlackout');
			setSpringCam(30);
			leaveCam[25]();
			onCam[30]();
			
			return;
		end
	end,
	[30] = function()
		if getMainVar('blackout').alph > 250 then -- move to phase 3
			runMainFunc('springBlackout');
			setSpringCam(35);
			
			return;
		end
	end,
	[35] = function()
		if getMainVar('inAPanel') then
			if r.action == 2 then
				resetMove();
				setSpringCam(1);
				
				return;
			elseif r.action > 2 then
				resetMove();
				setSpringCam(40);
				
				return;
			end
		end
		
		if getMainVar('blackout').alph > 250 then -- move to phase 4
			runMainFunc('springBlackout');
			setSpringCam(40);
			
			return;
		end
	end,
	[40] = function()
		if r.action > 1 then
			if getMainVar('viewingCams') then
				resetMove();
				setX('bigScare', 976);
				setAlpha('bigScare', 1);
				playAnim('bigScare', 'scare', true);
				
				setSpringCam(200);
				leaveCam[40]();
				
				return;
			elseif getMainVar('viewingLittle') then
				resetMove();
				setSpringCam(100);
				leaveCam[40]();
			else
				local xAt = getMainVar('xCam');
				if xAt > 1100 and xAt <= 1200 then
					resetMove();
					setSpringCam(100);
					leaveCam[40]();
					
					return;
				end
			end
			
			if getMainVar('blackout').alph > 250 then -- move to got you
				resetMove();
				runMainFunc('springBlackout');
				setSpringCam(100);
				leaveCam[40]();
			end
		end
	end,
	
	[100] = function(e)
		local xAt = getMainVar('xCam');
		if xAt > 1000 and getMainVar('blackout').alph > 250 then -- move to got you 2 setSpringCam(200);
			runMainFunc('springBlackout');
			setMainVar('xCam', 1000);
			xAt = 1000;
		end
		
		if xAt <= 1300 then
			setVar('gotYou', 1);
			
			return;
		end
		
		if getMainVar('viewingCams') then
			r.gotMoveTime = r.gotMoveTime + e;
			while r.gotMoveTime >= 1 do
				r.gotMoveTime = r.gotMoveTime - 1;
				
				if getRandomBool() then
					setX('bigScare', 976);
					setAlpha('bigScare', 1);
					playAnim('bigScare', 'scare', true);
					
					setSpringCam(200);
					
					return;
				end
			end
		end
	end,
	[200] = function(e)
		if getMainVar('viewingLittle') then
			setSpringCam(100);
		elseif getMainVar('viewingCams') then
			if getAlpha('bigScare') == 0 then
				r.tryGotTime = r.tryGotTime + e;
				while r.tryGotTime >= 1 do
					r.tryGotTime = r.tryGotTime - 1;
					if getRandomBool() then
						setVar('gotYou', 2);
					end
				end
			end
		elseif getMainVar('blackout').alph > 250 then
			setVar('gotYou', 2);
			
			setMainVar('xCam', 1488);
		end
	end
};
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
	
	local up = upCam[r.cam];
	if up then up(e); end
	
	if getMainVar('frozen') then
		if not r.movedFrozen then
			spForceMove();
		end
	elseif r.movedFrozen then
		r.movedFrozen = false;
	end
	
	if r.goingTo > 0 then
		r.goingTime = r.goingTime - t;
		if r.goingTime <= 0 then
			local leave = leaveCam[r.cam];
			if leave then leave(); end
			
			setSpringCam(r.goingTo);
			
			runMainFunc('setStaticProp', {'F', 50 + Random(100)});
			runMainFunc('updateACam');
			
			r.goingTo = 0;
		end
	end
end

local phaseCheck = {
	[25] = function()
		setAlpha('springWindow', 1);
		r.isVisible = true;
	end,
	[40] = function()
		setAlpha('springHead', 1);
		r.isVisible = true;
	end
};
local phaseMove = {
	[25] = function()
		if r.action > 2 then
			resetMove();
			r.gotMovePhase = true; 
		end
	end,
	[30] = function()
		if r.action > 2 then
			resetMove();
			setSpringCam(35);
		end
	end
};
local curCamFunc = {
	[1] = function(a)
		if getMainVar('inAPanel') then return 0; else
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
function makeMove()
	local action = getRandomInt(1, 3 + r.aggro);
	r.action = action;
	
	if action == 1 then
		r.totTurns = r.totTurns + 1;
	else
		if r.cam > 15 then
			r.action = action;
			
			tryFx();
			local pha = phaseMove[r.cam];
			if pha then pha(); end
		else
			local toRun = curCamFunc[r.cam];
			if toRun then 
				local newCam = toRun(action);
				if newCam == 0 then
					r.action = action;
				else
					setSpringCam(newCam);
					tryFx();
					
					local new = onCam[newCam];
					if new then new(); end
					
					r.action = 0;
				end
			else
				r.action = action;
			end
		end
		
		r.totTurns = 0;
	end
end

function resetMove()
	r.totTurns = 0;
	r.action = 0;
end

function tryFx()
	if not r.isVisible then
		springRandSound();
		runMainFunc('staticAddMove');
	end
end

function checkPhase()
	local ph = phaseCheck[r.cam];
	if ph then ph(); end
end

local eerieCheck = {
	[13] = true,
	[15] = true,
};
function checkEerie()
	if r.cam < 3 or r.cam > 16 then
		setMainVar('nearPhase', 2);
		setVar('springEerie', true);
		
		return;
	elseif r.cam < 6 or eerieCheck[r.cam] then
		setMainVar('nearPhase', 1);
		setVar('springEerie', true);
		
		return;
	end
	
	setVar('springEerie', false);
end

local forceTo = {
	[5] = 2,
	[2] = 25
};
local goForced = {
	[1] = 5,
	[2] = 4,
	[3] = 10
}
function spForceMove()
	local go = getRandomInt(1, 3)
	
	if r.cam > 5 and r.cam < 11 then --5, 4, 10
		local newGoin = goForced[go];
		
		setSpringCam(newGoin);
		local new = onCam[newGoin];
		if new then new(); end
		
		if go > 1 then
			r.moveCount = 0;
		end
	elseif forceTo[r.cam] then
		local newGoin = forceTo[r.cam];
		
		setSpringCam(newGoin);
		local new = onCam[newGoin];
		if new then new(); end
	end
end

function enterCams()
	checkPhase();
end

function enterSys()
	checkPhase();
end

function onCloseCams()
	checkPhase();
end

function onCloseSys()
	checkPhase();
	
	if r.cam == 35 and not r.peeked then
		r.peeked = true;
		
		playAnim('springHide', 'hide', true);
		setAlpha('springHide', 1);
	end
end

local lureWorks = {
	[1] = {[40] = true},
	[2] = {
		[25] = true, 
		[3] = true, 
		[4] = true, 
		[5] = true
	},
	[3] = {
		[2] = true, 
		[4] = true
	},
	[4] = {
		[2] = true, 
		[3] = true
	},
	[5] = {
		[2] = true, 
		[6] = true, 
		[7] = true, 
		[8] = true
	},
	[6] = {
		[5] = true, 
		[7] = true
	},
	[7] = {
		[6] = true, 
		[8] = true
	},
	[8] = {
		[7] = true, 
		[5] = true, 
		[9] = true
	},
	[9] = {
		[8] = true, 
		[10] = true
	},
	[10] = {[9] = true}
};
function getLured(i)
	if lureWorks[i][r.cam] then
		lureWorked(i);
	end
end

function lureWorked(i)
	runMainFunc('setStaticProp', {'E', 200});
	
	r.moveCount = 0;
	r.goingTime = Random(100);
	r.goingTo = i;
end

function onHour(h)
	curHour = h;
end

function springFinRun()
	setAlpha('springWalk', 0);
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
