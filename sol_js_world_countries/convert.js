const fs = require('fs');
const path = require('path');

/**
 * Database-specific SQL converters
 */
class DatabaseConverter {
    /**
     * Convert MySQL SQL to PostgreSQL format
     */
    static toPostgreSQL(sqlContent) {
        return sqlContent
            // Replace AUTO_INCREMENT with SERIAL
            .replace(/id INT PRIMARY KEY AUTO_INCREMENT/g, 'id SERIAL PRIMARY KEY')
            // Replace BOOLEAN values
            .replace(/TRUE/g, 'true')
            .replace(/FALSE/g, 'false')
            // Replace TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            .replace(/TIMESTAMP DEFAULT CURRENT_TIMESTAMP/g, 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP')
            // Add ON DELETE CASCADE for foreign keys
            .replace(/FOREIGN KEY \([^)]+\) REFERENCES [^)]+\)/g, (match) => `${match} ON DELETE CASCADE`);
    }

    /**
     * Convert MySQL SQL to SQLite format
     */
    static toSQLite(sqlContent) {
        return sqlContent
            // Remove AUTO_INCREMENT (SQLite uses AUTOINCREMENT)
            .replace(/AUTO_INCREMENT/g, 'AUTOINCREMENT')
            // SQLite doesn't support IF NOT EXISTS for foreign keys, so we'll comment them out
            .replace(/,\s*FOREIGN KEY[^;]+/g, (match) => `-- ${match.replace(/,\s*/, '')}`)
            // SQLite uses different boolean values
            .replace(/BOOLEAN/g, 'INTEGER')
            .replace(/TRUE/g, '1')
            .replace(/FALSE/g, '0')
            // SQLite doesn't support DECIMAL precision the same way
            .replace(/DECIMAL\((\d+),(\d+)\)/g, 'REAL');
    }

    /**
     * Convert MySQL SQL to SQL Server format
     */
    static toSQLServer(sqlContent) {
        return sqlContent
            // Replace AUTO_INCREMENT with IDENTITY
            .replace(/id INT PRIMARY KEY AUTO_INCREMENT/g, 'id INT IDENTITY(1,1) PRIMARY KEY')
            // SQL Server uses different boolean type
            .replace(/BOOLEAN/g, 'BIT')
            // SQL Server uses different timestamp
            .replace(/TIMESTAMP DEFAULT CURRENT_TIMESTAMP/g, 'DATETIME DEFAULT GETDATE()')
            // SQL Server uses different variable character type
            .replace(/VARCHAR/g, 'NVARCHAR')
            // Handle NULL values in different format
            .replace(/NULL/g, 'NULL');
    }
}

/**
 * Generate database-specific SQL files
 */
function generateDatabaseSpecificFiles() {
    const mysqlFilePath = path.join(__dirname, 'countries_data.sql');

    if (!fs.existsSync(mysqlFilePath)) {
        console.error('❌ MySQL SQL file not found. Please run "npm start" first.');
        return;
    }

    const mysqlContent = fs.readFileSync(mysqlFilePath, 'utf8');

    // Generate PostgreSQL version
    const postgresqlContent = DatabaseConverter.toPostgreSQL(mysqlContent);
    const postgresqlPath = path.join(__dirname, 'countries_data_postgresql.sql');
    fs.writeFileSync(postgresqlPath, postgresqlContent);
    console.log(`✅ PostgreSQL SQL file generated: ${postgresqlPath}`);

    // Generate SQLite version
    const sqliteContent = DatabaseConverter.toSQLite(mysqlContent);
    const sqlitePath = path.join(__dirname, 'countries_data_sqlite.sql');
    fs.writeFileSync(sqlitePath, sqliteContent);
    console.log(`✅ SQLite SQL file generated: ${sqlitePath}`);

    // Generate SQL Server version
    const sqlServerContent = DatabaseConverter.toSQLServer(mysqlContent);
    const sqlServerPath = path.join(__dirname, 'countries_data_sqlserver.sql');
    fs.writeFileSync(sqlServerPath, sqlServerContent);
    console.log(`✅ SQL Server SQL file generated: ${sqlServerPath}`);

    console.log('\n📝 Database-specific notes:');
    console.log('• PostgreSQL: Uses SERIAL for auto-increment and proper boolean values');
    console.log('• SQLite: Foreign keys are commented out (enable with PRAGMA foreign_keys=ON)');
    console.log('• SQL Server: Uses IDENTITY for auto-increment and BIT for boolean');
}

/**
 * Create a simple migration script
 */
function createMigrationScript() {
    const migrationScript = `-- Migration script for countries database
-- This script helps you set up the countries database step by step

-- Step 1: Create the database (uncomment the appropriate line for your database)
-- CREATE DATABASE countries_db;  -- MySQL/PostgreSQL
-- USE countries_db;              -- MySQL

-- Step 2: Enable foreign key constraints (if using SQLite)
-- PRAGMA foreign_keys = ON;      -- SQLite only

-- Step 3: Create tables and insert data
-- Run the appropriate SQL file for your database:
-- - countries_data.sql (MySQL/MariaDB)
-- - countries_data_postgresql.sql (PostgreSQL)
-- - countries_data_sqlite.sql (SQLite)
-- - countries_data_sqlserver.sql (SQL Server)

-- Step 4: Verify the data
SELECT 'Regions' as table_name, COUNT(*) as record_count FROM regions
UNION ALL
SELECT 'Subregions' as table_name, COUNT(*) as record_count FROM subregions
UNION ALL
SELECT 'Countries' as table_name, COUNT(*) as record_count FROM countries;

-- Step 5: Test the relationships
SELECT 
    r.name as region_name,
    COUNT(DISTINCT s.id) as subregions_count,
    COUNT(c.id) as countries_count
FROM regions r
LEFT JOIN subregions s ON r.id = s.region_id
LEFT JOIN countries c ON r.id = c.region_id
GROUP BY r.id, r.name
ORDER BY countries_count DESC;

-- Step 6: Create indexes for better performance (optional)
CREATE INDEX idx_countries_region_id ON countries(region_id);
CREATE INDEX idx_countries_subregion_id ON countries(subregion_id);
CREATE INDEX idx_countries_cca2 ON countries(cca2);
CREATE INDEX idx_countries_cca3 ON countries(cca3);
CREATE INDEX idx_subregions_region_id ON subregions(region_id);
`;

    const migrationPath = path.join(__dirname, 'migration.sql');
    fs.writeFileSync(migrationPath, migrationScript);
    console.log(`✅ Migration script created: ${migrationPath}`);
}

// Main execution
if (require.main === module) {
    console.log('🔧 Generating database-specific SQL files...\n');
    generateDatabaseSpecificFiles();
    console.log('\n🚀 Creating migration script...');
    createMigrationScript();
    console.log('\n✨ All database files generated successfully!');
}

module.exports = { DatabaseConverter, generateDatabaseSpecificFiles, createMigrationScript };
