#!/usr/bin/env python3
"""Rebuild and check this standalone restoration. Does not use archive pipelines.

Requires Python 3, ca65, and ld65. With --basic, also requires a2kit.
Default: verify in a temporary directory. --write updates generated artifacts here.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROGRAMS = (
    ('asp', 0x8700, 0xC46),
    ('get-utility', 0x0300, 0x71),
    ('reset', 0x0390, 0x1D),
)


def merlin_to_ca65(source: str) -> str:
    """Translate only the Merlin syntax used in these three listings."""
    lines = source.splitlines()
    symbols = {s.split()[0] for s in lines if s and not s[0].isspace() and not s.startswith('*')}

    def expression(value: str) -> str:
        parts = re.split(r"('[^']*'|\"[^\"]*\")", value)
        for i in range(0, len(parts), 2):
            # Leave hex literals and register suffixes (,X and ,Y) alone.
            parts[i] = re.sub(
                r'(?<![$,])\b[A-Z][A-Z0-9]*\b',
                lambda m: 'ASP_' + m[0] if m[0] in symbols else m[0], parts[i],
            )
        value = ''.join(parts)
        # Merlin applies < or > to the entire expression following it.
        if value.startswith(('#<', '#>')):
            value = value[:2] + '(' + value[2:] + ')'
        return value

    out = ['; ca65 translation of the adjacent Merlin source; ASP_ avoids reserved words.',
           '.setcpu "6502"', '.segment "CODE"']
    for line in lines:
        if not line or line.startswith('*'):
            out.append(';' + line[1:] if line.startswith('*') else '')
            continue
        quote, split = None, len(line)
        for j, char in enumerate(line):
            if char in ("'", '"'):
                if quote is None:
                    quote = char
                elif quote == char:
                    quote = None
            elif char == ';' and quote is None:
                split = j
                break
        code = line[:split]
        comment = line[split + 1:] if split < len(line) else ''
        label = ''
        if not code[0].isspace():
            label, code = code.split(None, 1)
        op, *args = code.strip().split(None, 1)
        arg = args[0] if args else ''
        pref = 'ASP_' + label if label else ''
        if op == '=':
            row = pref + ' = ' + expression(arg)
        elif op == 'OBJ':
            continue
        elif op == 'ORG':
            row = '.org ' + expression(arg)
        else:
            prefix = (pref + ':').ljust(16) if pref else ' ' * 16
            if op in ('DCI', 'ASC'):
                data = list(arg[1:-1].encode('ascii'))
                if op == 'DCI':
                    data[-1] ^= 0x80
                elif arg[0] == '"':
                    data = [b | 0x80 for b in data]
                row = prefix + '.byte ' + ', '.join(f'${b:02X}' for b in data)
            elif op == 'HEX':
                row = prefix + '.byte ' + ', '.join('$' + arg[i:i + 2] for i in range(0, len(arg), 2))
            elif op in ('DS', 'DFB'):
                row = prefix + ('.res ' if op == 'DS' else '.byte ') + expression(arg)
            else:
                row = prefix + op + ' ' + expression(arg)
        if comment:
            row += ' ;' + comment
        out.append(row.rstrip())
    return '\n'.join(out) + '\n'


def parse_hex(path: Path) -> tuple[int, bytes]:
    rows = []
    for line in path.read_text().splitlines():
        addr, text = line.split(':', 1)
        rows.append((int(addr, 16), bytes.fromhex(text)))
    start = rows[0][0]
    data = bytearray()
    for addr, row in rows:
        assert addr == start + len(data), f'{path.name}: address gap at {addr:04X}'
        data.extend(row)
    return start, bytes(data)


def monitor_hex(start: int, data: bytes) -> str:
    return ''.join(f'{start + i:04X}: {data[i:i + 8].hex(" ").upper()}\n'
                   for i in range(0, len(data), 8))


def check_sums(data: bytes, start: int, path: Path) -> dict:
    rows = columns = 0
    blocks = json.loads(path.read_text())
    for block in blocks:
        addr = int(block['address'], 16)
        expected_rows = bytes.fromhex(block['rows'])
        chunk = data[addr - start:addr - start + len(expected_rows) * 8]
        assert chunk, f'empty checksum block {addr:04X}'
        for i, expected in enumerate(expected_rows):
            got = sum(chunk[i * 8:i * 8 + 8]) & 255
            assert got == expected, f'row checksum {addr + i * 8:04X}: {got:02X} != {expected:02X}'
            rows += 1
        got_cols = bytes(sum(chunk[i::8]) & 255 for i in range(8))
        assert got_cols == bytes.fromhex(block['columns']), f'column checksums {addr:04X}'
        assert sum(chunk) & 255 == int(block['total'], 16), f'block checksum {addr:04X}'
        columns += 8
    assert rows == (len(data) + 7) // 8, 'incomplete checksum coverage'
    return {'rows': rows, 'columns': columns, 'blocks': len(blocks)}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='update generated source, hex, binary, and report files')
    parser.add_argument('--basic', action='store_true', help='also tokenize and round-trip BASIC with a2kit')
    args = parser.parse_args()
    for tool in ('ca65', 'ld65') + (('a2kit',) if args.basic else ()):
        if not shutil.which(tool):
            raise SystemExit(f'Required executable missing: {tool}')
    report = {'emulator_tested': False, 'assembly': {}, 'basic': {}}

    def artifact(path: Path, content: bytes) -> None:
        if args.write:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)
        else:
            assert path.read_bytes() == content, f'generated artifact differs: {path.relative_to(ROOT)}'

    with tempfile.TemporaryDirectory(prefix='asp-restoration-') as tmp:
        temp = Path(tmp)
        for name, address, size in PROGRAMS:
            text = merlin_to_ca65((ROOT / 'asm' / f'{name}.merlin.s').read_text())
            artifact(ROOT / 'asm' / f'{name}.ca65.s', text.encode())
            source, obj, binary, config = (temp / f'{name}.{suffix}' for suffix in ('s', 'o', 'bin', 'cfg'))
            source.write_text(text)
            config.write_text(f'MEMORY {{ RAM: start = ${address:04X}, size = ${0x10000 - address:04X}, file = %O; }}\n'
                              'SEGMENTS { CODE: load = RAM, type = ro; }\n')
            subprocess.run(['ca65', str(source), '-o', str(obj)], check=True)
            subprocess.run(['ld65', '-C', str(config), str(obj), '-o', str(binary)], check=True)
            data = binary.read_bytes()
            assert len(data) >= size
            payload = data[:size]
            # ASP ends with reserved workspace; the article saves only $8700-$9345.
            if name != 'asp':
                assert len(data) == size
            else:
                assert len(data) == 0x95EA - address
            filename = f'{name}-{address:04x}'
            artifact(ROOT / 'bin' / f'{filename}.bin', payload)
            info = {'address': f'{address:04X}', 'length': size,
                    'sha256': hashlib.sha256(payload).hexdigest()}
            if name == 'asp':
                info['printed_checksums'] = check_sums(payload, address, ROOT / 'hex' / 'asp-checksums.json')
                artifact(ROOT / 'hex' / f'{filename}.hex', monitor_hex(address, payload).encode())
            else:
                reference_address, reference_data = parse_hex(ROOT / 'hex' / f'{filename}.hex')
                assert (reference_address, reference_data) == (address, payload), f'{name}: printed byte comparison failed'
                info['matches_printed_bytes'] = True
            report['assembly'][name] = info
        address, data = parse_hex(ROOT / 'hex' / 'spr-fight-6000.hex')
        assert (address, len(data)) == (0x6000, 276)
        sums = check_sums(data, address, ROOT / 'hex' / 'spr-fight-checksums.json')
        artifact(ROOT / 'bin' / 'spr-fight-6000.bin', data)
        report['sprites'] = {'address': '6000', 'length': len(data),
                             'sha256': hashlib.sha256(data).hexdigest(), 'printed_checksums': sums}
        basic_files = sorted((ROOT / 'basic').glob('*.bas'))
        for source in basic_files:
            lines = source.read_text().splitlines()
            nums = [int(line.split()[0]) for line in lines]
            assert nums == sorted(set(nums)), f'{source.name}: repeated/out-of-order line numbers'
            assert all(len(line) <= 239 for line in lines), f'{source.name}: Applesoft input line too long'
            info = {'lines': len(lines)}
            if args.basic and any('&' in line.split('REM', 1)[0] for line in lines):
                info['token_roundtrip'] = 'not checked: a2kit parser rejects ASP extension syntax'
            elif args.basic:
                tokens = subprocess.run(['a2kit', 'tokenize', '-a', '2049', '-t', 'atxt'],
                                        input=source.read_bytes(), capture_output=True, check=True).stdout
                restored = subprocess.run(['a2kit', 'detokenize', '-t', 'atok'],
                                          input=tokens, capture_output=True, check=True).stdout
                tokens2 = subprocess.run(['a2kit', 'tokenize', '-a', '2049', '-t', 'atxt'],
                                         input=restored, capture_output=True, check=True).stdout
                assert tokens == tokens2, f'{source.name}: BASIC token round trip failed'
                # Each complete numbered source line must survive the tokenizer.
                roundtrip_nums = [int(line.split()[0]) for line in restored.decode().splitlines() if line.strip()]
                assert roundtrip_nums == nums, f'{source.name}: BASIC lines lost'
                info['token_roundtrip'] = True
                info['tokenized_bytes'] = len(tokens)
            report['basic'][source.name] = info
    if args.write:
        (ROOT / 'verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
