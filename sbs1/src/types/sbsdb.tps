/* =========================================================================
   SBSDB Specific Type Declarations - Start.
   ---------------------------------------------------------------------- */

CREATE OR REPLACE TYPE sbsdb_api_group_trans_ot FORCE AS OBJECT
(
    api_group VARCHAR2 (128),
    api_scope VARCHAR2 (128),
    package_impl_name VARCHAR2 (128),
    package_name VARCHAR2 (128),
    method_name VARCHAR2 (128)
);
/

CREATE OR REPLACE TYPE sbsdb_api_group_trans_nt FORCE AS TABLE OF sbsdb_api_group_trans_ot;
/

--------------------------------------------------------------------------------

CREATE OR REPLACE TYPE sbsdb_api_scope_help_ot FORCE AS OBJECT
(
    api_scope VARCHAR2 (257),
    api_help_text VARCHAR2 (32767)
);
/

CREATE OR REPLACE TYPE sbsdb_api_scope_help_nt FORCE AS TABLE OF sbsdb_api_scope_help_ot;
/

--------------------------------------------------------------------------------

CREATE OR REPLACE TYPE sbsdb_api_scope_trans_ot FORCE AS OBJECT
(
    api_scope VARCHAR2 (128),
    package_impl_name VARCHAR2 (128),
    package_name VARCHAR2 (128),
    method_name VARCHAR2 (128)
);
/

CREATE OR REPLACE TYPE sbsdb_api_scope_trans_nt FORCE AS TABLE OF sbsdb_api_scope_trans_ot;
/

--------------------------------------------------------------------------------

/* -------------------------------------------------------------------------
   SBSDB Specific Type Declarations - End.
   ====================================================================== */
