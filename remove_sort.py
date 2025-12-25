#!/usr/bin/env python3
"""Remove all sorting logic from scraper.py"""

import re

# Read file
with open('modules/scraper.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find and remove SORT_OPTIONS dict (lines ~40-71)
# Find and remove SORT_BTN and MENU_ITEMS (lines ~37-38)
# Find and remove set_sort method and check_if_menu_opened method

new_lines = []
skip_until = None
in_sort_options = False
in_set_sort_method = False
in_check_menu_method = False
brace_count = 0

for i, line in enumerate(lines, 1):
    # Remove SORT_BTN and MENU_ITEMS lines
    if 'SORT_BTN =' in line or 'MENU_ITEMS =' in line:
        print(f"Removing line {i}: {line.strip()}")
        continue
    
    # Detect start of SORT_OPTIONS
    if 'SORT_OPTIONS = {' in line:
        in_sort_options = True
        print(f"Start removing SORT_OPTIONS at line {i}")
        continue
    
    # Skip lines inside SORT_OPTIONS until closing brace
    if in_sort_options:
        if line.strip() == '}':
            in_sort_options = False
            print(f"End removing SORT_OPTIONS at line {i}")
            # Skip the empty line after closing brace
            continue
        continue
    
    # Detect start of set_sort method
    if 'def set_sort(self, driver: Chrome, method: str):' in line:
        in_set_sort_method = True
        brace_count = 0
        print(f"Start removing set_sort method at line {i}")
        continue
    
    # Detect start of check_if_menu_opened method
    if 'def check_if_menu_opened(self, driver):' in line:
        in_check_menu_method = True
        brace_count = 0
        print(f"Start removing check_if_menu_opened method at line {i}")
        continue
    
    # Skip lines inside methods - count indentation to find end
    if in_set_sort_method or in_check_menu_method:
        # Check if we've reached the next method (def keyword at class level)
        if line.strip().startswith('def ') and not line.startswith('        '):
            # Found next method - stop skipping
            in_set_sort_method = False
            in_check_menu_method = False
            print(f"End removing method at line {i} (found next method)")
            # Don't skip this line, it's the start of next method
        else:
            continue
    
    new_lines.append(line)

# Write back
with open('modules/scraper.py', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"\nOriginal lines: {len(lines)}")
print(f"New lines: {len(new_lines)}")
print(f"Removed: {len(lines) - len(new_lines)} lines")
