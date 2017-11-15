<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">
    
    <ns uri="http://www.loc.gov/METS/" prefix="mets" />

    <!-- reviewed language: must (errors), should (a mixture of errors and warnings), typically (warnings) -->
    <!-- only things fully within the scope of the METS are validatable (can't validate external content 
        or the semantics of external content -->
    
    
    <pattern id="mdsec-id-checks">
        <!-- @ADMID must reference [techMD|sourceMD|rightsMD|digiprovMD]@ID
    
         The following elements support references to <techMD>, <sourceMD>, <rightsMD> and <digiprovMD> 
         elements via an ADMID attribute: <metsHdr>, <dmdSec>, <techMD>, <sourceMD>, <rightsMD>, 
         <digiprovMD>, <fileGrp>, <file>, <stream>, <div>, <area>, <behavior>
    -->
        <rule context="//mets:techMD | //mets:rightsMD | //mets:sourceMD | //mets:digiprovMD">
            <let    name="thisid" value="@ID" />
            <assert role="warn" id="mdsec_id_is_referenced" test="//*[@ADMID=$thisid]">
                WARNING: The <value-of select="local-name(.)" /> with ID "<value-of select="$thisid"/>" is never referenced by a ADMID attribute
            </assert>
        </rule>
        <!-- [techMD|sourceMD|rightsMD|digiprovMD]@ID should be referenced by
        [metsHdr|dmdSec|techMD|sourceMD|rightsMD|digiprovMD|fileGrp|file|stream|div|area|behavior]@ADMID 
        (Document for @ID: "its value should be referenced from one or more DMDID attributes (when the ID 
        identifies a <dmdSec> element) or ADMID attributes (when the ID identifies a <techMD>, <sourceMD>, 
        <rightsMD> or <digiprovMD> element) that are associated with other elements in the METS document." -->
        <rule context="//*[@ADMID]">
            <let    name="thisid" value="@ADMID" />
            <assert id="admid_references_mdsec" test="(//mets:techMD | //mets:rightsMD | //mets:sourceMD | //mets:digiprovMD)[@ID=$thisid]">
                ERROR: The ADMID "<value-of select="$thisid" />" should reference a techMD, rightsMD, sourceMD, or digiprovMD, not a <value-of select="local-name(//*[@ID=$thisid])" />
            </assert>
        </rule>
    </pattern>

    
    <!-- [techMD|dmdSec|sourceMD|rightsMD|digiprovMD]@ADMID should reference digiprovMD@ID?
        ("Typically used in this context to reference preservation metadata (digiprovMD) which applies to the current metadata.") -->
    
    <!-- mets@OBJID should be present: "Although this attribute is not required, it is strongly recommended." -->
    
    
    
    <pattern id="file-id-checks">
        <!-- file@ID should be referenced by some [fptr|area]@FILEID -->      
        <rule context="//mets:file">
            <let    name="thisid" value="@ID" />
            <assert role="warn" test="//*[@FILEID=$thisid]" id="file_id_is_referenced">
                WARNING: The <value-of select="local-name(.)" /> with ID "<value-of select="$thisid"/>" is never referenced by a FILEID attribute
            </assert>
        </rule>

        <!-- @FILEID must reference file@ID -->
        <rule context="//*[@FILEID]">
            <let    name="thisid" value="@FILEID" />
            <assert test="//mets:file[@ID=$thisid]" id="fileid_references_file">
                ERROR: The FILEID "<value-of select="$thisid" />" should reference a file, not a <value-of select="local-name(//*[@ID=$thisid])" />
            </assert>
        </rule>
    </pattern>
    
    
    <pattern id="dmdsec-id-checks">        
        <rule context="//mets:dmdSec">
            <let    name="thisid" value="@ID" />
            <assert role="warn" id="dmd_id_is_referenced" test="//*[tokenize(@DMDID,'\s+')=$thisid]" >
               WARNING: The dmdSec with ID "<value-of select="$thisid"/>" is never referenced by a DMDID attribute
            </assert>
        </rule>
        <rule context="//*[@DMDID]">
            <let    name="thisid" value="@DMDID" />
            <assert id="dmdid_references_dmdsec" test="//mets:dmdSec[@ID=$thisid]">
                ERROR: The DMDID "<value-of select="$thisid" />" should reference a dmdSec, not a <value-of select="local-name(//*[@ID=$thisid])" />
            </assert>
        </rule>
    </pattern>         
    
    <pattern id="begin-end-betype-checks">
        <rule context="//mets:*[@BEGIN | @END | @BETYPE]">
            <assert role="info" id="end-default-value" test="@END">
                INFO: When no END attribute is specified, the end of the parent file is assumed also to be the end point of the current <name />.
            </assert>
            <assert id="begin-end-betype" test="@BEGIN and @BETYPE">
                ERROR: A <name /> with BEGIN, END or BETYPE attributes should have BEGIN and BETYPE.
            </assert>
        </rule>

    </pattern>
    
    <pattern id="file-parent-checks">
        <rule context="//mets:file[@BEGIN | @END | @BETYPE]">
            <assert id="file-begin-end-betype-has-parent" test="parent::mets:file">
                <!-- this is enforced by the XSD for streams, but not for files. -->
                ERROR: A <name /> with BEGIN, END or BETYPE attributes should have a parent file.
            </assert>
        </rule>
    </pattern>
       
    
    <pattern id="fptr-fileid-checks">
        <rule context="//mets:fptr[@FILEID]">
            <report id="fptr-with-children-has-no-fileid" test="./mets:area | ./mets:seq | ./mets:par">
                ERROR: A fptr element should only have a FILEID attribute value if it does not have a child area, par or seq element.
            </report>
         </rule>
        
        <rule context="//mets:fptr[not(mets:area) and not(mets:seq) and not(mets:par)]">
            <assert id="fptr-without-children-has-fileid" test="@FILEID">
                ERROR: A fptr element should have a FILEID attribute if it does not have child area, par, or seq elements.
            </assert>
        </rule>
    </pattern>


    
    <!-- @CHECKSUM must have a @CHECKSUMTYPE -->
    <!-- The syntax of @CHECKSUM must match the expected syntax for @CHECKSUMTYPE -->
    
    <!-- structid - error if there is a STRUCTID that does not reference a div -->    
        
    
    <!-- every fileGrp, file, or FLocat/FContent must have no more than one USE (inherited or otherwise) -->
    
    <!-- every fileGrp, file, or FLocat/FContent should have exactly one USE (inherited or otherwise) -->
    
    <!-- file@SEQ should appear in sequential order in the document and contain no gaps -->
    <!-- div@ORDER should appear in sequential order in the document and contain no gaps -->
    
    <!-- div,area@ADMID should reference a rightsMD? -->
    <!-- Typically the <div>, <area> ADMID attribute would be used to identify the <rightsMD> element or elements 
        that pertain to the <div>, but it could be used anytime there was a need to link a <div> 
        with pertinent administrative metadata. -->
          
    <!-- area: "If SHAPE is specified then COORDS must also be present" -->
    <!-- area should have one set of: @SHAPE, @COORDS; 
                                      @BEGIN, @END (optional, warn that it's end of doc if missing), @BETYPE; 
                                      @BEGIN, @EXTENT (optional, warn that it's end of doc if missing), @EXTTYPE -->
    
    <!-- @BEGIN, @END, @EXTENT should match the expected syntax for @BETYPE, @EXTTYPE -->
    
    <!-- area@BEGIN: It can be used in conjunction with either the END attribute or the EXTENT attribute 
        as a means of defining the relevant portion of the referenced file precisely. It 
        can only be interpreted meaningfully in conjunction with the BETYPE or EXTTYPE, 
        which specify the kind of beginning/ending point values or beginning/extent values 
        that are being used. The BEGIN attribute can be used with or without a companion END 
        or EXTENT element. In this case, the end of the content file is assumed to be the 
        end point. -->
    
    <!-- area questions: 
            Could you have an area with no SHAPE or BEGIN?
            Could you have an area with both?
            Could you have both END/BETYPE and EXTENT/EXTTYPE? -->    
        
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
    
</schema>
