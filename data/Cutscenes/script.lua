local scene = 'gameAssets/Cutscenes/';
local loose = scene .. 'looseObjs/';
local rm = loose .. 'room/';
local bits = loose .. 'bits/';
local hud = scene .. 'hud/';
local BOX = scene .. 'block';

--[[
	// TODO //
	- final scene
	- shadow freddy walking
	- current hint on 4-2
]]

local rem = table.remove;
local ins = table.insert;

local atan2 = math.atan2;
local floor = math.floor;
local sqrt = math.sqrt;
local cos = math.cos;
local sin = math.sin;
local abs = math.abs;

local min = math.min;
local max = math.max;

local curScene = 1;

local xRoom = 3;
local yRoom = 2;

local seeDir = false;

local desk = false;
local gift = false;

local hitErr = false;
man = {
	running = false,
	
	leftTime = 0,
	downTime = 0,
	upTime = 0,
	rightTime = 0
};
local manEnd = {
	
};

local isFinal = false;

local character = {
	canMove = true,
	moveSides = true,
	
	enteredDir = 0,
	
	dir = 'down',
};

local blocks = {
	left = false,
	down = false,
	up = false,
	right = false
};

local topPos = {499, -1};
local stageChars = {
	{'bonnie', {60, 98}, {342, 202}},
	{'chica', {61, 79}, {654, 200}}
};
local parts = {
	{'freddy', {145, 60}, {topPos[1] - 55, topPos[2] + 573}},
	{'bonnie', {203, 77}, {topPos[1] + 149, topPos[2] + 215}},
	{'chica', {179, 63}, {topPos[1] - 157, topPos[2] + 303}},
	{'foxy', {168, 50}, {topPos[1] + 141, topPos[2] + 455}},
};
local numStageChars = 0;

local rooms = {
	[1] = {
		[5] = function()
			setBlock('left', true);
			setBlock('right', true);
			setBlock('up', true);
			
			for i = 1, 3 do
				setAlpha('arcade' .. i, 1);
			end
			
			if isFinal then
				for i = 1, 4 do
					setAlpha('child' .. i, 1);
				end
			end
			
			setAlpha('blood1', 1);
			setAlpha('blood3', 1);
			setAlpha('blood4', 1);
			
			setAlpha('checkers', 1);
		end
	},
	[2] = {
		[1] = function()
			setBlock('left', true);
			setBlock('down', true);
			setBlock('up', true);
			
			gift = true;
			setAlpha('gift', 1);
		end,
		[2] = function()
			setBlock('up', true);
			
			setAlpha('desk221', 1);
			setAlpha('desk222', 1);
			
			setAlpha('checkers', 1);
		end,
		[3] = function()
			setBlock('up', true);
			
			for i = curScene, 2 do
				setAlpha(stageChars[i][1] .. 'Stage', 1);
			end
			
			setAlpha('stage', 1);
			setAlpha('trash', 1);
			
			setAlpha('checkers', 1);
		end,
		[4] = function()
			setBlock('up', true);
			
			setAlpha('desk241', 1);
			setAlpha('desk242', 1);
			
			setAlpha('trash', 1);
			setAlpha('checkers', 1);
		end,
		[5] = function()
			setBlock('right', true);
			
			for i = 1, min(curScene - 1, 4) do
				local p = parts[i];
				setAlpha(parts[i][1] .. 'Part', 1);
			end
			
			setAlpha('block', 1);
		end
	},
	[3] = {
		[2] = function()
			setBlock('left', true);
			
			setAlpha('desk321', 1);
			
			setAlpha('curtain', 1);
			setAlpha('checkers', 1);
		end,
		[3] = function()
			setBlock('down', true);
			
			setAlpha('desk331', 1);
			setAlpha('desk332', 1);
			
			setAlpha('blood4', 1);
		end,
		[4] = function()
			setBlock('right', true);
			
			setAlpha('desk341', 1);
			setAlpha('desk342', 1);
			
			setAlpha('blood1', 1);
			setAlpha('blood4', 1);
			
			setAlpha('checkers', 1);
		end,
		[5] = function()
			setBlock('left', true);
			setBlock('right', true);
			setBlock('down', true);
			
			setAlpha('block', 1);
			setAlpha('blood4', 1);
			setAlpha('checkers', 1);
		end
	},
	[4] = {
		[2] = function()
			character.moveSides = false;
			setBlock('right', true);
			setBlock('left', true);
			
			showTask();
			
			setAlpha('hall1', 1);
			setAlpha('hall2', 1);
			
			setAlpha('trash', 1);
			setAlpha('blood1', 1);
			setAlpha('checkers', 1);
		end,
		[4] = function()
			character.moveSides = false;
			setBlock('right', true);
			setBlock('left', true);
			
			setAlpha('hall1', 1);
			setAlpha('hall2', 1);
		end
	},
	[5] = {
		[2] = function()
			setBlock('left', true);
			setBlock('down', true);
		end,
		[3] = function()
			setBlock('up', true);
			setBlock('down', true);
			
			desk = true;
			setAlpha('tableFan', 1);
			
			setAlpha('checkers', 1);
		end,
		[4] = function()
			setBlock('right', true);
			setBlock('down', true);
		end
	},
};

local startPos = {
	{500, 272},
	{342, 212},
	{658, 212},
	{268, 420},
	{496, 494}
};

local rainSpawns = {
	{44, -25},
	{126, -25},
	{208, -25},
	{290, -25},
	{372, -25},
	{454, -25},
	{536, -25},
	{618, -25},
	{700, -25},
	{782, -25},
	{870, -27},
	{946, -23},
};
local rain = {};

local ratSpawns = {
	{162, 587},
	{354, 496},
	{96, 370},
	{240, 234},
	{492, 376},
	{446, 620}
};
local ratNodes = {
	[0] = {0, 0},
	{501, -6},
	{102, 1},
	{342, -4},
	{237, -3}
};
local rats = {};

local sv = 'FNAF3';
function create()
	luaDebugMode = true;
	
	runHaxeCode([[
		import flixel.FlxCamera;
		import psychlua.LuaUtils;
		
		var floorCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		floorCam.bgColor = 0xFF000000;
		floorCam.pixelPerfectRender = true;
		floorCam.antialiasing = false;
		setVar('floorCam', floorCam);
		
		var mainCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		mainCam.bgColor = 0x00000000;
		mainCam.pixelPerfectRender = true;
		mainCam.antialiasing = false;
		setVar('mainCam', mainCam);
		
		var txtCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		txtCam.bgColor = 0x00000000;
		txtCam.pixelPerfectRender = true;
		txtCam.antialiasing = false;
		setVar('txtCam', txtCam);
		
		var hudCam = FlxG.cameras.add(new FlxCamera(0, 0, 1024, 768), false);
		hudCam.bgColor = 0x00000000;
		hudCam.pixelPerfectRender = true;
		hudCam.antialiasing = false;
		setVar('hudCam', hudCam);
	]]);
	
	doSound('rainstorm2', 1, 'rainSnd', true);
	doSound('scanner4', 1, 'scanSnd', true);
	
	--curScene = min(getDataFromSave(sv, 'scene', 1), 5);
	
	if curScene == 4 then
		xRoom = 2;
		yRoom = 3;
	end
	
	makeScene();
	makeHud();
	
	initChar();
	
	makeTables();
	makeForScene();
	makeShadow();
	
	checkFollow();
	resetRoom();
	tryRatSpawn();
	
	cacheSounds();
	
	runTimer('hideStuff', pl(0.1));
	runTimer('pOne', pl(0.1), 0);
	runTimer('tFiv', pl(0.25), 0);
	runTimer('SMov', pl(0.29), 0);
	runTimer('hSec', pl(0.49), 0);
	runTimer('fiv', pl(5), 0);
	
	if curScene < 5 then runTimer('forceEnd', pl(120)); end
end

function makeScene()
	makeAnimatedLuaSprite('checkers', scene .. 'floor');
	addAnimationByPrefix('checkers', 'idle', 'Idle', 0);
	addAnimationByPrefix('checkers', 'glow', 'Glow', 3);
	playAnim('checkers', 'idle', true);
	setCam('checkers', 'floorCam');
	addLuaSprite('checkers');
	setAlpha('checkers', 0.00001);
	
	makeScanLines();
	makeStaticObjs();
	
	makeWalls();
	makeBlocks();
	
	makeLooseObjs();
end

local lineJumps = {
	39,
	81,
	123,
	165,
	207,
	249,
	291,
	333,
	375,
	417,
	459,
	501,
	543,
	585,
	627,
	669,
	711,
	753,
	795
};
function makeScanLines()
	makeLuaSprite('scan1', nil, 0, -46);
	makeGraphic('scan1', 1, 1, 'ffffff');
	scaleObject('scan1', 1024, 32);
	addToOffsets('scan1', 0, 15);
	setCam('scan1', 'floorCam');
	addLuaSprite('scan1');
	startTween('scanMove1', 'scan1', {y = -46 + 887}, pl(23.97297297), {type = 'LOOPING'});
	
	makeLuaSprite('scan2', nil, 0, -48);
	makeGraphic('scan2', 1, 1, 'ffffff');
	scaleObject('scan2', 1024, 78);
	addToOffsets('scan2', 0, 36);
	setCam('scan2', 'floorCam');
	addLuaSprite('scan2');
	startTween('scanMove2', 'scan2', {y = -48 + 888}, pl(40.363636363), {type = 'LOOPING'});
	
	makeLuaSprite('scan3', nil, 0, -26 - 16);
	makeGraphic('scan3', 1, 1, 'ffffff');
	scaleObject('scan3', 1024, 32);
	setCam('scan3', 'floorCam');
	addLuaSprite('scan3');
end

function makeWalls()
	makeLuaSprite('LU1', BOX, -2, -8);
	scaleObject('LU1', 310, 88);
	setCam('LU1', 'mainCam');
	addLuaSprite('LU1');
	setColor('LU1', 0x002B2B5F);
	
	makeLuaSprite('LU2', BOX, -2, 80);
	scaleObject('LU2', 102, 134);
	setCam('LU2', 'mainCam');
	addLuaSprite('LU2');
	setColor('LU2', 0x002B2B5F);
	
	makeLuaSprite('RU1', BOX, 714, -8);
	scaleObject('RU1', 310, 88);
	setCam('RU1', 'mainCam');
	addLuaSprite('RU1');
	setColor('RU1', 0x002B2B5F);
	
	makeLuaSprite('RU2', BOX, 926, 79);
	scaleObject('RU2', 102, 134);
	setCam('RU2', 'mainCam');
	addLuaSprite('RU2');
	setColor('RU2', 0x002B2B5F);
	
	
	makeLuaSprite('RD1', BOX, 716, 682);
	scaleObject('RD1', 310, 88);
	setCam('RD1', 'mainCam');
	addLuaSprite('RD1');
	setColor('RD1', 0x002B2B5F);
	
	makeLuaSprite('RD2', BOX, 926, 550);
	scaleObject('RD2', 102, 134);
	setCam('RD2', 'mainCam');
	addLuaSprite('RD2');
	setColor('RD2', 0x002B2B5F);
	
	makeLuaSprite('LD1', BOX, -2, 680);
	scaleObject('LD1', 310, 88);
	setCam('LD1', 'mainCam');
	addLuaSprite('LD1');
	setColor('LD1', 0x002B2B5F);
	
	makeLuaSprite('LD2', BOX, -2, 550);
	scaleObject('LD2', 102, 134);
	setCam('LD2', 'mainCam');
	addLuaSprite('LD2');
	setColor('LD2', 0x002B2B5F);
end

function makeBlocks()
	makeLuaSprite('leftBlock', BOX, 4, 213);
	scaleObject('leftBlock', 96, 342);
	setCam('leftBlock', 'mainCam');
	addLuaSprite('leftBlock');
	setColor('leftBlock', 0x002B2B5F);
	setAlpha('leftBlock', 0);
	
	makeLuaSprite('downBlock', BOX, 308, 684);
	scaleObject('downBlock', 408, 88);
	setCam('downBlock', 'mainCam');
	addLuaSprite('downBlock');
	setColor('downBlock', 0x002B2B5F);
	setAlpha('downBlock', 0);
	
	makeLuaSprite('upBlock', BOX, 308, -8);
	scaleObject('upBlock', 408, 88);
	setCam('upBlock', 'mainCam');
	addLuaSprite('upBlock');
	setColor('upBlock', 0x002B2B5F);
	setAlpha('upBlock', 0);
	
	makeLuaSprite('rightBlock', BOX, 927, 213);
	scaleObject('rightBlock', 96, 342);
	setCam('rightBlock', 'mainCam');
	addLuaSprite('rightBlock');
	setColor('rightBlock', 0x002B2B5F);
	setAlpha('rightBlock', 0);
	
	
	makeLuaSprite('leftGo', BOX, -1 - 35, 369 - 165);
	scaleObject('leftGo', 70, 330);
	setCam('leftGo', 'mainCam');
	addLuaSprite('leftGo');
	setAlpha('leftGo', 0);
	
	makeLuaSprite('rightGo', BOX, 1023 - 35, 377 - 165);
	scaleObject('rightGo', 70, 330);
	setCam('rightGo', 'mainCam');
	addLuaSprite('rightGo');
	setAlpha('rightGo', 0);
	
	makeLuaSprite('upGo', BOX, 499 - 233, -1 - 39);
	scaleObject('upGo', 466, 78);
	setCam('upGo', 'mainCam');
	addLuaSprite('upGo');
	setAlpha('upGo', 0);
	
	makeLuaSprite('downGo', BOX, 525 - 233, 771 - 39);
	scaleObject('downGo', 466, 78);
	setCam('downGo', 'mainCam');
	addLuaSprite('downGo');
	setAlpha('downGo', 0);
	
	
	makeLuaSprite('takeBox', BOX, 501 - 369, 387 - 59);
	scaleObject('takeBox', 738, 118);
	setCam('takeBox', 'mainCam');
	addLuaSprite('takeBox');
	setAlpha('takeBox', 0);
end

function makeHud()
	makeLuaSprite('err', hud .. 'text/err', 222, 618);
	addToOffsets('err', 99, 47);
	setCam('err', 'txtCam');
	addLuaSprite('err');
	setAlpha('err', 0.00001);
	
	makeLuaSprite('fol', hud .. 'text/follow', 14, 660);
	setCam('fol', 'txtCam');
	addLuaSprite('fol');
	setAlpha('fol', 0.00001);
	
	makeLuaSprite('lines', hud .. 'lines');
	setCam('lines', 'txtCam');
	addLuaSprite('lines');
	
	makeAnimatedLuaSprite('static', hud .. 'static');
	addAnimationByPrefix('static', 'static', 'Static', 3);
	setCam('static', 'hudCam');
	addLuaSprite('static');
	setAlpha('static', 0.00001);
end

local bloodPos = {
	{316, 308},
	{711, 308},
	{316, 468},
	{711, 468}
};
function makeStaticObjs()
	makeLuaSprite('ratCache', loose .. 'rat');
	addLuaSprite('ratCache');
	
	for i = 1, 4 do
		local t = 'blood' .. i;
		local p = bloodPos[i];
		makeLuaSprite(t, rm .. 'blood', p[1], p[2]);
		addToOffsets(t, 199, 79);
		setCam(t, 'floorCam');
		addLuaSprite(t);
		setAlpha(t, 0.00001);
	end
end

local arcadePos = {
	{557, 208},
	{381, 210},
	{211, 214}
};
local desksForRooms = {
	[2] = {
		[2] = function()
			makeLuaSprite('desk221', rm .. 'table/1', (topPos[1] - 243) - 149, (topPos[2] + 187) - 101);
			setCam('desk221', 'mainCam');
			addLuaSprite('desk221');
			setAlpha('desk221', 0.00001);
			
			makeLuaSprite('desk222', rm .. 'table/1', (topPos[1] + 265) - 149, (topPos[2] + 187) - 101);
			setCam('desk222', 'mainCam');
			addLuaSprite('desk222');
			setAlpha('desk222', 0.00001);
		end,
		[4] = function()
			makeLuaSprite('desk241', rm .. 'table/2', (topPos[1] - 243) - 149, (topPos[2] + 187) - 99);
			setCam('desk241', 'mainCam');
			addLuaSprite('desk241');
			setAlpha('desk241', 0.00001);
			
			makeLuaSprite('desk242', rm .. 'table/2', (topPos[1] + 265) - 149, (topPos[2] + 187) - 99);
			setCam('desk242', 'mainCam');
			addLuaSprite('desk242');
			setAlpha('desk242', 0.00001);
		end
	},
	[3] = {
		[2] = function()
			makeLuaSprite('desk321', rm .. 'table/3', (topPos[1] + 265) - 149, (topPos[2] + 537) - 98);
			setCam('desk321', 'mainCam');
			addLuaSprite('desk321');
			setAlpha('desk321', 0.00001);
		end,
		[3] = function()
			makeLuaSprite('desk331', rm .. 'table/4', (topPos[1] - 243) - 147, (topPos[2] + 537) - 112);
			setCam('desk331', 'mainCam');
			addLuaSprite('desk331');
			setAlpha('desk331', 0.00001);
			
			makeLuaSprite('desk332', rm .. 'table/4', (topPos[1] + 265) - 147, (topPos[2] + 537) - 112);
			setCam('desk332', 'mainCam');
			addLuaSprite('desk332');
			setAlpha('desk332', 0.00001);
		end,
		[4] = function()
			makeLuaSprite('desk341', rm .. 'table/5', (topPos[1] - 243) - 148, (topPos[2] + 187) - 103);
			setCam('desk341', 'mainCam');
			addLuaSprite('desk341');
			setAlpha('desk341', 0.00001);
			
			makeLuaSprite('desk342', rm .. 'table/5', (topPos[1] + 265) - 148, (topPos[2] + 537) - 103);
			setCam('desk342', 'mainCam');
			addLuaSprite('desk342');
			setAlpha('desk342', 0.00001);
		end
	}
};
function makeLooseObjs()
	makeLuaSprite('block', rm .. 'blocked', 958, 352);
	addToOffsets('block', 65, 200);
	setCam('block', 'mainCam');
	addLuaSprite('block');
	setAlpha('block', 0.00001);
	
	makeLuaSprite('stage', rm .. 'stage', 495, 393);
	addToOffsets('stage', 310, 210);
	setCam('stage', 'mainCam');
	addLuaSprite('stage');
	setAlpha('stage', 0.00001);
	
	numStageChars = max(3 - curScene, 0);
	
	for i = curScene, 2 do
		local m = stageChars[i];
		local t = m[1] .. 'Stage';
		local pos = m[3];
		local off = m[2];
		
		makeLuaSprite(t, scene .. 'chars/' .. m[1] .. '/stage', pos[1], pos[2]);
		addToOffsets(t, off[1], off[2]);
		setCam(t, 'mainCam');
		addLuaSprite(t);
	end
	
	for i = 1, #arcadePos do
		local t = 'arcade' .. i;
		local p = arcadePos[i];
		makeLuaSprite(t, rm .. 'arcade', p[1], p[2]);
		addToOffsets(t, 68, 104);
		setCam(t, 'mainCam');
		addLuaSprite(t);
		setAlpha(t, 0.00001);
	end
	
	makeLuaSprite('trash', rm .. 'trash', 492, 362);
	addToOffsets('trash', 376, 261);
	setCam('trash', 'mainCam');
	addLuaSprite('trash');
	setAlpha('trash', 0.00001);
	
	makeLuaSprite('gift', rm .. 'gift', (topPos[1] - 101) - 223, (topPos[2] + 343) - 189);
	setCam('gift', 'mainCam');
	addLuaSprite('gift');
	setAlpha('gift', 0.00001);
	
	makeLuaSprite('tableFan', rm .. 'tableFan', (topPos[1] + 1) - 175, (topPos[2] + 185) - 151);
	setCam('tableFan', 'mainCam');
	addLuaSprite('tableFan');
	setAlpha('tableFan', 0.00001);
	
	makeLuaSprite('curtain', rm .. 'curtain', 28, 370);
	addToOffsets('curtain', 99, 219);
	setCam('curtain', 'mainCam');
	addLuaSprite('curtain');
	setAlpha('curtain', 0.00001);
	
	
	makeLuaSprite('hall1', BOX, 214, -9);
	scaleObject('hall1', 96, 700);
	setCam('hall1', 'mainCam');
	addLuaSprite('hall1');
	setColor('hall1', 0x002B2B5F);
	setAlpha('hall1', 0);
	
	makeLuaSprite('hall2', BOX, 716, -3);
	scaleObject('hall2', 96, 700);
	setCam('hall2', 'mainCam');
	addLuaSprite('hall2');
	setColor('hall2', 0x002B2B5F);
	setAlpha('hall2', 0);
	
	makeTask();
end

function makeTables()
	for _, y in pairs(desksForRooms) do
		for _, x in pairs(y) do
			x();
		end
	end
end

function makeForScene()
	isFinal = (curScene >= 5);
	
	for i = 1, min(curScene, 4) do
		local p = parts[i];
		local t = p[1] .. 'Part';
		
		makeLuaSprite(t, bits .. p[1], p[3][1], p[3][2]);
		addToOffsets(t, p[2][1], p[2][2]);
		setCam(t, 'mainCam');
		addLuaSprite(t);
		setAlpha(t, 0.00001);
	end
	
	if isFinal then
		
	else
		makeAnimatedLuaSprite('man', scene .. 'chars/man/man', topPos[1] + 3, topPos[2] + 15);
		addAnimationByPrefix('man', 'man', 'Man', 6);
		addAnimationByPrefix('man', 'takeApart', 'TakeApart', 6);
		addOffset('man', 'man', 103, 101);
		addOffset('man', 'takeApart', 91, 101);
		playAnim('man', 'man', true);
		setCam('man', 'mainCam');
		addLuaSprite('man');
		setAlpha('man', 0.00001);
	end
end

local makeForTask = {
	[1] = function()
		
	end,
	[2] = function()
		
	end,
	[3] = function()
		
	end,
	[4] = function()
		
	end
};
function makeTask()
	local h = makeForTask[curScene];
	if h then h(); end
end

local playAs = {
	'freddy',
	'bonnie',
	'chica',
	'foxy',
	'child',
	
	'shadow'
};
local playOff = {
	['freddy'] = {
		left = {93, 99},
		right = {106, 99},
		
		up = {104, 101},
		down = {104, 99}
	},
	['bonnie'] = {
		left = {98, 92},
		right = {101, 92},
		
		up = {105, 95},
		down = {105, 93}
	},
	['chica'] = {
		left = {105, 108},
		right = {105, 108},
		
		up = {104, 110},
		down = {105, 108}
	},
	['foxy'] = {
		left = {105, 98},
		right = {104, 98},
		
		up = {104, 102},
		down = {103, 102}
	},
	['child'] = {
		left = {25, 43},
		right = {25, 43},
		
		up = {25, 43},
		down = {25, 43}
	},
	
	['shadow'] = {
		left = {93, 100},
		right = {106, 100},
		
		up = {104, 102},
		down = {104, 99}
	},
};
local curActualPos = {0, 0};
function initChar()
	local play = playAs[curScene];
	local p = startPos[curScene];
	curActualPos = {tonumber(p[1]), tonumber(p[2])};
	
	makeLuaSprite('charBox', BOX);
	scaleObject('charBox', 62, 62);
	setCam('charBox', 'mainCam');
	addLuaSprite('charBox');
	setVis('charBox', false);
	
	makeLuaSprite('LBox', BOX);
	scaleObject('LBox', 58, 102);
	setCam('LBox', 'mainCam');
	addLuaSprite('LBox');
	setVis('LBox', false);
	
	makeLuaSprite('DBox', BOX);
	scaleObject('DBox', 94, 62);
	setCam('DBox', 'mainCam');
	addLuaSprite('DBox');
	setVis('DBox', false);
	
	makeLuaSprite('UBox', BOX);
	scaleObject('UBox', 94, 62);
	setCam('UBox', 'mainCam');
	addLuaSprite('UBox');
	setVis('UBox', false);
	
	makeLuaSprite('RBox', BOX);
	scaleObject('RBox', 58, 102);
	setCam('RBox', 'mainCam');
	addLuaSprite('RBox');
	setVis('RBox', false);
	
	seeDir = true;
	makeLuaSprite('cont', hud .. 'text/cont');
	addToOffsets('cont', 128, 80);
	setCam('cont', 'mainCam');
	addLuaSprite('cont');
	
	makeChar('char', play);
	updateCharacterPos();
end

function makeChar(t, c)
	local LNR = (c == 'chica' or c == 'foxy');
	
	local lPref = (LNR and 'Left' or 'Side');
	local rPref = (LNR and 'Right' or 'Side');
	
	local off = playOff[c];
	
	makeAnimatedLuaSprite(t, scene .. 'chars/' .. c .. '/' .. c);
	addAnimationByPrefix(t, 'up', 'Up', 3);
	addAnimationByPrefix(t, 'down', 'Down', 3);
	addAnimationByPrefix(t, 'left', lPref, 3);
	addAnimationByPrefix(t, 'right', rPref, 3);
	if not LNR then setAnimFlipX(t, 'left', true); end
	
	addOffset(t, 'left', off.left[1], off.left[2]);
	addOffset(t, 'right', off.right[1], off.right[2]);
	addOffset(t, 'up', off.up[1], off.up[2]);
	addOffset(t, 'down', off.down[1], off.down[2]);
	
	playAnim(t, 'down', true);
	setCam(t, 'mainCam');
	addLuaSprite(t);
end

function updateCharacterPos()
	local pos = curActualPos;
	
	setPos('charBox', pos[1] - 31, pos[2] - 31);
	setPos('LBox', (pos[1] - 83) - 29, (pos[2] + 3) - 51);
	setPos('DBox', (pos[1] - 1) - 47, (pos[2] + 63) - 31);
	setPos('UBox', (pos[1] + 1) - 47, (pos[2] - 61) - 31);
	setPos('RBox', (pos[1] + 79) - 29, (pos[2] - 3) - 51);
	
	setPos('char', pos[1] + 1, pos[2] + 1);
	
	if seeDir then setPos('cont', pos[1], (pos[2] + 63) - 269); end
end

local showForScene = {
	[1] = function()
	
	end,
	[2] = function()
	
	end,
	[3] = function()
	
	end,
	[4] = function()
		setAlpha('findTxt', 1);
		setAlpha('find', 1);
	end
};
function showTask()
	local h = showForScene[curScene];
	if h then h(); end
end

local hideForScene = {
	[1] = function()
	
	end,
	[2] = function()
	
	end,
	[3] = function()
	
	end,
	[4] = function()
		setAlpha('findTxt', 0);
		setAlpha('find', 0);
	end
};
function hideTask()
	local h = hideForScene[curScene];
	if h then h(); end
end

function leaveARoom()
	for _, s in pairs({'left', 'down', 'up', 'right'}) do
		setBlock(s, false);
	end
	
	character.moveSides = true;
	
	killRain();
	killRats();
	hideTask();
	
	hideEverything();
end

function enterARoom()
	leaveARoom();
	resetRoom();
	tryRatSpawn();
	
	if seeDir then
		removeLuaSprite('cont');
		seeDir = false;
	end
end

function resetRoom()
	local y = rooms[yRoom];
	if y then
		local x = y[xRoom];
		if x then x(); end
	end
end

function killRain()
	
end

function killRats() -- https://www.youtube.com/watch?v=O5cIZ77jBTw&t=290s
	while #rats > 0 do
		local r = rem(rats, 1); -- give them the remmie the rat treatment
		removeLuaSprite(r.tag);
	end
end

function tryRatSpawn()
	if yRoom == 1 and xRoom == 5 then return; end
	
	for i = 1, #ratSpawns do
		if Random(7) == 1 then
			makeARat(ratSpawns[i]);
		end
	end
end

local spdMult = 7.487569464755777;
local ratSpd = floor(50 * spdMult);
function makeARat(p) -- https://www.youtube.com/watch?v=T_Z2ixASt8Q
	local m = #rats + 1;
	local t = 'ratSpr' .. m;
	
	makeLuaSprite(t, loose .. 'rat', p[1], p[2]);
	addToOffsets(t, 33, 17);
	setCam(t, 'floorCam');
	addLuaSprite(t);
	
	local toAdd = {
		tag = t,
		
		curNode = 1,
		prevNode = 0,
		
		isMoving = false,
		
		dir = 1,
		
		pos = {tonumber(p[1]), tonumber(p[2])},
		at = {0, 0},
		off = {0, 0},
		dis = {0, 0},
		trig = {0, 0}
	};
	
	calcTrig(toAdd);
	ins(rats, toAdd);
end

function updateRats(e)
	local vel = (ratSpd * e);
	for i = 1, #rats do
		updateARat(rats[i], e, vel);
	end
end

local ratOff = {
	[-1] = {32, 17},
	[1] = {33, 17}
};
function updateARat(r, e, v)
	if not r.isMoving then return; end
	
	r.off[1] = r.off[1] + (v * r.trig[1]);
	r.off[2] = r.off[2] + (v * r.trig[2]);
	
	local abOff = {abs(r.off[1]), abs(r.off[2])};
	local abDis = {abs(r.dis[1]), abs(r.dis[2])};
	
	while abOff[1] >= abDis[1] and abOff[2] >= abDis[2] do
		r.prevNode = r.curNode;
		r.curNode = (r.curNode + r.dir);
		
		local noCalc = false;
		
		local extraDistance = {abOff[1] - abDis[1], abOff[2] - abDis[2]};
		local disPyth = sqrt((extraDistance[1] * extraDistance[1]) + (extraDistance[2] * extraDistance[2]));
		local totPyth = sqrt((abDis[1] * abDis[1]) + (abDis[2] * abDis[2]));
		local per = 0;
		
		if totPyth == 0 then noCalc = true; else
			per = disPyth / totPyth;
		end
		
		if r.curNode == 0 or r.curNode == #ratNodes then r.dir = r.dir * -1; end
		
		calcTrig(r);
		
		local newOff = ratOff[r.dir];
		updateHitbox(r.tag);
		addToOffsets(r.tag, newOff[1], newOff[2]);
		setFlipX(r.tag, (r.dis[1] < 0));
		
		if not noCalc then
			r.off = {r.dis[1] * per, r.dis[2] * per};
		end
		
		abOff = {abs(r.off[1]), abs(r.off[2])};
		abDis = {abs(r.dis[1]), abs(r.dis[2])};
	end
	
	setPos(r.tag, r.pos[1] + r.at[1] + r.off[1], r.pos[2] + r.at[2] + r.off[2]);
end

function calcTrig(r)
	local cur = ratNodes[r.curNode];
	local las = ratNodes[r.prevNode];
	
	local xDist = cur[1] - las[1];
	local yDist = cur[2] - las[2];
	
	local ang = atan2(yDist, xDist);
	
	local xNew = cutForComp(cos(ang));
	local yNew = cutForComp(sin(ang));
	
	r.at = las;
	r.off = {0, 0};
	r.dis = {xDist, yDist};
	r.trig = {xNew, yNew};
end

function setBlock(b, s)
	blocks[b] = s;
	setAlpha(b .. 'Block', s);
end

function hideEverything()
	setAlpha('checkers', 0);
	setAlpha('block', 0);
	setAlpha('stage', 0);
	setAlpha('trash', 0);
	
	setAlpha('gift', 0);
	setAlpha('curtain', 0);
	setAlpha('tableFan', 0);
	
	setAlpha('desk221', 0);
	setAlpha('desk222', 0);
	
	setAlpha('desk241', 0);
	setAlpha('desk242', 0);
	
	setAlpha('desk321', 0);
	
	setAlpha('desk331', 0);
	setAlpha('desk332', 0);
	
	setAlpha('desk341', 0);
	setAlpha('desk342', 0);
	
	if isFinal then
		setAlpha('suit', 0);
		setAlpha('manFinal', 0);
		
		for i = 1, 4 do
			setAlpha('child' .. i, 1);
		end
	else
		setAlpha('man', 0);
	end
	
	for i = 1, min(curScene, 4) do
		local p = parts[i];
		setAlpha(parts[i][1] .. 'Part', 0);
	end
	
	gift = false;
	desk = false;
	
	for i = 1, 4 do
		setAlpha('blood' .. i, 0);
		if i < 4 then setAlpha('arcade' .. i, 0); end
		if i < 3 then setAlpha('hall' .. i, 0); end
		if i <= 2 then setAlpha(stageChars[i][1] .. 'Stage', 0); end
	end
end

local rainTime = 0;

local tickRate = 0;
local frameSec = 1 / 60;
function onUpdatePost(e)
	e = e * playbackRate;
	local ti = e * 60;
	
	updateRats(e);
	updateMan(e, ti);
	
	local ticks = 0;
	tickRate = tickRate + e;
	while (tickRate >= frameSec) do
		tickRate = tickRate - frameSec;
		ticks = ticks + 1;
	end
	
	callOnLuas('updateFunc', {e, ti, ticks});
	
	return Function_StopLua;
end

function tryMovements()
	if not character.canMove then return; end
	
	if keyboardPressed('W') then
		moveDir('up');
	end
	if keyboardPressed('S') then
		moveDir('down');
	end
	if character.moveSides and keyboardPressed('D') then
		moveDir('right');
	end
	if character.moveSides and keyboardPressed('A') then
		moveDir('left');
	end
	
	if character.dir ~= '' then
		playAnim('char', character.dir);
	end
	
	updateCharacterPos();
	checkHitEvent();
end

local dirFunc = {
	['left'] = function()
		if blocks.left and objectsOverlap('LBox', 'leftBlock') then return; end
		if objOnSpecial('LBox') then return; end
		if objOnCorner('LBox') then return; end
		if objOnDesk('LBox') then return; end
		
		curActualPos[1] = curActualPos[1] - 30;
		
		return true;
	end,
	['right'] = function()
		if blocks.right and objectsOverlap('RBox', 'rightBlock') then return; end
		if objOnSpecial('RBox') then return; end
		if objOnCorner('RBox') then return; end
		if objOnDesk('RBox') then return; end
		
		curActualPos[1] = curActualPos[1] + 30;
		
		return true;
	end,
	
	['up'] = function()
		if blocks.up and objectsOverlap('UBox', 'upBlock') then return; end
		if objOnSpecial('UBox') then return; end
		if objOnCorner('UBox') then return; end
		if objOnDesk('UBox') then return; end
		
		if not isFinal and yRoom == 2 and xRoom == 5 and objectsOverlap('charBox', 'upBlock') then
			curActualPos[2] = curActualPos[2] + 60;
			hitErr = true;
			
			triggerErr();
		else
			curActualPos[2] = curActualPos[2] - 30;
		end
		
		return true;
	end,
	['down'] = function()
		if blocks.down and objectsOverlap('DBox', 'downBlock') then return; end
		if objOnSpecial('DBox') then return; end
		if objOnCorner('DBox') then return; end
		if objOnDesk('DBox') then return; end
		
		curActualPos[2] = curActualPos[2] + 30;
		
		return true;
	end
};
function moveDir(d)
	local f = dirFunc[d];
	if f then 
		local ret = f();
		if ret then character.dir = d; end
	end
end

function objOnSpecial(o)
	if desk and pixPerfOverlap(o, 'tableFan') then return true; end
	if gift and pixPerfOverlap(o, 'gift') then return true; end
end

local desksInRoom = {
	[2] = {
		[2] = {
			'desk221',
			'desk222'
		},
		[4] = {
			'desk241',
			'desk242'
		},
	},
	[3] = {
		[2] = {
			'desk321'
		},
		[3] = {
			'desk331',
			'desk332'
		},
		[4] = {
			'desk341',
			'desk342'
		},
	},
};
function objOnDesk(o)
	local y = desksInRoom[yRoom];
	if y then
		local x = y[xRoom];
		if x then
			for i = 1, #x do
				local t = x[i];
				
				if pixPerfOverlap(o, t) then return true; end
			end
		end
	end
end

function objOnCorner(o)
	for _, s in pairs({'LU', 'LD', 'RU', 'RD'}) do
		for i = 1, 2 do
			local t = s .. i;
			if objectsOverlap(o, t) then return true; end
		end
	end
end

function checkHitEvent()
	for _, s in pairs({'left', 'down', 'up', 'right'}) do
		if objectsOverlap('charBox', s .. 'Go') then
			shiftRoom(s);
			
			return;
		end
	end
	
	if hitErr and objectsOverlap('charBox', 'takeBox') then
		hitErr = false;
		character.canMove = false;
		
		manRunIn();
	end
end

local offForApart = {
	{0, 66},
	{2, 8},
	{6, 64},
	{10, 32}
};
local tryingMan = false;
function updateMan(e, t)
	if tryingMan then
		if yRoom < 4 then
			tryingMan = false;
			character.canMove = false;
			
			manRunIn();
			
			setPos('man', topPos[1] + 475, topPos[2] + 373);
		end
	end
	
	if man.running then
		manMove(e);
		
		if pixPerfOverlap('man', 'char') then
			local pos = curActualPos;
			local p = parts[curScene][1] .. 'Part';
			local off = offForApart[curScene];
			
			man.running = false;
			
			playAnim('man', 'takeApart');
			setPos('man', pos[1] + 111, pos[2] + 3);
			
			setAlpha('char', 0);
			setAlpha(p, 1);
			setPos(p, pos[1] + off[1] + 1, pos[2] + off[2] + 1);
			
			runTimer('endScene', pl(100 / 60));
		end
	end
end

function manMove(e)
	local pos = getPos('man');
	local box = curActualPos;
	
	if pos[2] < box[2] then
		manAddAndMove('down', e, 
		function() addY('man', 30); end
		);
	end
		if pos[2] > box[2] then
		manAddAndMove('up', e, 
		function() addY('man', -30); end
		);
	end
	
	if pos[1] < box[1] then
		manAddAndMove('right', e, 
		function() addX('man', 30); end
		);
	end
	if pos[1] > box[1] then
		manAddAndMove('left', e, 
		function() addX('man', -30); end
		);
	end
end

function manAddAndMove(d, e, f)
	local p = (d .. 'Time');
	
	man[p] = man[p] + e;
	while man[p] >= 0.1 do
		man[p] = man[p] - 0.1;
		f();
	end
end

function manRunIn()
	man.running = true;
	setAlpha('man', 1);
	playAnim('man', 'man', true);
	
	doSound('crazy garble');
end

local sidePos = {
	left = {-1, 369},
	down = {525, 771},
	up = {499, -1},
	right = {1023, 377}
};
local shiftFunc = {
	['left'] = function()
		character.enteredDir = 4;
		xRoom = xRoom - 1;
		
		local toGo = sidePos.left;
		curActualPos = {tonumber(toGo[1] + 880), tonumber(toGo[2])};
	end,
	['down'] = function()
		character.enteredDir = 3;
		yRoom = yRoom + 1;
		
		local toGo = sidePos.down;
		curActualPos = {tonumber(toGo[1]), tonumber(toGo[2] - 649)};
	end,
	['up'] = function()
		character.enteredDir = 1;
		yRoom = yRoom - 1;
		
		local toGo = sidePos.up;
		curActualPos = {tonumber(toGo[1]), tonumber(toGo[2] + 665)};
	end,
	['right'] = function()
		character.enteredDir = 2;
		xRoom = xRoom + 1;
		
		local toGo = sidePos.right;
		curActualPos = {tonumber(toGo[1] - 881), tonumber(toGo[2])};
	end
};
function shiftRoom(d)
	local s = shiftFunc[d];
	if s then s(); end
	updateCharacterPos();
	
	enterARoom();
	checkFollow();
end

local followIn = {
	[2] = {
		[4] = function()
			return true, 'right';
		end,
		[5] = function()
			return true, 'up';
		end
	},
	[3] = {
		[2] = function()
			return character.enteredDir ~= 4, 'right';
		end,
		[3] = function()
			return character.enteredDir ~= 4, 'right';
		end,
		[4] = function()
			return character.enteredDir ~= 3, 'up';
		end
	},
	[4] = {
		[2] = function()
			return character.enteredDir ~= 1, 'down';
		end,
		[4] = function()
			return character.enteredDir ~= 3, 'up';
		end,
	},
	[5] = {
		[2] = function()
			return character.enteredDir ~= 4, 'right';
		end,
		[3] = function()
			return character.enteredDir ~= 4, 'right';
		end,
		[4] = function()
			return character.enteredDir ~= 3, 'up';
		end
	}
};
function checkFollow()
	if isFinal then return; end
	
	local y = followIn[yRoom];
	if y then
		local x = y[xRoom];
		if x then
			local shouldShadow, dir = x();
			
			if shouldShadow then
				showShadow(dir);
				
				y[xRoom] = nil;
			end
		end
	end
end

function makeShadow()
	initChar('toFollow', 'shadow');
end

function showShadow(d)
	
	triggerFollow();
end

local seeFol = false;
function triggerFollow()
	seeFol = true;
	setAlpha('fol', 1);
	runTimer('hideFollow', pl(200 / 60));
end

function triggerErr()
	setAlpha('err', 1);
	runTimer('hideErr', pl(200 / 60));
end

local randScanY = true;
local timers = {
	['hideStuff'] = function()
		removeLuaSprite('ratCache');
		
		setAlpha('err', 0);
		if not seeFol then setAlpha('fol', 0); end
		
		hideEverything();
		resetRoom();
	end,
	
	['pOne'] = function()
		setAlpha('static', clAlph(225 + Random(50)));
		
		tryMovements();
	end,
	['tFiv'] = function()
		--tryMovements();
		
		setAlpha('scan1', clAlph(200 + Random(100)));
		setAlpha('scan2', clAlph(225 + Random(25)));
		setAlpha('scan3', clAlph(225 + Random(25)));
		
		randScanY = not randScanY;
		if randScanY then
			setY('scan3', lineJumps[getRandomInt(1, #lineJumps)]);
		end
	end,
	['SMov'] = function()
		
	end,
	['hSec'] = function()
		for i = 1, #rats do
			rats[i].isMoving = (Random(3) == 1);
		end
	end,
	['fiv'] = function()
		if Random(4) == 1 then
			runTimer('stopFlashing', pl((30 + Random(60)) / 60));
			playAnim('checkers', 'glow');
		end
		
		if seeDir then
			removeLuaSprite('cont');
			seeDir = false;
		end
	end,
	
	['hideFollow'] = function()
		setAlpha('fol', 0);
	end,
	['hideErr'] = function()
		setAlpha('err', 0);
	end,
	
	['stopFlashing'] = function()
		playAnim('checkers', 'idle');
	end,
	
	['forceEnd'] = function()
		tryingMan = true;
	end,
	
	['endScene'] = function()
		switchState('End');
	end
};
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end

function cacheSounds()
	precacheSound('crazy garble');
	
	if isFinal then
		precacheSound('run');
		precacheSound('scare');
		precacheSound('insuit');
		precacheSound('laugh');
		precacheSound('crush');
	end
end

function cutForComp(n)
	return floor(n * 1000000) / 1000000;
end
