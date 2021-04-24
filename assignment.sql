\! clear
SET TIMEZONE = 'CET';
CREATE EXTENSION IF NOT EXISTS btree_gist;
DROP TABLE IF EXISTS domain;
CREATE TABLE domain (
	domain_name TEXT
	,registered TIMESTAMPTZ
	,unregistered TIMESTAMPTZ
	,EXCLUDE USING GIST (domain_name WITH =, tstzrange(registered, unregistered) WITH &&));
INSERT INTO
    domain (domain_name, registered, unregistered)
VALUES 
('duckduckgo.com', '2000-10-10', '2005-11-11')
,('duckduckgo.com', '2007-10-10', '2055-11-11')
,('google.com', '1999-10-10', '2010-11-11') 
,('google.com', '2015-10-10', NULL) 
,('bing.com', '2003-10-10', NULL)
,('yahoo.com', '1990-10-10', '2001-1-2')
,('seznam.cz', '2010-10-10', '2040-1-2')
RETURNING *;

DROP TABLE IF EXISTS domain_flag;
CREATE TABLE domain_flag  (
	domain_name TEXT
	,flagname TEXT
	,value BOOL
	,effective_range tstzrange);
INSERT INTO
	domain_flag
VALUES 
('duckduckgo.com', 'EXPIRED', FALSE, '[2015-06-06,2016-08-08]' )
,('google.com', 'OUTZONE', TRUE, '[2015-06-06,2016-06-06]')
,('bing.com', 'DELETE_CANDIDATE', FALSE, '[2015-06-06,]' )
,('duckduckgo.com', 'EXPIRED', FALSE, '[2017-06-06,]' )
,('yahoo.com', 'EXPIRED', FALSE, '[2017-06-06,]')
,('google.com', 'EXPIRED', TRUE, '[2005-06-06,2006-06-06]')
RETURNING *;

-- ``SELECT`` query which will return fully qualified domain name of domains which are currently 
-- (at the time query is run) registered and do not have and active (valid) expiration (``EXPIRED``) flag.
SELECT 
	domain_name
	FROM 
		(SELECT
			domain_name
			FROM
				domain 
			WHERE
				tstzrange(registered, unregistered) @> NOW()
		) as unused_mandatory_alias
INTERSECT
SELECT 
	domain_name
	FROM 
		domain_flag
	WHERE 
		NOT(flagname = 'EXPIRED' AND effective_range @> NOW());


-- ``SELECT`` query which will return fully qualified domain name of domains which have had active (valid)
--  ``EXPIRED`` and ``OUTZONE`` flags (means both flags and not necessarily at the same time) in the past (relative to the query run time).
SELECT
	domain_name
FROM
	domain_flag
WHERE
	flagname = 'EXPIRED'
INTERSECT
SELECT 
	domain_name
FROM
	domain_flag
WHERE
	 flagname = 'OUTZONE';



-- Proposal:
-- 1. Create REGEX constraint that validates domain_name.
-- 2. 'Registered' date should be between date of oldest record and NOW(), unless you can register with future date.
-- 3. domain_flag table should only accept domain flags from domains, that are in domain table.
-- 4. domain_flag table should only accept flags, whose effective_range is subset of registered-unregistered range.
