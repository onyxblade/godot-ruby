all:
	ruby util/generate.rb
	gcc -std=c11 -fPIC -c src/godot-ruby.c -I/home/cichol/godot_headers/ -I/home/cichol/.rbenv/versions/2.5.1/include/ruby-2.5.0/x86_64-linux -I/home/cichol/.rbenv/versions/2.5.1/include/ruby-2.5.0 -o src/godot-ruby.os -Wno-discarded-qualifiers
	gcc -shared src/godot-ruby.os -o bin/godot-ruby.so -L/home/cichol/.rbenv/versions/2.5.1/lib -lruby
