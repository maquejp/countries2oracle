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
     * Generate SQL for creating tables (Oracle format)
     */
    generateCreateTableStatements() {
        return `-- Create tables for countries, regions, and subregions (Oracle format)
    
CREATE TABLE regions (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subregions (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100) NOT NULL UNIQUE,
    region_id NUMBER(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_subregions_region FOREIGN KEY (region_id) REFERENCES regions(id)
);

CREATE TABLE countries (
    id NUMBER(10) PRIMARY KEY,
    cca2 VARCHAR2(2) NOT NULL UNIQUE,
    cca3 VARCHAR2(3) NOT NULL UNIQUE,
    ccn3 VARCHAR2(3),
    name VARCHAR2(100) NOT NULL,
    official_name VARCHAR2(200),
    region VARCHAR2(50),
    subregion VARCHAR2(100),
    region_id NUMBER(10),
    subregion_id NUMBER(10),
    capital VARCHAR2(100),
    area NUMBER(15,2),
    population NUMBER(19),
    independent NUMBER(1) CHECK (independent IN (0, 1)),
    un_member NUMBER(1) CHECK (un_member IN (0, 1)),
    flag VARCHAR2(10),
    latitude NUMBER(10,8),
    longitude NUMBER(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_countries_region FOREIGN KEY (region_id) REFERENCES regions(id),
    CONSTRAINT fk_countries_subregion FOREIGN KEY (subregion_id) REFERENCES subregions(id)
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
            .map((country, index) => {
                const values = [
                    index + 1, // Generate sequential ID for Oracle
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
                    country.independent !== undefined ? (country.independent ? '1' : '0') : 'NULL',
                    country.unMember !== undefined ? (country.unMember ? '1' : '0') : 'NULL',
                    country.flag ? `'${this.escapeString(country.flag)}'` : 'NULL',
                    country.latitude || 'NULL',
                    country.longitude || 'NULL'
                ];

                return `(${values.join(', ')})`;
            })
            .join(',\n    ');

        sql += `INSERT INTO countries (id, cca2, cca3, ccn3, name, official_name, region, subregion, region_id, subregion_id, capital, area, population, independent, un_member, flag, latitude, longitude) VALUES\n    ${countryValues};\n\n`;

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

        let sql = `-- Generated Oracle SQL for Countries, Regions, and Subregions
-- Generated on: ${new Date().toISOString()}
-- Total countries: ${this.countries.length}
-- Total regions: ${this.regions.size}
-- Total subregions: ${this.subregions.size}
-- Database: Oracle (without sequences/triggers)

`;

        sql += this.generateCreateTableStatements();
        sql += this.generateRegionInserts();
        sql += this.generateSubregionInserts();
        sql += this.generateCountryInserts();

        return sql;
    }

    /**
     * Save SQL to separate files
     */
    saveToFiles() {
        this.processCountries();

        // Ensure SQLs directory exists
        const sqlsDir = path.join(__dirname, 'SQLs');
        if (!fs.existsSync(sqlsDir)) {
            fs.mkdirSync(sqlsDir, { recursive: true });
        }

        const timestamp = new Date().toISOString();
        const header = `-- Generated Oracle SQL for Countries Database
-- Generated on: ${timestamp}
-- Total countries: ${this.countries.length}
-- Total regions: ${this.regions.size}
-- Total subregions: ${this.subregions.size}
-- Database: Oracle (without sequences/triggers)

`;

        // 1. Create tables file
        const createTablesSQL = header + this.generateCreateTableStatements();
        const createTablesPath = path.join(sqlsDir, '01_create_tables.sql');
        fs.writeFileSync(createTablesPath, createTablesSQL, 'utf8');
        console.log(`Tables creation file saved to: ${createTablesPath}`);

        // 2. Regions data file
        const regionsSQL = header + this.generateRegionInserts();
        const regionsPath = path.join(sqlsDir, '02_regions_data.sql');
        fs.writeFileSync(regionsPath, regionsSQL, 'utf8');
        console.log(`Regions data file saved to: ${regionsPath}`);

        // 3. Subregions data file
        const subregionsSQL = header + this.generateSubregionInserts();
        const subregionsPath = path.join(sqlsDir, '03_subregions_data.sql');
        fs.writeFileSync(subregionsPath, subregionsSQL, 'utf8');
        console.log(`Subregions data file saved to: ${subregionsPath}`);

        // 4. Countries data file
        const countriesSQL = header + this.generateCountryInserts();
        const countriesPath = path.join(sqlsDir, '04_countries_data.sql');
        fs.writeFileSync(countriesPath, countriesSQL, 'utf8');
        console.log(`Countries data file saved to: ${countriesPath}`);

        // 5. Keep the complete file as well
        const completeSQL = header + this.generateCreateTableStatements() +
            this.generateRegionInserts() +
            this.generateSubregionInserts() +
            this.generateCountryInserts();
        const completePath = path.join(sqlsDir, 'countries_data_oracle.sql');
        fs.writeFileSync(completePath, completeSQL, 'utf8');
        console.log(`Complete SQL file saved to: ${completePath}`);

        // Generate summary
        this.generateSummary();
    }

    /**
     * Save SQL to file (legacy method - now calls saveToFiles)
     */
    saveToFile(filename = 'countries_data_oracle.sql') {
        this.saveToFiles();
    }    /**
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

        // Save to SQLs folder
        const sqlsDir = path.join(__dirname, 'SQLs');
        if (!fs.existsSync(sqlsDir)) {
            fs.mkdirSync(sqlsDir, { recursive: true });
        }

        const summaryPath = path.join(sqlsDir, 'countries_summary.json');
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
