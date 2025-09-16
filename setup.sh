#!/bin/bash

# 하늘을 뚫어라 (Through The Sky) 개발 환경 설정 스크립트

echo "=== 하늘을 뚫어라 개발 환경 설정 ==="

# 시스템 업데이트
echo "시스템 패키지 업데이트 중..."
sudo apt update

# Flatpak 설치 확인
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak 설치 중..."
    sudo apt install -y flatpak
else
    echo "Flatpak이 이미 설치되어 있습니다."
fi

# Flathub 저장소 추가
echo "Flathub 저장소 추가 중..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Godot Engine 설치 확인
if ! flatpak list | grep -q "org.godotengine.Godot"; then
    echo "Godot Engine 설치 중... (시간이 걸릴 수 있습니다)"
    sudo flatpak install -y flathub org.godotengine.Godot
else
    echo "Godot Engine이 이미 설치되어 있습니다."
fi

# 설치 확인
echo "설치 확인 중..."
GODOT_VERSION=$(flatpak run org.godotengine.Godot --version 2>/dev/null || echo "설치 실패")
echo "설치된 Godot 버전: $GODOT_VERSION"

echo ""
echo "=== 설정 완료 ==="
echo "게임 개발을 시작하려면:"
echo "1. flatpak run org.godotengine.Godot"
echo "2. '프로젝트 가져오기' 클릭 후 project.godot 파일 선택"
echo "3. F5 키를 눌러 게임 실행"
echo ""
echo "개발 환경이 준비되었습니다!"