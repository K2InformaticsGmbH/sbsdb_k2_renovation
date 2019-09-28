CREATE OR REPLACE PROCEDURE sbs1_admin.configure_for_test
/* =========================================================================
   TODO.
   ---------------------------------------------------------------------- */
IS
    c_prod_nas_path                         VARCHAR2 (100) := '\sbs-prod\'; -- 011SO -- 010SO -- 009SO -- 006SO -- 003SO
    c_test_nas_path                         VARCHAR2 (100) := '\sbs-stag\'; -- 011SO -- 010SO -- 009SO -- 006SO -- 003SO
BEGIN
    -- RETURN;     -- comment out this line to use the procedure

    UPDATE packing
    SET    pac_esid = 'I'
    WHERE  pac_esid = 'A'; -- 004SO

    UPDATE packing
    SET    pac_outputdir = REPLACE (pac_outputdir, c_prod_nas_path, c_test_nas_path),
           pac_archivedir = REPLACE (pac_archivedir, c_prod_nas_path, c_test_nas_path); -- 006SO-- 004SO -- 003SO

    UPDATE packing
    SET    pac_archivedir = NULL,
           pac_archivestatistic = 0
    WHERE  pac_archivedir NOT LIKE c_test_nas_path || '%'; -- 006SO

    UPDATE notificationtempl
    SET    not_adrto = 'paul.marty@swisscom.com;MUS-LU.Mobile-Net@swisscom.com',
           not_adrcc = NULL,
           not_adrbcc = NULL; -- 005SO -- 004SO

    UPDATE sta_config
    SET    stac_archivedir = REPLACE (stac_archivedir, c_prod_nas_path, c_test_nas_path); -- 006SO-- 004SO -- 003SO

    UPDATE sta_config
    SET    stac_archivedir = REPLACE (stac_archivedir, c_prod_nas_path, c_test_nas_path); -- 006SO-- 004SO

    UPDATE sta_directory
    SET    stad_path = REPLACE (stad_path, c_prod_nas_path, c_test_nas_path),
           stad_mover = REPLACE (stad_mover, c_prod_nas_path, c_test_nas_path); -- 006SO-- 004SO -- 003SO

    UPDATE sta_directory
    SET    stad_path = REPLACE (stad_path, c_prod_nas_path, c_test_nas_path),
           stad_mover = REPLACE (stad_mover, c_prod_nas_path, c_test_nas_path); -- 006SO-- 004SO

    COMMIT WORK;

    RETURN; -- comment out this line to use the procedure

    -- 007SO

    EXECUTE IMMEDIATE 'truncate table BDETAIL';

    EXECUTE IMMEDIATE 'truncate table BDETAIL1';

    EXECUTE IMMEDIATE 'truncate table BDETAIL2';

    EXECUTE IMMEDIATE 'truncate table BDETAIL4';

    EXECUTE IMMEDIATE 'truncate table BDETAIL6';

    EXECUTE IMMEDIATE 'truncate table BDETAIL7';

    EXECUTE IMMEDIATE 'truncate table BDETAIL9';

    EXECUTE IMMEDIATE 'truncate table REVI_CONTENT_DEL';

    EXECUTE IMMEDIATE 'truncate table REVI_CONTENT_SUB';

    EXECUTE IMMEDIATE 'truncate table REVI_MMS';

    EXECUTE IMMEDIATE 'truncate table REVI_PRE';

    EXECUTE IMMEDIATE 'truncate table REVI_SMS';

    EXECUTE IMMEDIATE 'truncate table REVIPRE_MMS';

    EXECUTE IMMEDIATE 'truncate table REVIPRE_SMS';

    EXECUTE IMMEDIATE 'truncate table SMS_IW_MT_ARCH';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE LOG_DEBUG';

    EXECUTE IMMEDIATE 'truncate table REVA_DEBUG';

    EXECUTE IMMEDIATE 'truncate table STA_DEBUG';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE WARNING';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEST';

    EXECUTE IMMEDIATE 'truncate table TEST1';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE SCRIPT';

    EXECUTE IMMEDIATE 'truncate table ALL_CC_NDC';

    EXECUTE IMMEDIATE 'truncate table ALL_MCC_MNC';

    EXECUTE IMMEDIATE 'truncate table CODE';

    EXECUTE IMMEDIATE 'truncate table CONIOTE';

    EXECUTE IMMEDIATE 'truncate table PROXY';

    EXECUTE IMMEDIATE 'truncate table SRAS';

    EXECUTE IMMEDIATE 'truncate table IMSIRANGE';

    EXECUTE IMMEDIATE 'truncate table IRANGE';

    EXECUTE IMMEDIATE 'truncate table KEYWORD';

    EXECUTE IMMEDIATE 'truncate table LONGIDHISTDET';

    EXECUTE IMMEDIATE 'truncate table LONGIDMAP';

    EXECUTE IMMEDIATE 'truncate table MMSCADD';

    EXECUTE IMMEDIATE 'truncate table MMSPRICE';

    EXECUTE IMMEDIATE 'truncate table MMSRPRICE';

    EXECUTE IMMEDIATE 'truncate table NBRRANGE';

    EXECUTE IMMEDIATE 'truncate table NUMBERRANGE';

    EXECUTE IMMEDIATE 'truncate table PRMODELENTRY';

    EXECUTE IMMEDIATE 'truncate table PRMODELVERTRANS';

    EXECUTE IMMEDIATE 'truncate table SBS0_STATS';

    EXECUTE IMMEDIATE 'truncate table STA_JOBANALYZE';

    EXECUTE IMMEDIATE 'truncate table STA_JOBOUTPUT';

    EXECUTE IMMEDIATE 'truncate table STA_JOBPARAM';

    EXECUTE IMMEDIATE 'truncate table STA_JOBSQL';

    EXECUTE IMMEDIATE 'truncate table UAMLOG';

    EXECUTE IMMEDIATE 'truncate table BDCONSOLIDATION';

    EXECUTE IMMEDIATE 'truncate table ROCONSOLIDATION';

    EXECUTE IMMEDIATE 'truncate table DGTICONSOL';

    EXECUTE IMMEDIATE 'truncate table OGTICONSOL';

    EXECUTE IMMEDIATE 'truncate table MMSCONSOLIDATION';

    EXECUTE IMMEDIATE 'truncate table TPMCONSOL';

    EXECUTE IMMEDIATE 'truncate table TPMCONSOL_BAD';

    EXECUTE IMMEDIATE 'truncate table TRCONSOL';

    EXECUTE IMMEDIATE 'truncate table IWOCOUNTER';

    EXECUTE IMMEDIATE 'truncate table IWTCOUNTER';

    EXECUTE IMMEDIATE 'truncate table REVA_COUNTER';

    EXECUTE IMMEDIATE 'truncate table ISCONSOL';

    EXECUTE IMMEDIATE 'truncate table ISMSTAT';

    EXECUTE IMMEDIATE 'truncate table ISSUE';

    EXECUTE IMMEDIATE 'truncate table ISC_AGGREGATION';

    EXECUTE IMMEDIATE 'truncate table SETDETAIL';

    EXECUTE IMMEDIATE 'truncate table RACACHE';

    EXECUTE IMMEDIATE 'alter table STA_JOBSQL disable constraint FK_STA_JOBS_REF_JOBSQ_STA_JOB';

    EXECUTE IMMEDIATE 'alter table STA_JOBOUTPUT disable constraint FK_STA_JOBO_REF_STAJO_STA_JOB';

    EXECUTE IMMEDIATE 'alter table STA_JOBPARAM disable constraint FK_STA_JOBP_REF_JOBJO_STA_JOB';

    EXECUTE IMMEDIATE 'truncate table STA_JOB';

    EXECUTE IMMEDIATE 'alter table STA_JOBSQL enable constraint FK_STA_JOBS_REF_JOBSQ_STA_JOB';

    EXECUTE IMMEDIATE 'alter table STA_JOBOUTPUT enable constraint FK_STA_JOBO_REF_STAJO_STA_JOB';

    EXECUTE IMMEDIATE 'alter table STA_JOBPARAM enable constraint FK_STA_JOBP_REF_JOBJO_STA_JOB';

    EXECUTE IMMEDIATE 'alter table SETDETAIL disable constraint FK_SETDETAI_REF_1892_SETTLING';

    EXECUTE IMMEDIATE 'alter table SETTLING disable constraint FK_SETTLING_REF_1145_SETTLING';

    EXECUTE IMMEDIATE 'truncate table SETTLING';

    EXECUTE IMMEDIATE 'alter table SETDETAIL enable constraint FK_SETDETAI_REF_1892_SETTLING';

    EXECUTE IMMEDIATE 'alter table SETTLING enable constraint FK_SETTLING_REF_1145_SETTLING';

    EXECUTE IMMEDIATE 'alter table PRMODELENTRY disable constraint FK_PRMODELE_REF_131_PRMODELV';

    EXECUTE IMMEDIATE 'alter table SETDETAIL disable constraint FK_SETDETAI_REF_24272_PRMODELV';

    EXECUTE IMMEDIATE 'alter table BDCONSOLIDATION disable constraint FK_BDCONSOL_REF_24261_PRMODELV';

    EXECUTE IMMEDIATE 'alter table PRMODELVERTRANS disable constraint FK_PRMODELV_REF_20126_PRMODELV';

    EXECUTE IMMEDIATE 'alter table BDETAIL disable constraint FK_BDETAIL_REF_119_PRMODELV';

    EXECUTE IMMEDIATE 'truncate table PRMODELVER';

    EXECUTE IMMEDIATE 'alter table PRMODELENTRY enable constraint FK_PRMODELE_REF_131_PRMODELV';

    EXECUTE IMMEDIATE 'alter table SETDETAIL enable constraint FK_SETDETAI_REF_24272_PRMODELV';

    EXECUTE IMMEDIATE 'alter table BDCONSOLIDATION enable constraint FK_BDCONSOL_REF_24261_PRMODELV';

    EXECUTE IMMEDIATE 'alter table PRMODELVERTRANS enable constraint FK_PRMODELV_REF_20126_PRMODELV';

    EXECUTE IMMEDIATE 'alter table BDETAIL enable constraint FK_BDETAIL_REF_119_PRMODELV';

    EXECUTE IMMEDIATE 'truncate table CONTENTSERVICE';

    EXECUTE IMMEDIATE 'alter table CONIOTE disable constraint FK_CONIOTE_REFER_418_CONIOT';

    EXECUTE IMMEDIATE 'truncate table CONIOT';

    EXECUTE IMMEDIATE 'alter table CONIOTE enable constraint FK_CONIOTE_REFER_418_CONIOT';

    EXECUTE IMMEDIATE 'alter table CONTENTSERVICE disable constraint FK_CONTENTS_REFE_377_CONTRACT';

    EXECUTE IMMEDIATE 'alter table CONIOT disable constraint FK_CONIOT_REFE_419_CONTRACT';

    EXECUTE IMMEDIATE 'alter table ISSUE disable constraint FK_ISSUE_REF_44635_CONTRACT';

    EXECUTE IMMEDIATE 'alter table KEYWORD disable constraint FK_KEYWORD_REF_57110_CONTRACT';

    EXECUTE IMMEDIATE 'alter table MMSCADD disable constraint FK_MMSCADD_REF_30882_CONTRACT';

    EXECUTE IMMEDIATE 'alter table SETTLING disable constraint FK_SETTLING_REF_1142_CONTRACT';

    EXECUTE IMMEDIATE 'truncate table CONTRACT';

    EXECUTE IMMEDIATE 'alter table CONTENTSERVICE enable constraint FK_CONTENTS_REFE_377_CONTRACT';

    EXECUTE IMMEDIATE 'alter table CONIOT enable constraint FK_CONIOT_REFE_419_CONTRACT';

    EXECUTE IMMEDIATE 'alter table ISSUE enable constraint FK_ISSUE_REF_44635_CONTRACT';

    EXECUTE IMMEDIATE 'alter table KEYWORD enable constraint FK_KEYWORD_REF_57110_CONTRACT';

    EXECUTE IMMEDIATE 'alter table SETTLING enable constraint FK_SETTLING_REF_1142_CONTRACT';

    EXECUTE IMMEDIATE 'alter table PRMODELVER disable constraint FK_PRMODELV_REF_122_PRMODEL';

    EXECUTE IMMEDIATE 'alter table CONTRACT disable constraint FK_CONTRACT_REF_24266_PRMODEL';

    EXECUTE IMMEDIATE 'truncate table PRMODEL';

    EXECUTE IMMEDIATE 'alter table PRMODELVER enable constraint FK_PRMODELV_REF_122_PRMODEL';

    EXECUTE IMMEDIATE 'alter table CONTRACT enable constraint FK_CONTRACT_REF_24266_PRMODEL';

    EXECUTE IMMEDIATE 'alter table CONTRACT disable constraint FK_CONTRACT_R_292_MMSCC';

    EXECUTE IMMEDIATE 'truncate table MMSCC';

    EXECUTE IMMEDIATE 'alter table CONTRACT enable constraint FK_CONTRACT_R_292_MMSCC';

    EXECUTE IMMEDIATE 'alter table LONGIDHISTDET disable constraint FK_LONGIDHI_R_438_LONGIDHI';

    EXECUTE IMMEDIATE 'truncate table LONGIDHIST';

    EXECUTE IMMEDIATE 'alter table LONGIDHISTDET enable constraint FK_LONGIDHI_R_438_LONGIDHI';

    EXECUTE IMMEDIATE 'alter table SETDETAIL disable constraint FK_SETDETAI_RE_453_LONGID';

    EXECUTE IMMEDIATE 'alter table LONGIDHISTDET disable constraint FK_LONGIDHI_R_439_LONGID';

    EXECUTE IMMEDIATE 'alter table LONGIDMAP disable constraint FK_LONGIDMA_R_434_LONGID';

    EXECUTE IMMEDIATE 'alter table LONGIDMAP disable constraint FK_LONGIDMA_R_433_LONGID';

    EXECUTE IMMEDIATE 'truncate table LONGID';

    EXECUTE IMMEDIATE 'alter table SETDETAIL enable constraint FK_SETDETAI_RE_453_LONGID';

    EXECUTE IMMEDIATE 'alter table LONGIDHISTDET enable constraint FK_LONGIDHI_R_439_LONGID';

    EXECUTE IMMEDIATE 'alter table LONGIDMAP enable constraint FK_LONGIDMA_R_434_LONGID';

    EXECUTE IMMEDIATE 'alter table LONGIDMAP enable constraint FK_LONGIDMA_R_433_LONGID';

    EXECUTE IMMEDIATE 'truncate table ENPLAROUTING';

    EXECUTE IMMEDIATE 'alter table NBRRANGE disable constraint FK_NBRRANGE_REF_49037_CARRIER';

    EXECUTE IMMEDIATE 'alter table IRANGE disable constraint FK_IRANGE_REF_35220_CARRIER';

    EXECUTE IMMEDIATE 'truncate table CARRIER';

    EXECUTE IMMEDIATE 'alter table NBRRANGE enable constraint FK_NBRRANGE_REF_49037_CARRIER';

    EXECUTE IMMEDIATE 'alter table IRANGE enable constraint FK_IRANGE_REF_35220_CARRIER';

    EXECUTE IMMEDIATE 'alter table IWTCOUNTER disable constraint FK_IWTCOUNT_REF_13685_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 disable constraint FK_BDETAIL9_REF_26632_BOHEADE1';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 disable constraint FK_BDETAIL9_REF_26632_BOHEADE2';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 disable constraint FK_BDETAIL9_REF_26631_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL disable constraint FK_BDETAIL_REF_11648_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL disable constraint FK_BDETAIL_REF_11647_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL disable constraint FK_BDETAIL_REF_104_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 disable constraint FK_BDETAIL1_REF_14648_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 disable constraint FK_BDETAIL1_REF_14647_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 disable constraint FK_BDETAIL1_REF_14646_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 disable constraint FK_BDETAIL2_REF104871_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 disable constraint FK_BDETAIL2_REF104870_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 disable constraint FK_BDETAIL2_REF104869_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 disable constraint FK_BDETAIL4_REF_92640_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 disable constraint FK_BDETAIL4_REF_92639_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 disable constraint FK_BDETAIL4_REF_92638_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 disable constraint FK_BDETAIL6_RF_173507_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 disable constraint FK_BDETAIL6_RF_173503_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 disable constraint FK_BDETAIL6_RF_173499_BOHEADER';

    EXECUTE IMMEDIATE 'truncate table BOHEADER';

    EXECUTE IMMEDIATE 'alter table IWTCOUNTER enable constraint FK_IWTCOUNT_REF_13685_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 enable constraint FK_BDETAIL9_REF_26632_BOHEADE1';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 enable constraint FK_BDETAIL9_REF_26632_BOHEADE2';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 enable constraint FK_BDETAIL9_REF_26631_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL enable constraint FK_BDETAIL_REF_11648_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL enable constraint FK_BDETAIL_REF_11647_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL enable constraint FK_BDETAIL_REF_104_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 enable constraint FK_BDETAIL1_REF_14648_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 enable constraint FK_BDETAIL1_REF_14647_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 enable constraint FK_BDETAIL1_REF_14646_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 enable constraint FK_BDETAIL2_REF104871_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 enable constraint FK_BDETAIL2_REF104870_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 enable constraint FK_BDETAIL2_REF104869_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 enable constraint FK_BDETAIL4_REF_92640_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 enable constraint FK_BDETAIL4_REF_92639_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 enable constraint FK_BDETAIL4_REF_92638_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 enable constraint FK_BDETAIL6_RF_173507_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 enable constraint FK_BDETAIL6_RF_173503_BOHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 enable constraint FK_BDETAIL6_RF_173499_BOHEADER';

    EXECUTE IMMEDIATE 'truncate table VSHEADER';

    EXECUTE IMMEDIATE 'alter table VSHEADER disable constraint FK_VSHEADER_REFER_430_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL7 disable constraint FK_BDETAIL7_REF_369_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 disable constraint FK_BDETAIL9_REF_26631_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL disable constraint FK_BDETAIL_REF_98_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 disable constraint FK_BDETAIL1_REF_14645_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 disable constraint FK_BDETAIL2_REF_94856_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 disable constraint FK_BDETAIL4_REF_92635_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 disable constraint FK_BDETAIL6_REF_17349_BIHEADER';

    EXECUTE IMMEDIATE 'truncate table BIHEADER';

    EXECUTE IMMEDIATE 'alter table VSHEADER enable constraint FK_VSHEADER_REFER_430_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL7 enable constraint FK_BDETAIL7_REF_369_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL9 enable constraint FK_BDETAIL9_REF_26631_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL enable constraint FK_BDETAIL_REF_98_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL1 enable constraint FK_BDETAIL1_REF_14645_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL2 enable constraint FK_BDETAIL2_REF_94856_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL4 enable constraint FK_BDETAIL4_REF_92635_BIHEADER';

    EXECUTE IMMEDIATE 'alter table BDETAIL6 enable constraint FK_BDETAIL6_REF_17349_BIHEADER';

    EXECUTE IMMEDIATE 'truncate table SYSPARAMETERS';

    EXECUTE IMMEDIATE 'alter table CONTENTSERVICE disable constraint FK_CONTENTS_REF_357_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table CONTENTSERVICE disable constraint FK_CONTENTS_REF_356_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS disable constraint FK_SYSPARAM_REF_43130_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS disable constraint FK_SYSPARAM_REF_43129_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS disable constraint FK_SYSPARAM_REF_43128_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS disable constraint FK_SYSPARAM_REF_43127_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS disable constraint FK_SYSPARAM_REF_43126_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table ISSUE disable constraint FK_ISSUE_REF_43118_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table ISSUE disable constraint FK_ISSUE_REFERENCE_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_41600_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table CONTRACT disable constraint FK_CONTRACT_REF_586_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table LONGIDHIST disable constraint FK_LONGIDHI_R_437_ACCOUNT';

    EXECUTE IMMEDIATE 'truncate table ACCOUNT';

    EXECUTE IMMEDIATE 'alter table CONTENTSERVICE enable constraint FK_CONTENTS_REF_357_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table CONTENTSERVICE enable constraint FK_CONTENTS_REF_356_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS enable constraint FK_SYSPARAM_REF_43130_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS enable constraint FK_SYSPARAM_REF_43129_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS enable constraint FK_SYSPARAM_REF_43128_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS enable constraint FK_SYSPARAM_REF_43127_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table SYSPARAMETERS enable constraint FK_SYSPARAM_REF_43126_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table ISSUE enable constraint FK_ISSUE_REF_43118_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table ISSUE enable constraint FK_ISSUE_REFERENCE_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_41600_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table CONTRACT enable constraint FK_CONTRACT_REF_586_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table LONGIDHIST enable constraint FK_LONGIDHI_R_437_ACCOUNT';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_3323_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_3320_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_3314_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_3311_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_3308_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_3305_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_2055_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT disable constraint FK_ACCOUNT_REF_2054_ADDRESS';

    EXECUTE IMMEDIATE 'truncate table ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_3323_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_3320_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_3314_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_3311_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_3308_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_3305_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_2055_ADDRESS';

    EXECUTE IMMEDIATE 'alter table ACCOUNT enable constraint FK_ACCOUNT_REF_2054_ADDRESS';

    COMMIT WORK;
END configure_for_test;
/