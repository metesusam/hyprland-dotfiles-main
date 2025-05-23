#!/bin/bash

# Script to reset all workspaces and return to a clean state
# Similar to a freshly started Hyprland session

# Show a confirmation dialog using rofi
confirm=$(echo -e "Hayır\nEvet" | rofi -dmenu -i -p "Tüm çalışma alanlarını sıfırlamak istiyor musunuz?")

if [[ "$confirm" != "Evet" ]]; then
    echo "İşlem iptal edildi."
    exit 0
fi

# Kill all visible applications except for essential ones
echo "Açık uygulamalar kapatılıyor..."
hyprctl clients | grep "class: " | grep -v "Waybar\|Rofi\|polkit-kde" | awk '{print $2}' | xargs -I{} hyprctl dispatch closewindow {}

# Re-initialize the waybar (in case it's buggy)
echo "Waybar yeniden başlatılıyor..."
killall waybar
sleep 0.5
waybar &

# Reset to workspace 1
echo "1 numaralı çalışma alanına geçiliyor..."
hyprctl dispatch workspace 1

# Restart swww for wallpaper (refresh the wallpaper)
echo "Duvar kağıdı yenileniyor..."
pkill swww
sleep 0.5
swww init
swww img ~/Resimler/wallpapers/wallpaper.jpg

# Restart dunst/mako notifications
echo "Bildirim sistemi yenileniyor..."
pkill mako
sleep 0.5
mako -c ~/.config/hypr/mako/config &

# Reset clipboard history (optional)
echo "Pano geçmişi sıfırlanıyor..."
pkill wl-paste
sleep 0.5
wl-paste --watch cliphist store &

echo "Çalışma alanları sıfırlandı. Sistem yeni başlatılmış durumda." 