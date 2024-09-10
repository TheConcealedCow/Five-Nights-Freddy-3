local r = {
	chance = 0,
	didSpawn = false,
	canSpawn = true
};
local chancesPerNight = {[2] = 1000, [3] = 50, [4] = 25, [5] = 10};
local min = math.min;
local night = 1;
function onCreate()
	night = min(getMainVar('curNight'), 5);
	
	if night > 1 then
		r.chance = chancesPerNight[night];
	end
end

function updateFunc()
	if r.didSpawn then
		setX('scrnCen', getMainVar('xCam') - 15);
		
		if getMainVar('scareCooled') and objectsOverlap('scrnCen', 'foxyOffice') and pixPerfOverlap('scrnCen', 'foxyOffice') then
			doScare();
			
			return;
		end
	end
end

function doScare()
	r.canSpawn = false;
	r.didSpawn = false;
	
	setMainVar('frozen', true);
	setMainVar('scareCooled', false);
	
	local pos = getMainVar('foxyPos');
	setPos('foxyOffice', pos[1] - 647, pos[2] - 766);
	playAnim('foxyOffice', 'scare', true);
	
	runTimer('scareEndCool', pl(10));
	
	doSound('scream3', 1, 'scareSfx');
end

function enterCams()
	if r.canSpawn and night >= 2 then
		r.didSpawn = (getRandomInt(1, r.chance) == 1);
		
		setVis('foxyOffice', r.didSpawn);
	end
end

function onHour(h)
	curHour = h;
end
