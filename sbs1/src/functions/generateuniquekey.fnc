CREATE OR REPLACE FUNCTION generateuniquekey (identifier IN CHAR)
    RETURN VARCHAR2
/* =========================================================================
   ToDo.
   ---------------------------------------------------------------------- */
IS
BEGIN
    IF identifier = 'B'
    THEN
        RETURN LPAD (bdetail_seq.NEXTVAL, 10, '0');
    ELSE
        RETURN LPAD (general_seq.NEXTVAL, 10, '0');
    END IF;
END generateuniquekey;
/