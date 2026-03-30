@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for attachments'
@Metadata.ignorePropagatedAnnotations: true
define view entity zegui_i_attchmnts 
  as select from zegui_attchmnts
   association to parent zegui_i_agent_header as _Header on $projection.Queryid = _Header.Queryid
{
    key attachmentid as Attachmentid,
    key queryid as Queryid,
    document_type as DocumentType,
    attachment as Attachment,
    mime_type as MimeType,
    file_name as FileName
    
    ,_Header
}
