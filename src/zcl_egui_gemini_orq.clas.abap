CLASS zcl_egui_gemini_orq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    methods constructor importING iv_queryid type uuid  .
    INTERFACES if_serializable_object .
    INTERFACES if_bgmc_operation .
    INTERFACES if_bgmc_op_single_tx_uncontr .
  PROTECTED SECTION.
  PRIVATE SECTION.

    data :
        lv_queryid type uuid.

ENDCLASS.



CLASS zcl_egui_gemini_orq IMPLEMENTATION.
  method constructor.

    lv_queryid = iv_queryid.

  endmeTHOD.

  METHOD if_bgmc_op_single_tx_uncontr~execute.
    SELECT SINGLE a~attachment, a~mime_type, dc~document_type_name from ( ( zegui_attchmnts as a inner join zegui_doc_type as dc on a~doc_type_id = dc~doc_type_id ) )
    where queryid = @me->lv_queryid into @data(lv_attchment).
    data : lv_imgbase64 type string.
    try .
        data(lo_gemini) = new zcl_egui_gemini_client( ).
        lv_imgbase64 = CL_WEB_HTTP_UTILITY=>encode_x_base64( unencoded = lv_attchment-attachment ).
        data(lv_summary) = lo_gemini->summarize_order( exporting iv_attachment = lv_imgbase64 iv_mime_type = lv_attchment-mime_type iv_document_type = lv_attchment-document_type_name ).

        get time STAMP FIELD data(lv_tmp).
        update zegui_agent_hdr set query_status = 'D',
        prompt_string = @lv_imgbase64,
        model_name = 'GEMINI',
        llm_response_string = @lv_summary,
        processed_at = @lv_tmp
        where queryid = @me->lv_queryid.

        commit work.

    catch cx_root into data(ls_Error) .
    endtry.

  ENDMETHOD.
ENDCLASS.
