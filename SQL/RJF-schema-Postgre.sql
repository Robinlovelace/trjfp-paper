CREATE DATABASE RealJunkFood OWNER postgres;
\connect realjunkfood

CREATE TABLE tblCafe(
    Cafe        varchar(40) CONSTRAINT firstkey PRIMARY KEY,
    Address1    varchar(200) NOT NULL,
    Address2	varchar(200),
    Postcode	varchar(10),
    Lat		float,
    Lng		float,
    DateMod	date,
    DateCreated	date
);