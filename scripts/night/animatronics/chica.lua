local r = {
	ai = 0,
	
	tryingSpawn = false,
	forced = false,
	isOn = false,
	
	triggered = false,
	shownUp = false,
	
	startedScare = false,
	
	lookTime = 0,
	maxTime = 0
};
local curHour = 12;
local max = math.max;
function onCreate()
	runHaxeCode([[
		createGlobalCallback('chicaUpdateView', function(e, t) {
			parentLua.call('updateInCam', [e, t]);
		});
	]]);
	
	setVar('chicaEerie', false);
	
	r.tryingSpawn = getMainVar('curNight') >= 3;
	r.ai = getMainVar('AI');
	r.maxTime = getMainVar('timeLimit');
end

function updateFunc(_, t)
	if not r.forced and r.tryingSpawn and curHour == 5 and getMainVar('actualLooking') ~= 7 then
		r.forced = true;
		
		chicaShowUp();
	end
	
	if r.shownUp then
		local curX = getMainVar('xCam');
		
		if curX > 512 and curX < 1200 then
			setMainVar('xCam', max(curX - (t * 30), 512));
		end
		
		if not r.startedScare and getMainVar('xCam') < 600 then
			doScare();
		end
	end
end

function updateInCam(e, t)
	r.lookTime = r.lookTime + t;
	
	if not r.triggered and r.lookTime >= r.maxTime and getMainVar('scareCooled') then
		r.triggered = true;
		r.shownUp = true;
		r.isOn = false;
		
		setVar('chicaEerie', true);
		if getMainVar('nearPhase') == 0 then
			setMainVar('nearPhase', 1);
		end
		
		setAlpha('chicaOffice', 1);
	end
end

function chicaShowUp()
	r.isOn = true;
	r.tryingSpawn = false;
	
	setCamProp('cameraProps', 7, 'curIn', 'chica');
end

function onCloseCams()
	r.lookTime = 0;
	
	if r.isOn then
		r.isOn = false;
		r.tryingSpawn = true;
	end
	
	setCamProp('cameraProps', 7, 'curIn', '');
end

function doScare()
	r.startedScare = true;
	
	setCamProp('cameraProps', 7, 'curIn', '');
	
	setMainVar('frozen', true);
	setMainVar('scareCooled', false);
	
	playAnim('chicaOffice', 'scare', true);
	doSound('scream3', 1, 'scareSfx');
end

function chicaFinScare()
	setVar('chicaEerie', false);
	r.shownUp = false;
end

function onHour(h)
	curHour = h;
end

local timers = {
	['twen'] = function()
		if r.tryingSpawn and getMainVar('actualLooking') ~= 7 and getRandomInt(1, 10) <= r.ai and curHour ~= 12 then
			chicaShowUp();
		end
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
