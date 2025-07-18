const fs = require('fs');
const path = require('path');

/**
 * Database-specific SQL converters
 */
class DatabaseConverter {
    /**
     * Convert Oracle SQL to PostgreSQL format
     */
    static toPostgreSQL(sqlContent) {
        return sqlContent
            // Replace Oracle NUMBER with PostgreSQL types
            .replace(/NUMBER\(10\)/g, 'INTEGER')
            .replace(/NUMBER\(19\)/g, 'BIGINT')
            .replace(/NUMBER\(15,2\)/g, 'DECIMAL(15,2)')
            .replace(/NUMBER\(10,8\)/g, 'DECIMAL(10,8)')
            .replace(/NUMBER\(11,8\)/g, 'DECIMAL(11,8)')
            .replace(/NUMBER\(1\)/g, 'BOOLEAN')
            // Replace VARCHAR2 with VARCHAR
            .replace(/VARCHAR2/g, 'VARCHAR')
            // Replace Oracle constraint names with PostgreSQL style
            .replace(/CONSTRAINT fk_[^)]+\s+FOREIGN KEY/g, 'FOREIGN KEY')
            // Replace Oracle boolean checks
            .replace(/CHECK \([^)]+\)/g, '')
            // Replace boolean values in INSERT statements (be more specific)
            .replace(/,\s*1\s*,/g, ', true,')
            .replace(/,\s*0\s*,/g, ', false,')
            .replace(/,\s*1\s*\)/g, ', true)')
            .replace(/,\s*0\s*\)/g, ', false)')
            // Update comments
            .replace(/-- Database: Oracle \(without sequences\/triggers\)/g, '-- Database: PostgreSQL')
            .replace(/-- Create tables for countries, regions, and subregions \(Oracle format\)/g, '-- Create tables for countries, regions, and subregions (PostgreSQL format)');
    }

    /**
     * Convert Oracle SQL to MySQL format
     */
    static toMySQL(sqlContent) {
        return sqlContent
            // Replace Oracle NUMBER with MySQL types
            .replace(/NUMBER\(10\)/g, 'INT')
            .replace(/NUMBER\(19\)/g, 'BIGINT')
            .replace(/NUMBER\(15,2\)/g, 'DECIMAL(15,2)')
            .replace(/NUMBER\(10,8\)/g, 'DECIMAL(10,8)')
            .replace(/NUMBER\(11,8\)/g, 'DECIMAL(11,8)')
            .replace(/NUMBER\(1\)/g, 'BOOLEAN')
            // Replace VARCHAR2 with VARCHAR
            .replace(/VARCHAR2/g, 'VARCHAR')
            // Replace Oracle constraint names with MySQL style
            .replace(/CONSTRAINT fk_[^)]+\s+FOREIGN KEY/g, 'FOREIGN KEY')
            // Replace Oracle boolean checks with MySQL boolean
            .replace(/CHECK \([^)]+\)/g, '')
            // Replace boolean values in INSERT statements (be more specific)
            .replace(/,\s*1\s*,/g, ', TRUE,')
            .replace(/,\s*0\s*,/g, ', FALSE,')
            .replace(/,\s*1\s*\)/g, ', TRUE)')
            .replace(/,\s*0\s*\)/g, ', FALSE)')
            // Update comments
            .replace(/-- Database: Oracle \(without sequences\/triggers\)/g, '-- Database: MySQL')
            .replace(/-- Create tables for countries, regions, and subregions \(Oracle format\)/g, '-- Create tables for countries, regions, and subregions (MySQL format)')
            // Add AUTO_INCREMENT for countries table
            .replace(/id INT PRIMARY KEY,/g, 'id INT PRIMARY KEY AUTO_INCREMENT,');
    }

    /**
     * Convert Oracle SQL to SQLite format
     */
    static toSQLite(sqlContent) {
        return sqlContent
            // Replace Oracle NUMBER with SQLite types
            .replace(/NUMBER\(10\)/g, 'INTEGER')
            .replace(/NUMBER\(19\)/g, 'INTEGER')
            .replace(/NUMBER\(15,2\)/g, 'REAL')
            .replace(/NUMBER\(10,8\)/g, 'REAL')
            .replace(/NUMBER\(11,8\)/g, 'REAL')
            .replace(/NUMBER\(1\)/g, 'INTEGER')
            // Replace VARCHAR2 with TEXT
            .replace(/VARCHAR2/g, 'TEXT')
            // Remove Oracle constraint names (SQLite doesn't support named constraints well)
            .replace(/CONSTRAINT fk_[^)]+\s+FOREIGN KEY/g, 'FOREIGN KEY')
            // Remove Oracle boolean checks
            .replace(/CHECK \([^)]+\)/g, '')
            // Keep boolean values as 1/0 for SQLite (no replacement needed)
            // Update comments
            .replace(/-- Database: Oracle \(without sequences\/triggers\)/g, '-- Database: SQLite')
            .replace(/-- Create tables for countries, regions, and subregions \(Oracle format\)/g, '-- Create tables for countries, regions, and subregions (SQLite format)')
            // Add AUTOINCREMENT for countries table
            .replace(/id INTEGER PRIMARY KEY,/g, 'id INTEGER PRIMARY KEY AUTOINCREMENT,');
    }

    /**
     * Convert Oracle SQL to SQL Server format
     */
    static toSQLServer(sqlContent) {
        return sqlContent
            // Replace Oracle NUMBER with SQL Server types
            .replace(/NUMBER\(10\)/g, 'INT')
            .replace(/NUMBER\(19\)/g, 'BIGINT')
            .replace(/NUMBER\(15,2\)/g, 'DECIMAL(15,2)')
            .replace(/NUMBER\(10,8\)/g, 'DECIMAL(10,8)')
            .replace(/NUMBER\(11,8\)/g, 'DECIMAL(11,8)')
            .replace(/NUMBER\(1\)/g, 'BIT')
            // Replace VARCHAR2 with NVARCHAR
            .replace(/VARCHAR2/g, 'NVARCHAR')
            // Replace Oracle constraint names with SQL Server style
            .replace(/CONSTRAINT fk_[^)]+\s+FOREIGN KEY/g, 'FOREIGN KEY')
            // Replace Oracle boolean checks
            .replace(/CHECK \([^)]+\)/g, '')
            // Replace boolean values in INSERT statements
            .replace(/\b1\b/g, '1')
            .replace(/\b0\b/g, '0')
            // Replace Oracle timestamp with SQL Server datetime
            .replace(/TIMESTAMP DEFAULT CURRENT_TIMESTAMP/g, 'DATETIME DEFAULT GETDATE()')
            // Update comments
            .replace(/-- Database: Oracle \(without sequences\/triggers\)/g, '-- Database: SQL Server')
            .replace(/-- Create tables for countries, regions, and subregions \(Oracle format\)/g, '-- Create tables for countries, regions, and subregions (SQL Server format)')
            // Add IDENTITY for countries table
            .replace(/id INT PRIMARY KEY,/g, 'id INT IDENTITY(1,1) PRIMARY KEY,');
    }
}

/**
 * Generate database-specific SQL files
 */
function generateDatabaseSpecificFiles() {
    const sqlsDir = path.join(__dirname, 'SQLs');
    const oracleFilePath = path.join(sqlsDir, 'countries_data_oracle.sql');

    if (!fs.existsSync(oracleFilePath)) {
        console.error('❌ Oracle SQL file not found. Please run "npm start" first.');
        return;
    }

    const oracleContent = fs.readFileSync(oracleFilePath, 'utf8');

    // Generate PostgreSQL version
    const postgresqlContent = DatabaseConverter.toPostgreSQL(oracleContent);
    const postgresqlPath = path.join(sqlsDir, 'countries_data_postgresql.sql');
    fs.writeFileSync(postgresqlPath, postgresqlContent);
    console.log(`✅ PostgreSQL SQL file generated: ${postgresqlPath}`);

    // Generate MySQL version
    const mysqlContent = DatabaseConverter.toMySQL(oracleContent);
    const mysqlPath = path.join(sqlsDir, 'countries_data_mysql.sql');
    fs.writeFileSync(mysqlPath, mysqlContent);
    console.log(`✅ MySQL SQL file generated: ${mysqlPath}`);

    // Generate SQLite version
    const sqliteContent = DatabaseConverter.toSQLite(oracleContent);
    const sqlitePath = path.join(sqlsDir, 'countries_data_sqlite.sql');
    fs.writeFileSync(sqlitePath, sqliteContent);
    console.log(`✅ SQLite SQL file generated: ${sqlitePath}`);

    // Generate SQL Server version
    const sqlServerContent = DatabaseConverter.toSQLServer(oracleContent);
    const sqlServerPath = path.join(sqlsDir, 'countries_data_sqlserver.sql');
    fs.writeFileSync(sqlServerPath, sqlServerContent);
    console.log(`✅ SQL Server SQL file generated: ${sqlServerPath}`);

    console.log('\n📝 Database-specific notes:');
    console.log('• Oracle: Base format with NUMBER types and VARCHAR2 (no sequences/triggers)');
    console.log('• PostgreSQL: Uses INTEGER/BIGINT for numbers and proper boolean values');
    console.log('• MySQL: Uses INT/BIGINT with AUTO_INCREMENT and TRUE/FALSE booleans');
    console.log('• SQLite: Uses INTEGER PRIMARY KEY AUTOINCREMENT and 1/0 for booleans');
    console.log('• SQL Server: Uses IDENTITY for auto-increment and BIT for boolean');
}

/**
 * Create a simple migration script
 */
function createMigrationScript() {
    const migrationScript = `-- Migration script for countries database
-- This script helps you set up the countries database step by step

-- Step 1: Create the database (uncomment the appropriate line for your database)
-- CREATE DATABASE countries_db;         -- MySQL/PostgreSQL
-- CREATE USER countries_user;           -- Oracle
-- GRANT CREATE SESSION TO countries_user; -- Oracle

-- Step 2: Enable foreign key constraints (if using SQLite)
-- PRAGMA foreign_keys = ON;             -- SQLite only

-- Step 3: Create tables and insert data
-- Run the appropriate SQL file for your database from the SQLs folder:
-- - countries_data_oracle.sql (Oracle - base format)
-- - countries_data_mysql.sql (MySQL/MariaDB)
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
-- Note: Syntax may vary between databases
CREATE INDEX idx_countries_region_id ON countries(region_id);
CREATE INDEX idx_countries_subregion_id ON countries(subregion_id);
CREATE INDEX idx_countries_cca2 ON countries(cca2);
CREATE INDEX idx_countries_cca3 ON countries(cca3);
CREATE INDEX idx_subregions_region_id ON subregions(region_id);

-- Step 7: Oracle specific optimizations (if using Oracle)
-- ANALYZE TABLE regions;
-- ANALYZE TABLE subregions;
-- ANALYZE TABLE countries;
`;

    const sqlsDir = path.join(__dirname, 'SQLs');
    if (!fs.existsSync(sqlsDir)) {
        fs.mkdirSync(sqlsDir, { recursive: true });
    }

    const migrationPath = path.join(sqlsDir, 'migration.sql');
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
