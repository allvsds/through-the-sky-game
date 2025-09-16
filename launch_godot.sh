#!/bin/bash

# 하늘을 뚫어라 게임 개발용 Godot 실행 스크립트

echo "Godot Engine 실행 중..."
echo "프로젝트 경로: $(pwd)"

# Godot Engine 실행 (현재 디렉토리의 project.godot 자동 로드)
flatpak run org.godotengine.Godot project.godot