import os
import glob

def clean_file(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    out_lines = []
    header_done = False
    
    for i, line in enumerate(lines):
        # Keep the first 7 lines if they are part of the header block
        if not header_done:
            if i < 7 and line.startswith('//'):
                # Specifically drop lines that start with // MARK:
                if 'MARK:' in line or 'Handles' in line or 'Displays' in line or 'ViewModel for' in line or 'Page for' in line or 'Form for' in line or 'Detail page' in line:
                    pass # actually just keep the standard 6 lines
                else:
                    out_lines.append(line)
                    continue
            elif i >= 6 or not line.startswith('//'):
                header_done = True
        
        # After header, drop any line that is purely a comment
        stripped = line.strip()
        if stripped.startswith('//'):
            continue
            
        out_lines.append(line)
        
    with open(filepath, 'w') as f:
        f.writelines(out_lines)

# Process all swift files in the project
swift_files = glob.glob('LabWeek10/**/*.swift', recursive=True)
for sf in swift_files:
    clean_file(sf)

print(f"Processed {len(swift_files)} files.")
