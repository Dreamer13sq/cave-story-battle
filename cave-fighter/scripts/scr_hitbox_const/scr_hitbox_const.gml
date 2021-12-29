/// @desc

enum FL_COLLISION
{
	GROUND = 1 << 0,
	AIR = 1 << 1,
	DOWN = 1 << 2,
	
	GROUND_AIR = FL_COLLISION.GROUND | FL_COLLISION.AIR,
	GROUND_AIR_DOWN = FL_COLLISION.GROUND | FL_COLLISION.AIR | FL_COLLISION.DOWN,
}

enum FL_EFFECT
{
	FIRE = 1 << 0,
	SHOCK = 1 << 1,	
	RED = 1 << 2,
	REFLECT = 1 << 3,
	ABSORBABLE = 1 << 4,
}

enum AttackPriority
{
	base = 0,
	light,
	medium,
	heavy,
	superheavy,
}
