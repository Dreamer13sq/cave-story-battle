import bpy

classlist = []

def ActionPoll(context):
    action = bpy.data.actions[context.scene.actionnav_action_index] if bpy.data.actions else None
    return (
        bpy.data.actions and len(action.pose_markers) <= 1
    )

# ====================================================================

class ACTIONNAV_OP_ActionSelect(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "actionnav.action_select"
    bl_label = "Set Action"
    bl_options = {'REGISTER', 'UNDO'}
    
    actionname : bpy.props.StringProperty(name='Action Name')
    
    @classmethod
    def poll(self, context):
        return context.object and (
            context.object.type == 'ARMATURE' or
            context.object.find_armature()
            )
    
    def execute(self, context):
        if self.actionname in bpy.data.actions.keys():
            action = bpy.data.actions[self.actionname]
            obj = context.object if context.object.type == 'ARMATURE' else context.object.find_armature()
            # Set armature action
            obj.animation_data.action = action
            # Set frame range
            markers = action.pose_markers
            if markers:
                sc = context.scene
                sc.frame_start = min([x.frame for x in markers])
                sc.frame_end = max([x.frame for x in markers])
                
        return {'FINISHED'}
classlist.append(ACTIONNAV_OP_ActionSelect)

# --------------------------------------------------------------------------------------

class ACTIONNAV_OP_SyncActionRange(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "actionnav.sync_action_range"
    bl_label = "Sync Action Range to Markers"
    bl_options = {'REGISTER', 'UNDO'}
    
    @classmethod
    def poll(self, context):
        action = bpy.data.actions[context.scene.actionnav_action_index] if bpy.data.actions else None
        return (
            action and 
            (
                len(action.pose_markers) > 0 and
                context.scene.frame_start != min([x.frame for x in action.pose_markers]) or
                context.scene.frame_end != max([x.frame for x in action.pose_markers])
            )
        )
    
    def execute(self, context):
        scene = context.scene
        action = bpy.data.actions[scene.actionnav_action_index]
        scene.frame_start = min([x.frame for x in action.pose_markers])
        scene.frame_end = max([x.frame for x in action.pose_markers])
                
        return {'FINISHED'}
classlist.append(ACTIONNAV_OP_SyncActionRange)

# --------------------------------------------------------------------------------------

class ACTIONNAV_OP_AddRangeMarkers(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "actionnav.add_range_markers"
    bl_label = "Add Range Markers"
    bl_options = {'REGISTER', 'UNDO'}
    
    @classmethod
    def poll(self, context):
        ActionPoll(context)
    
    def execute(self, context):
        scene = context.scene
        action = bpy.data.actions[scene.actionnav_action_index]
        if len(action.pose_markers) == 0:
            action.pose_markers.new('start').frame = scene.frame_start
        if len(action.pose_markers) == 1:
            action.pose_markers.new('end').frame = scene.frame_end
                
        return {'FINISHED'}
classlist.append(ACTIONNAV_OP_AddRangeMarkers)

# --------------------------------------------------------------------------------------

class CSBATTLE_UL_Action(bpy.types.UIList):
    def draw_item(self, context, layout, data, item, icon, active_data, active_propname):
        r = layout.row(align=1)
        #r.operator('actionnav.action_select', text='', icon='ACTION').actionname = item.name
        r.prop(item, "use_fake_user", text="", emboss=True, icon_value=0)
        r.prop(item, "name", text="", emboss=False, icon_value=0)
classlist.append(CSBATTLE_UL_Action)

# ====================================================================

def ActionNav_IndexUpdate(self, context):
    bpy.ops.actionnav.action_select(actionname=bpy.data.actions.keys()[context.scene.actionnav_action_index])

# --------------------------------------------------------------------------------------

def ActionNav_draw(self, context):
    if len(bpy.data.actions) == 0:
        return
    
    layout = self.layout
    scene = context.scene    
    obj = context.object
    action = bpy.data.actions[scene.actionnav_action_index]
    markers = action.pose_markers
    
    # Marker Range
    c = layout.box().column(align=1)
    r = c.row()
    r.label(text='Action Export Range:')
    if len(markers) <= 1:
        r = c.row(align=1)
        r.operator('actionnav.add_range_markers', icon='ADD')
    else:
        r.operator('actionnav.sync_action_range', text='', icon='FILE_REFRESH')
        r = c.row(align=1)
        r.prop(markers[0], 'frame', text='Start')
        r.prop(markers[-1], 'frame', text='End')
    
    # Actions
    layout.template_list("CSBATTLE_UL_Action", "", bpy.data, "actions", scene, "actionnav_action_index")

class CSBATTLE_PT_ActionNav(bpy.types.Panel):
    """Creates a Panel in the Object properties window"""
    bl_label = "Action Nav"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "ActionNav" # Name of sidebar

    def draw(self, context):
        ActionNav_draw(self, context)
classlist.append(CSBATTLE_PT_ActionNav)

class CSBATTLE_PT_EditTab(bpy.types.Panel):
    """Creates a Panel in the Object properties window"""
    bl_label = "Quick edits"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "ActionNav" # Name of sidebar

    def draw(self, context):
        layout = self.layout
        obj = context.object
        if obj == None:
            return
        if obj.type != 'ARMATURE':
            obj = obj.find_armature()
        if obj == None:
            return
        for pb in obj.pose.bones:
            for c in pb.constraints:
                if c.name[0] == '*':
                    layout.prop(c, 'influence', text=pb.name)
        
classlist.append(CSBATTLE_PT_EditTab)

# ==================================================================

print('~'*80)

def register():
    for c in classlist:
        bpy.utils.register_class(c)
    
    bpy.types.Scene.actionnav_action_index = bpy.props.IntProperty(update=ActionNav_IndexUpdate)

def unregister():
    for c in classlist.reverse():
        bpy.utils.unregister_class(c)

if __name__ == "__main__":
    register()
