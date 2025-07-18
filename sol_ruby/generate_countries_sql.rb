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
      -- Create tables for regions, subregions, and countries
      
      DROP TABLE IF EXISTS countries;
      DROP TABLE IF EXISTS subregions;
      DROP TABLE IF EXISTS regions;
      
      CREATE TABLE regions (
          id INT PRIMARY KEY AUTO_INCREMENT,
          name VARCHAR(100) UNIQUE NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE subregions (
          id INT PRIMARY KEY AUTO_INCREMENT,
          name VARCHAR(100) UNIQUE NOT NULL,
          region_id INT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (region_id) REFERENCES regions(id)
      );
      
      CREATE TABLE countries (
          id INT PRIMARY KEY AUTO_INCREMENT,
          cca2 VARCHAR(2) UNIQUE NOT NULL,
          cca3 VARCHAR(3) UNIQUE NOT NULL,
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
      
    SQL
  end

  def generate_regions_sql
    sql = "-- Insert regions\n"
    @regions.to_a.sort.each_with_index do |region, index|
      sql += "INSERT INTO regions (id, name) VALUES (#{index + 1}, '#{escape_sql(region)}');\n"
    end
    sql += "\n"
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
      sql += country[:independent] ? "TRUE" : "FALSE"
      sql += ", "
      sql += country[:un_member] ? "TRUE" : "FALSE"
      sql += ", "
      sql += country[:flag] ? "'#{country[:flag]}'" : "NULL"
      sql += ", "
      sql += country[:latitude] ? country[:latitude].to_s : "NULL"
      sql += ", "
      sql += country[:longitude] ? country[:longitude].to_s : "NULL"
      sql += ");\n"
    end
    sql += "\n"
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
