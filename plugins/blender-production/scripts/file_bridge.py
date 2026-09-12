"""Optional ephemeral file queue installed explicitly inside an owned Blender UI."""
import json
import os
from pathlib import Path
import runpy
import time
import traceback
import uuid


def write_json(path, value):
    tmp = path.with_name(path.name + '.tmp')
    tmp.write_text(json.dumps(value, indent=2) + '\n')
    tmp.replace(path)


def install(control_dir, expected_blend, scripts_dir):
    import bpy
    expected = Path(expected_blend).resolve()
    allowed = Path(scripts_dir).resolve()
    control = Path(control_dir).resolve()
    if not bpy.data.filepath or Path(bpy.data.filepath).resolve() != expected:
        raise ValueError('Expected Blender file is not active')
    if not allowed.is_dir():
        raise ValueError('Allowed scripts directory does not exist')
    key = 'blender_production_bridge:' + str(control)
    if key in bpy.app.driver_namespace:
        raise RuntimeError('Bridge already installed in this session')
    control.mkdir(parents=True, exist_ok=True)
    if any((control / name).exists() for name in ('request.json', 'processing.json', 'STOP')):
        raise RuntimeError('Control directory has pending work or STOP; inspect it first')
    pid, session = os.getpid(), uuid.uuid4().hex
    # An exclusive lease also prevents a second process from claiming this queue.
    lease = control / 'bridge.lock'
    with lease.open('x') as handle:
        json.dump({'pid': pid, 'session': session}, handle)
    identity = {'pid': pid, 'session': session, 'file': str(expected),
                'scripts_dir': str(allowed), 'control_dir': str(control)}

    def stop(reason):
        write_json(control / 'state.json', dict(identity, status='stopped', reason=reason))
        bpy.app.driver_namespace.pop(key, None)
        lease.unlink(missing_ok=True)

    def tick():
        if not bpy.data.filepath or Path(bpy.data.filepath).resolve() != expected:
            stop('Active file changed')
            return None
        if (control / 'STOP').exists():
            stop('Requested')
            return None
        request, processing = control / 'request.json', control / 'processing.json'
        if not request.exists():
            return 0.5
        if processing.exists():
            stop('Unresolved processing file; manual inspection required')
            return None
        request.replace(processing)
        data, started = {}, time.perf_counter()
        try:
            if processing.stat().st_size > 65536:
                raise ValueError('Request exceeds 64 KiB')
            data = json.loads(processing.read_text())
            rid = data.get('request_id')
            if not isinstance(rid, str) or not 1 <= len(rid) <= 100:
                raise ValueError('Invalid request id')
            if data.get('session') != session or data.get('expected_pid') != pid:
                raise ValueError('Session/PID mismatch')
            if Path(data['expected_blend']).resolve() != expected:
                raise ValueError('Expected file mismatch')
            if data['action'] == 'inspect':
                result = dict(identity, objects=len(bpy.context.scene.objects),
                              scene=bpy.context.scene.name, engine=bpy.context.scene.render.engine)
            elif data['action'] == 'run_script':
                script = Path(data['script']).resolve()
                if not script.is_relative_to(allowed) or script.suffix != '.py' or not script.is_file():
                    raise ValueError('Script outside allowed directory or missing')
                runpy.run_path(str(script))
                result = {'executed': str(script), 'file_after': bpy.data.filepath}
            else:
                raise ValueError('Unsupported action')
            response = {'request_id': rid, 'ok': True, 'result': result}
        except Exception:
            response = {'request_id': data.get('request_id') if isinstance(data, dict) else None,
                        'ok': False, 'error': traceback.format_exc(limit=6)}
        response['seconds'] = time.perf_counter() - started
        write_json(control / 'response.json', response)
        processing.unlink()
        return 0.5

    bpy.app.driver_namespace[key] = tick
    bpy.app.timers.register(tick, first_interval=0.5, persistent=False)
    write_json(control / 'state.json', dict(identity, status='ready'))
    return dict(identity, status='ready', timer_key=key)
