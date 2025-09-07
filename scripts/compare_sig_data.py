#!/usr/bin/env python3
"""
Compare well-known UUIDs with the converted SIG database to show the improvements.
"""

import json
from pathlib import Path

def main():
    project_dir = Path(__file__).parent.parent
    converted_dir = project_dir / 'converted_sig_data'

    # Load converted data
    with open(converted_dir / 'sig_services.json', 'r') as f:
        services = json.load(f)

    with open(converted_dir / 'sig_characteristics.json', 'r') as f:
        characteristics = json.load(f)

    with open(converted_dir / 'sig_descriptors.json', 'r') as f:
        descriptors = json.load(f)

    with open(converted_dir / 'sig_company_identifiers.json', 'r') as f:
        companies = json.load(f)

    # Well-known service UUIDs from the Flutter service
    well_known_services = {
        '1800', '1801', '1802', '1803', '1804', '1805', '1806', '1807',
        '1808', '1809', '180a', '180d', '180e', '180f', '1810', '1811',
        '1812', '1813', '1814', '1815', '1816', '1818', '1819', '181a',
        '181b', '181c', '181d', '181e', '181f', '1820', '1821', '1822',
        '1823', '1824', '1825', '1826', '1827', '1828', '1829'
    }

    # Well-known characteristic UUIDs from the Flutter service
    well_known_characteristics = {
        '2a00', '2a01', '2a02', '2a03', '2a04', '2a05', '2a06', '2a07',
        '2a08', '2a09', '2a0a', '2a0c', '2a0d', '2a0e', '2a0f', '2a11',
        '2a12', '2a13', '2a14', '2a16', '2a17', '2a18', '2a19', '2a1c',
        '2a1d', '2a1e', '2a21', '2a22', '2a23', '2a24', '2a25', '2a26',
        '2a27', '2a28', '2a29', '2a2a', '2a2b', '2a31', '2a32', '2a33',
        '2a34', '2a35', '2a36', '2a37', '2a38', '2a39', '2a3a', '2a3b',
        '2a3c', '2a3d', '2a3e', '2a3f', '2a40', '2a41', '2a42', '2a43',
        '2a44', '2a45', '2a46', '2a47', '2a48', '2a49', '2a4a', '2a4b',
        '2a4c', '2a4d', '2a4e', '2a4f', '2a50', '2a51', '2a52', '2a53',
        '2a54', '2a55'
    }

    print("🔍 SIG Database Comparison")
    print("=" * 50)
    print()

    print("📊 **SERVICES**")
    print(f"   Well-known: {len(well_known_services)}")
    print(f"   Extended:   {len(services)}")
    print(f"   Improvement: +{len(services) - len(well_known_services)} services ({((len(services) / len(well_known_services)) - 1) * 100:.1f}% increase)")
    print()

    print("📊 **CHARACTERISTICS**")
    print(f"   Well-known: {len(well_known_characteristics)}")
    print(f"   Extended:   {len(characteristics)}")
    print(f"   Improvement: +{len(characteristics) - len(well_known_characteristics)} characteristics ({((len(characteristics) / len(well_known_characteristics)) - 1) * 100:.1f}% increase)")
    print()

    print("📊 **DESCRIPTORS**")
    print(f"   Well-known: 0")
    print(f"   Extended:   {len(descriptors)}")
    print(f"   Improvement: +{len(descriptors)} descriptors (new capability)")
    print()

    print("📊 **COMPANY IDENTIFIERS**")
    print(f"   Well-known: 0")
    print(f"   Extended:   {len(companies)}")
    print(f"   Improvement: +{len(companies)} company identifiers (new capability)")
    print()

    # Show some examples of new services
    new_services = {k: v for k, v in services.items() if k not in well_known_services}
    print("🆕 **EXAMPLES OF NEW SERVICES:**")
    for i, (uuid, name) in enumerate(list(new_services.items())[:5]):
        print(f"   0x{uuid.upper()}: {name}")
    print(f"   ... and {len(new_services) - 5} more")
    print()

    # Show some examples of new characteristics
    new_characteristics = {k: v for k, v in characteristics.items() if k not in well_known_characteristics}
    print("🆕 **EXAMPLES OF NEW CHARACTERISTICS:**")
    for i, (uuid, name) in enumerate(list(new_characteristics.items())[:5]):
        print(f"   0x{uuid.upper()}: {name}")
    print(f"   ... and {len(new_characteristics) - 5} more")
    print()

    # Show some company examples
    print("🏢 **EXAMPLES OF COMPANY IDENTIFIERS:**")
    for i, (id, name) in enumerate(list(companies.items())[:5]):
        print(f"   0x{id.upper()}: {name}")
    print(f"   ... and {len(companies) - 5} more")
    print()

    print("✨ **SUMMARY**")
    print("=" * 30)
    print("The extended SIG database provides significantly more")
    print("comprehensive Bluetooth UUID resolution, enabling your")
    print("app to display meaningful names for:")
    print("• Latest Bluetooth services and characteristics")
    print("• Device manufacturer information")
    print("• Descriptor details for better UX")
    print("• Future Bluetooth specifications")

if __name__ == '__main__':
    main()
