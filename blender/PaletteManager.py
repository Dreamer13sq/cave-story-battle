import bpy
import mathutils
import numpy
import math
import bmesh
from bpy_extras.io_utils import ExportHelper

MAXCOLORS = 32
NODEGROUPSIGNATURE = '<DFPALETTE>'
NODEGROUPSIGNATUREUV = '<DFPALETTEUV>'
NODEGROUPSIGNATURESPECULAR = '<DFPALETTESPECULAR>'

def DotProduct(v1, v2):
    return sum(x*y for x, y in zip(v1, v2))

def CrossProduct(a, b):
    c = [a[1]*b[2] - a[2]*b[1],
         a[2]*b[0] - a[0]*b[2],
         a[0]*b[1] - a[1]*b[0]]
    return c

def CmpColor(c1, c2):
    return c1[0] == c2[0] and c1[1] == c2[1] and c1[2] == c2[2] and c1[3] == c2[3]

def ColorDistSq(c1, c2):
    return numpy.sqrt(
        (c2[0]-c1[0])*(c2[0]-c1[0]) +
        (c2[1]-c1[1])*(c2[1]-c1[1]) +
        (c2[2]-c1[2])*(c2[2]-c1[2])
    )

def SRGBtoLinear(c):
    return (
        (c[0]/12.92) if c[0] <= 0.0405 else pow((c[0]+0.055)/1.055, 2.4),
        (c[1]/12.92) if c[1] <= 0.0405 else pow((c[1]+0.055)/1.055, 2.4),
        (c[2]/12.92) if c[2] <= 0.0405 else pow((c[2]+0.055)/1.055, 2.4),
        c[3]
        )

def HueShift(color, amt):
    k = [0.57735]*3
    cosangle = math.cos(amt)
    sinamt = math.sin(amt)
    invcosangle = 1-cosangle
    
    cp = CrossProduct(k, color[:3])
    dp = DotProduct(k, color[:3])
    
    return [
        x*cosangle + cp[i] * sinamt + k[0]*dp*invcosangle
        for i,x in enumerate(color)
    ]

def GetPalNodes(material):
    frames = {x.name: x for x in material.node_tree.nodes if (x.type=='FRAME' and x.label[:4]=='pal-')}
    return (
        material.node_tree,
        material.node_tree.nodes,
        frames,
        [x for x in frames.values()][0]
    )

def GetPalFrames(node_tree):
    return {x.name: x for x in node_tree.nodes if (x.type=='FRAME' and x.label[:4]=='pal-')}

def GetPalRamps(node_tree):
    ramps = [x for x in node_tree.nodes if x.type == 'VALTORGB']
    ramps.sort(key= lambda x: int(x.label[-2:]))
    return ramps

def GetPalGroups(self, context):
    groups = [x for x in bpy.data.node_groups if NODEGROUPSIGNATURE in x.nodes.keys()]
    if len(groups) == 0:
        return [tuple(['0', '<No Groups Found>', ''])]
    return (
        (x.name, x.name, x.name)
        for x in groups
    )

def GetPalLive():
    nodegroupname = bpy.context.scene.dfighter_active_palette
    if nodegroupname != '0':
        return bpy.data.node_groups[nodegroupname]
    return None

# ---------------------------------------------------------------------------------------

def Palette_AddColor(node_tree, index, do_update=True):
    nodes = node_tree.nodes    
    colorramps = GetPalRamps(node_tree)
    
    index = max(0, min(len(colorramps)-1, index))
    
    # Add 1 to ramps ahead of index
    for i in range(0, len(colorramps)):
        if i >= index:
            colorramps[i].label = str(i+1)
        else:
            colorramps[i].label = str(i)
    
    # Sync new ramp with source ramp
    ramp = nodes.new('ShaderNodeValToRGB')
    ramp.label = str(index)
    srcramp = ramp if len(colorramps) == 0 else colorramps[index]
    
    elements = ramp.color_ramp.elements
    srcelements = srcramp.color_ramp.elements
    
    # Match size of source
    while len(elements) < len(srcelements): elements.new(0.0)
    while len(elements) > len(srcelements): elements.remove(elements[-1])
    
    # Copy over source values
    for i, e in enumerate(srcelements):
        edest = elements[i]
        edest.color, edest.alpha, edest.position = (e.color, e.alpha, e.position)
    
    if do_update:
        PalUpdate(node_tree);
    
    return ramp

# ---------------------------------------------------------------------------------------

def Palette_RemoveColor(node_tree, index):
    nodes = node_tree.nodes
    colorramps = GetPalRamps(node_tree)
    nodes.remove(colorramps[index]);
    PalUpdate(node_tree);

# ---------------------------------------------------------------------------------------

def Palette_MoveColor(node_tree, index, move_up):
    colorramps = GetPalRamps(node_tree)
    
    targetramps = (
        colorramps[max(0, index)], 
        colorramps[max(0, index-1)] if move_up else colorramps[min(len(colorramps)-1, index+1)]
        )
    targetnames = (targetramps[0].label, targetramps[1].label)
    
    targetramps[0].label = targetnames[1]
    targetramps[1].label = targetnames[0]
    PalUpdate(node_tree);

# ---------------------------------------------------------------------------------------

def Palette_ToImage(node_tree, image_name, width):
    colorramps = GetPalRamps(node_tree)
    
    image = bpy.data.images[image_name]
    image.scale(width, len(colorramps))
    
    pixels = []
    ramps = [x.color_ramp for x in colorramps]
    ramps.reverse()
    
    for r in ramps:
        color = [x.color for x in r.elements]
        pos = [x.position for x in r.elements]
        n = len(pos)
        
        i = 0
        for p in range(0, width):
            if p/(width-1) >= pos[min(i+1, n-1)]:
                i = min(i+1, n-1)
            pixels += list(color[i])
    image.pixels = pixels

# ---------------------------------------------------------------------------------------

def Palette_FromImage(node_tree, image):
    image = bpy.data.images[image]
    w, height = image.size
    
    # Remove all palette colors
    [node_tree.nodes.remove(x) for x in node_tree.nodes if x.type=='VALTORGB']
    
    PalUpdate(node_tree);
    
    # Iterate Through Palette Colors
    for r in range(0, min(height, MAXCOLORS)):
        elements = Palette_AddColor(node_tree, 0, False).color_ramp.elements
        while len(elements) > 1: # Clear elements
            elements.remove(elements[-1])
        
        currentcolor = image.pixels[r*w*4:r*w*4+4] # Get first color in row
        if image.colorspace_settings.name == 'sRGB':
            currentcolor = SRGBtoLinear(currentcolor)
        
        elements[0].color = currentcolor
        elements[0].position = 0.0
        
        for c in range(0, w):
            color = image.pixels[r*w*4+c*4:r*w*4+c*4+4] # Get color in image
            if image.colorspace_settings.name == 'sRGB':
                color = SRGBtoLinear(color)
            
            if not CmpColor(currentcolor, color):
                currentcolor = color
                e = elements.new(c/w)
                e.color = color
        
        if len(elements) == 1:
            e = elements.new(1.0)
            e.color = color
    
    if height < MAXCOLORS:
        for i in range(MAXCOLORS-height):
            elements = Palette_AddColor(node_tree, MAXCOLORS, False).color_ramp.elements
    
    PalUpdate(node_tree)

# ---------------------------------------------------------------------------------------

def PalUpdate(node_tree):
    nodes = node_tree.nodes
    
    if 'pal-colors' not in nodes.keys():
        frame = nodes.new('NodeFrame')
        frame.name = frame.label = 'pal-colors'
    frame = nodes['pal-colors']
    
    ysep = 32
    
    for nd in [x for x in nodes if x.type in ['MIX_RGB', 'MATH', 'VALUE'] ]:
        nodes.remove(nd)
    
    rampnodes = GetPalRamps(node_tree)
    
    # Nested Functions
    def NewNode(name, label, type, x, y, hide=False, width=-1):
        nd = node_tree.nodes.new(type)
        nd.name = name
        nd.label = label
        nd.location = (x, y)
        nd.hide=hide
        if width > -1:
            nd.width = width
        if frame:
            nd.parent = frame
        return nd
    
    def LinkNodes(n1, output_index, n2, input_index):
        return node_tree.links.new(
            (node_tree.nodes[n1] if isinstance(n1, str) else n1).outputs[output_index], 
            (node_tree.nodes[n2] if isinstance(n2, str) else n2).inputs[input_index]
            )
    
    yy = ysep
    
    # Value nodes
    valuenode = NewNode('Num Colors = N', '', 'ShaderNodeValue', 0, yy, True, 50)
    valuenode.outputs[0].default_value = len(rampnodes)
    
    groupinput = [x for x in nodes if x.type == 'GROUP_INPUT'][0]
    groupoutput = [x for x in nodes if x.type == 'GROUP_OUTPUT'][0]
    
    # Math Nodes
    divnode = NewNode('1 / N', '', 'ShaderNodeMath', 150, yy, True, 50)
    divnode.operation = 'DIVIDE'
    divnode.inputs[0].default_value = 1.0
    LinkNodes(valuenode, 0, divnode, 1)
    
    subnode = NewNode('N - 1', '', 'ShaderNodeMath', 300, yy, True, 50)
    subnode.operation = 'ADD'
    subnode.inputs[1].default_value = 1.0
    LinkNodes(valuenode, 0, subnode, 0)
    
    invnode = NewNode('1 - 1/N', '', 'ShaderNodeMath', 450, yy, True, 50)
    invnode.operation = 'SUBTRACT'
    invnode.inputs[0].default_value = 1.0
    LinkNodes(divnode, 0, invnode, 1)
    
    halfnode = NewNode('-0.5 / N', '', 'ShaderNodeMath', 600, yy, True, 50)
    halfnode.operation = 'DIVIDE'
    halfnode.inputs[0].default_value = -0.5
    LinkNodes(valuenode, 0, halfnode, 1)
    
    # Color Ramps
    for i, nd in enumerate(rampnodes):
        nd.hide = 1
        nd.location[0] = 1
        nd.location[1] = -(i+1) * ysep
        nd.name = "row%02d" % (i)
        nd.label = str(i)
        nd.color_ramp.color_mode = 'RGB'
        nd.color_ramp.interpolation = 'CONSTANT'
        nd.parent = frame
        LinkNodes('dp', 0, nd, 0)
    
    # Color Calculations
    if len(rampnodes) > 0:
        mixnode = rampnodes[-1]
        mixalphanode = mixnode
        xx = rampnodes[0].location[0]+280
        yy = rampnodes[0].location[1]
    
    for i in range(1, len(rampnodes)):
        nd1 = rampnodes[i-1] if i == 1 else mixnode
        nd1alpha = rampnodes[i-1] if i == 1 else mixalphanode
        nd2 = rampnodes[i]
        
        multnode = NewNode('1/N * Index', '', 'ShaderNodeMath', xx, yy, True, 40)
        multnode.operation = 'MULTIPLY'
        multnode.inputs[1].default_value = i
        
        greaternode = NewNode('UV.y is Index', '', 'ShaderNodeMath', xx+120, yy, True, 40)
        greaternode.operation = 'GREATER_THAN'
        
        # Mix with next node
        mixnode = NewNode('Mix with Next', '', 'ShaderNodeMixRGB', xx+240, yy, True, 40)
        mixalphanode = NewNode('Mix Alpha Next', '', 'ShaderNodeMixRGB', xx+360, yy, True, 40)
        
        LinkNodes(divnode, 0, multnode, 0)
        LinkNodes('uv', 0, greaternode, 0)
        LinkNodes(multnode, 0, greaternode, 1)
        LinkNodes(greaternode, 0, mixnode, 0)
        LinkNodes(greaternode, 0, mixalphanode, 0)
        
        LinkNodes(nd1, 0, mixnode, 1)
        LinkNodes(nd2, 0, mixnode, 2)
        
        LinkNodes(nd1alpha, 1 if i == 1 else 0, mixalphanode, 1)
        LinkNodes(nd2, 1, mixalphanode, 2)
        
        yy -= ysep
    
    # End linking
    if 'palx' in nodes.keys():
        LinkNodes(nodes['palx'], 0, 'dp', 0)
    if 'paly' in nodes.keys():
        LinkNodes(nodes['paly'], 0, 'uv', 0)
    
    LinkNodes(groupinput, 0, 'uv', 0)
    LinkNodes(groupinput, 1, 'dp', 0)
    
    if len(rampnodes) > 0:
        LinkNodes(mixnode, 0, 'outcolor', 0)
        LinkNodes(mixalphanode, 0, 'outalpha', 0)
        LinkNodes('outcolor', 0, groupoutput, 0)
        if 'outroute' in nodes.keys():
            LinkNodes('outcolor', 0, nodes['outroute'], 0)
    
    LinkNodes('pal-uv', 2, 'uv', 0)
    LinkNodes('pal-uv', 1, 'dp', 0)
    LinkNodes('outcolor', 0, 'pal-specular', 4)
    LinkNodes('outalpha', 0, 'pal-specular', 3)
    LinkNodes('pal-specular', 0, 'output', 0)
    
    LinkNodes('outalpha', 0, 'output-roughness', 0)

print('='*80)

# ================================================================================
# ================================================================================

classlist = []

class DMR_OP_PaletteAddColor(bpy.types.Operator):
    bl_idname = "dmr.palette_add_color"
    bl_label = "Add Color"
    bl_options = {'REGISTER', 'UNDO'}
    
    index : bpy.props.IntProperty()
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def execute(self, context):
        Palette_AddColor(GetPalLive(), self.index)
        
        return {'FINISHED'}
classlist.append(DMR_OP_PaletteAddColor)

# ---------------------------------------------------------------------------------------

class DMR_OP_PaletteRemoveColor(bpy.types.Operator):
    bl_idname = "dmr.palette_remove_color"
    bl_label = "Remove Color"
    bl_options = {'REGISTER', 'UNDO'}
    
    index : bpy.props.IntProperty()
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def execute(self, context):
        Palette_RemoveColor(GetPalLive(), self.index)
        return {'FINISHED'}
classlist.append(DMR_OP_PaletteRemoveColor)

# ---------------------------------------------------------------------------------------

class DMR_OP_PaletteMoveColor(bpy.types.Operator):
    bl_idname = "dmr.move_pal_color"
    bl_label = "Add Color"
    bl_options = {'UNDO', 'REGISTER'}
    
    move_up : bpy.props.BoolProperty()
    index : bpy.props.IntProperty()
    remap_uvs : bpy.props.BoolProperty(name='Remap UVs', default=True)
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def draw(self, context):
        self.layout.prop(self, 'remap_uvs')
    
    def execute(self, context):
        node_tree = GetPalLive()
        Palette_MoveColor(node_tree, self.index, self.move_up)
        
        if self.remap_uvs and context.active_object:
            lastobjectmode = context.active_object.mode
            bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
            
            nodes = node_tree.nodes
            colorramps = GetPalRamps(node_tree)
            
            n = len(colorramps)
            yhalf = 0.5/n
            movesign = -1 if self.move_up else 1
            oldindex = self.index
            newindex = self.index+movesign
            
            for obj in [x for x in context.selected_objects if x.type == 'MESH']:
                me = obj.data
                if not me.vertex_colors or not me.uv_layers:
                    continue
                
                bm = bmesh.new()
                bm.from_mesh(me)
                
                uv_lay = bm.loops.layers.uv.active
                
                targetuvs = [loop[uv_lay].uv for face in bm.faces for loop in face.loops]
                uvold = [uv for uv in targetuvs if n-(uv[1]+yhalf)*n == oldindex]
                uvnew = [uv for uv in targetuvs if n-(uv[1]+yhalf)*n == newindex]
                
                for uv in uvold:
                    uv[1] -= movesign/n;
                for uv in uvnew:
                    uv[1] += movesign/n;
                
                bm.to_mesh(me)
                bm.free()
                me.update()
            
            bpy.ops.object.mode_set(mode=lastobjectmode)
        return {'FINISHED'}
classlist.append(DMR_OP_PaletteMoveColor)

# ----------------------------------------------------------------------------------

class DMR_OP_PaletteToImage(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_to_image"
    bl_label = "Palette -> Image"
    bl_options = {'UNDO'}
    
    image : bpy.props.EnumProperty(name='Target Image',
        items = lambda x,y: ((x.name, '%s (%dx%d)' % (x.name, x.size[0], x.size[1]), x.name) for x in bpy.data.images if x.size[0] > 0))
    
    width : bpy.props.IntProperty(name='Width', default=MAXCOLORS)
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self, width=200)
    
    def draw(self, context):
        self.layout.prop(self, 'image')
        self.layout.prop(self, 'width')
    
    def execute(self, context):
        Palette_ToImage(GetPalLive(), self.image, self.width)
        self.report({'INFO'}, 'Conversion to Image complete!')
        return {'FINISHED'}
classlist.append(DMR_OP_PaletteToImage)

# ----------------------------------------------------------------------------------

class DMR_OP_PaletteFromImage(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_from_image"
    bl_label = "Image -> Palette"
    bl_options = {'UNDO'}
    
    image : bpy.props.EnumProperty(name='Target Image',
        items = lambda x,y: ((x.name, '%s (%dx%d)' % (x.name, x.size[0], x.size[1]), x.name) for x in bpy.data.images if x.size[0] > 0))
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self, width=200)
    
    def draw(self, context):
        self.layout.prop(self, 'image')
    
    def execute(self, context):
        Palette_FromImage(GetPalLive(), self.image)
        
        return {'FINISHED'}
classlist.append(DMR_OP_PaletteFromImage)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_SetUV(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_set_uv"
    bl_label = "Set UV from Index"
    bl_options = {'REGISTER', 'UNDO'}
    
    movex : bpy.props.BoolProperty(name='Change X Position', default=0)
    index : bpy.props.IntProperty(name='Color Index', default=0)
    xposition : bpy.props.FloatProperty(name='Default Shadow', default=1.0, min=0.0, max=1.0)
    
    @classmethod
    def poll(self, context):
        return context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def draw(self, context):
        self.layout.prop(self, 'movex')
        self.layout.prop(self, 'index')
        if self.movex:
            self.layout.prop(self, 'xposition')
    
    def execute(self, context):
        lastobjectmode = bpy.context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        node_tree = GetPalLive()
        colorramps = GetPalRamps(node_tree)
        yy = 1.0-((self.index+0.5)/len(colorramps))
        xx = self.xposition
        
        for obj in [x for x in context.selected_objects if x.type == 'MESH']:
            me = obj.data
            bm = bmesh.new()
            bm.from_mesh(me)
            
            uv_lay = bm.loops.layers.uv.active
            
            targetloops = [x for face in bm.faces if face.select for x in face.loops]
            if len(targetloops) == 0:
                targetloops = [x for face in bm.faces for x in face.loops]
            for loop in targetloops:
                loop[uv_lay].uv[1] = yy;
                if self.movex:
                    loop[uv_lay].uv[0] = xx;
            
            bm.to_mesh(me)
            bm.free()
            me.update()
        
        bpy.ops.object.mode_set(mode=lastobjectmode)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_SetUV)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_MoveUV(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_move_uv"
    bl_label = "Offset Pal UV"
    bl_options = {'REGISTER', 'UNDO'}
    
    offset : bpy.props.IntProperty(name='Offset', default=0)
    
    @classmethod
    def poll(self, context):
        return GetPalLive() and context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def draw(self, context):
        self.layout.prop(self, 'offset')
    
    def execute(self, context):
        lastobjectmode = context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        node_tree = GetPalLive()
        colorramps = GetPalRamps(node_tree)
        
        for obj in [x for x in context.selected_objects if x.type == 'MESH']:
            me = obj.data
            bm = bmesh.new()
            bm.from_mesh(me)
            
            uv_lay = bm.loops.layers.uv.active
            yy = self.offset/len(colorramps)
            
            targetuvs = [loop[uv_lay].uv for face in bm.faces if face.select for loop in face.loops]
            if len(targetuvs) == 0:
                targetuvs = [loop[uv_lay].uv for face in bm.faces for loop in face.loops]
            for uv in targetuvs:
                uv[1] += yy;
            
            bm.to_mesh(me)
            bm.free()
            me.update()
        
        bpy.ops.object.mode_set(mode=lastobjectmode)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_MoveUV)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_ToggleRange(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_toggle_range"
    bl_label = "Switch UV Range"
    bl_options = {'REGISTER', 'UNDO'}
    
    @classmethod
    def poll(self, context):
        return GetPalLive() and context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def execute(self, context):
        lastobjectmode = context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        node_tree = GetPalLive()
        colorramps = GetPalRamps(node_tree)
        
        for obj in [x for x in context.selected_objects if x.type == 'MESH']:
            me = obj.data
            bm = bmesh.new()
            bm.from_mesh(me)
            
            uv_lay = bm.loops.layers.uv.active
            targetuvs = [loop[uv_lay].uv for face in bm.faces for loop in face.loops]
            
            n = len(colorramps)
            yhalf = 0.5/n
            
            # [0-1) Range
            if len([uv for uv in targetuvs if (uv[1]>0.0 and uv[1]<1.0)]) > 0:
                for uv in targetuvs:
                    uv[1] = (uv[1]-yhalf)*n;
            else:
                for uv in targetuvs:
                    uv[1] = uv[1]/n+yhalf;
            
            bm.to_mesh(me)
            bm.free()
            me.update()
            
        bpy.ops.object.mode_set(mode=lastobjectmode)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_ToggleRange)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_FromVertexColor(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_from_vcolor"
    bl_label = "From Vertex Color"
    bl_options = {'REGISTER', 'UNDO'}
    
    @classmethod
    def poll(self, context):
        return GetPalLive() and context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def execute(self, context):
        lastobjectmode = context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        node_tree = GetPalLive()
        colorramps = GetPalRamps(node_tree)
        
        colormap = {x.color_ramp.evaluate(0.75): i for i,x in enumerate(colorramps)}
        colorkeys = colormap.keys()
        
        print('Color Map Colors')
        for x in colorkeys:
            print(x[:])
        
        for obj in [x for x in context.selected_objects if x.type == 'MESH']:
            me = obj.data
            
            if not me.vertex_colors or not me.uv_layers:
                continue
            
            bm = bmesh.new()
            bm.from_mesh(me)
            
            uv_lay = bm.loops.layers.uv.active
            vc_lay = bm.loops.layers.color.active
            
            targetloops = [loop for face in bm.faces for loop in face.loops]
            
            n = len(colorramps)
            yhalf = 0.5/n
            
            print(obj.name + '~'*40)
            for x in (set([ SRGBtoLinear(x[vc_lay][:]) for x in targetloops])):
                print(x)
            
            for loop in targetloops:
                index = 0
                d = 1000000.0
                vc = SRGBtoLinear(loop[vc_lay])
                #vc = loop[vc_lay]
                
                for palcolor in colorkeys:
                    dd = ColorDistSq(vc, palcolor)
                    if dd < d:
                        index = colormap[palcolor]
                        d = dd
                
                loop[uv_lay].uv[1] = (float(n-index)/n)-yhalf
                
            bm.to_mesh(me)
            bm.free()
            me.update()
            
        bpy.ops.object.mode_set(mode=lastobjectmode)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_FromVertexColor)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_ColorHSV(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_color_hsv"
    bl_label = "Change HSV"
    bl_options = {'REGISTER', 'UNDO'}
    
    index : bpy.props.IntProperty()
    hue : bpy.props.FloatProperty(name='Hue', default=0.0, options={'SKIP_SAVE'}, step=1)
    sat : bpy.props.FloatProperty(name='Saturation', default=0.0, options={'SKIP_SAVE'}, step=1)
    val : bpy.props.FloatProperty(name='Value', default=0.0, options={'SKIP_SAVE'}, step=1)
    
    basecolors = []
    
    def invoke(self, context, event):
        node_tree = GetPalLive()
        colorramps = GetPalRamps(node_tree)
        self.basecolors = [mathutils.Vector([x for x in y.color][:3]) for y in colorramps[self.index].color_ramp.elements]
        return self.execute(context)
    
    def execute(self, context):
        node_tree = GetPalLive()
        colorramps = GetPalRamps(node_tree)
        
        for i,e in enumerate(colorramps[self.index].color_ramp.elements):
            c = mathutils.Vector(HueShift(self.basecolors[i], self.hue))
            c = c.lerp([c.length]*3, -self.sat)
            c += mathutils.Vector([self.val]*3)
            e.color[:3] = c;
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_ColorHSV)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_ImportPalette(bpy.types.Operator, ExportHelper):
    """Tooltip"""
    bl_idname = "dmr.palette_import"
    bl_label = "Import Palette from File"
    bl_options = {'REGISTER', 'UNDO'}
    
    filename_ext = ".png"
    filter_glob: bpy.props.StringProperty(default="*"+filename_ext, options={'HIDDEN'}, maxlen=255)
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def execute(self, context):
        image = bpy.data.images.load(self.filepath, check_existing=False)
        
        node_tree = GetPalLive()
        Palette_FromImage(node_tree, image.name)
        
        bpy.data.images.remove(image)
        
        self.report({'INFO'}, 'Palette read from "%s"' % self.filepath)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_ImportPalette)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_ExportPalette(bpy.types.Operator, ExportHelper):
    """Tooltip"""
    bl_idname = "dmr.palette_export"
    bl_label = "Export Palette to File"
    bl_options = {'REGISTER', 'UNDO'}
    
    filename_ext = ".png"
    filter_glob: bpy.props.StringProperty(default="*"+filename_ext, options={'HIDDEN'}, maxlen=255)
    
    width: bpy.props.IntProperty(name='Width', default=MAXCOLORS)
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def execute(self, context):
        image = bpy.data.images.new('__tempsprite', width=16, height=16)
        image.colorspace_settings.name = 'Linear'
        image.alpha_mode = 'STRAIGHT'
        image.filepath_raw = self.filepath
        image.file_format = 'PNG'
        
        node_tree = GetPalLive()
        Palette_ToImage(node_tree, image.name, self.width)
        
        colormode = context.scene.render.image_settings.color_mode
        context.scene.render.image_settings.color_mode = 'RGBA'
        context.scene.render.image_settings.color_mode = colormode
        image.save_render(self.filepath)
        bpy.data.images.remove(image)
        
        self.report({'INFO'}, 'Palette written to "%s"' % self.filepath)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_ExportPalette)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_NewLiveGroup(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_new_group"
    bl_label = "New Live Palette Group"
    bl_options = {'REGISTER', 'UNDO'}
    
    name : bpy.props.StringProperty(name='Name', default='Live Palette')
    
    def execute(self, context):
        node_tree = bpy.data.node_groups.new(self.name, 'ShaderNodeTree')
        header = node_tree.nodes.new('NodeFrame')
        header.name = header.label = NODEGROUPSIGNATURE
        header.location = (0, 400)
        
        def NewNode(name, label, type, x, y, hide=False, width=-1):
            nd = node_tree.nodes.new(type)
            nd.name = name
            nd.label = label
            nd.location = (x, y)
            nd.hide=hide
            if width > -1:
                nd.width = width
            return nd
        
        def LinkNodes(n1, output_index, n2, input_index):
            return node_tree.links.new(
                (node_tree.nodes[n1] if isinstance(n1, str) else n1).outputs[output_index], 
                (node_tree.nodes[n2] if isinstance(n2, str) else n2).inputs[input_index]
                )
        
        context.scene.dfighter_active_palette = node_tree.name
        
        # I/O
        node_tree.inputs.new('NodeSocketVector', 'Palette UV')
        node_tree.inputs.new('NodeSocketVector', 'Texture UV')
        node_tree.inputs.new('NodeSocketVector', 'Pal Params').default_value = (1,0,1)
        node_tree.inputs.new('NodeSocketVector', 'Surface Normal').default_value = (0,0,1)
        node_tree.inputs.new('NodeSocketVector', 'Light Direction').default_value = (0.256158, -0.819705, 0.512316)
        
        node_tree.outputs.new('NodeSocketColor', 'Color')
        node_tree.outputs.new('NodeSocketVector', 'UV')
        
        inputs = node_tree.nodes.new('NodeGroupInput')
        inputs.name = 'input'
        inputs.location = (-1000, 0)
        
        outputs = node_tree.nodes.new('NodeGroupOutput')
        outputs.name = 'output'
        outputs.label = 'Base Output'
        outputs.location = (1200, 0)
        
        # Reroutes
        NewNode('uv', '', 'NodeReroute', -40, 80)
        NewNode('dp', '', 'NodeReroute', -40, 40)
        NewNode('outcolor', '', 'NodeReroute', 800, 40)
        NewNode('outalpha', '', 'NodeReroute', 800, 0)
        
        # UV
        ng_uv = NewNode('pal-uv', '', 'ShaderNodeGroup', -500, 0)
        ng_uv.node_tree = [x for x in bpy.data.node_groups if NODEGROUPSIGNATUREUV in x.nodes.keys()][0]
        LinkNodes(inputs, 0, ng_uv, 0)
        LinkNodes(inputs, 1, ng_uv, 1)
        LinkNodes(inputs, 2, ng_uv, 2)
        LinkNodes(inputs, 3, ng_uv, 3)
        LinkNodes(inputs, 4, ng_uv, 4)
        
        # Specular
        ng_spe = NewNode('pal-specular', '', 'ShaderNodeGroup', 1000, 400)
        ng_spe.node_tree = [x for x in bpy.data.node_groups if NODEGROUPSIGNATURESPECULAR in x.nodes.keys()][0]
        LinkNodes(inputs, 3, ng_spe, 0)
        LinkNodes(inputs, 1, ng_spe, 1)
        LinkNodes(inputs, 4, ng_spe, 2)
        
        # Param Preview
        paluvXYZ = NewNode('palXYZ', 'Palette UV', 'ShaderNodeSeparateXYZ', -500, -400, True)
        LinkNodes(inputs, 0, paluvXYZ, 0)
        paramsXYZ = NewNode('paramsXYZ', 'Params XYZ', 'ShaderNodeSeparateXYZ', -500, -500, True)
        LinkNodes(inputs, 2, paramsXYZ, 0)
        
        for i,entry in enumerate([
            ('output-light', 'Light Value'),
            ('output-ao', 'Ambient Occlusion'),
            ('output-roughness', 'Roughness'),
            ('output-specular', 'Specular'),
        ]):
            NewNode(entry[0], entry[1], 'NodeGroupOutput', 1200, -200-50*i, True)
        
        LinkNodes(ng_uv, 1, 'output-light', 0)
        LinkNodes(paluvXYZ, 0, 'output-ao', 0)
        LinkNodes('outalpha', 0, 'output-roughness', 0)
        LinkNodes(ng_spe, 1, 'output-specular', 0)
        LinkNodes(paluvXYZ, 0, ng_spe, 5)
        
        # Generate nodes
        for i in range(0, MAXCOLORS):
            Palette_AddColor(node_tree, i, False)
        PalUpdate(node_tree)
        
        for nd in [nd for nd in node_tree.nodes if 'output' in nd.name]:
            LinkNodes(ng_uv, 0, nd, 1)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_NewLiveGroup)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_RemoveLiveGroup(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_remove_group"
    bl_label = "Remove Active Live Palette Group"
    bl_options = {'REGISTER', 'UNDO'}
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def execute(self, context):
        groups = [x[0] for x in GetPalGroups(self, context)]
        n = len(groups)
        active = GetPalLive()
        
        if n > 1:
            context.scene.dfighter_active_palette = groups[min(groups.index(active.name), n-2)]
        bpy.data.node_groups.remove(active)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_RemoveLiveGroup)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_SetActiveOutput(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_set_active_output"
    bl_label = "Set Active Node Group Output"
    bl_options = {'REGISTER', 'UNDO'}
    
    node_name : bpy.props.StringProperty()
    
    @classmethod
    def poll(self, context):
        return GetPalLive()
    
    def execute(self, context):
        node_tree = GetPalLive()
        
        if self.node_name in node_tree.nodes.keys():
            for nd in [x for x in node_tree.nodes if 'output' in x.name]:
                nd.is_active_output = False
            node_tree.nodes[self.node_name].is_active_output = True
            print('Active set to "%s"' % self.node_name)
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_SetActiveOutput)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_PalUVsToVC(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_uvs_to_vc"
    bl_label = "Palette UVs to Vertex Colors"
    bl_description = "Sets VC.rg to UV"
    bl_options = {'REGISTER', 'UNDO'}
    
    uv_layer_name : bpy.props.StringProperty(default='UVPal')
    vc_layer_name : bpy.props.StringProperty(default='PalControl')
    
    @classmethod
    def poll(self, context):
        return len(context.selected_objects)
    
    def execute(self, context):
        for obj in context.selected_objects:
            if obj.type != 'MESH':
                continue
            if self.uv_layer_name in obj.data.uv_layers.keys() and self.vc_layer_name in obj.data.vertex_colors.keys():
                uvlayer = obj.data.uv_layers[self.uv_layer_name].data
                vclayer = obj.data.vertex_colors[self.vc_layer_name].data
                
                for l in obj.data.loops:
                    vc = vclayer[l.index].color
                    uv = uvlayer[l.index].uv
                    vclayer[l.index].color = (uv[0], 1.0-(uv[1] % 1.0), vc[2], vc[3])
        
        return {'FINISHED'}
classlist.append(DMR_OP_Palette_PalUVsToVC)

# ====================================================================================

class DMR_MT_CSFighterPalette_Submenu(bpy.types.Menu):
    """Creates a Panel in the Object properties window"""
    bl_label = "Palette Color Options"
    index = 0
    def draw(self, context):
        layout = self.layout
        layout.label(text='Color %d Options' % self.index)
        layout.operator('dmr.palette_color_hsv').index=self.index

if 1:
    class DMR_MT_CSFighterPalette_Submenu0(DMR_MT_CSFighterPalette_Submenu): index=0
    class DMR_MT_CSFighterPalette_Submenu1(DMR_MT_CSFighterPalette_Submenu): index=1
    class DMR_MT_CSFighterPalette_Submenu2(DMR_MT_CSFighterPalette_Submenu): index=2
    class DMR_MT_CSFighterPalette_Submenu3(DMR_MT_CSFighterPalette_Submenu): index=3
    class DMR_MT_CSFighterPalette_Submenu4(DMR_MT_CSFighterPalette_Submenu): index=4
    class DMR_MT_CSFighterPalette_Submenu5(DMR_MT_CSFighterPalette_Submenu): index=5
    class DMR_MT_CSFighterPalette_Submenu6(DMR_MT_CSFighterPalette_Submenu): index=6
    class DMR_MT_CSFighterPalette_Submenu7(DMR_MT_CSFighterPalette_Submenu): index=7
    class DMR_MT_CSFighterPalette_Submenu8(DMR_MT_CSFighterPalette_Submenu): index=8
    class DMR_MT_CSFighterPalette_Submenu9(DMR_MT_CSFighterPalette_Submenu): index=9
    class DMR_MT_CSFighterPalette_Submenu10(DMR_MT_CSFighterPalette_Submenu): index=10
    class DMR_MT_CSFighterPalette_Submenu11(DMR_MT_CSFighterPalette_Submenu): index=11
    class DMR_MT_CSFighterPalette_Submenu12(DMR_MT_CSFighterPalette_Submenu): index=12
    class DMR_MT_CSFighterPalette_Submenu13(DMR_MT_CSFighterPalette_Submenu): index=13
    class DMR_MT_CSFighterPalette_Submenu14(DMR_MT_CSFighterPalette_Submenu): index=14
    class DMR_MT_CSFighterPalette_Submenu15(DMR_MT_CSFighterPalette_Submenu): index=15
    class DMR_MT_CSFighterPalette_Submenu16(DMR_MT_CSFighterPalette_Submenu): index=16
    class DMR_MT_CSFighterPalette_Submenu17(DMR_MT_CSFighterPalette_Submenu): index=17
    class DMR_MT_CSFighterPalette_Submenu18(DMR_MT_CSFighterPalette_Submenu): index=18
    class DMR_MT_CSFighterPalette_Submenu19(DMR_MT_CSFighterPalette_Submenu): index=19
    class DMR_MT_CSFighterPalette_Submenu20(DMR_MT_CSFighterPalette_Submenu): index=20
    class DMR_MT_CSFighterPalette_Submenu21(DMR_MT_CSFighterPalette_Submenu): index=21
    class DMR_MT_CSFighterPalette_Submenu22(DMR_MT_CSFighterPalette_Submenu): index=22
    class DMR_MT_CSFighterPalette_Submenu23(DMR_MT_CSFighterPalette_Submenu): index=23
    class DMR_MT_CSFighterPalette_Submenu24(DMR_MT_CSFighterPalette_Submenu): index=24
    class DMR_MT_CSFighterPalette_Submenu25(DMR_MT_CSFighterPalette_Submenu): index=25
    class DMR_MT_CSFighterPalette_Submenu26(DMR_MT_CSFighterPalette_Submenu): index=26
    class DMR_MT_CSFighterPalette_Submenu27(DMR_MT_CSFighterPalette_Submenu): index=27
    class DMR_MT_CSFighterPalette_Submenu28(DMR_MT_CSFighterPalette_Submenu): index=28
    class DMR_MT_CSFighterPalette_Submenu29(DMR_MT_CSFighterPalette_Submenu): index=29
    class DMR_MT_CSFighterPalette_Submenu30(DMR_MT_CSFighterPalette_Submenu): index=30
    class DMR_MT_CSFighterPalette_Submenu31(DMR_MT_CSFighterPalette_Submenu): index=31

    classlist.append(DMR_MT_CSFighterPalette_Submenu0)
    classlist.append(DMR_MT_CSFighterPalette_Submenu1)
    classlist.append(DMR_MT_CSFighterPalette_Submenu2)
    classlist.append(DMR_MT_CSFighterPalette_Submenu3)
    classlist.append(DMR_MT_CSFighterPalette_Submenu4)
    classlist.append(DMR_MT_CSFighterPalette_Submenu5)
    classlist.append(DMR_MT_CSFighterPalette_Submenu6)
    classlist.append(DMR_MT_CSFighterPalette_Submenu7)
    classlist.append(DMR_MT_CSFighterPalette_Submenu8)
    classlist.append(DMR_MT_CSFighterPalette_Submenu9)
    classlist.append(DMR_MT_CSFighterPalette_Submenu10)
    classlist.append(DMR_MT_CSFighterPalette_Submenu11)
    classlist.append(DMR_MT_CSFighterPalette_Submenu12)
    classlist.append(DMR_MT_CSFighterPalette_Submenu13)
    classlist.append(DMR_MT_CSFighterPalette_Submenu14)
    classlist.append(DMR_MT_CSFighterPalette_Submenu15)
    classlist.append(DMR_MT_CSFighterPalette_Submenu16)
    classlist.append(DMR_MT_CSFighterPalette_Submenu17)
    classlist.append(DMR_MT_CSFighterPalette_Submenu18)
    classlist.append(DMR_MT_CSFighterPalette_Submenu19)
    classlist.append(DMR_MT_CSFighterPalette_Submenu20)
    classlist.append(DMR_MT_CSFighterPalette_Submenu21)
    classlist.append(DMR_MT_CSFighterPalette_Submenu22)
    classlist.append(DMR_MT_CSFighterPalette_Submenu23)
    classlist.append(DMR_MT_CSFighterPalette_Submenu24)
    classlist.append(DMR_MT_CSFighterPalette_Submenu25)
    classlist.append(DMR_MT_CSFighterPalette_Submenu26)
    classlist.append(DMR_MT_CSFighterPalette_Submenu27)
    classlist.append(DMR_MT_CSFighterPalette_Submenu28)
    classlist.append(DMR_MT_CSFighterPalette_Submenu29)
    classlist.append(DMR_MT_CSFighterPalette_Submenu30)
    classlist.append(DMR_MT_CSFighterPalette_Submenu31)

# ----------------------------------------------------------------------------------

class DMR_PT_CSFighterPalette(bpy.types.Panel):
    """Creates a Panel in the Object properties window"""
    bl_label = "Palette Panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "Palette" # Name of sidebar

    def draw(self, context):
        layout = self.layout
        
        c = layout.column(align=True)
        r = c.row(align=True)
        r.prop(context.scene, 'dfighter_active_palette', text='')
        r.operator('dmr.palette_new_group', text='', icon='ADD')
        r.operator('dmr.palette_remove_group', text='', icon='REMOVE')
        
        node_tree = GetPalLive()
        
        if node_tree:
            c.prop(node_tree, 'name', text='')
            
            nodes = node_tree.nodes
            colorramps = GetPalRamps(node_tree)
            
            # I/O operators
            #layout.label(text=node_tree.name + ' %s' % len(colorramps))
            c = layout.column(align=1)
            rr = c.row(align=1)
            rr.operator('dmr.palette_import', icon='IMPORT', text='Import')
            rr.operator('dmr.palette_export', icon='EXPORT', text='Export')
            rr = c.row(align=1)
            rr.operator('dmr.palette_from_image', text='From Image')
            rr.operator('dmr.palette_to_image', text='To Image')
            c.operator('dmr.palette_from_vcolor')
            
            # Palette color operators
            rr = c.row(align=1)
            rr.operator('dmr.palette_set_uv', text='UV From Index')
            rr.operator('dmr.palette_move_uv')
            c.operator('dmr.palette_toggle_range')
            c.operator('dmr.palette_uvs_to_vc')
            
            # Output Visibility
            rr = layout.row()
            rr.label(text='Isolate:')
            rr = rr.row(align=1)
            rr.operator('dmr.palette_set_active_output', icon='COLOR', text='').node_name = 'output'
            rr.operator('dmr.palette_set_active_output', icon='OUTLINER_OB_LIGHT', text='').node_name = 'output-light'
            rr.operator('dmr.palette_set_active_output', icon='MOD_MASK', text='').node_name = 'output-ao'
            rr.operator('dmr.palette_set_active_output', icon='NODE_MATERIAL', text='').node_name = 'output-roughness'
            rr.operator('dmr.palette_set_active_output', icon='PROP_OFF', text='').node_name = 'output-specular'
            
            # Normal sphere
            c = layout.column()
            for nd in nodes:
                if nd.type == 'NORMAL':
                    c.prop(nd.outputs[0], 'default_value', text='')
            
            # Add color default
            c = layout.column(align=1)
            if len(colorramps) == 0:
                layout.operator('dmr.palette_add_color', icon='ADD', text='').index=0
            
            # Draw color ramps
            for i, cr_node in enumerate(colorramps):
                b = c.box().row(align=1)
                cc = b.row(align=1)
                cc.scale_x = 0.3
                cc.label(text='%02d' % i)
                cc = b.column(align=1)
                cc.scale_y = 0.7
                cc.template_color_ramp(cr_node, "color_ramp", expand=True)
                cc = b.column(align=1)
                op = cc.operator('dmr.move_pal_color', icon='TRIA_UP', text='')
                op.move_up=1
                op.index=i
                op = cc.operator('dmr.move_pal_color', icon='TRIA_DOWN', text='')
                op.move_up=0
                op.index=i
                cc = b.column(align=1)
                op = cc.operator('dmr.palette_add_color', icon='ADD', text='').index=i
                op = cc.operator('dmr.palette_remove_color', icon='REMOVE', text='').index=i
                cc = b.column(align=1)
                op = cc.operator('dmr.palette_set_uv', icon='UV', text='').index=i
                cc.menu("DMR_MT_CSFighterPalette_Submenu%d"%i, icon='DOWNARROW_HLT', text="")

classlist.append(DMR_PT_CSFighterPalette)

def register():
    for c in classlist:
        bpy.utils.register_class(c)
    
    bpy.types.Scene.dfighter_active_palette = bpy.props.EnumProperty(
        name="Active Live Palette", items=GetPalGroups, default=0
    )

def unregister():
    for c in classlist.reverse():
        bpy.utils.unregister_class(c)

if __name__ == "__main__":
    register()