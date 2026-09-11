---
description: Screenshot a scene from a real running build and look at it
argument-hint: [scene path or room name] [any capture.gd flags]
---

CLAUDE.md: an assertion proves the code ran, not that the picture is right, so
draw the thing you measured. This takes that picture.

Scene and flags: $ARGUMENTS

1. Resolve the scene to a `res://` path under `scenes/`. A bare name like
   `room_m1` means `res://scenes/rooms/room_m1.tscn`.
2. Run it, writing into the scratchpad rather than the repo:

   `tools/dev.sh shot <scene> /tmp/shot.png --zoom=0.38 --centre=800,180 --overwrite`

   `tools/capture.gd` documents the rest of the flags, `--input` and
   `--until-apex` among them. Pass through anything Matt gave above.
3. **Read the PNG.** Producing the file is not the point, looking at it is.
4. Say what is actually in the frame, including anything wrong that nobody asked
   about. If it does not match the numbers you expected, that gap is the finding.
