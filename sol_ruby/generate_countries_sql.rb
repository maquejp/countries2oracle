#!/usr/bin/env ruby
require 'countries'
require 'set'

# SQL Generator for Countries, Regions, and Subregions
# Uses the Ruby Countries gem: https://github.com/countries/countries

class CountriesSQLGenerator
  def initialize
    @regions = Set.new
    @subregions = Set.new
    @countries_data = []
  end

  def generate_sql
    collect_data
    generate_create_tables_sql + 
    generate_regions_sql + 
    generate_subregions_sql + 
    generate_countries_sql
  end

  def generate_separate_files
    collect_data
    
    # Create SQLs directory if it doesn't exist
    Dir.mkdir('SQLs') unless Dir.exist?('SQLs')
    
    # Generate schema file
    File.write('SQLs/schema.sql', generate_create_tables_sql)
    
    # Generate regions file
    File.write('SQLs/regions.sql', generate_regions_sql)
    
    # Generate subregions file
    File.write('SQLs/subregions.sql', generate_subregions_sql)
    
    # Generate countries file
    File.write('SQLs/countries.sql', generate_countries_sql)
    
    puts "Generated separate SQL files in SQLs/ directory:"
    puts "- SQLs/schema.sql (table definitions)"
    puts "- SQLs/regions.sql (#{@regions.size} regions)"
    puts "- SQLs/subregions.sql (#{@subregions.size} subregions)"
    puts "- SQLs/countries.sql (#{@countries_data.size} countries)"
  end

  private

  def collect_data
    ISO3166::Country.all.each do |country|
      # Skip countries without region data
      next unless country.region && country.subregion
      next if country.region.empty? || country.subregion.empty?

      @regions.add(country.region)
      @subregions.add(country.subregion)
      
      @countries_data << {
        alpha2: country.alpha2,
        alpha3: country.alpha3,
        numeric_code: country.number,
        name: country.iso_short_name,
        official_name: country.iso_long_name,
        region: country.region,
        subregion: country.subregion,
        capital: country.data['capital'], # Try to get capital from raw data
        area: country.data['area'],
        population: country.data['population'],
        independent: country.data['independent'],
        un_member: country.data['un_member'],
        flag: country.emoji_flag,
        latitude: country.latitude,
        longitude: country.longitude
      }
    end
  end

  def generate_create_tables_sql
    <<~SQL
      -- Create tables for regions, subregions, and countries (Oracle compatible)
      
      -- Drop tables in reverse order due to foreign key constraints
      DROP TABLE countries CASCADE CONSTRAINTS;
      DROP TABLE subregions CASCADE CONSTRAINTS;
      DROP TABLE regions CASCADE CONSTRAINTS;
      
      -- Drop sequences if they exist
      DROP SEQUENCE regions_seq;
      DROP SEQUENCE subregions_seq;
      DROP SEQUENCE countries_seq;
      
      -- Create sequences for auto-increment functionality
      CREATE SEQUENCE regions_seq START WITH 1 INCREMENT BY 1;
      CREATE SEQUENCE subregions_seq START WITH 1 INCREMENT BY 1;
      CREATE SEQUENCE countries_seq START WITH 1 INCREMENT BY 1;
      
      -- Create regions table
      CREATE TABLE regions (
          id NUMBER PRIMARY KEY,
          name VARCHAR2(100) UNIQUE NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      
      -- Create subregions table
      CREATE TABLE subregions (
          id NUMBER PRIMARY KEY,
          name VARCHAR2(100) UNIQUE NOT NULL,
          region_id NUMBER NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          CONSTRAINT fk_subregions_region FOREIGN KEY (region_id) REFERENCES regions(id)
      );
      
      -- Create countries table
      CREATE TABLE countries (
          id NUMBER PRIMARY KEY,
          cca2 VARCHAR2(2) UNIQUE NOT NULL,
          cca3 VARCHAR2(3) UNIQUE NOT NULL,
          ccn3 VARCHAR2(3),
          name VARCHAR2(100) NOT NULL,
          official_name VARCHAR2(200),
          region VARCHAR2(50),
          subregion VARCHAR2(100),
          region_id NUMBER,
          subregion_id NUMBER,
          capital VARCHAR2(100),
          area NUMBER(15,2),
          population NUMBER(15),
          independent NUMBER(1) DEFAULT 0,
          un_member NUMBER(1) DEFAULT 0,
          flag VARCHAR2(10),
          latitude NUMBER(10,8),
          longitude NUMBER(11,8),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          CONSTRAINT fk_countries_region FOREIGN KEY (region_id) REFERENCES regions(id),
          CONSTRAINT fk_countries_subregion FOREIGN KEY (subregion_id) REFERENCES subregions(id)
      );
      
      -- Create triggers for auto-increment functionality
      CREATE OR REPLACE TRIGGER regions_trigger
      BEFORE INSERT ON regions
      FOR EACH ROW
      BEGIN
          IF :NEW.id IS NULL THEN
              :NEW.id := regions_seq.NEXTVAL;
          END IF;
      END;
      /
      
      CREATE OR REPLACE TRIGGER subregions_trigger
      BEFORE INSERT ON subregions
      FOR EACH ROW
      BEGIN
          IF :NEW.id IS NULL THEN
              :NEW.id := subregions_seq.NEXTVAL;
          END IF;
      END;
      /
      
      CREATE OR REPLACE TRIGGER countries_trigger
      BEFORE INSERT ON countries
      FOR EACH ROW
      BEGIN
          IF :NEW.id IS NULL THEN
              :NEW.id := countries_seq.NEXTVAL;
          END IF;
      END;
      /
      
    SQL
  end

  def generate_regions_sql
    sql = "-- Insert regions\n"
    @regions.to_a.sort.each_with_index do |region, index|
      sql += "INSERT INTO regions (id, name) VALUES (#{index + 1}, '#{escape_sql(region)}');\n"
    end
    sql += "\n"
    sql += "-- Commit the transaction\n"
    sql += "COMMIT;\n"
  end

  def generate_subregions_sql
    sql = "-- Insert subregions\n"
    regions_array = @regions.to_a.sort
    subregions_array = @subregions.to_a.sort
    
    subregions_array.each_with_index do |subregion, index|
      # Find the region for this subregion by checking countries
      region = find_region_for_subregion(subregion)
      region_id = regions_array.index(region) + 1 if region
      
      sql += "INSERT INTO subregions (id, name, region_id) VALUES (#{index + 1}, '#{escape_sql(subregion)}', #{region_id});\n"
    end
    sql += "\n"
    sql += "-- Commit the transaction\n"
    sql += "COMMIT;\n"
  end

  def generate_countries_sql
    sql = "-- Insert countries\n"
    regions_array = @regions.to_a.sort
    subregions_array = @subregions.to_a.sort
    
    @countries_data.each_with_index do |country, index|
      region_id = regions_array.index(country[:region]) + 1 if country[:region]
      subregion_id = subregions_array.index(country[:subregion]) + 1 if country[:subregion]
      
      sql += "INSERT INTO countries ("
      sql += "id, cca2, cca3, ccn3, name, official_name, region, subregion, "
      sql += "region_id, subregion_id, capital, area, population, independent, "
      sql += "un_member, flag, latitude, longitude"
      sql += ") VALUES ("
      sql += "#{index + 1}, "
      sql += "'#{escape_sql(country[:alpha2])}', "
      sql += "'#{escape_sql(country[:alpha3])}', "
      sql += country[:numeric_code] ? "'#{country[:numeric_code]}'" : "NULL"
      sql += ", "
      sql += "'#{escape_sql(country[:name])}', "
      sql += country[:official_name] ? "'#{escape_sql(country[:official_name])}'" : "NULL"
      sql += ", "
      sql += "'#{escape_sql(country[:region])}', "
      sql += "'#{escape_sql(country[:subregion])}', "
      sql += "#{region_id}, "
      sql += "#{subregion_id}, "
      sql += country[:capital] ? "'#{escape_sql(country[:capital])}'" : "NULL"
      sql += ", "
      sql += country[:area] ? country[:area].to_s : "NULL"
      sql += ", "
      sql += country[:population] ? country[:population].to_s : "NULL"
      sql += ", "
      sql += country[:independent] ? "1" : "0"
      sql += ", "
      sql += country[:un_member] ? "1" : "0"
      sql += ", "
      sql += country[:flag] ? "'#{country[:flag]}'" : "NULL"
      sql += ", "
      sql += country[:latitude] ? country[:latitude].to_s : "NULL"
      sql += ", "
      sql += country[:longitude] ? country[:longitude].to_s : "NULL"
      sql += ");\n"
    end
    sql += "\n"
    sql += "-- Commit the transaction\n"
    sql += "COMMIT;\n"
  end

  def find_region_for_subregion(subregion)
    @countries_data.find { |country| country[:subregion] == subregion }&.dig(:region)
  end

  def escape_sql(string)
    return "" unless string
    string.to_s.gsub("'", "''")
  end
end

# Generate and output the SQL
generator = CountriesSQLGenerator.new

# Check command line arguments
if ARGV.include?('--separate') || ARGV.include?('-s')
  generator.generate_separate_files
else
  puts generator.generate_sql
end
