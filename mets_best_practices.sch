<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">

    <ns uri="http://www.loc.gov/METS/" prefix="mets"/>

    <!-- reviewed language: must (errors), should (a mixture of errors and warnings), typically (warnings) -->
    <!-- only things fully within the scope of the METS are validatable (can't validate external content
        or the semantics of external content -->


    <pattern id="mdsec-id">
        <!-- @ADMID must reference [techMD|sourceMD|rightsMD|digiprovMD]@ID

         The following elements support references to <techMD>, <sourceMD>, <rightsMD> and <digiprovMD>
         elements via an ADMID attribute: <metsHdr>, <dmdSec>, <techMD>, <sourceMD>, <rightsMD>,
         <digiprovMD>, <fileGrp>, <file>, <stream>, <div>, <area>, <behavior>
    -->
        <rule context="//mets:techMD | //mets:rightsMD | //mets:sourceMD | //mets:digiprovMD">
            <let name="thisid" value="@ID"/>

            <assert role="warn" id="mdsec-id-is-referenced"
                test="//*[tokenize(@ADMID, '\s+') = $thisid]"> WARNING: The <value-of
                    select="local-name(.)"/> with ID "<value-of select="$thisid"/>" is never
                referenced by a ADMID attribute </assert>
        </rule>
        <!-- [techMD|sourceMD|rightsMD|digiprovMD]@ID should be referenced by
        [metsHdr|dmdSec|techMD|sourceMD|rightsMD|digiprovMD|fileGrp|file|stream|div|area|behavior]@ADMID
        (Document for @ID: "its value should be referenced from one or more DMDID attributes (when the ID
        identifies a <dmdSec> element) or ADMID attributes (when the ID identifies a <techMD>, <sourceMD>,
        <rightsMD> or <digiprovMD> element) that are associated with other elements in the METS document." -->
        <rule context="//*[@ADMID]">
            <let name="theseids" value="tokenize(@ADMID, '\s+')"/>

            <assert id="admid-references-mdsec"
                test="count((//mets:techMD | //mets:rightsMD | //mets:sourceMD | //mets:digiprovMD)[$theseids = @ID]) = count($theseids)"
                > ERROR: Each ADMID in "<value-of select="@ADMID"/>" should reference a techMD,
                rightsMD, sourceMD, or digiprovMD /> </assert>
        </rule>
    </pattern>


    <!-- [techMD|dmdSec|sourceMD|rightsMD|digiprovMD]@ADMID should reference digiprovMD@ID?
        ("Typically used in this context to reference preservation metadata (digiprovMD) which applies to the current metadata.") -->

    <!-- mets@OBJID should be present: "Although this attribute is not required, it is strongly recommended." -->



    <pattern id="file-id">
        <!-- file@ID should be referenced by some [fptr|area]@FILEID -->
        <rule context="//mets:file">
            <let name="thisid" value="@ID"/>
            <assert role="warn" test="//*[@FILEID = $thisid]" id="file-id-is-referenced"> WARNING:
                The <value-of select="local-name(.)"/> with ID "<value-of select="$thisid"/>" is
                never referenced by a FILEID attribute </assert>
        </rule>

        <!-- @FILEID must reference file@ID -->
        <rule context="//*[@FILEID]">
            <let name="thisid" value="@FILEID"/>
            <assert test="//mets:file[@ID = $thisid]" id="fileid-references-file"> ERROR: The FILEID
                    "<value-of select="$thisid"/>" should reference a file, not a <value-of
                    select="local-name(//*[@ID = $thisid])"/>
            </assert>
        </rule>
    </pattern>


    <pattern id="dmdsec-id">
        <rule context="//mets:dmdSec">
            <let name="thisid" value="@ID"/>
            <assert role="warn" id="dmd-id-is-referenced"
                test="//*[tokenize(@DMDID, '\s+') = $thisid]"> WARNING: The dmdSec with ID
                    "<value-of select="$thisid"/>" is never referenced by a DMDID attribute
            </assert>
        </rule>
        <rule context="//*[@DMDID]">
            <let name="theseids" value="tokenize(@DMDID, '\s+')"/>
            <assert id="dmdid-references-dmdsec"
                test="count(//mets:dmdSec[$theseids = @ID]) = count($theseids)"> ERROR: Each DMDID
                in "<value-of select="@DMDID"/>" should reference a dmdSec </assert>
        </rule>
    </pattern>

    <pattern id="begin-end-betype">
        <rule context="//mets:file[@BEGIN | @END | @BETYPE] | //mets:stream[@BEGIN | @END | @BETYPE]">
            <assert role="info" id="end-default-value" test="@END"> INFO: When no END attribute is
                specified, the end of the parent file is assumed also to be the end point of the
                current <name/>. </assert>
            <assert id="begin-end-betype-has-begin-betype" test="@BEGIN and @BETYPE"> ERROR: A <name/> with BEGIN,
                END or BETYPE attributes should have BEGIN and BETYPE. </assert>
        </rule>

    </pattern>

    <pattern id="file-parent">
        <rule context="//mets:file[@BEGIN | @END | @BETYPE]">
            <assert id="file-begin-end-betype-has-parent" test="parent::mets:file">
                <!-- this is enforced by the XSD for streams, but not for files. --> ERROR: A
                <name/> with BEGIN, END or BETYPE attributes should have a parent file. </assert>
        </rule>
    </pattern>


    <pattern id="fptr-fileid">
        <rule context="//mets:fptr[@FILEID]">
            <report id="fptr-with-children-has-no-fileid"
                test="./mets:area | ./mets:seq | ./mets:par"> ERROR: A fptr element should only have
                a FILEID attribute value if it does not have a child area, par or seq element.
            </report>
        </rule>

        <rule context="//mets:fptr[not(mets:area) and not(mets:seq) and not(mets:par)]">
            <assert id="fptr-without-children-has-fileid" test="@FILEID"> ERROR: A fptr element
                should have a FILEID attribute if it does not have child area, par, or seq elements.
            </assert>
        </rule>
    </pattern>


    <pattern id="checksum">
        <!-- @CHECKSUM must have a @CHECKSUMTYPE -->
        <rule context="//mets:file[@CHECKSUMTYPE]">
            <assert id="checksumtype-hasum" test="@CHECKSUM"> ERROR: A file with a
                CHECKSUMTYPE should also have an CHECKSUM </assert>
        </rule>

        <rule context="//mets:file[@CHECKSUM]">
            <assert id="checksum-hasumtype" test="@CHECKSUMTYPE"> ERROR: A file with a
                CHECKSUM should also have a CHECKSUMTYPE </assert>
        </rule>
    </pattern>

    <pattern id="checksum-format">
        <!-- The syntax of @CHECKSUM must match the expected syntax for @CHECKSUMTYPE -->

        <rule context="//mets:file[@CHECKSUMTYPE = 'MD5']">
            <assert id="checksum-md5-format" test="matches(./@CHECKSUM, '^[a-fA-F0-9]{32}$')">
                ERROR: A file with CHECKSUMTYPE=MD5 must have a CHECKSUM that is 32 hexadecimal
                digits </assert>
        </rule>

        <rule context="//mets:file[@CHECKSUMTYPE = 'SHA-1']">
            <assert id="checksum-sha1-format" test="matches(./@CHECKSUM, '^[a-fA-F0-9]{40}$')">
                ERROR: A file with CHECKSUMTYPE=SHA-1 must have a CHECKSUM that is 40 hexadecimal
                digits </assert>
        </rule>

        <rule context="//mets:file[@CHECKSUMTYPE = 'SHA-256']">
            <assert id="checksum-sha256-format" test="matches(./@CHECKSUM, '^[a-fA-F0-9]{64}$')">
                ERROR: A file with CHECKSUMTYPE=SHA-256 must have a CHECKSUM that is 64 hexadecimal
                digits </assert>
        </rule>

        <!-- todo: Adler-32, CRC32, HAVAL, MNP, SHA-384, SHA-512, TIGER, WHIRLPOOL -->
    </pattern>


    <pattern id="area-attribute-set">
        <!-- area: "If SHAPE is specified then COORDS must also be present" -->
        <rule context="//mets:area[@SHAPE | @COORDS]">
            <assert id="area-shape-has-coords" test="@COORDS"> ERROR: An area with SHAPE must also
                have COORDS </assert>
            <assert id="area-coords-has-shape" test="@SHAPE"> ERROR: An area with COORDS must also
                have SHAPE </assert>
            <report id="area-shape-and-range" test="@BETYPE | @BEGIN | @END | @EXTENT | @EXTTYPE"
                role="warn"> WARNING: An area shouldn't have both a shape and a range </report>
        </rule>
                
        <rule context="//mets:area">
            <assert id="area-has-shape-or-begin" test="@SHAPE or @BEGIN">
                ERROR: An area must have either SHAPE or BEGIN.
            </assert>
        </rule>
        
    </pattern>
    
    <pattern id="area-type">
        <rule context="//mets:area[@BETYPE | @EXTTYPE]">
            <report id="area-betype-exttype" test="@BETYPE and @EXTTYPE" role="warn"> WARNING: An
                area shouldn't have both BETYPE and EXTTYPE </report>
        </rule>
    </pattern>
    
    <pattern id="area-extent">
        <rule context="//mets:area[@EXTENT | @END]">
            <report id="area-end-extent" test="@EXTENT and @END" role="warn"> WARNING: An area
                shouldn't have both EXTENT and END </report>
        </rule>
    </pattern>

    <pattern id="area-begin">
        <rule context="//mets:area[@BEGIN]">
            <assert role="info" id="area-end-default-value" test="@END or @EXTENT"> INFO: When no END or EXTENT attribute is
                specified, the end of the parent file is assumed also to be the end point of the
                current <name/>. </assert>            
        </rule>
    </pattern>
        
    <!-- warn if area has no SHAPE or BEGIN -->
    
    <!-- every fileGrp, file, or FLocat/FContent must have no more than one USE (inherited or otherwise) -->

    <!-- every fileGrp, file, or FLocat/FContent should have exactly one USE (inherited or otherwise) -->

    <!-- file@SEQ should appear in sequential order in the document and contain no gaps -->
    <!-- div@ORDER should appear in sequential order in the document and contain no gaps -->

    <!-- div,area@ADMID should reference a rightsMD? -->
    <!-- Typically the <div>, <area> ADMID attribute would be used to identify the <rightsMD> element or elements
        that pertain to the <div>, but it could be used anytime there was a need to link a <div>
        with pertinent administrative metadata. -->


    <!-- area@COORDS should have the expected syntax for the shape -->
    <!-- @BEGIN, @END, @EXTENT should match the expected syntax for @BETYPE, @EXTTYPE -->

    <!-- OTHER[WHATEVER]TYPE should appear when [WHATEVER]TYPE="OTHER": LOCTYPE, MDTYPE -->

    <!-- structLink stuff? We don't use it - I'm not familiar with xlink. Seems like
        only internal links could be validated anyway. Wouldn't want to duplicate what
        xlink schema already validates anyway -->

    <!-- Typically the <smArcLink> ADMID attribute would be used to identify one or
        more <sourceMD> and/or <techMD> elements that refine or clarify the relationship
        between the xlink:from and xlink:to sides of the arc. -->

    <!-- behavior stuff? -->

    <!-- behavior@STRUCTID must refer to a div@ID -->
    <!-- transformfile@TRANSFORMBEHAVIOR must reference behavior@ID -->


    <!-- anything useful for GROUPID? Looks like a given GROUPID should only be used within the scope of a particular kind of element?

    file@GROUPID: An identifier that establishes a correspondence between this file and files in other file groups.
    Typically, this will be used to associate a master file in one file group with the derivative files made
    from it in other file groups.

    behavior@GROUPID: An identifier that establishes a correspondence between the given behavior and
    other behaviors, typically used to facilitate versions of behaviors.

    dmdSec/techMD/rightsMD/digiprovMD/sourceMD@GROUPID: This identifier is used to indicate that different metadata sections may be considered
    as part of a group. Two metadata sections with the same GROUPID value are to be considered part of the
    same group. For example this facility might be used to group changed versions of the same metadata
    if previous versions are maintained in a file for tracking purposes.
    -->

    <!-- mdWrap: type of metadata embedded via xmlData must match mdType (check root element? namespace?) -->

    <!-- structid - error if there is a STRUCTID that does not reference a div -->

</schema>
