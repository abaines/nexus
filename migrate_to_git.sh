#!/bin/bash
# Migrate all Nexus files to version control with history

# Set max files to process (use argument or default to all)
# Usage: ./migrate_to_git.sh [number_of_files]
# Example: ./migrate_to_git.sh 3  (test with 3 files)
#          ./migrate_to_git.sh     (process all files)
MAX_FILES=${1:-999}

# Create backup directory for original files
mkdir -p .backup_originals

count=0

# Get all .ds-hero files sorted by modification date (oldest first), excluding Nexus.ds-hero
while IFS= read -r filename; do
    # Stop if we've reached the max
    if [[ $count -ge $MAX_FILES ]]; then
        echo "Reached limit of $MAX_FILES files. Stopping."
        break
    fi
    
    # Skip if this is already Nexus.ds-hero
    if [[ "$filename" == "Nexus.ds-hero" ]]; then
        continue
    fi
    
    # Get modification date for git commit
    mod_date=$(stat -c '%y' "$filename" | cut -d'.' -f1)
    
    echo "Processing: $filename (Date: $mod_date)"
    
    # Copy file to Nexus.ds-hero
    cp "$filename" "Nexus.ds-hero"
    
    # Stage the file
    git add Nexus.ds-hero
    
    # Commit with original date preserved
    git commit --date="$mod_date" -m "Version: $filename" -m "Original date: $mod_date"
    
    # Move original file to backup
    mv "$filename" ".backup_originals/"
    
    echo "✓ Committed: $filename (moved to .backup_originals/)"
    echo "---"
    
    ((count++))
    
done < <(ls -1t *.ds-hero 2>/dev/null | tac)

echo ""
echo "Migration complete! Processed $count files."
echo "Try: git log --oneline Nexus.ds-hero"
