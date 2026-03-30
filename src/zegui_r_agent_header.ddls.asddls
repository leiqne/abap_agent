@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transactional view agent header'
@Metadata.ignorePropagatedAnnotations: false
define root view entity zegui_r_agent_header
  as select from zegui_i_agent_header

composition [1..*] of zegui_r_attchmnts as _Attachment

{
key Queryid,
PromptString,
LlmResponseString,
ModelName,
QueryStatus,
ProcessedAt,
ErrorMessage
/* Associations */
//,_attachment.Attachment as AttachmentImage
,_Attachment
}
