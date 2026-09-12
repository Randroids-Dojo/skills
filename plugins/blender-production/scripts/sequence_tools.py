"""Check numbered SDR PNG frames and encode an atomically delivered verified MP4."""
import argparse
from fractions import Fraction
import json
from pathlib import Path
import shutil
import struct
import subprocess
import zlib


def png_info(path):
    with Path(path).open('rb') as f:
        if f.read(8) != b'\x89PNG\r\n\x1a\n':
            raise ValueError('Invalid PNG signature')
        info, has_data = None, False
        while True:
            head = f.read(8)
            if len(head) != 8:
                raise ValueError('Truncated PNG before IEND')
            size, kind = struct.unpack('>I4s', head)
            if size > 128 * 1024 * 1024:
                raise ValueError('PNG chunk exceeds inspection bound')
            payload, crc = f.read(size), f.read(4)
            if len(payload) != size or len(crc) != 4:
                raise ValueError('Truncated PNG chunk')
            if zlib.crc32(kind + payload) & 0xffffffff != struct.unpack('>I', crc)[0]:
                raise ValueError('PNG CRC mismatch')
            if info is None:
                if kind != b'IHDR' or size != 13:
                    raise ValueError('Missing valid first IHDR')
                w, h, depth, color, compression, filtering, interlace = struct.unpack('>IIBBBBB', payload)
                if not w or not h or compression != 0 or filtering != 0 or interlace not in (0, 1):
                    raise ValueError('Invalid IHDR values')
                info = {'width': w, 'height': h, 'bit_depth': depth, 'color_type': color}
            elif kind == b'IHDR':
                raise ValueError('Duplicate IHDR')
            if kind == b'IDAT':
                has_data = True
            if kind == b'IEND':
                if size or not has_data or f.read(1):
                    raise ValueError('Invalid PNG termination or missing image data')
                return info


def check_sequence(folder, first, count, width, height):
    if first < 0 or count < 1 or width < 1 or height < 1:
        raise ValueError('Invalid sequence range or dimensions')
    folder = Path(folder)
    bad, total_bytes = [], 0
    for n in range(first, first + count):
        path = folder / f'{n:06d}.png'
        try:
            info = png_info(path)
            if (info['width'], info['height']) != (width, height):
                raise ValueError(f'Wrong dimensions: {info}')
            total_bytes += path.stat().st_size
        except (OSError, ValueError) as exc:
            bad.append({'frame': n, 'error': str(exc)})
    return {'folder': str(folder.resolve()), 'first': first, 'count': count,
            'width': width, 'height': height, 'bytes': total_bytes,
            'ok': not bad, 'bad_count': len(bad), 'bad_frames': bad[:30],
            'check_scope': 'PNG coverage, dimensions, chunk CRC and structure; pixel decode occurs during encoding'}


def encode(folder, output, first, count, width, height, fps, ffmpeg='ffmpeg', ffprobe='ffprobe', crf=17, threads=4):
    output = Path(output).resolve()
    if output.exists():
        raise FileExistsError('Destination exists; inspect it instead of overwriting')
    if width % 2 or height % 2:
        raise ValueError('H.264 yuv420p requires even dimensions in this helper')
    rate = Fraction(str(fps))
    if rate <= 0 or not 0 <= crf <= 51 or threads < 1:
        raise ValueError('Invalid FPS, CRF, or thread count')
    for executable in (ffmpeg, ffprobe):
        if not shutil.which(executable):
            raise FileNotFoundError(executable)
    checked = check_sequence(folder, first, count, width, height)
    if not checked['ok']:
        raise ValueError(json.dumps(checked))
    output.parent.mkdir(parents=True, exist_ok=True)
    temp = output.with_name(output.stem + '.encoding.mp4')
    if temp.exists():
        raise FileExistsError('Partial encode exists; verify no encoder is active before recovering')
    cmd = [ffmpeg, '-hide_banner', '-nostdin', '-v', 'error', '-xerror', '-n',
           '-framerate', str(rate), '-start_number', str(first), '-i', str(Path(folder) / '%06d.png'),
           '-frames:v', str(count), '-an', '-vf', 'scale=out_color_matrix=bt709:out_range=tv,format=yuv420p',
           '-c:v', 'libx264', '-threads', str(threads), '-preset', 'medium', '-crf', str(crf),
           '-movflags', '+faststart', '-color_primaries', 'bt709', '-color_trc', 'bt709', '-colorspace', 'bt709', str(temp)]
    subprocess.run(cmd, check=True)
    metadata = json.loads(subprocess.check_output([ffprobe, '-v', 'error', '-count_frames',
                         '-show_streams', '-show_format', '-of', 'json', str(temp)]))
    streams = [s for s in metadata['streams'] if s['codec_type'] == 'video']
    if len(streams) != 1:
        raise ValueError('Expected exactly one video stream')
    video = streams[0]
    if int(video['nb_read_frames']) != count or Fraction(video['avg_frame_rate']) != rate:
        raise ValueError('Encoded frame count or rate mismatch')
    if (video['width'], video['height']) != (width, height):
        raise ValueError('Encoded dimensions mismatch')
    if abs(float(video['duration']) - float(count / rate)) > float(1 / rate):
        raise ValueError('Encoded duration mismatch')
    subprocess.run([ffmpeg, '-v', 'error', '-xerror', '-i', str(temp), '-f', 'null', '-'], check=True)
    if output.exists():
        raise FileExistsError('Destination appeared during encoding; leaving verified temporary file')
    temp.replace(output)
    report = {'file': str(output), 'sequence': checked, 'count': count, 'fps': str(rate),
              'duration_s': float(video['duration']), 'full_decode_check': True,
              'interpolated_frames': False, 'visual_review': 'pending'}
    output.with_suffix('.qa.json').write_text(json.dumps(report, indent=2) + '\n')
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('action', choices=('check', 'encode'))
    p.add_argument('folder', type=Path)
    p.add_argument('output', type=Path, nargs='?')
    p.add_argument('--first', type=int, default=1)
    p.add_argument('--count', type=int, required=True)
    p.add_argument('--width', type=int, required=True)
    p.add_argument('--height', type=int, required=True)
    p.add_argument('--fps', default='30')
    p.add_argument('--ffmpeg', default='ffmpeg')
    p.add_argument('--ffprobe', default='ffprobe')
    args = p.parse_args()
    if args.action == 'encode':
        if not args.output:
            p.error('encode requires an output path')
        result = encode(args.folder, args.output, args.first, args.count, args.width, args.height,
                        args.fps, args.ffmpeg, args.ffprobe)
    else:
        result = check_sequence(args.folder, args.first, args.count, args.width, args.height)
    print(json.dumps(result, indent=2))
    if result.get('ok') is False:
        raise SystemExit(1)
