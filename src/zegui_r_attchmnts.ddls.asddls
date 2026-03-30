@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TRansactional view attachments'
@Metadata.ignorePropagatedAnnotations: true

define  view entity zegui_r_attchmnts
  as select from zegui_i_attchmnts
association to parent zegui_r_agent_header as _header
on $projection.Queryid = _header.Queryid
{
    key Attachmentid,
    key Queryid,
    DocumentType,
    Attachment,
    MimeType,
    FileName,
    _header
}
