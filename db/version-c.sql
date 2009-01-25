--- WannaBuild Database Schema for PostgreSQL                        -*- sql -*-
--- Debian version type and operators
---
--- Code derived from Dpkg::Version:
--- Copyright © Colin Watson <cjwatson@debian.org>
--- Copyright © Ian Jackson <iwj@debian.org>
--- Copyright © 2007 by Don Armstrong <don@donarmstrong.com>
---
--- PostgreSQL SQL, PL/pgSQL and PL/Perl:
--- Copyright © 2008 Roger Leigh <rleigh@debian.org>
---
--- This program is free software: you can redistribute it and/or modify
--- it under the terms of the GNU General Public License as published by
--- the Free Software Foundation, either version 2 of the License, or
--- (at your option) any later version.
---
--- This program is distributed in the hope that it will be useful, but
--- WITHOUT ANY WARRANTY; without even the implied warranty of
--- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--- General Public License for more details.
---
--- You should have received a copy of the GNU General Public License
--- along with this program.  If not, see
--- <http://www.gnu.org/licenses/>.

CREATE TYPE debversion;

CREATE OR REPLACE FUNCTION debversionin(cstring)
RETURNS debversion
AS 'textin'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION debversionout(debversion)
RETURNS cstring
AS 'textout'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION debversionrecv(internal)
RETURNS debversion
AS 'textrecv'
LANGUAGE internal STABLE STRICT;

CREATE OR REPLACE FUNCTION debversionsend(debversion)
RETURNS bytea
AS 'textsend'
LANGUAGE internal STABLE STRICT;

CREATE TYPE debversion (
    INPUT          = debversionin,
    OUTPUT         = debversionout,
    RECEIVE        = debversionrecv,
    SEND           = debversionsend,
    INTERNALLENGTH = VARIABLE,
    STORAGE        = extended,
    -- make it a non-preferred member of string type category
    CATEGORY       = 'S',
    PREFERRED      = false
);

COMMENT ON TYPE debversion IS 'Debian package version number';

CREATE OR REPLACE FUNCTION debversion(bpchar)
RETURNS debversion
AS 'rtrim1'
LANGUAGE internal IMMUTABLE STRICT;

CREATE CAST (debversion AS text)    WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (debversion AS varchar) WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (debversion AS bpchar)  WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (text AS debversion)    WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (varchar AS debversion) WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (bpchar AS debversion)  WITH FUNCTION debversion(bpchar);

CREATE OR REPLACE FUNCTION debversion_cmp (version1 debversion,
       	  	  	   		   version2 debversion)
  RETURNS integer AS 'debversion', 'debversion_cmp'
  LANGUAGE C
  IMMUTABLE STRICT;
COMMENT ON FUNCTION debversion_cmp (debversion, debversion)
  IS 'Compare Debian versions';

CREATE OR REPLACE FUNCTION debversion_eq (version1 debversion,
       	  	  	   		  version2 debversion)
  RETURNS boolean AS 'debversion', 'debversion_eq'
  LANGUAGE C
  IMMUTABLE STRICT;
COMMENT ON FUNCTION debversion_eq (debversion, debversion)
  IS 'debversion equal';

CREATE OR REPLACE FUNCTION debversion_ne (version1 debversion,
       	  	  	   		  version2 debversion)
  RETURNS boolean AS 'debversion', 'debversion_ne'
  LANGUAGE C
  IMMUTABLE STRICT;
COMMENT ON FUNCTION debversion_ne (debversion, debversion)
  IS 'debversion not equal';

CREATE OR REPLACE FUNCTION debversion_lt (version1 debversion,
       	  	  	   		  version2 debversion)
  RETURNS boolean AS 'debversion', 'debversion_lt'
  LANGUAGE C
  IMMUTABLE STRICT;
COMMENT ON FUNCTION debversion_lt (debversion, debversion)
  IS 'debversion less-than';

CREATE OR REPLACE FUNCTION debversion_gt (version1 debversion,
       	  	  	   		  version2 debversion)
  RETURNS boolean AS 'debversion', 'debversion_gt'
  LANGUAGE C
  IMMUTABLE STRICT;
COMMENT ON FUNCTION debversion_gt (debversion, debversion)
  IS 'debversion greater-than';

CREATE OR REPLACE FUNCTION debversion_le (version1 debversion,
       	  	  	   		  version2 debversion)
  RETURNS boolean AS 'debversion', 'debversion_le'
  LANGUAGE C
  IMMUTABLE STRICT;
COMMENT ON FUNCTION debversion_le (debversion, debversion)
  IS 'debversion less-than-or-equal';

CREATE OR REPLACE FUNCTION debversion_ge (version1 debversion,
       	  	  	   		  version2 debversion)
  RETURNS boolean AS 'debversion', 'debversion_ge'
  LANGUAGE C
  IMMUTABLE STRICT;
COMMENT ON FUNCTION debversion_ge (debversion, debversion)
  IS 'debversion greater-than-or-equal';

CREATE OPERATOR = (
  PROCEDURE = debversion_eq,
  LEFTARG = debversion,
  RIGHTARG = debversion,
  COMMUTATOR = =,
  NEGATOR = !=
);
COMMENT ON OPERATOR = (debversion, debversion)
  IS 'debversion equal';

CREATE OPERATOR != (
  PROCEDURE = debversion_ne,
  LEFTARG = debversion,
  RIGHTARG = debversion,
  COMMUTATOR = !=,
  NEGATOR = =
);
COMMENT ON OPERATOR != (debversion, debversion)
  IS 'debversion not equal';

CREATE OPERATOR < (
  PROCEDURE = debversion_lt,
  LEFTARG = debversion,
  RIGHTARG = debversion,
  COMMUTATOR = >,
  NEGATOR = >=
);
COMMENT ON OPERATOR < (debversion, debversion)
  IS 'debversion less-than';

CREATE OPERATOR > (
  PROCEDURE = debversion_gt,
  LEFTARG = debversion,
  RIGHTARG = debversion,
  COMMUTATOR = <,
  NEGATOR = >=
);
COMMENT ON OPERATOR > (debversion, debversion)
  IS 'debversion greater-than';

CREATE OPERATOR <= (
  PROCEDURE = debversion_le,
  LEFTARG = debversion,
  RIGHTARG = debversion,
  COMMUTATOR = >=,
  NEGATOR = >
);
COMMENT ON OPERATOR <= (debversion, debversion)
  IS 'debversion less-than-or-equal';

CREATE OPERATOR >= (
  PROCEDURE = debversion_ge,
  LEFTARG = debversion,
  RIGHTARG = debversion,
  COMMUTATOR = <=,
  NEGATOR = <
);
COMMENT ON OPERATOR >= (debversion, debversion)
  IS 'debversion greater-than-or-equal';

CREATE OPERATOR CLASS debversion_ops
DEFAULT FOR TYPE DEBVERSION USING btree AS
    OPERATOR    1   <  (debversion, debversion),
    OPERATOR    2   <= (debversion, debversion),
    OPERATOR    3   =  (debversion, debversion),
    OPERATOR    4   >= (debversion, debversion),
    OPERATOR    5   >  (debversion, debversion),
    FUNCTION    1   debversion_cmp(debversion, debversion);

