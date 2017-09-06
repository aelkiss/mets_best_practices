<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <sch:ns uri="http://www.loc.gov/METS/" prefix="mets" />
    

    <!-- reviewed language: must (errors), should (a mixture of errors and warnings), typically (warnings) -->
    <!-- only things fully within the scope of the METS are validatable (can't validate external content 
        or the semantics of external content -->
    
    <!-- @ADMID must reference [techMD|sourceMD|rightsMD|digiprovMD]@ID 
    
    
         The following elements support references to <techMD>, <sourceMD>, <rightsMD> and <digiprovMD> 
         elements via an ADMID attribute: <metsHdr>, <dmdSec>, <techMD>, <sourceMD>, <rightsMD>, 
         <digiprovMD>, <fileGrp>, <file>, <stream>, <div>, <area>, <behavior>
    -->
    

    
    <!-- [techMD|sourceMD|rightsMD|digiprovMD]@ID should be referenced by 
        [metsHdr|dmdSec|techMD|sourceMD|rightsMD|digiprovMD|fileGrp|file|stream|div|area|behavior]@ADMID 
        (Document for @ID: "its value should be referenced from one or more DMDID attributes (when the ID 
        identifies a <dmdSec> element) or ADMID attributes (when the ID identifies a <techMD>, <sourceMD>, 
        <rightsMD> or <digiprovMD> element) that are associated with other elements in the METS document." -->
    
    <!-- [techMD|dmdSec|sourceMD|rightsMD|digiprovMD]@ADMID should reference digiprovMD@ID?
        
        ("Typically used in this context to reference preservation metadata (digiprovMD) which applies to the current metadata.") -->
    
    <!-- mets@OBJID should be present: "Although this attribute is not required, it is strongly recommended." -->
    
    <!-- @FILEID must reference file@ID -->
    <!-- file@ID should be referenced by some [fptr|area]@FILEID -->
    
    
    
    
    <sch:pattern id="dmdsec-id-checks">
        <!-- dmdSec@ID should be referenced by @DMDID
        
         The following elements support references to a <dmdSec> via a DMDID attribute: <file>, <stream>, <div>.
    --> 
        <sch:rule context="//mets:dmdSec">
            <sch:let    name="thisid" value="@ID" />
            <sch:assert test="//*[@DMDID=$thisid]">The dmdSec @ID "<sch:value-of select="@ID"/>" is never referenced</sch:assert>
        </sch:rule>
        <!-- @DMDID must reference dmdSec@ID -->
        <sch:rule context="//*[@DMDID]">
            <sch:assert test="(name(//*[@ID=//*/@DMDID]) = 'METS:dmdSec')">The @DMDID "<sch:value-of select="@DMDID" />" should reference a dmdSec, not a <sch:value-of select="local-name(//*[@ID=//*/@DMDID])" /></sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    <!-- mdWrap: type of metadata embedded via xmlData must match mdType (check root element? namespace?) -->
    
    
    <!-- files with @BEGIN, @END, or @BETYPE must have a parent file -->
    <!-- file@BEGIN, file@END (optional but warn that it's assumed to be end of file if missing), file@BETYPE must appear if any do -->
    <!-- stream@BEGIN, stream@END (optional but warn that it's assumed to be end of file if missing), stream@BETYPE must appear if any do -->
    
    
    
    <!-- "A <fptr> element should only have a FILEID attribute value if it does not have a child <area>, <par> 
        or <seq> element. If it has a child element, then the responsibility for pointing to the relevant content 
        falls to this child element or its descendants." --> 
    
    
    <!-- fptr with @FILEID should not have a child <area>, <par>, or <seq> -->
    <!-- fptr should have @FILEID if there is no child <area>, <par>, or <seq> -->
    
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
    
    
    
</sch:schema>