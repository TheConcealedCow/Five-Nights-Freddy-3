local sv = 'FNAF3';
function create()
	runHaxeCode([[
		import psychlua.LuaUtils;
		
		createCallback('setFinFunc', function(o, f) {
			var obj = LuaUtils.getObjectDirectly(o, false);
			obj.animation.finishCallback = function(n) {
				parentLua.call(f, []);
			}
		});
	]]);
	
	makeAnimatedLuaSprite('white', 'gameAssets/endBit/white', 478, 364);
	addAnimationByPrefix('white', 'white', 'Fade', 12, false);
	addOffset('white', 'white', 489, 57);
	playAnim('white', 'white', true);
	setFinFunc('white', 'toNext');
	addLuaSprite('white');
	
	makeLuaSprite('lines', 'gameAssets/endBit/scanLines');
	addLuaSprite('lines');
	
	doSound('end');
end

function toNext()
	local curScene = math.min(getDataFromSave(sv, 'scene', 1), 5);
	
	if curScene == 5 then
		if getDataFromSave(sv, 'goodEnd', false) then
			switchState('goodEnd');
		else
			switchState('badEnd');
		end
	else
		switchState('WhatDay');
	end
end
