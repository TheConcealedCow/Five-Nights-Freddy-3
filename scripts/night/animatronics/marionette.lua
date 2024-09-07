local r = { -- IN THE CODE SHE'S REFERRED TO AS MARIONETTE
	ai = 0,
	
	tryingSpawn = false,
	forced = false,
	
	isOn = false,
	
	didStop = false,
	fullStop = true,
	
	lookTime = 0,
	maxTime = 0,
	
	appearTime = 0,
	
	leftTime = 0,
	rightTime = 0,
	
	lookPhase = 0,
};
local curHour = 12;
function onCreate()
	runHaxeCode([[
		import psychlua.LuaUtils;
		
		createGlobalCallback('marionUpdateView', function(e, t) {
			parentLua.call('updateInCam', [e, t]);
		});
		
		createCallback('setFinFunc', function(o, f, ?p) {
			var obj = LuaUtils.getObjectDirectly(o, false);
			obj.animation.finishCallback = function(n) {
				parentLua.call(f, [obj.animation.curAnim.reversed, p]);
			}
		});
	]]);
	
	setFinFunc('puppetHead', 'puppetEndLook');
	
	r.tryingSpawn = getMainVar('curNight') >= 4;
	r.ai = getMainVar('AI');
	r.maxTime = getMainVar('timeLimit');
end

function updateFunc(e, t)
	if not r.forced and r.tryingSpawn and curHour == 5 and getMainVar('actualLooking') ~= 8 then
		r.forced = true;
		puppetShowUp();
	end
	
	if r.appearTime > 0 then
		r.appearTime = r.appearTime - t;
		
		if r.lookPhase == 0 then
			r.leftTime = r.leftTime + e;
			while r.leftTime >= 0.25 do
				r.leftTime = r.leftTime - 0.25;
				
				if getRandomBool() then
					playAnim('puppetHead', 'lookRight', true);
					r.lookPhase = 1;
				end
			end
		elseif r.lookPhase == 2 then
			r.rightTime = r.rightTime + e;
			while r.rightTime >= 0.25 do
				r.rightTime = r.rightTime - 0.25;
				
				if getRandomBool() then
					playAnim('puppetHead', 'lookRight', true, true);
					r.lookPhase = 3;
				end
			end
		end
	end
	
	if not r.fullStop and r.appearTime <= 0 then
		if getMainVar('blackout').alph > 250 then
			r.fullStop = true;
			
			setAlpha('puppetHead', 0);
		end
		
		addX('puppetHead', (15 * -t));
		
		if not r.didStop then
			r.didStop = true;
			
			setMainVar('marionActive', false);
			runMainFunc('checkHitSides');
			
			doSound('stop', 1, 'puppetSnd');
		end
	end
end

function updateInCam(e, t)
	r.lookTime = r.lookTime + t;
	
	if r.lookTime >= r.maxTime and getMainVar('scareCooled') then
		doScare();
		
		return;
	end
end

function puppetShowUp()
	r.isOn = true;
	r.tryingSpawn = false;
	
	setCamProp('cameraProps', 8, 'curIn', 'puppet');
end

function doScare()
	r.lookTime = 0;
	r.fullStop = false;
	r.isOn = false;
	
	r.appearTime = 1000;
	
	setCamProp('cameraProps', 8, 'curIn', '');
	
	setMainVar('marionActive', true);
	
	setAlpha('puppetHead', 1);
	
	runMainFunc('dropItAll');
	runMainFunc('hitMid');
	
	doSound('mask', 1, 'puppetSnd', true);
end

function onCloseCams()
	r.lookTime = 0;
	
	if r.isOn then
		r.isOn = false;
		r.tryingSpawn = true;
		
		setCamProp('cameraProps', 8, 'curIn', '');
	end
end

function puppetEndLook(re)	
	if re then
		r.lookPhase = 0;
		playAnim('puppetHead', 'left');
	else
		r.lookPhase = 2;
		playAnim('puppetHead', 'right');
	end
end

function onHour(h)
	curHour = h;
end

local timers = {
	['twen'] = function()
		if r.tryingSpawn and getMainVar('actualLooking') ~= 8 and getRandomInt(1, 10) <= r.ai and curHour ~= 12 then
			puppetShowUp();
		end
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
