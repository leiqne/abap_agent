@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for agent header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zegui_i_agent_header as select from zegui_agent_hdr
composition [1..*] of zegui_i_attchmnts as _Attachment
{
    key queryid as Queryid,
    prompt_string as PromptString,
    llm_response_string as LlmResponseString,
    model_name as ModelName,
    query_status as QueryStatus,
    @Semantics.systemDateTime.createdAt: true
      @Semantics.systemDateTime.lastChangedAt: true
    processed_at as ProcessedAt,
    error_message as ErrorMessage
    
    ,_Attachment
}
