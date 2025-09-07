#!/usr/bin/env python3
"""
Comprehensive SIG data converter - converts ALL useful Bluetooth SIG YAML files to JSON.

This script converts all valuable types of YAML files from the Bluetooth SIG repository
into JSON format for use with the Flutter SIG service, maximizing data utilization.
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
                    sub_key = f"{sub_value:04x}"
                elif isinstance(sub_value, str):
                    sub_key = sub_value.replace('0x', '').lower()
                else:
                    continue

                if sub_key and sub_name:
                    result[sub_key] = f"{name} - {sub_name}"
    return result

def convert_generic_value_name_list(yaml_data, list_key):
    """Convert generic value/name list from YAML to JSON dict format."""
    result = {}

    if not yaml_data or list_key not in yaml_data:
        return result

    for item in yaml_data[list_key]:
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

def convert_mesh_model_uuids_to_json(yaml_data):
    """Convert mesh model UUIDs from YAML to JSON dict format."""
    result = {}

    if not yaml_data or 'mesh_model_uuids' not in yaml_data:
        return result

    for item in yaml_data['mesh_model_uuids']:
        uuid_raw = item.get('uuid', '')
        name = item.get('name', '')
        model_type = item.get('type', '')

        # Handle both string and integer UUIDs
        if isinstance(uuid_raw, int):
            uuid = f"{uuid_raw:04x}"
        elif isinstance(uuid_raw, str):
            uuid = uuid_raw.replace('0x', '').lower()
        else:
            continue

        if uuid and name:
            # Include type in the name for context
            if model_type:
                result[uuid] = f"{name} ({model_type})"
            else:
                result[uuid] = name

    return result

def convert_cod_services_to_json(yaml_data):
    """Convert Class of Device services from YAML to JSON dict format."""
    result = {}

    if not yaml_data or 'cod_services' not in yaml_data:
        return result

    for item in yaml_data['cod_services']:
        bit = item.get('bit', '')
        name = item.get('name', '')

        if bit and name:
            result[str(bit)] = name

    return result

def main():
    # Define source and target directories
    sig_dir = Path('SIG')
    target_dir = Path('converted_sig_data')

    # Create target directory if it doesn't exist
    target_dir.mkdir(exist_ok=True)

    # Original essential files
    files_to_convert = [
        {
            'source': sig_dir / 'uuids' / 'service_uuids.yaml',
            'target': target_dir / 'sig_services.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'characteristic_uuids.yaml',
            'target': target_dir / 'sig_characteristics.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'descriptors.yaml',
            'target': target_dir / 'sig_descriptors.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'company_identifiers' / 'company_identifiers.yaml',
            'target': target_dir / 'sig_company_identifiers.json',
            'converter': convert_company_identifiers_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'member_uuids.yaml',
            'target': target_dir / 'sig_member_uuids.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'core' / 'appearance_values.yaml',
            'target': target_dir / 'sig_appearance_values.json',
            'converter': convert_appearance_values_to_json
        },
        {
            'source': sig_dir / 'core' / 'ad_types.yaml',
            'target': target_dir / 'sig_ad_types.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'ad_types')
        },
        {
            'source': sig_dir / 'core' / 'coding_format.yaml',
            'target': target_dir / 'sig_coding_formats.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'coding_formats')
        },
        {
            'source': sig_dir / 'mesh' / 'mesh_beacon_types.yaml',
            'target': target_dir / 'sig_mesh_beacons.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'mesh_beacon_types')
        },
        {
            'source': sig_dir / 'core' / 'uri_schemes.yaml',
            'target': target_dir / 'sig_uri_schemes.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'uri_schemes')
        },
        {
            'source': sig_dir / 'core' / 'diacs.yaml',
            'target': target_dir / 'sig_diacs.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'diacs')
        }
    ]

    # NEW COMPREHENSIVE FILES - Additional valuable data types
    additional_files = [
        # Core protocol and format files
        {
            'source': sig_dir / 'core' / 'class_of_device.yaml',
            'target': target_dir / 'sig_class_of_device.json',
            'converter': convert_cod_services_to_json
        },
        {
            'source': sig_dir / 'core' / 'pcm_data_format.yaml',
            'target': target_dir / 'sig_pcm_formats.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'pcm_data_formats')
        },
        {
            'source': sig_dir / 'core' / 'formattypes.yaml',
            'target': target_dir / 'sig_format_types.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'format_types')
        },
        {
            'source': sig_dir / 'core' / 'transport_layers.yaml',
            'target': target_dir / 'sig_transport_layers.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'transport_layers')
        },

        # UUID and protocol files
        {
            'source': sig_dir / 'uuids' / 'protocol_identifiers.yaml',
            'target': target_dir / 'sig_protocol_identifiers.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'units.yaml',
            'target': target_dir / 'sig_units.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'declarations.yaml',
            'target': target_dir / 'sig_declarations.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'object_types.yaml',
            'target': target_dir / 'sig_object_types.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'browse_group_identifiers.yaml',
            'target': target_dir / 'sig_browse_groups.json',
            'converter': convert_uuids_to_json
        },
        {
            'source': sig_dir / 'uuids' / 'service_class.yaml',
            'target': target_dir / 'sig_service_classes.json',
            'converter': convert_uuids_to_json
        },

        # Mesh networking files
        {
            'source': sig_dir / 'mesh' / 'mesh_model_uuids.yaml',
            'target': target_dir / 'sig_mesh_models.json',
            'converter': convert_mesh_model_uuids_to_json
        },
        {
            'source': sig_dir / 'mesh' / 'mesh_opcodes.yaml',
            'target': target_dir / 'sig_mesh_opcodes.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'mesh_opcodes')
        },
        {
            'source': sig_dir / 'mesh' / 'mesh_health_faults.yaml',
            'target': target_dir / 'sig_mesh_health_faults.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'mesh_health_faults')
        },
        {
            'source': sig_dir / 'uuids' / 'mesh_profile_uuids.yaml',
            'target': target_dir / 'sig_mesh_profile_uuids.json',
            'converter': convert_uuids_to_json
        },

        # Service discovery files
        {
            'source': sig_dir / 'service_discovery' / 'protocol_parameters.yaml',
            'target': target_dir / 'sig_protocol_parameters.json',
            'converter': lambda d: convert_generic_value_name_list(d, 'protocol_parameters')
        }
    ]

    # Combine all files
    all_files = files_to_convert + additional_files

    print(f"🔄 Converting {len(all_files)} SIG data files to JSON...")
    print(f"📁 Source: {sig_dir}")
    print(f"📁 Target: {target_dir}")
    print()

    converted_count = 0
    skipped_count = 0

    for file_config in all_files:
        source_path = file_config['source']
        target_path = file_config['target']
        converter_func = file_config['converter']

        if not source_path.exists():
            print(f"⚠️  Skipping {source_path.name} (file not found)")
            skipped_count += 1
            continue

        print(f"📝 Converting {source_path.name}...")

        # Load YAML data
        yaml_data = load_yaml_file(source_path)
        if yaml_data is None:
            print(f"❌ Failed to load {source_path.name}")
            skipped_count += 1
            continue

        # Convert to JSON format
        try:
            json_data = converter_func(yaml_data)

            # Write JSON file
            with open(target_path, 'w', encoding='utf-8') as f:
                json.dump(json_data, f, indent=2, ensure_ascii=False)

            entry_count = len(json_data)
            print(f"✅ {target_path.name}: {entry_count} entries")
            converted_count += 1

        except Exception as e:
            print(f"❌ Error converting {source_path.name}: {e}")
            skipped_count += 1

    print()
    print("📊 Conversion Summary:")
    print(f"✅ Successfully converted: {converted_count} files")
    if skipped_count > 0:
        print(f"⚠️  Skipped: {skipped_count} files")
    print()
    print(f"🎯 JSON files created in: {target_dir.absolute()}")
    print()
    print("📋 Next steps:")
    print("1. Copy these JSON files to your Flutter app's assets or database directory")
    print("2. Update your SIG service to load the additional database types")
    print("3. Add getter methods for the new data types")

if __name__ == '__main__':
    main()
