#!/usr/bin/env python3
"""
Script to add EU, EFTA, and EEA membership fields to countries.json
Creates an amended version while preserving the original file
"""

import json
import shutil
import os

# EU member countries (27 members as of 2023)
EU_MEMBERS = {
    'AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA',
    'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD',
    'POL', 'PRT', 'ROU', 'SVK', 'SVN', 'ESP', 'SWE'
}

# EFTA member countries (4 members)
EFTA_MEMBERS = {
    'ISL', 'LIE', 'NOR', 'CHE'
}

# EEA member countries (EU + EFTA except Switzerland)
EEA_MEMBERS = EU_MEMBERS | {'ISL', 'LIE', 'NOR'}

def add_membership_fields(input_file='data/countries.json', output_file='data/countries_amended.json'):
    """Add euMember, eftaMember, and eeaMember fields to countries.json"""
    
    # Create backup of original if it doesn't exist
    if not os.path.exists('data/countries_original.json') and os.path.exists('data/countries.json'):
        shutil.copy2('data/countries.json', 'data/countries_original.json')
        print("Created backup: data/countries_original.json")
    
    # Read the existing JSON file
    with open(input_file, 'r', encoding='utf-8') as f:
        countries = json.load(f)
    
    # Add the new membership fields to each country
    for country in countries:
        cca3 = country.get('cca3', '')
        
        # Add EU membership
        country['euMember'] = cca3 in EU_MEMBERS
        
        # Add EFTA membership (note: using eftaMember to match SQL schema)
        country['eftaMember'] = cca3 in EFTA_MEMBERS
        
        # Add EEA membership
        country['eeaMember'] = cca3 in EEA_MEMBERS
    
    # Write the updated JSON to output file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(countries, f, indent=4, ensure_ascii=False)
    
    print(f"Successfully added euMember, eftaMember, and eeaMember fields to {output_file}")
    
    # Print some statistics
    eu_count = sum(1 for c in countries if c['euMember'])
    efta_count = sum(1 for c in countries if c['eftaMember'])
    eea_count = sum(1 for c in countries if c['eeaMember'])
    
    print(f"EU members: {eu_count}")
    print(f"EFTA members: {efta_count}")
    print(f"EEA members: {eea_count}")
    
    return output_file

if __name__ == "__main__":
    # Create amended version while preserving original
    amended_file = add_membership_fields()
    print(f"\nAmended file created: {amended_file}")
    print("Original file preserved as: data/countries.json")
    print("Backup created as: data/countries_original.json")
