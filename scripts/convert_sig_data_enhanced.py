#!/usr/bin/env python3
"""
Enhanced SIG data converter - converts all useful Bluetooth SIG YAML files to JSON.

This script converts multiple types of YAML files from the Bluetooth SIG repository
into JSON format for use with the Flutter SIG service.
"""

import json
import yaml
import os
from pathlib import Path

def load_yaml_file(filepath):
    """Load and parse a YAML file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Warning: Could not load {filepath}: {e}")
        return None

def convert_uuids_to_json(yaml_data):
    """Convert UUID list from YAML to JSON dict format."""
    result = {}
    if yaml_data and 'uuids' in yaml_data:
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

    if not yaml_data:
        return result

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

def convert_appearance_values_to_json(yaml_data):
    """Convert appearance values from YAML to JSON dict format."""
    result = {}

    if not yaml_data or 'appearance_values' not in yaml_data:
        return result

    for item in yaml_data['appearance_values']:
        category = item.get('category', '')
        name = item.get('name', '')

        # Handle category value
        if isinstance(category, int):
            cat_key = f"{category:04x}"
        elif isinstance(category, str):
            cat_key = category.replace('0x', '').lower()
        else:
            continue

        if cat_key and name:
            result[cat_key] = name

        # Handle subcategories
        if 'subcategory' in item:
            for subitem in item['subcategory']:
                sub_value = subitem.get('value', '')
                sub_name = subitem.get('name', '')

                if isinstance(sub_value, int):
                    sub_key = f"{category:04x}{sub_value:02x}"
                elif isinstance(sub_value, str):
                    sub_val_int = int(sub_value.replace('0x', ''), 16)
                    sub_key = f"{category:04x}{sub_val_int:02x}"
                else:
                    continue

                if sub_key and sub_name:
                    result[sub_key] = f"{name} - {sub_name}"

    return result

def convert_ad_types_to_json(yaml_data):
    """Convert AD (Advertisement Data) types from YAML to JSON dict format."""
    result = {}

    if not yaml_data or 'ad_types' not in yaml_data:
        return result

    for item in yaml_data['ad_types']:
        value = item.get('value', '')
        name = item.get('name', '')

        # Handle value
        if isinstance(value, int):
            key = f"{value:02x}"
        elif isinstance(value, str):
            key = value.replace('0x', '').lower()
        else:
            continue

        if key and name:
            result[key] = name

    return result

def convert_simple_list_to_json(yaml_data, list_key):
    """Convert a simple list with value/name pairs to JSON dict format."""
    result = {}

    if not yaml_data or list_key not in yaml_data:
        return result

    for item in yaml_data[list_key]:
        if isinstance(item, dict):
            value = item.get('value', item.get('id', ''))
            name = item.get('name', '')

            # Handle value formatting
            if isinstance(value, int):
                key = f"{value:04x}"
            elif isinstance(value, str):
                key = value.replace('0x', '').lower()
            else:
                continue

            if key and name:
                result[key] = name

    return result

def main():
    # Define paths
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent
    sig_dir = project_dir / 'SIG'

    # Output directory (create if doesn't exist)
    output_dir = project_dir / 'converted_sig_data'
    output_dir.mkdir(exist_ok=True)

    print("🔄 Converting SIG database files...")
    print("=" * 50)

    # Convert core UUID files
    print("\n📋 Core UUIDs:")

    # Services
    services_yaml = sig_dir / 'uuids' / 'service_uuids.yaml'
    services_data = load_yaml_file(services_yaml)
    services_json = convert_uuids_to_json(services_data)
    with open(output_dir / 'sig_services.json', 'w', encoding='utf-8') as f:
        json.dump(services_json, f, indent=2, ensure_ascii=False)
    print(f"  ✅ Services: {len(services_json)} entries")

    # Characteristics
    characteristics_yaml = sig_dir / 'uuids' / 'characteristic_uuids.yaml'
    characteristics_data = load_yaml_file(characteristics_yaml)
    characteristics_json = convert_uuids_to_json(characteristics_data)
    with open(output_dir / 'sig_characteristics.json', 'w', encoding='utf-8') as f:
        json.dump(characteristics_json, f, indent=2, ensure_ascii=False)
    print(f"  ✅ Characteristics: {len(characteristics_json)} entries")

    # Descriptors
    descriptors_yaml = sig_dir / 'uuids' / 'descriptors.yaml'
    descriptors_data = load_yaml_file(descriptors_yaml)
    descriptors_json = convert_uuids_to_json(descriptors_data)
    with open(output_dir / 'sig_descriptors.json', 'w', encoding='utf-8') as f:
        json.dump(descriptors_json, f, indent=2, ensure_ascii=False)
    print(f"  ✅ Descriptors: {len(descriptors_json)} entries")

    # Member UUIDs (additional services/companies)
    member_yaml = sig_dir / 'uuids' / 'member_uuids.yaml'
    member_data = load_yaml_file(member_yaml)
    member_json = convert_uuids_to_json(member_data)
    with open(output_dir / 'sig_member_uuids.json', 'w', encoding='utf-8') as f:
        json.dump(member_json, f, indent=2, ensure_ascii=False)
    print(f"  ✅ Member UUIDs: {len(member_json)} entries")

    # Company identifiers
    print("\n🏢 Company Data:")
    company_yaml = sig_dir / 'company_identifiers' / 'company_identifiers.yaml'
    company_data = load_yaml_file(company_yaml)
    company_json = convert_company_identifiers_to_json(company_data)
    with open(output_dir / 'sig_company_identifiers.json', 'w', encoding='utf-8') as f:
        json.dump(company_json, f, indent=2, ensure_ascii=False)
    print(f"  ✅ Company Identifiers: {len(company_json)} entries")

    # Core data types
    print("\n⚙️  Core Data Types:")

    # Appearance values
    appearance_yaml = sig_dir / 'core' / 'appearance_values.yaml'
    appearance_data = load_yaml_file(appearance_yaml)
    appearance_json = convert_appearance_values_to_json(appearance_data)
    with open(output_dir / 'sig_appearance_values.json', 'w', encoding='utf-8') as f:
        json.dump(appearance_json, f, indent=2, ensure_ascii=False)
    print(f"  ✅ Appearance Values: {len(appearance_json)} entries")

    # Advertisement Data types
    ad_types_yaml = sig_dir / 'core' / 'ad_types.yaml'
    ad_types_data = load_yaml_file(ad_types_yaml)
    ad_types_json = convert_ad_types_to_json(ad_types_data)
    with open(output_dir / 'sig_ad_types.json', 'w', encoding='utf-8') as f:
        json.dump(ad_types_json, f, indent=2, ensure_ascii=False)
    print(f"  ✅ AD Types: {len(ad_types_json)} entries")

    # Additional useful core files
    core_files = [
        ('diacs.yaml', 'sig_diacs.json', 'diacs'),
        ('formattypes.yaml', 'sig_format_types.json', 'formattypes'),
        ('namespace.yaml', 'sig_namespaces.json', 'namespaces'),
        ('psm.yaml', 'sig_psm.json', 'psm'),
        ('uri_schemes.yaml', 'sig_uri_schemes.json', 'uri_schemes'),
        ('coding_format.yaml', 'sig_coding_formats.json', 'coding_formats'),
        ('class_of_device.yaml', 'sig_class_of_device.json', 'cod_services'),
    ]

    for yaml_file, json_file, list_key in core_files:
        yaml_path = sig_dir / 'core' / yaml_file
        if yaml_path.exists():
            data = load_yaml_file(yaml_path)
            if data and list_key in data:
                result = convert_simple_list_to_json(data, list_key)
                if result:
                    with open(output_dir / json_file, 'w', encoding='utf-8') as f:
                        json.dump(result, f, indent=2, ensure_ascii=False)
                    print(f"  ✅ {yaml_file}: {len(result)} entries")

    # Mesh data types
    print("\n🔗 Bluetooth Mesh Data:")
    mesh_files = [
        ('mesh_model_uuids.yaml', 'sig_mesh_models.json', 'mesh_model_uuids'),
        ('mesh_opcodes.yaml', 'sig_mesh_opcodes.json', 'mesh_opcodes'),
        ('mesh_beacon_types.yaml', 'sig_mesh_beacons.json', 'mesh_beacon_types'),
    ]

    for yaml_file, json_file, list_key in mesh_files:
        yaml_path = sig_dir / 'mesh' / yaml_file
        if yaml_path.exists():
            data = load_yaml_file(yaml_path)
            if data and list_key in data:
                result = convert_simple_list_to_json(data, list_key)
                if result:
                    with open(output_dir / json_file, 'w', encoding='utf-8') as f:
                        json.dump(result, f, indent=2, ensure_ascii=False)
                    print(f"  ✅ {yaml_file}: {len(result)} entries")

    print("\n" + "=" * 50)
    print(f"✨ Conversion complete! Files saved to: {output_dir}")

    # Summary
    total_files = len(list(output_dir.glob('*.json')))
    print(f"\n📊 Summary: {total_files} JSON files created")

    print("\n📋 Next steps:")
    print("1. Review the generated JSON files")
    print("2. Update the SIG service to use additional data types")
    print("3. Test with the enhanced database")
    print("4. Deploy to the app's data directory")

if __name__ == '__main__':
    main()
