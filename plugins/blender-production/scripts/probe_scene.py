"""Read-only bounded Blender diagnostics; usable via runpy/MCP or Blender CLI."""
import argparse
import collections
import json
import os
from pathlib import Path
import sys


def inspect_scene(limit=20):
    import bpy
    limit = max(0, min(int(limit), 100))
    scene = bpy.context.scene
    missing, unresolved = [], []
    external_count = 0
    for collection in (bpy.data.images, bpy.data.libraries, bpy.data.fonts, bpy.data.sounds):
        for block in collection:
            path = getattr(block, 'filepath', '')
            if not path or path == '<builtin>' or getattr(block, 'packed_file', None) or getattr(block, 'packed_files', None):
                continue
            external_count += 1
            if getattr(block, 'source', '') in {'TILED', 'SEQUENCE'} or '<UDIM>' in path or '<UVTILE>' in path:
                unresolved.append({'name': block.name, 'path': path, 'reason': 'Inspect tiles/sequence range separately'})
                continue
            absolute = bpy.path.abspath(path, library=getattr(block, 'library', None))
            if not Path(absolute).exists():
                missing.append({'name': block.name, 'path': absolute})
    cycles = getattr(scene, 'cycles', None)
    eevee = getattr(scene, 'eevee', None)
    preferences = bpy.context.preferences.addons.get('cycles')
    devices = []
    if preferences:
        # Read known devices only. Do not refresh drivers or change preferences.
        devices = [{'name': d.name, 'type': d.type, 'enabled': d.use}
                   for d in getattr(preferences.preferences, 'devices', [])]
    objects = list(scene.objects)
    return {
        'pid': os.getpid(), 'file': bpy.data.filepath, 'dirty': bpy.data.is_dirty,
        'version': bpy.app.version_string,
        'build': bpy.app.build_hash.decode(errors='replace'),
        'background': bpy.app.background, 'scene': scene.name,
        'engine': scene.render.engine,
        'units': {'system': scene.unit_settings.system, 'scale_length': scene.unit_settings.scale_length},
        'object_count': len(objects), 'object_types': dict(collections.Counter(o.type for o in objects)),
        'root_collections': [c.name for c in scene.collection.children][:limit],
        'shared_meshes': sum(1 for m in bpy.data.meshes if m.users > 1),
        'camera': scene.camera.name if scene.camera else None,
        'frame': scene.frame_current, 'range': [scene.frame_start, scene.frame_end],
        'fps': scene.render.fps / scene.render.fps_base,
        'resolution': [scene.render.resolution_x, scene.render.resolution_y, scene.render.resolution_percentage],
        'color': {'view_transform': scene.view_settings.view_transform,
                  'look': scene.view_settings.look, 'exposure': scene.view_settings.exposure,
                  'display': scene.display_settings.display_device},
        'cycles': {key: getattr(cycles, key, None) for key in ('device', 'samples', 'use_denoising')},
        'eevee': {key: getattr(eevee, key, None) for key in ('taa_samples', 'taa_render_samples', 'shadow_resolution_scale')},
        'known_devices': devices,
        'assets': {'external_count': external_count, 'missing_count': len(missing),
                   'missing': missing[:limit], 'unresolved_count': len(unresolved),
                   'unresolved': unresolved[:limit], 'cache_audit': 'separate inspection required'},
        'objects_sample': [{'name': o.name, 'type': o.type, 'hidden_render': o.hide_render,
                            'data_users': getattr(o.data, 'users', None)} for o in objects[:limit]],
    }


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output', type=Path)
    p.add_argument('--limit', type=int, default=20)
    args = p.parse_args(sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else [])
    report = inspect_scene(args.limit)
    serialized = json.dumps(report, indent=2) + '\n'
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(serialized)
    else:
        print(serialized)
