#!/usr/bin/env python3
"""
Copy converted SIG database files to the app's data directory.

This script copies the converted JSON files to the location where
the Flutter app expects to find them.
"""

import json
import shutil
import os
from pathlib import Path

def main():
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent

    # Source directory with converted files
    source_dir = project_dir / 'converted_sig_data'

    # For development/testing, we'll create a local copy in the test assets
    test_assets_dir = project_dir / 'test' / 'assets' / 'sig_data'
    test_assets_dir.mkdir(parents=True, exist_ok=True)

    # Copy files
    files_to_copy = [
        'sig_services.json',
        'sig_characteristics.json',
        'sig_descriptors.json',
        'sig_company_identifiers.json'
    ]

    print("📁 Copying SIG database files...")
    print(f"Source: {source_dir}")
    print(f"Test destination: {test_assets_dir}")
    print("")

    for filename in files_to_copy:
        source_file = source_dir / filename
        dest_file = test_assets_dir / filename

        if source_file.exists():
            shutil.copy2(source_file, dest_file)
            print(f"✅ Copied {filename}")

            # Show some stats
            with open(source_file, 'r') as f:
                data = json.load(f)
                print(f"   📊 Contains {len(data)} entries")
        else:
            print(f"❌ Missing {filename}")

    print("")
    print("📋 Next Steps:")
    print("=============")
    print("1. Run the app on a device/emulator")
    print("2. Use sigService.getDatabasePath() to find the actual app data directory")
    print("3. Copy these files to that directory:")
    for filename in files_to_copy:
        print(f"   - {filename}")
    print("4. Call sigService.refreshDatabases() to load the extended data")
    print("")
    print("💡 Tip: You can add this as a development feature in your app")
    print("   to automatically copy files from assets to the data directory.")

if __name__ == '__main__':
    main()
