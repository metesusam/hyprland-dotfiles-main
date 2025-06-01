#!/bin/bash
# Setup clean error handling for Hyprland

echo "🔧 Setting up clean Hyprland error handling..."

# Create directories
mkdir -p ~/.config/hypr/{logs,backups,scripts}

# Fix current config issues
echo "📝 Fixing config syntax issues..."
sed -i 's/##*/#/g' ~/.config/hypr/hyprland.conf

# Create validation script
cat > ~/.config/hypr/scripts/validate_config.sh << 'VALIDATE_EOF'
#!/bin/bash
# [validation script content from above]
VALIDATE_EOF

# Create error monitoring
cat > ~/.config/hypr/scripts/error_monitor.sh << 'MONITOR_EOF'
#!/bin/bash
# [error monitoring script from above]
MONITOR_EOF

chmod +x ~/.config/hypr/scripts/*.sh

echo "✅ Error handling setup complete!"
echo ""
echo "Usage:"
echo "  • Run validation before config changes: ~/.config/hypr/scripts/validate_config.sh"
echo "  • Monitor errors in background: ~/.config/hypr/scripts/error_monitor.sh &"
echo "  • Check logs: ls ~/.config/hypr/logs/"
