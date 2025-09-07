#!/usr/bin/env python3
"""
Convert Bluetooth SIG YAML files to JSON format for the SIG service.

This script converts the YAML files from the Bluetooth SIG repository into
the JSON format expected by the Flutter SIG service.
"""

import json
import yaml
import os
from pathlib import Path

def load_yaml_file(filepath):
    """Load and parse a YAML file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

def convert_uuids_to_json(yaml_data):
    """Convert UUID list from YAML to JSON dict format."""
    result = {}
    if 'uuids' in yaml_data:
        for item in yaml_data['uuids']:
            uuid_raw = item.get('uuid', '')
            name = item.get('name', '')

            # Handle both string and integer UUIDs
            if isinstance(uuid_raw, int):
                uuid = f"{uuid_raw:04x}"
            elif isinstance(uuid_raw, str):
                uuid = uuid_raw.replace('0x', '').lower()
            else:
                continue

            if uuid and name:
                result[uuid] = name
    return result

def convert_company_identifiers_to_json(yaml_data):
    """Convert company identifiers from YAML to JSON dict format."""
    result = {}

    # Handle nested structure with company_identifiers key
    company_list = yaml_data
    if 'company_identifiers' in yaml_data:
        company_list = yaml_data['company_identifiers']

    if isinstance(company_list, list):
        for item in company_list:
            if isinstance(item, dict):
                value_raw = item.get('value', '')
                name = item.get('name', '')

                # Handle both string and integer values
                if isinstance(value_raw, int):
                    value = f"{value_raw:04x}"
                elif isinstance(value_raw, str):
                    value = value_raw.replace('0x', '').lower()
                else:
                    continue

                if value and name:
                    result[value] = name
    return result

def main():
    # Define paths
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent
    sig_dir = project_dir / 'SIG'

    # Input files
    services_yaml = sig_dir / 'uuids' / 'service_uuids.yaml'
    characteristics_yaml = sig_dir / 'uuids' / 'characteristic_uuids.yaml'
    descriptors_yaml = sig_dir / 'uuids' / 'descriptors.yaml'
    company_yaml = sig_dir / 'company_identifiers' / 'company_identifiers.yaml'

    # Output directory (create if doesn't exist)
    output_dir = project_dir / 'converted_sig_data'
    output_dir.mkdir(exist_ok=True)

    # Convert services
    print("Converting services...")
    services_data = load_yaml_file(services_yaml)
    services_json = convert_uuids_to_json(services_data)
    with open(output_dir / 'sig_services.json', 'w', encoding='utf-8') as f:
        json.dump(services_json, f, indent=2, ensure_ascii=False)
    print(f"  Converted {len(services_json)} services")

    # Convert characteristics
    print("Converting characteristics...")
    characteristics_data = load_yaml_file(characteristics_yaml)
    characteristics_json = convert_uuids_to_json(characteristics_data)
    with open(output_dir / 'sig_characteristics.json', 'w', encoding='utf-8') as f:
        json.dump(characteristics_json, f, indent=2, ensure_ascii=False)
    print(f"  Converted {len(characteristics_json)} characteristics")

    # Convert descriptors
    print("Converting descriptors...")
    descriptors_data = load_yaml_file(descriptors_yaml)
    descriptors_json = convert_uuids_to_json(descriptors_data)
    with open(output_dir / 'sig_descriptors.json', 'w', encoding='utf-8') as f:
        json.dump(descriptors_json, f, indent=2, ensure_ascii=False)
    print(f"  Converted {len(descriptors_json)} descriptors")

    # Convert company identifiers
    print("Converting company identifiers...")
    company_data = load_yaml_file(company_yaml)
    company_json = convert_company_identifiers_to_json(company_data)
    with open(output_dir / 'sig_company_identifiers.json', 'w', encoding='utf-8') as f:
        json.dump(company_json, f, indent=2, ensure_ascii=False)
    print(f"  Converted {len(company_json)} company identifiers")

    print(f"\nConversion complete! Files saved to: {output_dir}")
    print("\nNext steps:")
    print("1. Test the converted files with the SIG service")
    print("2. Copy them to the app's data directory when ready")
    print("3. Call sigService.refreshDatabases() to load them")

if __name__ == '__main__':
    main()
