/*
*/

// ============================================================================
// Vector Basic Operations
// ============================================================================

function Vec3Add(vec3A, vec3B)
{
	return [vec3A[0] + vec3B[0], vec3A[1] + vec3B[1], vec3A[2] + vec3B[2]];
}

function Vec3Add_ref(vec3A, vec3B, outvec3)
{
	outvec3[@ 0] = vec3A[0] + vec3B[0];
	outvec3[@ 1] = vec3A[1] + vec3B[1];
	outvec3[@ 2] = vec3A[2] + vec3B[2];
}

// ------------------------------------

function Vec3Subtract(vec3A, vec3B)
{
	return [vec3A[0] - vec3B[0], vec3A[1] - vec3B[1], vec3A[2] - vec3B[2]];
}

function Vec3Subtract_ref(vec3A, vec3B, outvec3)
{
	outvec3[@ 0] = vec3A[0] - vec3B[0];
	outvec3[@ 1] = vec3A[1] - vec3B[1];
	outvec3[@ 2] = vec3A[2] - vec3B[2];
}

// ------------------------------------

function Vec3Multiply(vec3A, vec3B)
{
	return [vec3A[0] * vec3B[0], vec3A[1] * vec3B[1], vec3A[2] * vec3B[2]];
}

function Vec3Multiply_ref(vec3A, vec3B, outvec3)
{
	outvec3[@ 0] = vec3A[0] * vec3B[0];
	outvec3[@ 1] = vec3A[1] * vec3B[1];
	outvec3[@ 2] = vec3A[2] * vec3B[2];
}

// ------------------------------------

function Vec3Divide(vec3A, vec3B)
{
	return [vec3A[0] / vec3B[0], vec3A[1] / vec3B[1], vec3A[2] / vec3B[2]];
}

function Vec3Divide_ref(vec3A, vec3B, outvec3)
{
	outvec3[@ 0] = vec3A[0] / vec3B[0];
	outvec3[@ 1] = vec3A[1] / vec3B[1];
	outvec3[@ 2] = vec3A[2] / vec3B[2];
}

// ------------------------------------

function Vec3Scale(vec3A, value)
{
	return [vec3A[0] * value, vec3A[1] * value, vec3A[2] * value];
}

function Vec3Scale_ref(vec3A, value, outvec3)
{
	outvec3[@ 0] = vec3A[0] * value;
	outvec3[@ 1] = vec3A[1] * value;
	outvec3[@ 2] = vec3A[2] * value;
}

// ============================================================================
// Normalization
// ============================================================================

// Normalizes Vec2 (Array of 2 numbers) -------------------------------
function Vec2Normalize(vec) // Direct Modification
{
	var d = point_distance(0, 0, vec[0], vec[1]);
	if d == 0 {return;}
	vec[@ 0] /= d; vec[@ 1] /= d;
}

function Vec2Normalized(vec) // Returns Copy
{
	var d = point_distance(0, 0, vec[0], vec[1]);
	return [vec[0]/d, vec[1]/d];
}

function Vec2NormalizedXY(x, y) // Returns Copy
{
	var d = point_distance(0, 0, x, y);
	return [x/d, y/d];
}

// Normalizes Vec3 (Array of 3 numbers) -------------------------------
function Vec3Normalize(vec) // Direct Modification
{
	var d = point_distance_3d(0, 0, 0, vec[0], vec[1], vec[2]);
	vec[@ 0] /= d; vec[@ 1] /= d; vec[@ 2] /= d;
}

function Vec3Normalized(vec) // Returns Copy
{
	var d = point_distance_3d(0, 0, 0, vec[0], vec[1], vec[2]);
	return [vec[0] / d, vec[1] / d, vec[2] / d];
}

function Vec3NormalizedXYZ(x, y, z) // Returns Copy
{
	var d = sqrt(x * x + y * y + z * z);
	return [x / d, y / d, z / d];
}

// ============================================================================
// Cross Product
// ============================================================================

/*
	Cross Product:
	X = (AyBz - AzBy)
	Y = (AzBx - AxBz)
	Z = (AxBy - AyBx)
*/

function CrossProduct3d(vec3A, vec3B) // Returns Copy
{
	return [
		vec3A[1] * vec3B[2] - vec3A[2] * vec3B[1],
		vec3A[2] * vec3B[0] - vec3A[0] * vec3B[2],
		vec3A[0] * vec3B[1] - vec3A[1] * vec3B[0]
		];
}

function CrossProduct3d_ref(vec3A, vec3B, outvec3) // Direct
{
	outvec3[@ 0] = vec3A[1] * vec3B[2] - vec3A[2] * vec3B[1];
	outvec3[@ 1] = vec3A[2] * vec3B[0] - vec3A[0] * vec3B[2];
	outvec3[@ 2] = vec3A[0] * vec3B[1] - vec3A[1] * vec3B[0];
}

function CrossProduct3dXYZ(x1, y1, z1, x2, y2, z2) // Returns Copy
{
	return [
		y1 * z2 - z1 * y2,
		z1 * x2 - x1 * z2,
		x1 * y2 - y1 * x2
		];
}

function CrossProduct3dXYZ_ref(x1, y1, z1, x2, y2, z2, outvec3) // Direct
{
	outvec3[@ 0] = y1 * z2 - z1 * y2;
	outvec3[@ 1] = z1 * x2 - x1 * z2;
	outvec3[@ 2] = x1 * y2 - y1 * x2;
}

// --------------------------------------------------------------------

function CrossProduct3dNormalized(vec3A, vec3B) // Returns Copy
{
	var xx = vec3A[1] * vec3B[2] - vec3A[2] * vec3B[1];
	var yy = vec3A[2] * vec3B[0] - vec3A[0] * vec3B[2];
	var zz = vec3A[0] * vec3B[1] - vec3A[1] * vec3B[0];
	var l = point_distance_3d(0,0,0, xx, yy, zz);
	return [xx/l, yy/l, zz/l];
}

function CrossProduct3dNormalized_ref(vec3A, vec3B, outvec3) // Direct
{
	var xx = vec3A[1] * vec3B[2] - vec3A[2] * vec3B[1];
	var yy = vec3A[2] * vec3B[0] - vec3A[0] * vec3B[2];
	var zz = vec3A[0] * vec3B[1] - vec3A[1] * vec3B[0];
	var l = point_distance_3d(0,0,0, xx, yy, zz);
	outvec3[@ 0] = xx/l;
	outvec3[@ 1] = yy/l;
	outvec3[@ 2] = zz/l;
}

function CrossProduct3dXYZNormalized(x1, y1, z1, x2, y2, z2) // Returns Copy
{
	var xx = y1 * z2 - z1 * y2;
	var yy = z1 * x2 - x1 * z2;
	var zz = x1 * y2 - y1 * x2;
	var l = point_distance_3d(0,0,0, xx, yy, zz);
	return [xx/l, yy/l, zz/l];
}

function CrossProduct3dXYZNormalized_ref(x1, y1, z1, x2, y2, z2, outvec3) // Direct
{
	var xx = y1 * z2 - z1 * y2;
	var yy = z1 * x2 - x1 * z2;
	var zz = x1 * y2 - y1 * x2;
	var l = point_distance_3d(0,0,0, xx, yy, zz);
	outvec3[@ 0] = xx/l;
	outvec3[@ 1] = yy/l;
	outvec3[@ 2] = zz/l;
}

// ============================================================================
// 3D -> 2D conversions
// ============================================================================

/// @desc Returns [Px, Py, Pz, Dx, Dy, Dz] with P the ray origin and D the ray direction
function ScreenToWorld(x, y, w, h, view_mat, proj_mat, outvec6 = [0,0,0,0,0,0])
{
    /*
	    Transforms a 2D coordinate (in window space) to a 3D vector.
	    Returns a Vector of the following format:
	    [dx, dy, dz, ox, oy, oz]
	    where [dx, dy, dz] is the direction vector and [ox, oy, oz] is the origin of the ray.
	    Works for both orthographic and perspective projections.
	    Script created by TheSnidr
	    (slightly modified by @dragonitespam)
		Modified again by Dreamer13sq (Swapped direction and origin of return. Added w and h arguments)
    */
	
    var mx = 2 * (x / w - 0.5) / proj_mat[0];
    var my = 2 * (y / h - 0.5) / proj_mat[5];
    var camX = - (view_mat[12] * view_mat[0] + view_mat[13] * view_mat[1] + view_mat[14] * view_mat[2]);
    var camY = - (view_mat[12] * view_mat[4] + view_mat[13] * view_mat[5] + view_mat[14] * view_mat[6]);
    var camZ = - (view_mat[12] * view_mat[8] + view_mat[13] * view_mat[9] + view_mat[14] * view_mat[10]);
    
    if (proj_mat[15] == 0) // This is a perspective projection
	{
		outvec6[@ 0] = camX;
		outvec6[@ 1] = camY;
		outvec6[@ 2] = camZ;
		outvec6[@ 3] = view_mat[2]  + mx * view_mat[0] + my * view_mat[1];
		outvec6[@ 4] = view_mat[6]  + mx * view_mat[4] + my * view_mat[5];
		outvec6[@ 5] = view_mat[10] + mx * view_mat[8] + my * view_mat[9];
        return outvec6;
    } 
	else // This is an ortho projection
	{    
		outvec6[@ 0] = camX + mx * view_mat[0] + my * view_mat[1];
		outvec6[@ 1] = camY + mx * view_mat[4] + my * view_mat[5];
		outvec6[@ 2] = camZ + mx * view_mat[8] + my * view_mat[9];
		outvec6[@ 3] = view_mat[2];
		outvec6[@ 4] = view_mat[6];
		outvec6[@ 5] = view_mat[10];
        return outvec6;
    }
}

/*
	Transforms a 3D world-space coordinate to a 2D window-space coordinate. Returns an array of the following format:
	[xx, yy]
	Returns [~0, ~0] if the 3D point is not in view
   
	Script created by TheSnidr
	www.thesnidr.com
	Edited by Dreamer13sq
*/
function WorldToScreen(x, y, z, view_mat, proj_mat, 
	width = window_get_width(), height = window_get_height(), outvec2 = [0,0])
{
    if (proj_mat[15] == 0) // This is a perspective projection
	{   
        var w = view_mat[2] * x + view_mat[6] * y + view_mat[10] * z + view_mat[14];
        // If you try to convert the camera's "from" position to screen space, you will
        // end up dividing by zero (please don't do that)
        //if (w <= 0) return [-1, -1];
        if (w == 0) 
		{
			outvec2[@ 0] = ~0;
			outvec2[@ 1] = ~0;
			return outvec2;
		}
        var cx = proj_mat[8] + proj_mat[0] * (view_mat[0] * x + view_mat[4] * y + view_mat[8] * z + view_mat[12]) / w;
        var cy = proj_mat[9] + proj_mat[5] * (view_mat[1] * x + view_mat[5] * y + view_mat[9] * z + view_mat[13]) / w;
    } 
	else // This is an ortho projection
	{    
        var cx = proj_mat[12] + proj_mat[0] * (view_mat[0] * x + view_mat[4] * y + view_mat[8]  * z + view_mat[12]);
        var cy = proj_mat[13] + proj_mat[5] * (view_mat[1] * x + view_mat[5] * y + view_mat[9]  * z + view_mat[13]);
    }
	
	outvec2[@ 0] = (0.5 + 0.5 * cx) * width;
	outvec2[@ 1] = (0.5 - 0.5 * cy) * height;
	return outvec2;
}

