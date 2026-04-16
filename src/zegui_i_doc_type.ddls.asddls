@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Doc type'
@Metadata.ignorePropagatedAnnotations: true
define view entity zegui_i_doc_type as select from zegui_doc_type
{
    key doc_type_id as DocTypeId,
    document_type_name as DocumentTypeName,
    description as Description
}
