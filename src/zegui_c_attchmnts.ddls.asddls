@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection for Attachments'
@Metadata.ignorePropagatedAnnotations: false
define view entity zegui_c_attchmnts
  as projection on zegui_r_attchmnts
{

    @UI.facet : [{
        id : 'idFiles',
        label : 'Files',
        position : 35 ,
        type : #IDENTIFICATION_REFERENCE,
        targetQualifier: 'FILE'
    }]

      @UI.hidden : true
  key Attachmentid,
      @UI.hidden: true
  key Queryid,

      //@UI.lineItem: [{  position: 10 }]
      @EndUserText.label: 'Document Type'
      @Consumption.valueHelpDefinition : [{ 
      entity: { name: 'zegui_i_doc_type', element: 'DocTypeId' },
      additionalBinding: [{ 
      localElement: 'DocumentType',
      element: 'DocTypeId',
      usage: #RESULT
       }]
       }]
      @ObjectModel.text.association: '_DocType'
      DocumentType,
      
      @UI.lineItem: [{ position: 10 , label : 'Document Type' }]
      @EndUserText.label: 'Document Type'
      _DocType.DocumentTypeName as DocumentTypeText,

      @Semantics.largeObject: {
      mimeType: 'MimeType',
      fileName: 'FileName',
      contentDispositionPreference: #INLINE
      }
      @UI.identification: [{ position : 20, qualifier: 'FILE' }]
      @EndUserText.label: 'Upload Image'
      @UI.lineItem: [{  position: 15 }]
      Attachment,
      
      @UI.hidden: true
      @Semantics.mimeType: true
      MimeType,

      @UI.lineItem: [{ position : 20 }] 
      @EndUserText.label: 'File name'
      FileName,

      /* Associations */
      _header : redirected to parent ZEGUI_C_AGENT_HEADER
      ,_DocType
}
