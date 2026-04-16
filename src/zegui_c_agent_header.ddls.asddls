@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection for Agent Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZEGUI_C_AGENT_HEADER
provider contract transactional_query
 as projection on zegui_r_agent_header
 
{
    @UI.facet : [
    { id : 'idIdentification', type : #IDENTIFICATION_REFERENCE, label : 'Header details', position : 10 },
    { id : 'idAttachments' , type: #LINEITEM_REFERENCE, label : 'File Uploader', position : 20, targetElement: '_Attachment' }
    ]
    
    // in the table
    @UI.lineItem: [{ position : 5 }]
    //filter bar
    @UI.selectionField: [{ position : 5 }]
    // in view item
    @UI.identification: [{ position : 5 }]
    key Queryid,
    
//    @UI.lineItem: [{ position : 10 }] 
//    @UI.identification: [{ position : 10 }]
//    @EndUserText.label: 'Prompt to LLM'
//    PromptString,

    @UI.lineItem: [{ position : 15 }]
    @UI.identification: [{ position : 15, importance :#HIGH },
                         { type  : #FOR_ACTION, dataAction: 'sendToLlm', label : 'Send BO to llm'  }    ]
    @EndUserText.label: 'LLM response'
    LlmResponseString,
    ModelName,
    
    @UI.lineItem: [{ position : 20 }]
    @UI.identification: [{ position : 20  }]
    @UI.selectionField: [{ position :20 }]
    @EndUserText.label: 'Status of prompt' 
    QueryStatus,
    
    @UI.lineItem: [{ position :  25 }]
    @UI.selectionField: [{ position : 25 }]
    @UI.identification: [{ position : 25 }]
    ProcessedAt,
    
    @UI.lineItem: [{ position : 30 }]
    @UI.selectionField: [{ position : 30 }]
    ErrorMessage,
    /* Associations */
    _Attachment :redirected to composition child zegui_c_attchmnts
}
