/// @desc


function HitboxAttack() constructor
{
	damage = 0;
	frames = 0;
	xknockback = 0;
	yknockback = 0;
	effect = 0;
	collision = 0;
}

function Hitbox() constructor
{
	active = false;
	anchored = false;
	source = 0;
	
	x1 = 0;
	y1 = 0;
	x2 = 0;
	y2 = 0;
	w = 0;
	h = 0;
	xcenter = 0;
	ycenter = 0;
	
	priority = AttackPriority.base;
	
	hitattack = new HitboxAttack();
	blockattack = new HitboxAttack();
	counterattack = new HitboxAttack();
	
	function HB_DefinePosition(_x1, _y1, _x2, _y2)
	{
		x1 = (_x1 > _x2)? _x1: _x2;
		y1 = (_y1 > _y2)? _y1: _y2;
		x2 = (_x1 > _x2)? _x2: _x1;
		y2 = (_y1 > _y2)? _y2: _y1;
		
		w = x2-x1;
		h = y2-y1;
		xcenter = x1+w/2;
		ycenter = y1+h/2;
		return self;
	}
	
	function HB_DefineHit(value, frames, xknockback, yknockback, collision, effect)
	{
		var hba = hitattack;
		hba.damage = value;
		hba.frames = frames;
		hba.xknockback = xknockback;
		hba.yknockback = yknockback;
		hba.effect = collision;
		hba.collision = effect;
		return self;
	}
	
	function HB_DefineBlock(value, frames, xknockback, yknockback, collision, effect)
	{
		var hba = blockattack;
		hba.damage = value;
		hba.frames = frames;
		hba.xknockback = xknockback;
		hba.yknockback = yknockback;
		hba.effect = collision;
		hba.collision = effect;
		return self;
	}
	
	function HB_DefineCounter(value, frames, xknockback, yknockback, collision, effect)
	{
		var hba = counterattack;
		hba.damage = value;
		hba.frames = frames;
		hba.xknockback = xknockback;
		hba.yknockback = yknockback;
		hba.effect = collision;
		hba.collision = effect;
		return self;
	}
	
	function Clear()
	{
		active = false;
		anchored = false;
		source = 0;
		priority = AttackPriority.base;
		
		HB_DefinePosition(0, 0, 0, 0);
		HB_DefineHit(0, 0, 0, 0, 0, 0);
		HB_DefineBlock(0, 0, 0, 0, 0, 0);
		HB_DefineCounter(0, 0, 0, 0, 0, 0);
	}
}
