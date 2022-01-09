/*
	
*/

enum EntityLayer
{
	background = 100,
	back = 10,
	battle = 0,
	front = -10,
	foreground = -100,
}

function EntityLL() constructor
{
	headnode = 0;
	tailnode = 0;
	nodecount = 0;
	slotcurrent = 1;
	slotmax = 256;
	name = "<no name>";
	
	nodelist = array_create(slotmax);
	
	function Free()
	{
		ds_map_destroy(nodemap);
	}
	
	function AppendNode(_newstruct)
	{
		nodelist[@ slotcurrent] = _newstruct;
		_newstruct.nodeslot = slotcurrent;
		_newstruct.nodelinkedlist = self;
		
		// Empty list
		if (headnode == 0)
		{
			headnode = _newstruct;
			tailnode = _newstruct;
		}
		// Not empty
		else
		{
			tailnode.nodenext = _newstruct;
			_newstruct.nodeprev = tailnode;
			tailnode = _newstruct;
		}
		
		nodecount += 1;
		
		// Find next open slot
		while (nodelist[@ slotcurrent])
		{
			slotcurrent += 1;
			if (slotcurrent == slotmax) {slotcurrent = 1;}
		}
		
		return _newstruct;
	}
	
	function RemoveNode(_node, _clean=true, _delete=true)
	{
		return RemoveNodeSlot(_node.nodeslot, _clean, _delete);
	}
	
	function RemoveNodeSlot(_nodeslot, _clean=true, _delete=true)
	{
		if (_nodeslot >= 1 && _nodeslot <= slotmax)
		{
			var nd = nodelist[@ _nodeslot];
			
			// Re-link nodes
			if (nd.nodeprev)
			{
				nd.nodeprev.nodenext = nd.nodenext;
			}
			
			if (nd.nodenext)
			{
				nd.nodenext.nodeprev = nd.nodeprev;
			}
			
			if (nd == tailnode)
			{
				tailnode = nd.nodeprev;
			}
			
			if (nd == headnode)
			{
				headnode = nd.nodenext;
			}
			
			// Run Functions
			if (_clean)
			{
				nd.Clean();
			}
			
			if (_delete)
			{
				delete nd;
				nd = 0;
			}
			
			nodelist[@ _nodeslot] = 0;
			nodecount -= 1;
			
			if (nodecount == 0)
			{
				slotcurrent = 1;
			}
		}
	}
	
	function ClearNodes(_clean=true, _delete=true)
	{
		for (var i = 0; i < slotmax; i++)
		{
			if (nodelist[@ i])
			{
				RemoveNode(i, _clean, _delete);
			}
		}
	}
}

function Entity() constructor
{
	nodelinkedlist = 0;
	nodeslot = 0;
	nodenext = 0;
	nodeprev = 0;
	nodeinert = false; // Set to true to destroy node
	
	x = 0;
	y = 0;
	z = 0;
	
	state = 0;
	frame = 0;
	
	vb = -1;
	vbx = -1;
	
	drawlayer = 0;
	drawdepth = 0;
	
	#region Common =====================================
	
	function Start()
	{
		
	}
	
	function Update(ts=1.0)
	{
		
	}
	
	function Render2D()
	{
		
	}
	
	function Render3D()
	{
		
	}
	
	function Clean()
	{
		
	}
	
	function Destroy()
	{
		nodeinert = true;
	}
	
	function toString()
	{
		return stringf("%s: %s", nodeslot, [x, y, z])
	}
	
	#endregion ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	#region Entity Utility =====================================
	
	function SetLocation(_x, _y, _z)
	{
		x = _x;
		y = _y;
		z = _z;
	}
	
	function GetLocation() {return [x, y, z];}
	
	function Update(ts=1.0)
	{
		
	}
	
	#endregion ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
}

function E_Hitball() : Entity() constructor
{
	vb = FetchVB("hitball.vb", HEADER.vbf_pct);
	
	elementcount = 16;
	element = array_create(elementcount);
	
	radius = 10;
	
	for (var i = 0; i < elementcount; i++)
	{
		element[i] = [0, 0, 0, 0, 0, 1, 1]; // [x, y, z, dirx, diry, dirz, speed]
	}
	
	function Update(ts)
	{
		var e;
		for (var i = 0; i < elementcount; i++)
		{
			e = element[i];
			
			e[@ 0] += e[6] * e[3];
			e[@ 1] += e[6] * e[4];
			e[@ 2] += e[6] * e[5];
			e[@ 6] *= 0.8;
		}
		
		radius *= 0.8;
		
		if (radius < 1)
		{
			Destroy();
			return;
		}
	}
	
	function Render3D()
	{
		for (var i = 0; i < elementcount; i++)
		{
			e = element[i];
			matrix_set(matrix_world, Mat4TranslateScale(e[0], e[1], e[2], radius));
			vertex_submit(vb, pr_trianglelist, -1);
		}
	}
}