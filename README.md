how 2 dfvoice backend

- Install Haxe
- Install NodeJS
- Install all dependencies:
  
- haxelib install flixel
- haxelib install lime
- haxelib install openfl
- haxelib install haxeui-core
- haxelib install haxeui-openfl
- haxelib install haxeui-flixel

- Run setups:
- haxelib run lime setup flixel
- haxelib run lime setup
- haxelib install flixel-tools
- haxelib run flixel-tools setup
- (in ./server/) npm i


Proximity chat Recieving code is in PlayState.hx
Sending code is in Microphone.js.hx.
All compression/decompression is done in Microphone.js.hx
