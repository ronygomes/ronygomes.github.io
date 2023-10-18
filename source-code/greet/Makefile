.DEFAULT_GOAL:= run
.SILENT:

libgreet.so: greeter.c decorate.c greet.h
	gcc -I. -fpic -c greeter.c decorate.c
	gcc -shared -o libgreet.so decorate.o greeter.o

build: greet.h main.c libgreet.so
	gcc -I. -L. main.c -o main -lgreet

clean:
	rm -f greeter.o decorate.o libgreet.so main

run: build
	LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" ./main && make -s clean
