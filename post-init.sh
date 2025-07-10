#!/bin/bash

# Serve ollama and pull models
ollama serve &
ollama pull llama2 &
ollama pull qwen2.5-coder &
