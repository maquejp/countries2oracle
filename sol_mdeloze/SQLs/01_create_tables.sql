-- Oracle SQL Table Creation Script
-- Generated on: 2025-07-18 16:35:08
-- Based on: https://github.com/mledoze/countries

-- Drop tables if they exist (in correct order due to foreign keys)
drop table countries cascade constraints;
drop table subregions cascade constraints;
drop table regions cascade constraints;

-- Create REGIONS table
create table regions (
   region_id    number primary key,
   region_name  varchar2(100) not null unique,
   created_date date default sysdate
);

-- Create SUBREGIONS table
create table subregions (
   subregion_id   number primary key,
   subregion_name varchar2(100) not null,
   region_id      number,
   created_date   date default sysdate,
   constraint fk_subregion_region foreign key ( region_id )
      references regions ( region_id ),
   constraint uk_subregion_name unique ( subregion_name,
                                         region_id )
);

-- Create COUNTRIES table
create table countries (
   country_id        number primary key,
    -- Basic country information
   common_name       varchar2(100) not null,
   official_name     varchar2(200),
   cca2              char(2) unique,
   cca3              char(3) unique,
   ccn3              char(3),
   cioc              char(3),
    
    -- Status information
   independent       number(1) default 0,
   status            varchar2(50),
   un_member         number(1) default 0,
   un_regional_group varchar2(100),
    
    -- Geographic information
   region_id         number,
   subregion_id      number,
   capital           varchar2(500), -- Can be multiple capitals
   latlng            varchar2(50), -- Stored as "lat,lng"
   landlocked        number(1) default 0,
   borders           varchar2(1000), -- Comma-separated country codes
   area              number,
    
    -- Additional information
   tld               varchar2(200), -- Top-level domains
   currencies        varchar2(1000), -- JSON string of currencies
   languages         varchar2(1000), -- JSON string of languages
   alt_spellings     varchar2(1000), -- Comma-separated alternative spellings
   flag_emoji        varchar2(10),
    
    -- Metadata
   created_date      date default sysdate,
    
    -- Foreign key constraints
   constraint fk_country_region foreign key ( region_id )
      references regions ( region_id ),
   constraint fk_country_subregion foreign key ( subregion_id )
      references subregions ( subregion_id )
);

-- Create indexes for better performance
create index idx_countries_region on
   countries (
      region_id
   );
create index idx_countries_subregion on
   countries (
      subregion_id
   );
create index idx_countries_cca2 on
   countries (
      cca2
   );
create index idx_countries_cca3 on
   countries (
      cca3
   );
create index idx_countries_independent on
   countries (
      independent
   );
create index idx_countries_un_member on
   countries (
      un_member
   );

-- Add comments to tables
comment on table regions is
   'World regions (continents)';
comment on table subregions is
   'World subregions within continents';
comment on table countries is
   'World countries and territories based on ISO 3166-1';

-- Add comments to columns
comment on column countries.common_name is
   'Common name in English';
comment on column countries.official_name is
   'Official name in English';
comment on column countries.cca2 is
   'ISO 3166-1 alpha-2 code';
comment on column countries.cca3 is
   'ISO 3166-1 alpha-3 code';
comment on column countries.ccn3 is
   'ISO 3166-1 numeric code';
comment on column countries.cioc is
   'International Olympic Committee code';
comment on column countries.independent is
   '1 if independent sovereign state, 0 otherwise';
comment on column countries.un_member is
   '1 if UN member, 0 otherwise';
comment on column countries.landlocked is
   '1 if landlocked, 0 otherwise';
comment on column countries.area is
   'Area in square kilometers';
comment on column countries.flag_emoji is
   'Unicode flag emoji';

commit;