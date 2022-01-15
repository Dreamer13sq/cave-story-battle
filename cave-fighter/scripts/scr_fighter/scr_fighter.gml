/// @desc

#region Fighter =====================================

function Fighter() constructor
{
	#region Variables =========================================
	
	battleflag = 0;
	fighterflag = 0;
	buttonstrength = 0; // 0 = A, 1 = B, 2 = C
	
	healthmetermax = 1000;
	healthmeter = healthmetermax;
	healthprovisional = healthmeter;
	healthmeterold = healthmeter;
	healthwait = 0;
	healthrecoverwait = 0;
	
	dashmetermax = 100;
	dashmeter = dashmetermax*0.7;
	dashmeterlast = 0;
	dashmeterflash = 0;
	dashmeterold = dashmeter;
	dashprovisional = dashmeter;
	dashstockcount = 5;
	dashstockflash = array_create(8);
	
	powerstockcount = 3;
	powermetermax = 100;
	powermeter = floor(powermetermax*powerstockcount);
	powermeterlast = 0;
	powermeterflash = 0;
	powermeterold = powermeter;
	
	state = 0;
	statestart = 0;
	frame = 0;
	framelast = 0;
	
	attributes = {
		walkspeed : 6,
		deceleration : 0.9,
		acceleration : 1.0,
		
		dashspeed : 8,
		backdashspeed : 8,
		runspeed : 7.5,
		dashframes : 16,
		dashframesmin : 10,
		backdashframes : 12,
		backdashframesmin : 10,
		dashstopframes : 5,
		backdashstopframes : 5,
		runstopframes : 5,
		
		jumpsquatframes : 3,
		jumpheight : 10,
		leapsquatframes : 6,
		leapheight : 13,
		airspeed : 4,
		gravity : 0.4,
		terminal : -16,
		airdrift : 0.12,
		airdriftmax : 3,
		};
	
	sequences = {
		dash0 : [BTN_FORWARD, BTN_FORWARD],
		dash1 : [BTN_FORWARD, -BTN_FORWARD, -BTN_UP],
		bdash0 : [BTN_BACK, BTN_BACK],
		bdash1 : [BTN_BACK, -BTN_BACK, -BTN_UP],
	}
	
	x = 0;
	y = 0;
	z = 0;
	
	xspeed = 0;
	yspeed = 0;
	xspeedtarget = 0;
	yspeedtarget = 0;
	xacc = 0;
	yacc = 0;
	ts = 0;
	
	forwardsign = 1; // 1 if facing right, -1 if facing left
	
	hitboxcount = 16;
	hitbox = array_create(hitboxcount);
	hitboxconnect = 0; // Bit field
	
	hurtboxcount = 16;
	hurtbox = array_create(hurtboxcount);
	
	commandavailable = array_create(16); // Array of bit fields
	
	inputmgr = HEADER.playerinput[0];
	inputlastframe = array_create(16, 255);
	ipressed = 0;
	iheld = 0;
	ireleased = 0;
	
	inputhistorycount = 16;
	inputhistoryindex = 0;
	inputhistory = array_create(inputhistorycount);
	for (var i = 0; i < inputhistorycount; i++)
		{inputhistory[i] = [0, 0];}
	
	vbx = -1;
	pos = 0;
	posmax = 1;
	posspeed = 1.0;
	poseset = {};
	posekey = -1;
	activepose = -1;
	matpose = Mat4ArrayFlat(200);
	
	texture_base = sprite_get_texture(tex_sue_pal_c00, 0);
	texture_dash = sprite_get_texture(tex_sue_pal_dash, 0);
	texture_parry = sprite_get_texture(tex_sue_pal_c00, 0);
	texture_charge = sprite_get_texture(tex_sue_pal_c00, 0);
	activetexture = texture_base;
	
	#endregion ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	function Start()
	{
		for (var i = 0; i < hitboxcount; i++)
		{
			hitbox[i] = new Hitbox();	
		}
		
		for (var i = 0; i < hurtboxcount; i++)
		{
			hurtbox[i] = new Hitbox();	
		}
	}
	
	function StateSet(_state)
	{
		state = _state;
		statestart = true;
		frame = 0;
		framelast = -1;
		Runner(0);
		
		return false;
	}
	
	function StateStartPop()
	{
		if statestart 
		{
			statestart = 0; 
			return true;
		}
		
		return false;
	}
	
	#region Meters ============================================
	
	// Health -------------------------------------------------
	
	function HealthValue()
	{
		return healthmeter;
	}
	
	function HealthUpdate(ts=1.0)
	{
		if (healthmeterold > healthmeter)
		{
			if (healthwait > 0) {healthwait = max(0, healthwait-ts);}
			else
			{
				healthmeterold = Approach(healthmeterold, healthmeter, ts);	
			}
		}
		
		if (healthmeter < healthprovisional)
		{
			if (healthrecoverwait > 0) {healthrecoverwait = max(0, healthrecoverwait-ts);}
			else
			{
				healthmeter = Approach(healthmeter, healthprovisional, ts*0.1);	
			}
		}
	}
	
	function DoDamage(value, valueprovisional, _flags=0)
	{
		// Real damage
		if (value > 0)
		{
			healthmeter = clamp(healthmeter-value, 0, healthmetermax);
			healthprovisional = clamp(healthprovisional-valueprovisional, healthmeter, healthmetermax);
			
			healthwait = 60;
		}
		// Only provisional, can't KO
		else
		{
			healthprovisional = clamp(healthprovisional-valueprovisional, 1, healthmetermax);
			
			if healthprovisional < healthmeter
			{
				healthmeter = clamp(healthprovisional, 1, healthmetermax);
				healthmeterold = healthmeter;
			}
		}
		
		if healthmeterold < healthmeter
		{
			healthmeterold = healthmeter;
		}
		
		healthrecoverwait = 120;
	}
	
	// Dash -------------------------------------------------
	
	function DashValue()
	{
		return dashmeter;
	}
	
	function DashStock()
	{
		return floor(dashstockcount*dashmeter/dashmetermax);
	}
	
	function DashUpdate(ts=1.0)
	{
		// Dash is not full
		if (dashmeter < dashmetermax)
		{
			// Dash penalty
			if ( dashprovisional > dashmeter )
			{
				dashprovisional = max(dashprovisional-ts*0.25, dashmeter);
			}
			// Ready to refill
			else
			{
				dashmeter = min(dashmeter+ts*0.5, dashmetermax);
				dashmeterold = max(dashmeterold, dashmeter);
				dashprovisional = dashmeter;
				
				var stockcost;
				for (var i = 0; i < dashstockcount; i++)
				{
					stockcost = (i+1) * dashmetermax/dashstockcount;
					
					if ( dashmeterlast <= stockcost && dashmeter >= stockcost )
					{
						dashstockflash[i] = DASHMETERFLASHTIME;
					}
				}
			}
		}
		
		// Used meter flash
		if (dashmeterflash > 0)
		{
			dashmeterflash = max(dashmeterflash-1, 0);
			
			if (dashmeterflash == 0)
			{
				dashmeterold = dashmeter;
			}
		}
		
		// Stock ready flash
		for (var i = 0; i < dashstockcount; i++)
		{
			if ( dashstockflash[i] > 0 ) {dashstockflash[i] = max(0, dashstockflash[i]-1);}
		}
		
		dashmeterlast = dashmeter;
	}
	
	function DashUse(_penalty=false)
	{
		if ( DashStock() )
		{
			//dashmeterold = dashmeter;
			
			// Add extra recharge (used for cancels)
			if ( _penalty )
			{
				dashmeter -= dashmetermax/dashstockcount;
				dashmeterflash = DASHMETERFLASHTIME;
			}
			// Simple takeaway
			else
			{
				dashmeter -= dashmetermax/dashstockcount;
				dashprovisional = dashmeter;
				dashmeterflash = DASHMETERFLASHTIME;
			}
			
			return true;
		}
		
		return false;
	}
	
	// Power -------------------------------------------------
	
	function PowerValue()
	{
		return powermeter;
	}
	
	function PowerStock()
	{
		return floor(powermeter/powermetermax);
	}
	
	function PowerUpdate(ts=1.0)
	{
		if ( powermeterflash > 0 )
		{
			powermeterflash = max(powermeterflash-1, 0);
		}
		else if ( powermeterold > powermeter )
		{
			powermeterold = powermeter;	
		}
	}
	
	function PowerAdd(value)
	{
		powermeter = clamp(powermeter+value, 0, powermetermax*(powerstockcount));
		if (powermeter > powermeterold) {powermeterold = powermeter;}
	}
	
	// Returns true and uses ex meter cost if sufficient
	function PowerUseEX(_silent=false)
	{
		if ( powermeter >= POWEREXCOST )
		{
			powermeterold = powermeter;
			powermeter -= POWEREXCOST;
			
			if ( !_silent )
			{
				powermeterflash = DASHMETERFLASHTIME;	
			}
			
			return true;
		}
		
		return false;
	}
	
	// Returns true and uses super meter cost if sufficient
	function PowerUseSuper(_stocks, _silent=false)
	{
		if ( powermeter >= powermetermax*_stocks )
		{
			powermeterold = powermeter;
			powermeter -= powermetermax*_stocks;
			
			if ( !_silent )
			{
				powermeterflash = DASHMETERFLASHTIME;	
			}
			
			return true;
		}
		
		return false;
	}
	
	#endregion
	
	#region Hitboxes ==========================================
	
	// Resets hitbox values
	function HitboxClear(index)
	{
		hitbox[index].Clear();
	}
	
	// Resets all hitbox values
	function HitboxClearAll()
	{
		for (var i = 0; i < hitboxcount; i++)
		{
			hitbox[i].Clear();
		}
	}
	
	// Sets hitbox active state
	function HitboxSetActive(index, active)
	{
		hitbox[index].active = active;
	}
	
	// Returns hitbox struct at index
	function GetHitbox(index)
	{
		return hitbox[index];	
	}
	
	// Returns true if hitbox is colliding with opponent
	function OnHitboxConnect(index)
	{
		return (hitboxconnect & (1 << index)) != 0;
	}
	
	#endregion ================================================
	
	#region Input =============================================
	
	function ButtonUpdate()
	{
		var _inputindex;
		var _lastheld = iheld;
		iheld = 0;
		
		// Parse for inputs
		for (var i = 0; i < 8; i++)
		{
			_inputindex = i;
			
			if inputmgr.Held(i)
			{
				switch(i)
				{
					default: _inputindex = BTN_NEUTRAL; break;
					case(InputIndex.right):	_inputindex = (forwardsign? BTN_FORWARD: BTN_BACK); break;
					case(InputIndex.up):	_inputindex = BTN_UP; break;
					case(InputIndex.left):	_inputindex = (forwardsign? BTN_BACK: BTN_FORWARD); break;
					case(InputIndex.down):	_inputindex = BTN_DOWN; break;
					case(InputIndex.a):		_inputindex = BTN_A; break;
					case(InputIndex.b):		_inputindex = BTN_B; break;
					case(InputIndex.c):		_inputindex = BTN_C; break;
					case(InputIndex.dash):	_inputindex = BTN_DASH; break;
				}
				
				iheld |= 1 << _inputindex;	
			}
		}
		
		ipressed = iheld & ~_lastheld;
		ireleased = ~iheld & _lastheld;
		
		// Update history values
		for (var i = 0; i < inputhistorycount; i++)
		{
			inputhistory[i][1]++;	
		}
		
		// Add history entries
		for (var i = 0; i < 10; i++)
		{
			// If button was pressed
			if ( ipressed & (1 << i) )
			{
				// Reset last frame of input
				inputlastframe[i] = 0;
				
				// Update history
				inputhistoryindex = (inputhistoryindex+1) mod inputhistorycount;
				
				var entry = inputhistory[inputhistoryindex];
				entry[@ 0] = i;
				entry[@ 1] = 0;
			}
			else
			{
				inputlastframe[i]++;
			}
		}
	}
	
	function ButtonPressed(_inputindex)
	{
		return (ipressed & 1 << _inputindex) != 0;
	}
	
	function ButtonHeld(_inputindex)
	{
		return (iheld & 1 << _inputindex) != 0;
	}
	
	function ButtonReleased(_inputindex)
	{
		return (ireleased & 1 << _inputindex) != 0;
	}
	
	function Button(_inputindex, _frames=0)
	{
		return inputlastframe[_inputindex] <= _frames;
	}
	
	function SequenceEvaluate(seq)
	{
		var n = array_length(seq);
		var h = inputhistoryindex;
		
		// Read AND-ed inputs starting from end of sequence
		var _onepressed = false;
		var _allheld = true;
		for (var i = n-1; i >= 0; i--)
		{
			// Pressed within a time
			if ( Button(abs(seq[i]), SEQUENCEBUFFERFRAMES) )
			{
				_onepressed = true;
				
			}
			
			// End of merged inputs
			if ( seq[i] >= 0 )
			{
				break;
			}
			
			// Held
			if ( !ButtonHeld(abs(seq[i])) )
			{
				_allheld = false;
				break;
			}
			else
			{
				h = Modulo(h-1, inputhistorycount);	
			}
		}
		
		// Not all merged buttons are held
		if ( !_allheld || !_onepressed )
		{
			if _onepressed
			if !_allheld {printf("Missing hold. Button: %s", BTNName(seq[i])); return false;}
			return false;	
		}
		
		var histentry;
		var f = SEQUENCEBUFFERFRAMES; // Last frame reference
		// Read TO-ed inputs starting from end of sequence
		repeat(inputhistorycount)
		{
			histentry = inputhistory[h];
			if ( histentry[0] == seq[i] )
			{
				//printf(BTNName(seq[i]));
				
				if ( histentry[1]-f <= SEQUENCEBUFFERFRAMES ) 
				{
					f += histentry[1];
					if (i == 0) {return true;} // TRUE *********************
					i--;
				}
				else
				{
					//printf("Out of time. %s frames late", histentry[1]-SEQUENCEBUFFERFRAMES);
					return false;	
				}
			}
			
			h = Modulo(h-1, inputhistorycount);
		}
		
		return true;
	}
	
	function SequenceEvaluateKey(key)
	{
		return SequenceEvaluate(sequences[$ key]);	
	}
	
	function SequenceEvaluateKey2(key1, key2)
	{
		return (
			SequenceEvaluate(sequences[$ key1]) ||
			SequenceEvaluate(sequences[$ key2])
			);
	}
	
	function SequenceEvaluateKey3(key1, key2, key3)
	{
		return (
			SequenceEvaluate(sequences[$ key1]) ||
			SequenceEvaluate(sequences[$ key2]) ||
			SequenceEvaluate(sequences[$ key3])
			);
	}
	
	#endregion ================================================
	
	#region Runner Utility ====================================
	
	// Returns true if frame is before given frame
	function FrameIs(_frame)
	{
		if (framelast < frame)
		{
			return _frame > framelast && _frame <= frame;
		}
		return false;
	}
	
	// Returns true if frame is on a frame in step interval
	function FrameStep(_framestart, _frameend, _step)
	{
		_frameend = min(_frameend, frame);
		if (_frameend < 0) {_frameend = frame;}
		
		while (_framestart <= _frameend)
		{
			if ( FrameIs(_framestart) )
			{
				return true;
			}
			
			_framestart += _step;
		}
		
		return false;
	}
	
	// Returns true if frame is within a step interval
	function FrameStepBool(_framestart, _frameend, _step)
	{
		_frameend = min(_frameend, frame);
		if (_frameend < 0) {_frameend = frame;}
		
		var f1 = framelast, f2 = frame;
		
		f1 -= _framestart;
		f2 -= _framestart;
		
		return (f1 < f2) && BoolStep(f2, _step) && f2 <= _frameend;
	}
	
	// Returns true if frame is past or at given frame
	function FrameElapsed(_frame)
	{
		if (framelast < frame)
		{
			return _frame <= frame;
		}
		return false;
	}
	
	
	// Sets or clears battle flag
	function FlagSet(_flag, _active)
	{
		if (_active)
		{
			battleflag |= _flag;
		}
		else
		{
			battleflag &= ~(_flag);	
		}
	}
	
	function FlagGet(_flag)
	{
		return (battleflag & _flag) != 0;
	}
	
	// Sets available command from current state
	function SetAvailable(_commandindex)
	{
		commandavailable[_commandindex div COMMAND_INDEX_BITSPERINDEX] |= 
			1 << (_commandindex << COMMAND_INDEX_BITSPERINDEX);
	}
	
	// Clears available command from current state
	function ClearAvailable(_commandindex)
	{
		commandavailable[_commandindex div COMMAND_INDEX_BITSPERINDEX] &= 
			~(1 << (_commandindex << COMMAND_INDEX_BITSPERINDEX));
	}
	
	// Clears all available commands from current state
	function ClearAvailableAll(_commandindex)
	{
		var n = array_length(commandavailable);
		for (var i = 0; i < n; i++)
		{
			commandavailable[i] = 0;	
		}
	}
	
	function SetSpeed(_xspeed, _yspeed, _useforwardsign=true)
	{
		xspeed = _xspeed * forwardsign;
		yspeed = _yspeed;
	}
	
	function SetApproach(_xspeedtarget, _xacc, _yspeedtarget, _yacc)
	{
		xspeedtarget = _xspeedtarget * forwardsign;
		yspeedtarget = _yspeedtarget;
		xacc = _xacc;
		yacc = _yacc;
	}
	
	#endregion ================================================
	
	#region Animation ====================================
	
	// Returns true if frame is before given frame
	function SetPose(key)
	{
		if (!variable_struct_exists(poseset, key))
		{
			show_debug_message("Unknown key \"" + key + "\"")
			return;
		}
	
		if (key != posekey)
		{
			posekey = key;
			activepose = poseset[$ key];
			pos = 0;
			posmax = array_length(activepose);
		}
	}
	
	function CreateAfterImage(_texture, _tintpreset)
	{
		var nd = NewEntity_Battle(new E_Fighter_Afterimage());
		nd.SetLocation(x, y, z);
		nd.vbx = vbx;
		nd.forwardsign = forwardsign;
		nd.texture = _texture;
		nd.tintpreset = _tintpreset;
		
		array_copy(nd.matpose, 0, matpose, 0, array_length(matpose));
	}
	
	#endregion ================================================
	
	DefaultRunner = Fighter_Default_Runner;
	Runner = DefaultRunner;
	
	function Update(_ts=1.0)
	{
		ts = _ts;
		
		ButtonUpdate();
		
		if keyboard_check_pressed(VKey.p)
		{
			if forwardsign == -1 {forwardsign = 1;}	
			else {forwardsign = -1;}	
		}
		
		FlagSet(FL_Fighter.justlanding, false);
		FlagSet(FL_Fighter.justairborne, false);
		
		// Movement
		var _xlast = x;
		var _ylast = y;
		
		if (xacc != 0)
		{
			xspeed = Approach(xspeed, xspeedtarget, xacc*ts);
		}
		
		if (yacc != 0)
		{
			yspeed = Approach(yspeed, yspeedtarget, yacc*ts);
		}
		
		x += xspeed;
		y += yspeed;
		
		if (y <= 0 && yspeed < 0)
		{
			FlagSet(FL_Fighter.justlanding, true);
			y = 0;
		}
		
		// Meter updates
		HealthUpdate(ts);
		PowerUpdate(ts);
		DashUpdate(ts);
		
		framelast = frame;
		frame += ts;
		Runner(ts);
		
		pos = Modulo(pos+posspeed, posmax);
		matpose = activepose[pos];
		
		activetexture = texture_base;
		
		if FlagGet(FL_Fighter.dashing)
		{
			if ( FrameIs(0) && (powermeter != powermeterold) )
			{
				CreateHitBall(self);
			}
			
			if ( FrameStep(0, -1, 6) )
			{
				printf(frame)
				CreateAfterImage(activetexture, (powermeter != powermeterold)? 
					FighterTintPreset.charge: FighterTintPreset.dash);
			}
		}
	}
}

#endregion ==========================================

#region Default Runner ==============================

function Fighter_Default_Runner(ts, f)
{
	switch(state)
	{
		// ----------------------------------------------------------
		default:{
			if FlagGet(FL_Fighter.airborne)
			{
				StateSet(ST_Fighter.jump); return false;
			}
			else
			{
				StateSet(ST_Fighter.wait); return false;
			}
		}
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.wait):{
			FlagSet(FL_Fighter.airborne, false);
			SetApproach(0, attributes.deceleration, 0, 0);
			
			if ButtonHeld(BTN_FORWARD) {return StateSet(ST_Fighter.walkforward);}
			if ButtonHeld(BTN_BACK) {return StateSet(ST_Fighter.walkback);}
			if ButtonHeld(BTN_UP) 
			{
				if ( Button(BTN_DOWN, LEAPBUFFERFRAMES) ) 
					{return StateSet(ST_Fighter.leapsquat);}
				else 
					{return StateSet(ST_Fighter.jumpsquat);}
			}
			if ButtonHeld(BTN_DOWN) {return StateSet(ST_Fighter.crouch);}
			
			if ( SequenceEvaluate([BTN_DOWN, BTN_FORWARD, BTN_A]) )
			{
				printf("はどうけん");
				//PowerUseEX();
				PowerAdd(7);
				return StateSet(ST_Fighter.dash);
			}
			
			if ( SequenceEvaluate([BTN_DOWN, BTN_FORWARD, BTN_B]) )
			if PowerUseEX()
			{
				printf("さくねつ");
				
				return StateSet(ST_Fighter.dash);
			}
			
			if ( SequenceEvaluate([BTN_DOWN, BTN_FORWARD, BTN_C]) )
			if PowerUseSuper(1)
			{
				printf("だいはどうけん");
				
				return StateSet(ST_Fighter.dash);
			}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.walkforward):{
			SetApproach(attributes.walkspeed, attributes.acceleration, 0, 0);
			
			if ButtonHeld(BTN_DOWN) {return StateSet(ST_Fighter.crouch);}
			if ButtonHeld(BTN_UP) 
			{
				if ( Button(BTN_DOWN, LEAPBUFFERFRAMES) ) 
					{return StateSet(ST_Fighter.leapsquat);}
				else 
					{return StateSet(ST_Fighter.jumpsquat);}
			}
			if !ButtonHeld(BTN_FORWARD) {return StateSet(ST_Fighter.wait);}
			if ( Button(BTN_DASH, DASHBUFFERFRAMES) || SequenceEvaluateKey2("dash0", "dash1") )
			{
				if ( DashUse(0) ) {return StateSet(ST_Fighter.dash);}
			}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.walkback):{
			SetApproach(-attributes.walkspeed, attributes.acceleration, 0, 0);
			
			if ButtonHeld(BTN_DOWN) {return StateSet(ST_Fighter.crouch);}
			if ButtonHeld(BTN_UP) 
			{
				if ( Button(BTN_DOWN, LEAPBUFFERFRAMES) ) 
					{return StateSet(ST_Fighter.leapsquat);}
				else 
					{return StateSet(ST_Fighter.jumpsquat);}
			}
			if !ButtonHeld(BTN_BACK) {return StateSet(ST_Fighter.wait);}
			if ( Button(BTN_DASH, DASHBUFFERFRAMES) || SequenceEvaluateKey2("bdash0", "bdash1") )
			{
				if ( DashUse(0) ) {return StateSet(ST_Fighter.backdash);}
			}
		}
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.crouch):{
			SetApproach(0, attributes.deceleration, 0, 0);
			
			if !ButtonHeld(BTN_DOWN) {return StateSet(ST_Fighter.wait);}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.dash):{
			if ( StateStartPop() )
			{
				FlagSet(FL_Fighter.useddashbutton, ButtonHeld(BTN_DASH));
				FlagSet(FL_Fighter.dashing, 1);
				return;
			}
			
			SetApproach(attributes.dashspeed, attributes.dashspeed, 0, 0);
			
			if ( FrameElapsed(attributes.dashframesmin) )
			{
				if ( 
					FrameIs(attributes.dashframes) ||
					!(FlagGet(FL_Fighter.useddashbutton)? ButtonHeld(BTN_DASH): ButtonHeld(BTN_FORWARD))
					)
				{
					FlagSet(FL_Fighter.dashing, 0);
					
					if ( ButtonHeld(BTN_FORWARD) )
						{return StateSet(ST_Fighter.run);}
					else
						{return StateSet(ST_Fighter.dash_stop);}
				}
			}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.dash_stop):{
			SetApproach(0, attributes.deceleration, 0, 0);
			if ( FrameIs(attributes.dashstopframes) ) {return StateSet(ST_Fighter.wait);}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.run):{
			SetApproach(attributes.runspeed, attributes.acceleration, 0, 0);
			
			if ( !ButtonHeld(BTN_FORWARD) )
			{
				return StateSet(ST_Fighter.run_stop);
			}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.run_stop):{
			SetApproach(0, attributes.deceleration, 0, 0);
			if ( FrameIs(attributes.runstopframes) ) {return StateSet(ST_Fighter.wait);}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.backdash):{
			if ( StateStartPop() )
			{
				FlagSet(FL_Fighter.useddashbutton, ButtonHeld(BTN_DASH));
				FlagSet(FL_Fighter.dashing, 1);
				return;
			}
			
			SetApproach(-attributes.backdashspeed, attributes.backdashspeed, 0, 0);
			
			if ( FrameElapsed(attributes.backdashframesmin) )
			{
				if ( 
					FrameIs(attributes.backdashframes) ||
					!(FlagGet(FL_Fighter.useddashbutton)? ButtonHeld(BTN_DASH): ButtonHeld(BTN_BACK))
					)
				{
					FlagSet(FL_Fighter.dashing, 0);
					return StateSet(ST_Fighter.backdash_stop);
				}
			}
		}	
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.backdash_stop):{
			SetApproach(0, attributes.deceleration, 0, 0);
			if ( FrameIs(attributes.backdashstopframes) ) {return StateSet(ST_Fighter.wait);}
		}	
			break;
		
		// ======================================================================
		// JUMP
		// ======================================================================
		
		// ----------------------------------------------------------
		case(ST_Fighter.jumpsquat):{
			SetApproach(0, attributes.deceleration, 0, 0);
			
			if ( FrameIs(attributes.jumpsquatframes) )
			{
				if ButtonHeld(BTN_FORWARD) 
				{
					StateSet(ST_Fighter.jumpforward);
					SetSpeed(attributes.airspeed, attributes.jumpheight);
					SetApproach(attributes.airspeed, attributes.airdrift, attributes.terminal, attributes.gravity);
					return false;
				}
				
				if ButtonHeld(BTN_BACK) 
				{
					StateSet(ST_Fighter.jumpback); 
					SetSpeed(-attributes.airspeed, attributes.jumpheight);
					SetApproach(-attributes.airspeed, attributes.airdrift, attributes.terminal, attributes.gravity);
					return false;
				}
				
				SetSpeed(xspeed, attributes.jumpheight);
				StateSet(ST_Fighter.jump);
			}
		}
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.leapsquat):{
			SetApproach(0, attributes.deceleration, 0, 0);
			
			if ( FrameIs(attributes.leapsquatframes) )
			{
				if ButtonHeld(BTN_FORWARD) 
				{
					StateSet(ST_Fighter.leapforward);
					SetSpeed(attributes.airspeed, attributes.leapheight);
					SetApproach(attributes.airspeed, attributes.airdrift, attributes.terminal, attributes.gravity);
					return false;
				}
				
				if ButtonHeld(BTN_BACK) 
				{
					StateSet(ST_Fighter.leapback); 
					SetSpeed(-attributes.airspeed, attributes.leapheight);
					SetApproach(-attributes.airspeed, attributes.airdrift, attributes.terminal, attributes.gravity);
					return false;
				}
				
				SetSpeed(xspeed, attributes.leapheight);
				StateSet(ST_Fighter.leap);
			}
		}
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.leapforward):
		case(ST_Fighter.leapback):
		case(ST_Fighter.leap):
		case(ST_Fighter.jumpforward):
		case(ST_Fighter.jumpback):
		case(ST_Fighter.jump):{
			if ( StateStartPop() )
			{
				FlagSet(FL_Fighter.airborne, true);
				return false;
			}
			
			// Drift
			var lev = ButtonHeld(BTN_FORWARD)-ButtonHeld(BTN_BACK);
			if lev != 0
			{
				SetApproach(lev*attributes.airspeed, attributes.airdrift, attributes.terminal, attributes.gravity);
			}
			else
			{
				SetApproach(0, 0, attributes.terminal, attributes.gravity);
			}
			
			// Airdash
			if ( (Button(BTN_DASH, DASHBUFFERFRAMES) && ButtonHeld(BTN_BACK)) || SequenceEvaluateKey2("bdash0", "bdash1") )
			{
				if ( DashUse(true) ) {return StateSet(ST_Fighter.airbackdash);}
			}
			if ( Button(BTN_DASH, DASHBUFFERFRAMES) || SequenceEvaluateKey2("dash0", "dash1") )
			{
				if ( DashUse(true) ) {return StateSet(ST_Fighter.airdash);}
			}
			
			if ( y == 0 )
			{
				StateSet(ST_Fighter.wait);
				return false;
			}
		}
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.airdash):{
			if ( StateStartPop() )
			{
				FlagSet(FL_Fighter.useddashbutton, ButtonHeld(BTN_DASH));
				FlagSet(FL_Fighter.dashing, 1);
				return;
			}
			
			SetSpeed(0, 0);
			SetApproach(attributes.dashspeed, attributes.dashspeed, 0, 0);
			
			if ( FrameElapsed(attributes.dashframesmin) )
			{
				if ( 
					FrameIs(attributes.dashframes) ||
					!(FlagGet(FL_Fighter.useddashbutton)? ButtonHeld(BTN_DASH): ButtonHeld(BTN_FORWARD))
					)
				{
					FlagSet(FL_Fighter.dashing, 0);
					return StateSet(ST_Fighter.jump);
				}
			}
		}
			break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.airbackdash):{
			if ( StateStartPop() )
			{
				FlagSet(FL_Fighter.useddashbutton, ButtonHeld(BTN_DASH));
				FlagSet(FL_Fighter.dashing, 1);
				return;
			}
			
			SetSpeed(0, 0);
			SetApproach(-attributes.backdashspeed, attributes.dashspeed, 0, 0);
			
			if ( FrameElapsed(attributes.backdashframesmin) )
			{
				if ( 
					FrameIs(attributes.backdashframes) ||
					!(FlagGet(FL_Fighter.useddashbutton)? ButtonHeld(BTN_DASH): ButtonHeld(BTN_BACK))
					)
				{
					FlagSet(FL_Fighter.dashing, 0);
					return StateSet(ST_Fighter.jump);
				}
			}
		}
			break;
		
	}
	
	return true;
}

#endregion ==========================================