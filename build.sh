#!/bin/sh

cc -std=c11 -g3 -Wall -I. -o main main.c -lglfw -lGL -lm
