const CountriesSQLGenerator = require('./index');

/**
 * Test script to validate the generated SQL
 */
function runTests() {
    console.log('🧪 Running tests for Countries SQL Generator...\n');

    const generator = new CountriesSQLGenerator();
    generator.processCountries();

    // Test 1: Check if all required regions exist
    console.log('✅ Test 1: Verifying regions');
    const expectedRegions = ['Americas', 'Asia', 'Africa', 'Europe', 'Oceania', 'Antarctic'];
    const actualRegions = Array.from(generator.regions.keys());

    expectedRegions.forEach(region => {
        if (!actualRegions.includes(region)) {
            console.error(`❌ Missing region: ${region}`);
        } else {
            console.log(`   ✓ ${region}`);
        }
    });

    // Test 2: Check if all subregions have valid region references
    console.log('\n✅ Test 2: Verifying subregion-region relationships');
    let invalidSubregions = 0;
    Array.from(generator.subregions.values()).forEach(subregion => {
        if (!subregion.regionId) {
            console.error(`❌ Subregion "${subregion.name}" has no region reference`);
            invalidSubregions++;
        }
    });

    if (invalidSubregions === 0) {
        console.log(`   ✓ All ${generator.subregions.size} subregions have valid region references`);
    }

    // Test 3: Check if all countries have required fields
    console.log('\n✅ Test 3: Verifying country data integrity');
    let invalidCountries = 0;
    generator.countries.forEach(country => {
        if (!country.cca2 || !country.cca3 || !country.name) {
            console.error(`❌ Country missing required fields: ${JSON.stringify(country)}`);
            invalidCountries++;
        }
    });

    if (invalidCountries === 0) {
        console.log(`   ✓ All ${generator.countries.length} countries have required fields`);
    }

    // Test 4: Check for SQL injection vulnerabilities
    console.log('\n✅ Test 4: Checking for SQL injection vulnerabilities');
    let vulnerableCountries = 0;
    generator.countries.forEach(country => {
        if (country.name.includes("'") && !country.name.includes("''")) {
            console.error(`❌ Potential SQL injection in country: ${country.name}`);
            vulnerableCountries++;
        }
    });

    if (vulnerableCountries === 0) {
        console.log(`   ✓ No SQL injection vulnerabilities found`);
    }

    // Test 5: Verify data consistency
    console.log('\n✅ Test 5: Verifying data consistency');

    // Check if region/subregion string values match the referenced IDs
    let inconsistentCountries = 0;
    generator.countries.forEach(country => {
        if (country.regionId) {
            const region = Array.from(generator.regions.values()).find(r => r.id === country.regionId);
            if (!region || region.name !== country.region) {
                console.error(`❌ Inconsistent region data for ${country.name}: ${country.region} vs ${region?.name}`);
                inconsistentCountries++;
            }
        }

        if (country.subregionId) {
            const subregion = Array.from(generator.subregions.values()).find(s => s.id === country.subregionId);
            if (!subregion || subregion.name !== country.subregion) {
                console.error(`❌ Inconsistent subregion data for ${country.name}: ${country.subregion} vs ${subregion?.name}`);
                inconsistentCountries++;
            }
        }
    });

    if (inconsistentCountries === 0) {
        console.log(`   ✓ All country region/subregion references are consistent`);
    }

    // Summary
    console.log('\n📊 Test Summary:');
    console.log(`   Regions: ${generator.regions.size}`);
    console.log(`   Subregions: ${generator.subregions.size}`);
    console.log(`   Countries: ${generator.countries.length}`);
    console.log(`   Invalid countries: ${invalidCountries}`);
    console.log(`   Invalid subregions: ${invalidSubregions}`);
    console.log(`   Vulnerable countries: ${vulnerableCountries}`);
    console.log(`   Inconsistent countries: ${inconsistentCountries}`);

    const totalErrors = invalidCountries + invalidSubregions + vulnerableCountries + inconsistentCountries;

    if (totalErrors === 0) {
        console.log('\n🎉 All tests passed! The generated SQL should be safe to use.');
    } else {
        console.log(`\n❌ ${totalErrors} errors found. Please review the output above.`);
    }

    return totalErrors === 0;
}

// Run tests if this file is executed directly
if (require.main === module) {
    runTests();
}

module.exports = { runTests };
