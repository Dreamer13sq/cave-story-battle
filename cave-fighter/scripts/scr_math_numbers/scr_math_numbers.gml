/// @desc

// Performs modulo on float
function FMod(_value, _denominator)
{
	if _denominator == 0 {return _value;}
		
	if _value > 0
	{
		while (_value > _denominator) {_value -= _denominator;}
		return _value;
	}
	else if _value < 0
	{
		while (_value < 0) {_value += _denominator;}
		return _value;
	}
		
	return 0;
}
	
// Wraps value to interval [start, limit)
function Wrap(value, start, limit)
{
	var _diff = limit - start;
	
	while value >= limit {value -= _diff;}
	while value < start {value += _diff;}
	
	return value;
}
	
// a mod n
function Modulo(a, n)
{
	if (n <= 0) {return a;}
	while a < 0 {a += n;} return a mod n;
}
	
// Approaches number in steps
function Approach(value, target, step)
{
	// Value equals target
	if value == target {return target}
		
	// Value is less than target
	if value < target
	{
		if value + step >= target {return target}
		return value + step;
	}
	// Value is greater than target
	if (value - step) <= target {return target}
	return value - step;
}
	
// Approaches angle in steps
function ApproachAngle(_value, _target_angle, _step)
{
	var _diff = angle_difference(_value, _target_angle);
	if abs(_diff) <= _step {return _target_angle;}
		
	return _value - sign(_diff) * _step;
}
	
// Approaches color
function ApproachColor(_color1, _color2, _amt)
{
	var _dist = point_distance_3d(
		color_get_red(_color1), color_get_green(_color1), color_get_blue(_color1),
		color_get_red(_color2), color_get_green(_color2), color_get_blue(_color2),
		);
		
	_amt = max(1, _amt * _dist);
		
	return make_color_rgb(
		Approach( color_get_red(_color1), color_get_red(_color2), _amt ),
		Approach( color_get_green(_color1), color_get_green(_color2), _amt ),
		Approach( color_get_blue(_color1), color_get_blue(_color2), _amt ),
		);
}

// Returns true if value is approaching target
function IsApproaching(value, target, step)
{
	// Value can't approach anything...
	if step == 0 {return false;}
		
	if value < target {return step > 0;}
	if value > target {return step < 0;}
		
	// Value is at target
	return false;
}

// Returns true when value is in an odd interval
function BoolStep(value, step)
{
	return (value mod (step * 2)) div step;
}

// Returns 1 when value is in an odd interval, -1 otherwise
function BoolStepPol(value, step)
{
	return ((value mod (step * 2)) div step)? 1: -1;
}

// Returns value from 0 to 1 based on position in interval
function UnitStep(value, _amtstep)
{
	return clamp( floor(value * _amtstep) / (_amtstep - 1), 0, 1);
}

// Returns result of integer division and modulo
function DivMod(value, divdivisor, moddivisor)
{
	gml_pragma("forceinline");
	return (value div divdivisor) mod moddivisor;
}

// Returns true if value is in range from [min, max]
function InRange(value, min_value, max_value)
{
	return value >= min_value && value <= max_value; 	
}

// Returns true if value is in range from [min, max], flipping values if needed
function InRange_smart(value, min_value, max_value)
{
	return (max_value < min_value)?
		(value >= max_value && value <= min_value):
		(value >= min_value && value <= max_value);
}
	
/// @arg amt,c1,c2,...
function MergeColorExt()
{
	var amt = argument[0];
	var n = argument_count - 1;
		
	if amt <= 0.0 {return argument[1];}
	if amt >= 1.0 {return argument[n];}
		
	var i1 = (amt * n);
	var i2 = min(i1 + 1, n);
	amt = lerp(0, 1, amt mod (1 / n));
	return merge_color(argument[i1], argument[i2], amt);
}
	
function ApproachSmooth(value, target, smooth)
{
	if value < target {return min(value + (target - value) / smooth, target);}
	else {return max(value + (target - value) / smooth, target);}
}
	
// Returns value quantized, like a grid
function Quantize(value, _step) {gml_pragma("forceinline"); return floor(value / _step) * _step;}
function Quantize_r(value, _step) {gml_pragma("forceinline"); return round(value / _step) * _step;}
function Quantize_c(value, _step) {gml_pragma("forceinline"); return ceil(value / _step) * _step;}
	
function QuantizeI(_amt, _step) {gml_pragma("forceinline"); return floor(_amt * _step) / _step;}
function QuantizeI_r(_amt, _step) {gml_pragma("forceinline"); return round(_amt * _step) / _step;}
function QuantizeI_c(_amt, _step) {gml_pragma("forceinline"); return ceil(_amt * _step) / _step;}
	
// Lever. Returns 1, -1, or 0 based on given values
function Lev(positive_bool, negative_bool) {gml_pragma("forceinline"); return bool(positive_bool) - bool(negative_bool);}
	
// Lever. Returns 1, -1, or 0 based on given values
function LevKeyPressed(positive_boolKey, negative_boolKey) 
{
	gml_pragma("forceinline"); 
	return keyboard_check_pressed(positive_boolKey) - keyboard_check_pressed(negative_boolKey);
}
	
// Lever. Returns 1, -1, or 0 based on given values
function LevKeyReleased(positive_boolKey, negative_boolKey) 
{
	gml_pragma("forceinline"); 
	return keyboard_check_released(positive_boolKey) - keyboard_check_released(negative_boolKey);
}
	
// Lever. Returns 1, -1, or 0 based on given values
function LevKeyHeld(positive_boolKey, negative_boolKey) 
{
	gml_pragma("forceinline"); 
	return keyboard_check(positive_boolKey) - keyboard_check(negative_boolKey);
}
	
// Lever. Returns 1, -1, or 0 based on mouse wheel. Up = +1, Down = -1
function LevMouseWheel() 
{
	gml_pragma("forceinline"); 
	return mouse_wheel_up() - mouse_wheel_down();
}
	
// Polarize. Returns 1 or -1 based on value
function Pol(value) {gml_pragma("forceinline"); return value? 1: -1;}
	
// Flips first and last two bytes of RGB/BGR value
function FlipColor(value)
{
	gml_pragma("forceinline");
	return (value & 0x0000FF) << 16 | (value & 0x00FF00) | (value & 0xFF0000) >> 16;
}
	
// Returns position of value between two bounds
function RangeToAmt(value, bound1, bound2)
{
	return (value - bound1) / (bound2 - bound2);
}
	
// Returns signed random number
function RandomSigned(x) {return random(x) * (irandom(1)? -1: 1);}
function RandomRangeSigned(x1, x2) {return random_range(x1, x2) * (irandom(1)? -1: 1);}
function IRandomSigned(x) {return irandom(x) * (irandom(1)? -1: 1);}
function IRandomRangeSigned(x1, x2) {return irandom_range(x1, x2) * (irandom(1)? -1: 1);}
	
// Returns random sign
function RandomSign() {gml_pragma("forceinline"); return choose(1, -1);}
	
// Changes magnitude of value
function Mag(x, magnitude) {gml_pragma("forceinline"); return sign(x) * magnitude;}
	
// Returns highest power of 2 value above given value
function NextPowTwo(value)
{
	var _ret = 1;
	while (_ret < value) {_ret = _ret << 1;}
	return _ret;
}
	
// Returns bit shifted by a number
function ShiftBit(index) {gml_pragma("forceinline"); return 1 << index;}
	
// Returns number of bits a value has been shifted
function UnshiftBit(b)
{
	if b == 0 {return -1;}
	var _index = 0;
	while((b & (1 << _index)) == 0) {_index++;}
	return _index;
}
	
/* FOR REFERENCE:
function Lerp(val1, val2, amt)
{
	amt = (v - v1) / (v2 - v1)
	amt * (v2 - v1) = v - v1
	amt * (v2 - v1) + v1 = v
	v = amt * (v2 - v1) + v1
}
*/
	
// Reverses effects of lerp() to return amt
function LerpRev(_value, _val1, _val2)
{
	gml_pragma("forceinline");
	return (_value - _val1) / (_val2 - _val1);
}
	
// Remaps value to new amount. Works like Blender's Map Range node
function MapRange(_value, _fromMin, _fromMax, _toMin, _toMax)
{
	gml_pragma("forceinline");
	return lerp(_toMin, _toMax, (_value - _fromMin) / (_fromMax - _fromMin));
}
function MapRangeClamp(_value, _fromMin, _fromMax, _toMin, _toMax)
{
	gml_pragma("forceinline");
	return lerp(_toMin, _toMax, clamp( (_value - _fromMin) / (_fromMax - _fromMin), 0, 1) );
}
	
// Returns position within center.
// C=4, I=2: [ - - X - ]
// C=1, I=0: [    -    ]
function OffsetCenterSplit(_width, _count, _index)
{
	return _width * (_index + 1) / (_count + 1);
}
	
function Distance1D(_x1, _x2)
{
	gml_pragma("forceinline"); return abs(_x1 - _x2);
}
	
function SameSign(x1, x2)
{
	gml_pragma("forceinline");
	return sign(x1) == sign(x2);
}

function HexToReal(hex_string)
{
	var _l = string_length(hex_string),
		_value = 0, _pos = 0;
		
	for (var i = _l; i > 0; i--)
	{
		switch( string_char_at(hex_string, i) )
		{
			case("0"): _value += 0 << _pos; break;
			case("1"): _value += 1 << _pos; break;
			case("2"): _value += 2 << _pos; break;
			case("3"): _value += 3 << _pos; break;
			case("4"): _value += 4 << _pos; break;
			case("5"): _value += 5 << _pos; break;
			case("6"): _value += 6 << _pos; break;
			case("7"): _value += 7 << _pos; break;
			case("8"): _value += 8 << _pos; break;
			case("9"): _value += 9 << _pos; break;
			case("a"): case("A"): _value += 10 << _pos; break;
			case("b"): case("B"): _value += 11 << _pos; break;
			case("c"): case("C"): _value += 12 << _pos; break;
			case("d"): case("D"): _value += 13 << _pos; break;
			case("e"): case("E"): _value += 14 << _pos; break;
			case("f"): case("F"): _value += 15 << _pos; break;
		}
			
		_pos += 4;
	}
		
	return _value;
}

function StringBinary(value, num_digits=8)
{
	var s = "";
	for (var i = 0; i < num_digits; i++)
	{
		s += (value & (1<<i))? "1": "0";
	}
	
	return s;
}

