local r = {
	ai = 0,
	
	tryingSpawn = false,
	forced = false,
	
	isOn = false,
	
	didStop = false,
	fullStop = true,
	
	lookTime = 0,
	maxTime = 0,
};
local curHour = 12;
function onCreate()
	runHaxeCode([[
		createGlobalCallback('mangleUpdateView', function(e, t) {
			parentLua.call('updateInCam', [e, t]);
		});
	]]);
	
	r.tryingSpawn = getMainVar('curNight') >= 2;
	r.ai = getMainVar('AI');
	r.maxTime = getMainVar('timeLimit');
end

function updateFunc(e, t)
	if not r.forced and r.tryingSpawn and curHour == 5 and getMainVar('viewingCams') and getMainVar('actualLooking') ~= 4 then
		r.forced = true;
		mangleShowUp();
	end
end

function updateInCam(e, t)
	r.lookTime = r.lookTime + t;
	
	if r.lookTime >= r.maxTime then
		doScare();
		
		return;
	end
end

function mangleShowUp()
	r.isOn = true;
	r.tryingSpawn = false;
	
	setCamProp('cameraProps', 4, 'curIn', 'mangle');
end

function doScare()
	r.lookTime = 0;
	r.isOn = false;
	
	setCamProp('cameraProps', 4, 'curIn', '');
	setCamProp('systems', 'audio', 'prog', -10);
	
	setAlpha('mangleWindow', 1);
	doTweenY('mangleUP', 'mangleWindow', 412, pl(2.7027027));
	
	runMainFunc('dropItAll');
	runTimer('mangleGo', pl(10));
	
	doSound('garble1', 1, 'mangleSnd', true);
end

function onCloseCams()
	r.lookTime = 0;
	
	if r.isOn then
		r.isOn = false;
		r.tryingSpawn = true;
		
		setCamProp('cameraProps', 4, 'curIn', '');
	end
end

function onHour(h)
	curHour = h;
end

local timers = {
	['twen'] = function()
		if r.tryingSpawn and getMainVar('actualLooking') ~= 4 and getRandomInt(1, 7) <= r.ai and curHour ~= 12 then
			mangleShowUp();
		end
	end,
	
	['mangleGo'] = function()
		doTweenY('mangleDOWN', 'mangleWindow', 513, pl(0.27005347));
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

local tweens = {
	['mangleDOWN'] = function()
		stopSound('mangleSnd');
		
		setMainVar('breatheNum', 500);
	end
};
function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end
