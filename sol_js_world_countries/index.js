const fs = require('fs');
const path = require('path');
const countries = require('world-countries');

/**
 * Generate SQL insert statements for countries, regions, and subregions
 */
class CountriesSQLGenerator {
    constructor() {
        this.regions = new Map();
        this.subregions = new Map();
        this.countries = [];
        this.regionId = 1;
        this.subregionId = 1;
    }

    /**
     * Process all countries and extract regions/subregions
     */
    processCountries() {
        // First pass: collect all unique regions and subregions
        countries.forEach(country => {
            if (country.region && !this.regions.has(country.region)) {
                this.regions.set(country.region, {
                    id: this.regionId++,
                    name: country.region
                });
            }

            if (country.subregion && !this.subregions.has(country.subregion)) {
                const regionId = this.regions.get(country.region)?.id || null;
                this.subregions.set(country.subregion, {
                    id: this.subregionId++,
                    name: country.subregion,
                    regionId: regionId
                });
            }
        });

        // Second pass: process countries
        countries.forEach(country => {
            const regionId = this.regions.get(country.region)?.id || null;
            const subregionId = this.subregions.get(country.subregion)?.id || null;

            this.countries.push({
                cca2: country.cca2,
                cca3: country.cca3,
                ccn3: country.ccn3,
                name: country.name.common,
                officialName: country.name.official,
                region: country.region,
                subregion: country.subregion,
                regionId: regionId,
                subregionId: subregionId,
                capital: country.capital ? country.capital[0] : null,
                area: country.area,
                population: country.population || null,
                independent: country.independent,
                unMember: country.unMember,
                flag: country.flag,
                latitude: country.latlng ? country.latlng[0] : null,
                longitude: country.latlng ? country.latlng[1] : null
            });
        });
    }

    /**
     * Generate SQL for creating tables
     */
    generateCreateTableStatements() {
        return `-- Create tables for countries, regions, and subregions
    
CREATE TABLE IF NOT EXISTS regions (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS subregions (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    region_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(id)
);

CREATE TABLE IF NOT EXISTS countries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cca2 VARCHAR(2) NOT NULL UNIQUE,
    cca3 VARCHAR(3) NOT NULL UNIQUE,
    ccn3 VARCHAR(3),
    name VARCHAR(100) NOT NULL,
    official_name VARCHAR(200),
    region VARCHAR(50),
    subregion VARCHAR(100),
    region_id INT,
    subregion_id INT,
    capital VARCHAR(100),
    area DECIMAL(15,2),
    population BIGINT,
    independent BOOLEAN,
    un_member BOOLEAN,
    flag VARCHAR(10),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(id),
    FOREIGN KEY (subregion_id) REFERENCES subregions(id)
);

`;
    }

    /**
     * Generate SQL INSERT statements for regions
     */
    generateRegionInserts() {
        let sql = '-- Insert regions\n';

        const regionValues = Array.from(this.regions.values())
            .map(region => `(${region.id}, '${this.escapeString(region.name)}')`)
            .join(',\n    ');

        sql += `INSERT INTO regions (id, name) VALUES\n    ${regionValues};\n\n`;

        return sql;
    }

    /**
     * Generate SQL INSERT statements for subregions
     */
    generateSubregionInserts() {
        let sql = '-- Insert subregions\n';

        const subregionValues = Array.from(this.subregions.values())
            .map(subregion => `(${subregion.id}, '${this.escapeString(subregion.name)}', ${subregion.regionId})`)
            .join(',\n    ');

        sql += `INSERT INTO subregions (id, name, region_id) VALUES\n    ${subregionValues};\n\n`;

        return sql;
    }

    /**
     * Generate SQL INSERT statements for countries
     */
    generateCountryInserts() {
        let sql = '-- Insert countries\n';

        const countryValues = this.countries
            .map(country => {
                const values = [
                    `'${this.escapeString(country.cca2)}'`,
                    `'${this.escapeString(country.cca3)}'`,
                    country.ccn3 ? `'${this.escapeString(country.ccn3)}'` : 'NULL',
                    `'${this.escapeString(country.name)}'`,
                    `'${this.escapeString(country.officialName)}'`,
                    country.region ? `'${this.escapeString(country.region)}'` : 'NULL',
                    country.subregion ? `'${this.escapeString(country.subregion)}'` : 'NULL',
                    country.regionId || 'NULL',
                    country.subregionId || 'NULL',
                    country.capital ? `'${this.escapeString(country.capital)}'` : 'NULL',
                    country.area || 'NULL',
                    country.population || 'NULL',
                    country.independent !== undefined ? (country.independent ? 'TRUE' : 'FALSE') : 'NULL',
                    country.unMember !== undefined ? (country.unMember ? 'TRUE' : 'FALSE') : 'NULL',
                    country.flag ? `'${this.escapeString(country.flag)}'` : 'NULL',
                    country.latitude || 'NULL',
                    country.longitude || 'NULL'
                ];

                return `(${values.join(', ')})`;
            })
            .join(',\n    ');

        sql += `INSERT INTO countries (cca2, cca3, ccn3, name, official_name, region, subregion, region_id, subregion_id, capital, area, population, independent, un_member, flag, latitude, longitude) VALUES\n    ${countryValues};\n\n`;

        return sql;
    }

    /**
     * Escape strings for SQL (simple version)
     */
    escapeString(str) {
        if (!str) return '';
        return str.replace(/'/g, "''");
    }

    /**
     * Generate complete SQL file
     */
    generateSQL() {
        this.processCountries();

        let sql = `-- Generated SQL for Countries, Regions, and Subregions
-- Generated on: ${new Date().toISOString()}
-- Total countries: ${this.countries.length}
-- Total regions: ${this.regions.size}
-- Total subregions: ${this.subregions.size}

`;

        sql += this.generateCreateTableStatements();
        sql += this.generateRegionInserts();
        sql += this.generateSubregionInserts();
        sql += this.generateCountryInserts();

        return sql;
    }

    /**
     * Save SQL to file
     */
    saveToFile(filename = 'countries_data.sql') {
        const sql = this.generateSQL();
        const filePath = path.join(__dirname, filename);

        fs.writeFileSync(filePath, sql, 'utf8');
        console.log(`SQL file saved to: ${filePath}`);

        // Also generate a summary
        this.generateSummary();
    }

    /**
     * Generate a summary of the data
     */
    generateSummary() {
        const summary = {
            totalCountries: this.countries.length,
            totalRegions: this.regions.size,
            totalSubregions: this.subregions.size,
            regions: Array.from(this.regions.values()).map(r => ({ id: r.id, name: r.name })),
            subregions: Array.from(this.subregions.values()).map(s => ({
                id: s.id,
                name: s.name,
                regionId: s.regionId,
                regionName: Array.from(this.regions.values()).find(r => r.id === s.regionId)?.name
            })),
            countriesByRegion: {}
        };

        // Count countries by region
        this.countries.forEach(country => {
            if (country.region) {
                if (!summary.countriesByRegion[country.region]) {
                    summary.countriesByRegion[country.region] = 0;
                }
                summary.countriesByRegion[country.region]++;
            }
        });

        const summaryPath = path.join(__dirname, 'countries_summary.json');
        fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2), 'utf8');
        console.log(`Summary saved to: ${summaryPath}`);

        // Log summary to console
        console.log('\n=== SUMMARY ===');
        console.log(`Total Countries: ${summary.totalCountries}`);
        console.log(`Total Regions: ${summary.totalRegions}`);
        console.log(`Total Subregions: ${summary.totalSubregions}`);
        console.log('\nRegions:');
        summary.regions.forEach(region => {
            console.log(`  ${region.id}: ${region.name} (${summary.countriesByRegion[region.name] || 0} countries)`);
        });
        console.log('\nSubregions:');
        summary.subregions.forEach(subregion => {
            console.log(`  ${subregion.id}: ${subregion.name} (Region: ${subregion.regionName})`);
        });
    }
}

// Main execution
if (require.main === module) {
    const generator = new CountriesSQLGenerator();
    generator.saveToFile();
}

module.exports = CountriesSQLGenerator;
