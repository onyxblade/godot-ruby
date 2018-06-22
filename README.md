# godot-ruby

godot-ruby provides a Ruby language binding for Godot game engine. It is designed to be a drop-in replacement of GDScript.

**However this project is mainly experimental due to serveral limitations. Use in production is highly not recommended.**

# Building

Modify the paths in `env.yml` and `makefile` then `make`. Currently only Linux (and Mac maybe) are supported because the workaround of limitation 3. uses `pthread.h`.

# Implementation

godot-ruby utilizes code generation to generate Godot apis and bind them to ruby side. By defining [C types](https://github.com/CicholGricenchos/godot-ruby/blob/master/util/generator/types.rb) and [Ruby classes](https://github.com/CicholGricenchos/godot-ruby/blob/master/util/generator/classes.rb), the apis can be automatically generated, as [generated.c](https://gist.github.com/CicholGricenchos/6698738dbbf753061b3d94eefbad5481). Therefore the code for this project is simple.

The `util` folder contains code for generation. `lib` contains Ruby codes and `src` contains C codes.

# Known limitations

1. godot-ruby is considerably slower than GDScript (about 15x in my benchmark, see https://github.com/touilleMan/godot-python/issues/101). This could be due to inefficient implementation of pluginscript api.
2. Ruby's method semantic is incompatible with the seperate properties and methods in GDScript since there are only methods in Ruby.
For this we have to use `get` which looks weird:
```ruby
rect2.position #GDScript
rect2.get(:position) #Ruby
```
3. CRuby vm cannot support multi-threading. When godot engine calls the vm in different threads it crashs, which happens in resource preview loading (could be safely bypassed). To solve this we can use MRuby instead or use a single thread to run Ruby vm. However these two all need thread and mutex support and GDNative api currently does not provide one.