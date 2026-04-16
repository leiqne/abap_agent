@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for attachments'
@Metadata.ignorePropagatedAnnotations: true
define view entity zegui_i_attchmnts 
  as select from zegui_attchmnts
   association to parent zegui_i_agent_header as _Header on $projection.Queryid = _Header.Queryid
   association [ 1..1 ] to zegui_i_doc_type as _DocType on $projection.DocumentType = _DocType.DocTypeId
{
    key attachmentid as Attachmentid,
    key queryid as Queryid,
    doc_type_id as DocumentType,
    attachment as Attachment,
    mime_type as MimeType,
    file_name as FileName
    
    ,_Header,
    _DocType
}
