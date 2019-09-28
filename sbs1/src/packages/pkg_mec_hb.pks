CREATE OR REPLACE PACKAGE sbs1_admin.pkg_mec_hb
IS
    /*<>
    Message Event Consolidation DUMMY package for SBS1 Database.
    Referenced by PKG_MEC_IC

    MODIFICATION HISTORY (for details see VSS repository)
    Person      Date        Comments
    000SO       13.02.2019  HASH:D15EFD1F34D581259C5923104E63C7C0 pkg_mec_hb.pkb
    */

    TYPE tbillingtables IS RECORD
    ( -- 009AA billing tables
        bdetailisrv VARCHAR2 (10) := 'BDETAIL',
        bdetailsmsc VARCHAR2 (10) := 'BDETAIL1', -- and BDETAIL2
        bdetailmsc VARCHAR2 (10) := 'BDETAIL4',
        bdetailmmsc VARCHAR2 (10) := 'BDETAIL6',
        bdetailm2m VARCHAR2 (10) := 'BDETAIL7', -- 474SO
        bdetailufih VARCHAR2 (10) := 'BDETAIL9' -- 233SO
    );

    -- common billing fields used in most CDR types
    TYPE tcdrinfo IS RECORD
    (
        aaatopstopupdated VARCHAR2 (1),
        amountcustomer NUMBER (12, 4), -- 031AA    -- Number(12,4)
        ascii0 VARCHAR2 (4000),
        attempts NUMBER (10), -- 475SO
        billrate VARCHAR2 (10), -- Number(3)
        billtext VARCHAR2 (254), -- isrv billtext
        billingdetailid VARCHAR2 (10),
        billingdomain VARCHAR2 (10), -- 144AA
        billingtime VARCHAR2 (30), -- isrv
        -- DiaResponse             Varchar2(4000),                                 -- 514SO
        diaresult VARCHAR2 (10), -- 514SO
        -- CallbackNumber          Varchar2(20),                                   -- 514SO
        -- CallbackAddress         Varchar2(254),                                  -- 514SO
        -- CallbackPresence        Varchar2(20),                                   -- 514SO
        campaign VARCHAR2 (32), -- 418SO
        category VARCHAR2 (254), -- 193SO
        cdrbilled VARCHAR2 (2), -- 465SO -- 110SO
        cdrrated NUMBER (1), -- 110SO
        cdrtypeid VARCHAR2 (10),
        cell VARCHAR2 (20),
        contractsubtype VARCHAR2 (10),
        datetime VARCHAR2 (30), -- 085AA
        deliveraddress VARCHAR2 (254), -- 514SO
        deliveraddressnpi VARCHAR2 (3), -- 514SO
        deliveraddresston VARCHAR2 (3), -- 514SO
        deliverattempt NUMBER (8), -- 514SO
        deliveresmeid VARCHAR2 (6), -- 514SO
        delivergti VARCHAR2 (20),
        delivergtiopkey VARCHAR2 (10), -- 117SO
        deliverimsi VARCHAR2 (20),
        deliverip VARCHAR2 (50), -- 573SO -- 514SO
        delivermicros VARCHAR2 (20), -- 514SO
        deliveropkey VARCHAR2 (10), -- 523SO -- 117SO
        deliverpid VARCHAR2 (3),
        delivertime VARCHAR2 (30),
        delivertype NUMBER (2),
        dser VARCHAR2 (40), -- 493SO
        errorcode VARCHAR2 (20), -- 514SO
        errorid VARCHAR2 (10),
        errorparameter VARCHAR2 (20), -- 175SO
        errortype VARCHAR2 (20), -- 514SO
        eventdisposition VARCHAR2 (10), -- Number(8)
        foreignrecipient VARCHAR2 (1),
        gart VARCHAR2 (10), -- 416SO
        imei VARCHAR2 (20), -- 017SO
        imsi VARCHAR2 (20),
        incominginterfaceid VARCHAR2 (254), -- 136SO
        info VARCHAR2 (254),
        interworkingamount NUMBER (12, 4), -- 528SO
        interworkingapmn VARCHAR2 (10), -- 528SO
        interworkingcase VARCHAR2 (1), -- NULL/0=notChargeable/1=Chargeable
        interworkingcontractid VARCHAR2 (10),
        interworkingcurrency VARCHAR2 (3), -- 528SO
        interworkingdirection VARCHAR2 (1), -- 528SO
        interworkingscenario VARCHAR2 (1), -- 528SO
        interworkingstate VARCHAR2 (1), -- 135SO temp variable (A=active I=Inactive)
        isgenerated NUMBER (1), -- 342SO
        ishomerouted BOOLEAN, -- 342SO
        ishomeroutedonnet BOOLEAN, -- 563SO
        lang VARCHAR2 (10),
        legacytermindicator NUMBER (8), -- 153SO
        location VARCHAR2 (80), -- 425SO
        mappingstateid VARCHAR2 (1),
        messageid VARCHAR2 (40),
        messagetype VARCHAR2 (10),
        mmsdestinationzoneid VARCHAR2 (10), -- 076AA mmsc
        mmsroamingcontractid VARCHAR2 (10), -- no input / output MEC local variable only
        mmsroamingzoneid1 VARCHAR2 (10), -- 107SO -- 076AA mmsc
        mmssizezoneid VARCHAR2 (10), -- 076AA mmsc
        moroamingpromotion NUMBER (1), -- 156SO
        mscidentificationid VARCHAR2 (20),
        msgpid VARCHAR2 (3), -- 514SO
        msgreference VARCHAR2 (40), -- 330SO
        msgstatus VARCHAR2 (20),
        msgreqtype VARCHAR2 (20), -- 514SO
        msgscheduletime VARCHAR2 (30), -- 514SO
        msgexpirytime VARCHAR2 (30), -- 514SO
        mtroamingpromotion NUMBER (1), -- 156SO
        network VARCHAR2 (10),
        nodename VARCHAR2 (64), -- 422SO
        onlinecharge NUMBER (12, 4), -- 316AT
        origaddress VARCHAR2 (254),
        origaddresston VARCHAR2 (3), -- 514SO
        origaddressnpi VARCHAR2 (3),
        origbillingid VARCHAR2 (20), -- 514SO
        origcharset VARCHAR2 (20), -- 514SO
        origdcs NUMBER (3), -- 558SO
        origesmeid VARCHAR2 (6), -- 514SO
        origgti VARCHAR2 (20),
        origgtiopkey VARCHAR2 (10), -- 117SO
        origimsi VARCHAR2 (20), -- 347SO
        origip VARCHAR2 (50), -- 573SO -- 514SO
        origmessageid VARCHAR2 (64), -- 559SO
        origsca VARCHAR2 (40), -- 494SO
        origsubmittime VARCHAR2 (30), -- 182SO
        output1 VARCHAR2 (4000),
        output2 VARCHAR2 (4000),
        outputhb VARCHAR2 (4000),
        packingid1 VARCHAR2 (10),
        packingid2 VARCHAR2 (10),
        packingidhb VARCHAR2 (10),
        partytocharge VARCHAR2 (254),
        paymentmethod NUMBER (2), -- 162SO
        pppser VARCHAR2 (40), -- 347SO
        prepaid VARCHAR2 (1),
        rarrshortidp2p VARCHAR2 (10), -- 174SO
        ratedunits VARCHAR2 (15), -- Number(15) -- 017SO
        ratingzoneid VARCHAR2 (10),
        recipaddress VARCHAR2 (254),
        recipaddressnpi VARCHAR2 (3),
        recipaddresston VARCHAR2 (3), -- 514SO
        recipcount NUMBER (8), -- 076AA
        recipimsi VARCHAR2 (20), -- 520SO
        recipindex NUMBER (4), -- 094SO
        requestid VARCHAR2 (20), -- 188SO
        requestitem VARCHAR2 (20), -- isrv itemno
        requestitemtext VARCHAR2 (254), -- isrv keyword
        requesttime VARCHAR2 (30),
        requesttype VARCHAR2 (10), -- Number(4)
        revenuesharemobile NUMBER (12, 4), -- 031AA    -- Number(12,4)
        revenueshareprovider NUMBER (12, 4), -- 031AA    -- Number(12,4)
        reversecharge NUMBER (1), -- 109SO
        roamingcgi VARCHAR2 (10), -- 432SO use for SMS too -- no input / output MEC local variable only
        roaminginfo VARCHAR2 (32), -- 307SO
        scaopkey VARCHAR2 (10), -- 509SO
        schedule1 VARCHAR2 (1),
        schedule2 VARCHAR2 (1),
        schedule3 VARCHAR2 (1),
        segid NUMBER (10), -- 514SO
        segcount NUMBER (10), -- 514SO
        seglength NUMBER (10), -- 038AA    -- Varchar2(10)
        service VARCHAR2 (32),
        servicecenteraddress VARCHAR2 (20),
        shortid VARCHAR2 (10), -- 004AA
        show VARCHAR2 (32), -- 418SO
        sinkname VARCHAR2 (254), -- 475SO
        sinktype VARCHAR2 (10), -- 475SO
        srcname VARCHAR2 (254), -- 475SO
        srctype VARCHAR2 (10), -- 475SO
        subscriptiontype VARCHAR2 (10), -- Varchar2(2) for MSC(bdetail4)
        submittime VARCHAR2 (30), -- 514SO
        submitmicros VARCHAR2 (20), -- 514SO
        submitgti VARCHAR2 (20), -- 514SO
        submitapp VARCHAR2 (20), -- 514SO
        tariffid VARCHAR2 (10), -- 224SO
        taxrate VARCHAR2 (10), -- 193SO
        testmode VARCHAR2 (10), -- 193SO
        thirdpartyid VARCHAR2 (10),
        transportclass VARCHAR2 (15), -- Number(12,4)
        transportclassiw VARCHAR2 (15), -- Number(12,4)
        transportcost NUMBER (12, 4), -- 117SO  was Varchar2(15)
        transportcount NUMBER (2), -- 237SO -- 016SO
        transportmedium VARCHAR2 (10), -- 144AA
        vascontractid VARCHAR2 (10),
        vaspricemodelversionid VARCHAR2 (10),
        vsmscid VARCHAR2 (20), -- 346SO
        origimei VARCHAR2 (20), -- 591SO
        deliverimei VARCHAR2 (20), -- 591SO
        origpaniheader VARCHAR2 (200), -- 591SO
        deliverpaniheader VARCHAR2 (200), -- 608SO
        delivermapgti VARCHAR2 (20), -- 609SO
        bioclientid VARCHAR2 (100), -- 629SO -- 623SO
        bioorigesmeid VARCHAR2 (6), -- 629SO -- 623SO
        biomsgreference VARCHAR2 (40), -- 629SO -- 623SO
        recipesmeid VARCHAR2 (6), -- 629SO -- 625SO
        biorequesttype NUMBER (3), -- 629SO -- 623SO
        cdrmonitored VARCHAR2 (1), -- 696SO
        packingidmon VARCHAR2 (10), -- 696SO
        outputmon VARCHAR2 (4000) -- 696SO
    ); -- 607SO

    -- MMSC billing fields (not going into MEC engine)                          --  002SO
    TYPE tcdrinfommsc IS RECORD
    (
        price VARCHAR2 (10),
        storageduration VARCHAR2 (10),
        layerspecificattr VARCHAR2 (10),
        deliveryreadrepreqind VARCHAR2 (10),
        numofnotification VARCHAR2 (10),
        numhomerecipients VARCHAR2 (10),
        numnonhomeincountryrecipients VARCHAR2 (10),
        numinternationalrecipients VARCHAR2 (10),
        numemailrecipients VARCHAR2 (10),
        numshortcoderecipients VARCHAR2 (10),
        messagesize VARCHAR2 (10),
        durationofstorage VARCHAR2 (10),
        messagepriority VARCHAR2 (254),
        messageclass VARCHAR2 (254),
        messagecontent VARCHAR2 (254),
        numofnotifications VARCHAR2 (10),
        numofconversions VARCHAR2 (10),
        mmsidentifier VARCHAR2 (254),
        fwdcopycopyind VARCHAR2 (10),
        contentrequestid VARCHAR2 (254),
        outgoinginterfaceid VARCHAR2 (254),
        deliveryreadreportreqind VARCHAR2 (10),
        freetext VARCHAR2 (1000),
        mm7linkedid VARCHAR2 (254),
        prepaidfreetext VARCHAR2 (254),
        useragent VARCHAR2 (254),
        transcodingid VARCHAR2 (254),
        cdrrecordtype VARCHAR2 (254),
        promotionplan VARCHAR2 (254),
        tariffclass VARCHAR2 (254)
    );

    TYPE tpackingidtemplates IS RECORD
    ( -- packing ids (templates)
        ascii0 packing.pac_id%TYPE := 'INTSBS',
        postpaidsms1ch packing.pac_id%TYPE := 'MOSMSCH',
        postpaidsms1chdel packing.pac_id%TYPE := 'mosmsch', -- 322SO Delayed delivery from cache
        postpaidsms1fl packing.pac_id%TYPE := 'MOSMSFL',
        postpaidsms1fldel packing.pac_id%TYPE := 'mosmsfl', -- 322SO Delayed delivery from cache
        postpaidsms3ch packing.pac_id%TYPE := 'MOSMS3CH', -- 574SO
        postpaidsms3chdel packing.pac_id%TYPE := 'mosms3ch', -- 574SO
        postpaidsms3fl packing.pac_id%TYPE := 'MOSMS3FL', -- 574SO
        postpaidsms3fldel packing.pac_id%TYPE := 'mosms3fl', -- 574SO
        postpaidsms4ch packing.pac_id%TYPE := 'MOSMS4CH', -- 593SO
        postpaidsms4chdel packing.pac_id%TYPE := 'mosms4ch', -- 593SO
        postpaidsms4fl packing.pac_id%TYPE := 'MOSMS4FL', -- 593SO
        postpaidsms4fldel packing.pac_id%TYPE := 'mosms4fl', -- 593SO
        postpaidsmsor packing.pac_id%TYPE := 'MOSMSOR', -- 432SO Outbound Roaming
        postpaidsmsordel packing.pac_id%TYPE := 'mosmsor', -- 433SO Delayed delivery from cache
        postpaidmms1ch packing.pac_id%TYPE := 'MOMMSCH', -- 108SO
        postpaidmms1chdel packing.pac_id%TYPE := 'mommsch', -- 322SO Delayed delivery from cache
        postpaidmms1fl packing.pac_id%TYPE := 'MOMMSFL', -- 108SO
        postpaidmms1fldel packing.pac_id%TYPE := 'mommsfl', -- 322SO Delayed delivery from cache
        postpaidcontentch packing.pac_id%TYPE := 'MOCONTCH',
        postpaidcontentchdel packing.pac_id%TYPE := 'mocontch', -- 322SO Delayed delivery from cache
        postpaidcontentfl packing.pac_id%TYPE := 'MOCONTFL',
        postpaidcontentfldel packing.pac_id%TYPE := 'mocontfl', -- 322SO Delayed delivery from cache
        prepaidisrvrap packing.pac_id%TYPE := 'RAPISRV', -- 318SO
        prepaidsmscrap packing.pac_id%TYPE := 'RAPSMSC', -- 330SO
        icbinterworking packing.pac_id%TYPE := 'ICB<MAPID>' -- 528SO
    );

    cascii0versionsmsn_01_00_01             VARCHAR2 (8) := '01.00.01'; -- 513SO
    cascii0versionsmsn_current              VARCHAR2 (8) := cascii0versionsmsn_01_00_01;

    cascii0versionufih_01_00_01             VARCHAR2 (8) := '01.00.01'; -- 233SO -- 130AA
    cascii0versionufih_current              VARCHAR2 (8) := cascii0versionufih_01_00_01;

    cascii0versionm2m_01_00_02              VARCHAR2 (8) := '01.00.02'; -- 508SO
    cascii0versionm2m_current               VARCHAR2 (8) := cascii0versionm2m_01_00_02;

    cascii0versionmsc_01_00_04              VARCHAR2 (8) := '01.00.04'; -- 182SO
    cascii0versionmsc_current               VARCHAR2 (8) := cascii0versionmsc_01_00_04;

    cascii0versionmmsc_01_00_05             VARCHAR2 (8) := '01.00.05'; -- 497SO
    cascii0versionmmsc_current              VARCHAR2 (8) := cascii0versionmmsc_01_00_05;
END pkg_mec_hb;
/