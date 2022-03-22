import bpy
import numpy
import bmesh

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

def GetPalNodes(material):
    material = bpy.data.materials['PalMaker']
    frames = {x.name: x for x in material.node_tree.nodes if (x.type=='FRAME' and x.label[:4]=='pal-')}
    activeframe = [x for x in frames.values()][0]
    return (
        material.node_tree,
        material.node_tree.nodes,
        frames,
        activeframe
    )

# ---------------------------------------------------------------------------------------

def Palette_AddColor(node_tree, frame, index):
    nodetree, nodes, nodeframes, activeframe = GetPalNodes(bpy.context.object.active_material)
    colorramps = [x for x in nodes if (x.type=='VALTORGB' and x.parent==activeframe)]
    colorramps.sort(key=lambda x: x.label)
    
    ramp = nodes.new('ShaderNodeValToRGB')
    srcramp = ramp if len(colorramps) == 0 else colorramps[index]
    ramp.parent = activeframe
    ramp.label = srcramp.label
    
    elements = ramp.color_ramp.elements
    srcelements = srcramp.color_ramp.elements
    
    # Match size of source
    while len(elements) < len(srcelements): elements.new(0.0)
    while len(elements) > len(srcelements): elements.remove(elements[-1])
    
    # Copy over source values
    for i, e in enumerate(srcelements):
        edest = elements[i]
        edest.color, edest.alpha, edest.position = (e.color, e.alpha, e.position)
    PalCheck();
    
    return ramp

# ---------------------------------------------------------------------------------------

def Palette_RemoveColor(node_tree, frame, index):
    nodetree, nodes, nodeframes, activeframe = GetPalNodes(bpy.context.object.active_material)
    colorramps = [x for x in nodes if (x.type=='VALTORGB' and x.parent==activeframe)]
    colorramps.sort(key=lambda x: x.label)
    
    nodes.remove(colorramps[index]);
    PalCheck();

# ---------------------------------------------------------------------------------------

def Palette_MoveColor(node_tree, frame, index, move_up):
    colorramps = [x for x in node_tree.nodes if (x.type=='VALTORGB' and x.parent==frame)]
    colorramps.sort(key=lambda x: x.label)
    
    targetramps = (
        colorramps[max(0, index)], 
        colorramps[max(0, index-1)] if move_up else colorramps[min(len(colorramps)-1, index+1)]
        )
    targetnames = (targetramps[0].label, targetramps[1].label)
    
    targetramps[0].label = targetnames[1]
    targetramps[1].label = targetnames[0]
    PalCheck();

# ---------------------------------------------------------------------------------------

def Palette_ToImage(node_tree, frame, image_name, width):
    colorramps = [x for x in node_tree.nodes if (x.type=='VALTORGB' and x.parent==frame)]
    colorramps.sort(key=lambda x: x.label)
    
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

def Palette_FromImage(node_tree, frame, image):
    image = bpy.data.images[image]
    w, height = image.size
    
    [node_tree.nodes.remove(x) for x in node_tree.nodes if (x.type=='VALTORGB' and x.parent==frame)]
    
    # Remove all colors
    for r in range(0, height):
        elements = Palette_AddColor(node_tree, frame, 0).color_ramp.elements
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

# ---------------------------------------------------------------------------------------

def PalCheck(material = bpy.data.materials['PalMaker']):
    nodetree, nodes, nodeframes, activeframe = GetPalNodes(material)
    
    ysep = 32
    
    for label, frame in nodeframes.items():
        frame.name = frame.label
        nameprefix = frame.name+'_'
        
        framenodes = [x for x in nodes if x.parent == frame]
        for nd in [x for x in framenodes if x.type in ['MIX_RGB', 'MATH', 'VALUE', 'REROUTE'] ]:
            nodes.remove(nd)
            framenodes.remove(nd)
        
        framenodes.sort(key=lambda x: x.name)
        rampnodes = [x for x in framenodes if x.type == 'VALTORGB']
        
        uvnode = nodes.new('NodeReroute')
        uvnode.parent = frame
        uvnode.location = (-40,80)
        uvnode.name = uvnode.label = nameprefix + 'uv'
        
        dpnode = nodes.new('NodeReroute')
        dpnode.parent = frame
        dpnode.location = (-40,40)
        dpnode.name = dpnode.label = nameprefix + 'dp'
        
        outcolornode = nodes.new('NodeReroute')
        outcolornode.parent = frame
        outcolornode.location = (700,40)
        outcolornode.name = outcolornode.label = nameprefix + 'outcolor'
        
        valuenode = nodes.new('ShaderNodeValue');
        valuenode.parent = frame
        valuenode.location = (0,0)
        valuenode.width=50
        valuenode.hide=1
        valuenode.name = valuenode.label = 'Num Colors'
        valuenode.outputs[0].default_value = len(rampnodes)
        
        divnode = nodes.new('ShaderNodeMath')
        divnode.parent = frame
        divnode.location = (150,0)
        divnode.width=50
        divnode.hide=1
        divnode.name = divnode.label = '1 / Num Colors'
        divnode.operation = 'DIVIDE'
        divnode.inputs[0].default_value = 1.0
        nodetree.links.new(valuenode.outputs[0], divnode.inputs[1])
        
        subnode = nodes.new('ShaderNodeMath')
        subnode.parent = frame
        subnode.location = (300,0)
        subnode.width=50
        subnode.hide=1
        subnode.name = subnode.label = 'Num Colors - 1'
        subnode.operation = 'ADD'
        subnode.inputs[1].default_value = 1.0
        nodetree.links.new(valuenode.outputs[0], subnode.inputs[0])
        
        # Color Ramps
        rampnodes.sort(key=lambda x: x.label)
        for i, nd in enumerate(rampnodes):
            nd.hide = 1
            nd.location[0] = 1
            nd.location[1] = -(i+1) * ysep
            nd.name = nameprefix+"row%02d" % (i)
            nd.label = "Color %02d" % (i)
            nd.color_ramp.color_mode = 'RGB'
            nd.color_ramp.interpolation = 'CONSTANT'
            
            nodetree.links.new(dpnode.outputs[0], nd.inputs[0])
        
        # Color Calculations
        if len(rampnodes) > 0:
            mixnode = rampnodes[-1]
            xx = rampnodes[0].location[0]+280
            yy = rampnodes[0].location[1]
            lastmixnode = None
        for i in range(1, len(rampnodes)):
            nd1 = rampnodes[i-1] if i == 1 else mixnode
            nd2 = rampnodes[i]
            
            if 1:
                multnode = nodes.new('ShaderNodeMath')
                multnode.parent = frame
                multnode.location = (xx, yy)
                multnode.width=40
                multnode.hide=1
                multnode.operation = 'MULTIPLY'
                multnode.inputs[1].default_value = i
                
                greaternode = nodes.new('ShaderNodeMath')
                greaternode.parent = frame
                greaternode.location = (xx+120, yy)
                greaternode.width=40
                greaternode.hide=1
                greaternode.operation = 'GREATER_THAN'
                
                mixnode = nodes.new('ShaderNodeMixRGB')
                mixnode.parent = frame
                mixnode.location = (xx+240, yy)
                mixnode.width=50
                mixnode.hide=1
                
                nodetree.links.new(divnode.outputs[0], multnode.inputs[0])
                nodetree.links.new(uvnode.outputs[0], greaternode.inputs[0])
                nodetree.links.new(multnode.outputs[0], greaternode.inputs[1])
                nodetree.links.new(greaternode.outputs[0], mixnode.inputs[0])
            else:
                multnode = nodes.new('ShaderNodeMath')
                multnode.parent = frame
                multnode.location = (xx, yy)
                multnode.width=40
                multnode.hide=1
                multnode.operation = 'MULTIPLY'
                
                greaternode = nodes.new('ShaderNodeMath')
                greaternode.parent = frame
                greaternode.location = (xx+120, yy)
                greaternode.width=40
                greaternode.hide=1
                greaternode.operation = 'SUBTRACT'
                greaternode.inputs[1].default_value = i;
                
                mixnode = nodes.new('ShaderNodeMixRGB')
                mixnode.parent = frame
                mixnode.location = (xx+240, yy)
                mixnode.width=50
                mixnode.hide=1
                
                nodetree.links.new(subnode.outputs[0], multnode.inputs[0])
                nodetree.links.new(uvnode.outputs[0], multnode.inputs[1])
                nodetree.links.new(multnode.outputs[0], greaternode.inputs[0])
                nodetree.links.new(greaternode.outputs[0], mixnode.inputs[0])
            
            nodetree.links.new(nd1.outputs[0], mixnode.inputs[1])
            nodetree.links.new(nd2.outputs[0], mixnode.inputs[2])
            
            yy -= ysep
        
        nodetree.links.new(nodes['palx'].outputs[0], dpnode.inputs[0])
        nodetree.links.new(nodes['paly'].outputs[0], uvnode.inputs[0])
        
        if len(rampnodes) > 0:
            nodetree.links.new(mixnode.outputs[0], outcolornode.inputs[0])
            nodetree.links.new(outcolornode.outputs[0], nodes['outroute'].inputs[0])
        
        
print('='*80)
PalCheck()

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
        return context.object and context.object.active_material
    
    def execute(self, context):
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        Palette_AddColor(nodetree, activeframe, self.index)
        
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
        return context.object and context.object.active_material
    
    def execute(self, context):
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        Palette_RemoveColor(nodetree, activeframe, self.index)
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
        return context.object and context.object.active_material
    
    def draw(self, context):
        self.layout.prop(self, 'remap_uvs')
    
    def execute(self, context):
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        Palette_MoveColor(nodetree, activeframe, self.index, self.move_up)
        
        if self.remap_uvs:
            lastobjectmode = context.active_object.mode
            bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
            
            nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
            colorramps = [x for x in nodetree.nodes if (x.type=='VALTORGB' and x.parent==activeframe)]
            
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
    bl_label = "Convert Palette to Image"
    bl_options = {'UNDO'}
    
    image : bpy.props.EnumProperty(name='Target Image',
        items = lambda x,y: ((x.name, '%s (%dx%d)' % (x.name, x.size[0], x.size[1]), x.name) for x in bpy.data.images if x.size[0] > 0))
    
    width : bpy.props.IntProperty(name='Width', default=16)
    
    @classmethod
    def poll(self, context):
        return context.object and context.object.active_material
    
    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self, width=200)
    
    def draw(self, context):
        self.layout.prop(self, 'image')
        self.layout.prop(self, 'width')
    
    def execute(self, context):
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        Palette_ToImage(nodetree, activeframe, self.image, self.width)
        self.report({'INFO'}, 'Conversion to Image complete!')
        return {'FINISHED'}
classlist.append(DMR_OP_PaletteToImage)

# ----------------------------------------------------------------------------------

class DMR_OP_PaletteFromImage(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_from_image"
    bl_label = "Generate Palette from Image"
    bl_options = {'UNDO'}
    
    image : bpy.props.EnumProperty(name='Target Image',
        items = lambda x,y: ((x.name, '%s (%dx%d)' % (x.name, x.size[0], x.size[1]), x.name) for x in bpy.data.images if x.size[0] > 0))
    
    @classmethod
    def poll(self, context):
        return context.object and context.object.active_material
    
    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self, width=200)
    
    def draw(self, context):
        self.layout.prop(self, 'image')
    
    def execute(self, context):
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        Palette_FromImage(nodetree, activeframe, self.image)
        
        return {'FINISHED'}
classlist.append(DMR_OP_PaletteFromImage)

# ----------------------------------------------------------------------------------

class DMR_OP_Palette_SetUV(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "dmr.palette_set_uv"
    bl_label = "Set UV from Index"
    bl_options = {'REGISTER', 'UNDO'}
    
    index : bpy.props.IntProperty(name='Color Index', default=0)
    
    @classmethod
    def poll(self, context):
        return context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def draw(self, context):
        self.layout.prop(self, 'index')
    
    def execute(self, context):
        lastobjectmode = bpy.context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        colorramps = [x for x in nodetree.nodes if (x.type=='VALTORGB' and x.parent==activeframe)]
        
        me = context.object.data
        bm = bmesh.new()
        bm.from_mesh(me)
        
        uv_lay = bm.loops.layers.uv.active
        yy = 1.0-((self.index+0.5)/len(colorramps))
        
        targetloops = [x for face in bm.faces if face.select for x in face.loops]
        if len(targetloops) == 0:
            targetloops = [x for face in bm.faces for x in face.loops]
        for loop in targetloops:
            loop[uv_lay].uv[1] = yy;
        
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
        return context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def draw(self, context):
        self.layout.prop(self, 'offset')
    
    def execute(self, context):
        lastobjectmode = context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        colorramps = [x for x in nodetree.nodes if (x.type=='VALTORGB' and x.parent==activeframe)]
        
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
        return context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def execute(self, context):
        lastobjectmode = context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        colorramps = [x for x in nodetree.nodes if (x.type=='VALTORGB' and x.parent==activeframe)]
        
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
        return context.object and context.object.active_material and context.object.data.uv_layers.active
    
    def execute(self, context):
        lastobjectmode = context.active_object.mode
        bpy.ops.object.mode_set(mode = 'OBJECT') # Update selected
        
        nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
        colorramps = [x for x in nodetree.nodes if (x.type=='VALTORGB' and x.parent==activeframe)]
        
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

# ====================================================================================

class DMR_PT_CSFighterPalette(bpy.types.Panel):
    """Creates a Panel in the Object properties window"""
    bl_label = "Palette Panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "Palette" # Name of sidebar

    def draw(self, context):
        layout = self.layout
        
        if context.object and context.object.active_material:
            material = context.object.active_material
            
            nodetree, nodes, nodeframes, activeframe = GetPalNodes(context.object.active_material)
            
            framenodes = [x for x in nodes if x.parent == activeframe]
            
            colorramps = [x for x in framenodes if (x.type=='VALTORGB')]
            colorramps.sort(key=lambda x: x.label)
            
            layout.label(text=material.name + ' %s' % len(colorramps))
            c = layout.column(align=1)
            c.operator('dmr.palette_to_image')
            c.operator('dmr.palette_from_image')
            c.operator('dmr.palette_from_vcolor')
            rr = c.row(align=1)
            rr.operator('dmr.palette_set_uv', text='UV From Index')
            rr.operator('dmr.palette_move_uv')
            c.operator('dmr.palette_toggle_range')
            
            c = layout.column(align=1)
            if len(colorramps) == 0:
                layout.operator('dmr.palette_add_color', icon='ADD', text='').index=0
            
            for nd in nodes:
                if nd.type == 'NORMAL':
                    c.prop(nd.outputs[0], 'default_value', text='Light Direction')
            
            for i, cr_node in enumerate(colorramps):
                b = c.box().row(align=1)
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

classlist.append(DMR_PT_CSFighterPalette)

def register():
    for c in classlist:
        bpy.utils.register_class(c)


def unregister():
    for c in classlist.reverse():
        bpy.utils.unregister_class(c)

if __name__ == "__main__":
    register()