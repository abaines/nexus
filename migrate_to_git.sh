#!/bin/bash
# Migrate all Nexus files to version control with history

# Get all .ds-hero files sorted by modification date (oldest first)
while IFS= read -r line; do
    # Extract filename from ls output (last column)
    filename=$(echo "$line" | awk '{for(i=9;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":""); print ""}')
    
    # Get modification date for git commit
    mod_date=$(stat -c '%y' "$filename" | cut -d'.' -f1)
    
    echo "Processing: $filename (Date: $mod_date)"
    
    # Copy file to Nexus.ds-hero
    cp "$filename" "Nexus.ds-hero"
    
    # Stage the file
    git add Nexus.ds-hero
    
    # Commit with original date preserved
    git commit --date="$mod_date" -m "Version: $filename" -m "Original date: $mod_date"
    
    echo "Committed: $filename"
    echo "---"
    
done < <(ls -lt --time-style=long-iso *.ds-hero | tac)

echo "Migration complete! All 46 versions are now in git history."
echo "Try: git log --oneline Nexus.ds-hero"
