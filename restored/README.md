# Restored Apple Sprite Processor article code

Standalone restoration of the two scans in `tmp-pdf`. All new files are confined to this directory. No archive pipelines, repository tools, configuration, plans, tests, or existing sources were changed.

The assembly, BASIC listings, and sprite data have been transcribed from the scans. Page references below use the magazine's printed numbers; PDF pages are one-based. Original BASIC line numbers and statements are retained. Wrapped print lines and REM headings are joined; whitespace and decorative assembly comments are simplified. The assembly has comments marking the original page and source-line spans.

## Sources and inventory

| Article item | Printed pages / PDF pages | Restored files |
|---|---|---|
| January list 1: ASP hex dump | 147-153 / 2-8 | `hex/asp-8700.hex`, `hex/asp-checksums.json` |
| January example 1 | 150 / 5 | `basic/january-example-1.bas` |
| January list 2: reset-vector patch | 154 / 9 | `asm/reset.merlin.s`, `asm/reset.ca65.s`, `hex/reset-0390.hex` |
| January list 3: fighter demo | 154-158 / 9-13 | `basic/january-demo.bas` |
| January list 3: sprite-pattern data | 159 / 14 | `hex/spr-fight-6000.hex`, `hex/spr-fight-checksums.json` |
| February list 1: ampersand and POKE/CALL equivalents | 135 / 4 | `basic/february-list-1-ampersand.bas`, `basic/february-list-1-poke-call.bas` |
| February list 2: GET-UTILITY | 135-136 / 4-5 | `asm/get-utility.merlin.s`, `asm/get-utility.ca65.s`, `hex/get-utility-0300.hex` |
| February list 3: pattern capture and sprite demo | 136-137 / 5-6 | `basic/february-get-demo.bas` |
| February list 4: full ASP Merlin source | 137-147 / 6-16 | `asm/asp.merlin.s`, `asm/asp.ca65.s` |

The February symbol tables on printed pages 147-149 are assembler output rather than another program. Prose command-reference tables and diagrams are not separate program listings.

Input identities:

- `../maso-8701-p146-asp-1.pdf`: SHA-256 `66d6097140b13a0278fbd32ec034d36492875b3c99279563f8ec78f1d945ae82`
- `../maso-8702-p132-asp-2.pdf`: SHA-256 `99206d510755c183975751871554af8f33cfe1ced539a4bc8c8de8d937293eff`

## Verification

The February ASP source assembles to 3,142 initialized bytes at `$8700-$9345`. Its output passes **all 393 row checksums, 160 column checksums, and 20 block checksums** printed in January's dump. This cross-check uses the January checksums independently transcribed from the scan, rather than checksums generated from the assembly. The normalized ASP hex file is generated from that verified assembly.

The 276 sprite bytes at `$6000-$6113` pass **all 35 row checksums, 16 column checksums, and two block checksums** in the January listing. The eight sprite definitions in January's demo account for the entire 276-byte pattern block.

The GET utility and reset patch assemble byte-for-byte to their separately transcribed printed object bytes: 113 bytes and 29 bytes respectively. See `verification.json` for lengths, hashes, and check results.

BASIC files were checked for ordered, unique line numbers and input-line lengths. The POKE/CALL example passes an a2kit tokenize/detokenize/tokenize round trip. a2kit's parser rejects ASP extensions such as `& PUT#5,(I,50),1` and semicolon-separated ASP commands, so that check is not claimed for the other listings. **The demos have not been executed in an emulator.**

## Printed quirks and corrections

- January's first dump page places the final rows `$8838`, `$8798`, and `$88D8` in different columns from the preceding addresses, and the first two column footers are exchanged relative to the `P:1`/`P:2` headings. The restored hex is sorted by address; the checksum JSON follows the logical 160-byte blocks. All checks match after restoring that order.
- January BASIC line 865 visibly prints `DATA -160,...`. It is preserved in `january-demo.bas`. `january-demo.corrected.bas` changes **only that first value to `160`**, the `$A0` opcode (`LDY #0`) required by the sound routine. The negative printed value cannot be passed to `POKE`. This is a documented inferred correction, not a separately validated edition of the game.
- January line 205 uses both `KB` and `KBD`; the transcription preserves this. Applesoft identifies numeric variables by their first two characters, so these names alias.
- February gives GET-UTILITY a save length of `$70`, but its printed listing includes the final `RTS` at `$0370`, making the complete range `$0300-$0370`, length **`$71`**. The restored binary includes that final byte.
- January's sound DATA is left in the BASIC listing. The `.corrected.bas` variant does not otherwise alter game logic or sound bytes.

## Rebuilding locally

Requirements: Python 3 and the cc65 executables `ca65` and `ld65`. Optional BASIC checking requires `a2kit`.

From the repository root:

```sh
python3 tmp-pdf/restored/rebuild.py --basic
```

This builds in a temporary directory and checks the included generated files without modifying them. To regenerate the ca65 translations, normalized ASP hex, raw binaries, and verification report after an intentional source edit:

```sh
python3 tmp-pdf/restored/rebuild.py --write --basic
```

The helper is independent of the repository's existing pipelines. The readable `.merlin.s` files are its source inputs. The `.ca65.s` files translate directives and prefix symbols with `ASP_` to avoid ca65 reserved names; instruction semantics and bytes are preserved. Merlin `DCI` sets the high bit of the final string character, and double-quoted `ASC` emits high-bit text.

## Binary loading

| File in `bin/` | Load address | Bytes | Entry / purpose |
|---|---:|---:|---|
| `asp-8700.bin` | `$8700` | 3,142 | `$8700` installs ASP; `CALL 34560` |
| `get-utility-0300.bin` | `$0300` | 113 | `CALL 768;x,y,width,height,destination` |
| `reset-0390.bin` | `$0390` | 29 | `CALL 912` installs the printed reset patch |
| `spr-fight-6000.bin` | `$6000` | 276 | January demo's `SPR.FIGHT` pattern data |

These are **raw payloads without DOS load/length headers**. Use an emulator's raw-binary loader or import them into a DOS disk with the corresponding load addresses. ASP's reserved tables and buffers extend from `$9346` through `$95E9`; those are omitted from its saved payload, as in the article. The examples assume Applesoft and the Apple II language-card memory used by ASP. January's demo loads a DOS file named `SPR.FIGHT`; February's demo expects `ASP V1.0` and `GET-UTILITY`.
