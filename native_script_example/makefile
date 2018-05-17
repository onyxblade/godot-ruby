all:
	gcc -std=c11 -fPIC -c src/ruby.c -I/home/cichol/godot_headers/ -I/home/cichol/.rbenv/versions/2.5.1/include/ruby-2.5.0/x86_64-linux -I/home/cichol/.rbenv/versions/2.5.1/include/ruby-2.5.0 -o src/ruby.os
	gcc -shared src/ruby.os -o bin/ruby.so -L/home/cichol/.rbenv/versions/2.5.1/lib -lruby
