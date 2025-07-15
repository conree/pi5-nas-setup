#!/bin/bash
# anonymize_repository.sh - Automated anonymization for Pi 5 NAS repository
# Run this script to remove all personal information before publishing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup directory
BACKUP_DIR="./original_backup_$(date +%Y%m%d_%H%M%S)"

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup of original files
create_backup() {
    log "Creating backup of original files..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup all files that will be modified
    find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.env*" \) \
        -not -path "./.git/*" \
        -not -path "./original_backup*" \
        -exec cp --parents {} "$BACKUP_DIR/" \;
    
    success "Backup created in $BACKUP_DIR"
}

# Define replacement mappings
setup_replacements() {
    # Personal information
    ORIGINAL_USER="trinity"
    NEW_USER="pi-user"
    
    ORIGINAL_HOSTNAME="pi5"
    NEW_HOSTNAME="pi5-nas"
    
    ORIGINAL_TIMEZONE="America/Denver"
    NEW_TIMEZONE="America/New_York"
    
    ORIGINAL_NETWORK="192.168.0"
    NEW_NETWORK="192.168.1"
    
    ORIGINAL_IP="192.168.0.77"
    NEW_IP="192.168.1.100"
    
    # Storage UUIDs (real -> generic)
    declare -A UUID_MAP=(
        ["3ca082fe-18ad-4ce9-b638-c51208993311"]="aaaaaaaa-bbbb-cccc-dddd-111111111111"  # Movies drive
        ["5a833aa3-e71b-4f4d-846e-e75c4f59c7ef"]="bbbbbbbb-cccc-dddd-eeee-222222222222"  # Music drive
        ["44b3757b-70a8-412d-b12f-5dfd1c0b6e24"]="cccccccc-dddd-eeee-ffff-333333333333"  # Photos/TV drive
        ["34b2c3a7-65f3-4425-a0a7-57c72d73e8b6"]="dddddddd-eeee-ffff-aaaa-444444444444"  # Parity drive
    )
    
    # Personal folder names
    ORIGINAL_PHOTOS="family_history_photos"
    NEW_PHOTOS="photo_collection"
    
    ORIGINAL_PHOTOS_SPACES="family history photos"
    NEW_PHOTOS_SPACES="photo collection"
    
    # Personal references
    ORIGINAL_GDRIVE_PHOTOS="FamilyHistoryPhotos"
    NEW_GDRIVE_PHOTOS="PhotoCollection"
    
    ORIGINAL_MESSAGE="Trinity Family Photo Server"
    NEW_MESSAGE="Home Photo Server"
}

# Perform text replacements
perform_replacements() {
    log "Performing anonymization replacements..."
    
    # Find all relevant files
    local files=$(find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.env*" \) \
        -not -path "./.git/*" \
        -not -path "./original_backup*")
    
    # Username replacements
    log "Replacing username: $ORIGINAL_USER -> $NEW_USER"
    echo "$files" | xargs sed -i "s/$ORIGINAL_USER/$NEW_USER/g"
    
    # Hostname replacements
    log "Replacing hostname: $ORIGINAL_HOSTNAME -> $NEW_HOSTNAME"
    echo "$files" | xargs sed -i "s/$ORIGINAL_HOSTNAME:/$NEW_HOSTNAME:/g"
    echo "$files" | xargs sed -i "s/@$ORIGINAL_HOSTNAME/@$NEW_HOSTNAME/g"
    
    # Timezone replacements
    log "Replacing timezone: $ORIGINAL_TIMEZONE -> $NEW_TIMEZONE"
    echo "$files" | xargs sed -i "s|$ORIGINAL_TIMEZONE|$NEW_TIMEZONE|g"
    
    # Network replacements
    log "Replacing network: $ORIGINAL_NETWORK -> $NEW_NETWORK"
    echo "$files" | xargs sed -i "s/$ORIGINAL_NETWORK\\\./$NEW_NETWORK./g"
    echo "$files" | xargs sed -i "s/$ORIGINAL_IP/$NEW_IP/g"
    
    # UUID replacements
    log "Replacing storage UUIDs..."
    for original_uuid in "${!UUID_MAP[@]}"; do
        new_uuid="${UUID_MAP[$original_uuid]}"
        echo "$files" | xargs sed -i "s/$original_uuid/$new_uuid/g"
        log "  $original_uuid -> $new_uuid"
    done
    
    # Photo folder replacements
    log "Replacing photo folder references..."
    echo "$files" | xargs sed -i "s/$ORIGINAL_PHOTOS/$NEW_PHOTOS/g"
    echo "$files" | xargs sed -i "s/$ORIGINAL_PHOTOS_SPACES/$NEW_PHOTOS_SPACES/g"
    echo "$files" | xargs sed -i "s/$ORIGINAL_GDRIVE_PHOTOS/$NEW_GDRIVE_PHOTOS/g"
    echo "$files" | xargs sed -i "s/$ORIGINAL_MESSAGE/$NEW_MESSAGE/g"
}

# Handle special cases that need manual attention
handle_special_cases() {
    log "Handling special cases..."
    
    # Update README disclaimer
    if [ -f "README.md" ]; then
        # Add anonymization notice to README
        sed -i '1i\> **⚠️ Privacy Notice**: This repository contains example configurations with anonymized data for educational purposes. All usernames, IP addresses, UUIDs, and personal information have been replaced with generic examples. Replace these with your actual values when implementing.\n' README.md
    fi
    
    # Update any remaining personal references in comments
    find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" \) \
        -not -path "./.git/*" \
        -not -path "./original_backup*" \
        -exec sed -i 's/my home/home environment/g' {} \;
    
    find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" \) \
        -not -path "./.git/*" \
        -not -path "./original_backup*" \
        -exec sed -i 's/my Pi 5/the Pi 5/g' {} \;
    
    find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" \) \
        -not -path "./.git/*" \
        -not -path "./original_backup*" \
        -exec sed -i 's/my setup/this setup/g' {} \;
}

# Verification function
verify_anonymization() {
    log "Verifying anonymization..."
    
    local issues=0
    
    # Check for remaining personal information
    local files=$(find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.env*" \) \
        -not -path "./.git/*" \
        -not -path "./original_backup*")
    
    # Check for original username
    if echo "$files" | xargs grep -l "$ORIGINAL_USER" 2>/dev/null; then
        error "Original username '$ORIGINAL_USER' still found in files"
        issues=$((issues + 1))
    fi
    
    # Check for original network
    if echo "$files" | xargs grep -l "$ORIGINAL_NETWORK\." 2>/dev/null; then
        error "Original network '$ORIGINAL_NETWORK' still found in files"
        issues=$((issues + 1))
    fi
    
    # Check for original UUIDs
    for original_uuid in "${!UUID_MAP[@]}"; do
        if echo "$files" | xargs grep -l "$original_uuid" 2>/dev/null; then
            error "Original UUID '$original_uuid' still found in files"
            issues=$((issues + 1))
        fi
    done
    
    # Check for family references
    if echo "$files" | xargs grep -il "family.*photo" 2>/dev/null | grep -v "photo collection"; then
        warning "Possible family references still found - please review manually"
    fi
    
    if [ $issues -eq 0 ]; then
        success "Anonymization verification passed"
        return 0
    else
        error "Anonymization verification failed with $issues issues"
        return 1
    fi
}

# Generate summary report
generate_report() {
    log "Generating anonymization report..."
    
    cat > ANONYMIZATION_REPORT.md << EOF
# Anonymization Report

**Date**: $(date)
**Backup Location**: $BACKUP_DIR

## Changes Made

### Personal Information
- Username: \`$ORIGINAL_USER\` → \`$NEW_USER\`
- Hostname: \`$ORIGINAL_HOSTNAME\` → \`$NEW_HOSTNAME\`
- Timezone: \`$ORIGINAL_TIMEZONE\` → \`$NEW_TIMEZONE\`
- Network: \`$ORIGINAL_NETWORK.x\` → \`$NEW_NETWORK.x\`
- IP Address: \`$ORIGINAL_IP\` → \`$NEW_IP\`

### Storage UUIDs
EOF

    for original_uuid in "${!UUID_MAP[@]}"; do
        new_uuid="${UUID_MAP[$original_uuid]}"
        echo "- \`$original_uuid\` → \`$new_uuid\`" >> ANONYMIZATION_REPORT.md
    done
    
    cat >> ANONYMIZATION_REPORT.md << EOF

### Folder Names
- \`$ORIGINAL_PHOTOS\` → \`$NEW_PHOTOS\`
- \`$ORIGINAL_PHOTOS_SPACES\` → \`$NEW_PHOTOS_SPACES\`

### Google Drive References
- \`$ORIGINAL_GDRIVE_PHOTOS\` → \`$NEW_GDRIVE_PHOTOS\`

## Files Modified
EOF
    
    find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.env*" \) \
        -not -path "./.git/*" \
        -not -path "./original_backup*" \
        -exec echo "- {}" \; >> ANONYMIZATION_REPORT.md
    
    cat >> ANONYMIZATION_REPORT.md << EOF

## Manual Review Required

Please manually review the following:
- Video script content for personal anecdotes
- Any remaining personal references in comments
- Screenshot images that may contain personal information
- Log examples with personal data
- Configuration examples with real credentials

## Restoration

To restore original files:
\`\`\`bash
cp -r $BACKUP_DIR/* ./
\`\`\`
EOF
    
    success "Anonymization report generated: ANONYMIZATION_REPORT.md"
}

# Main execution
main() {
    echo "======================================================"
    echo "   Pi 5 NAS Repository Anonymization Script"
    echo "======================================================"
    echo
    
    warning "This script will modify files in the current directory"
    warning "A backup will be created before making changes"
    echo
    
    read -p "Continue with anonymization? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Anonymization cancelled"
        exit 0
    fi
    
    # Setup replacement variables
    setup_replacements
    
    # Create backup
    create_backup
    
    # Perform anonymization
    perform_replacements
    
    # Handle special cases
    handle_special_cases
    
    # Verify results
    if verify_anonymization; then
        generate_report
        echo
        success "Anonymization completed successfully!"
        success "Original files backed up to: $BACKUP_DIR"
        success "Review ANONYMIZATION_REPORT.md for details"
        echo
        warning "Manual review recommended for:"
        warning "- Video scripts and personal anecdotes"
        warning "- Screenshots with personal information"  
        warning "- Any remaining personal references"
    else
        error "Anonymization completed with issues - see errors above"
        exit 1
    fi
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi