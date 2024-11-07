dependency to open this project:
- Godot 4.2.2 (IMPORTANT! This project breaks in 4.3+ due to unknown changes in AnimationTree. I'll investigate this soon.)
- FBX2gltf
- Blender 4.1 (recommended, but i think 3.6 is also okay for just importing)
  - Blender 4.0 is NOT recommended due to some bug in its gltf exporter

For FBX2gltf, follow the on screen guide provided by Godot engine to download the executable, then provide the path.

If you open the project before setting up Blender, it will show as a lot of scene is corrupted, that's okay.
Now go to `Editor > Editor Settings > FileSystem > Import` and copy the path of your Blender installation (the folder of which the blender executable is there)
<img src=".github/images/guide.png">

Godot license: https://godotengine.org/license/