#!/bin/bash

pub global activate protoc_plugin

protoc lib/protobuff/*.proto  --plugin=protoc-gen-dart=$HOME/.pub-cache/bin/protoc-gen-dart --dart_out=grpc:.