CLASS zcl_egui_gemini_orq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor IMPORTING iv_queryid TYPE uuid  .
    INTERFACES if_serializable_object .
    INTERFACES if_bgmc_operation .
    INTERFACES if_bgmc_op_single_tx_uncontr .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA :
        lv_queryid TYPE uuid.

ENDCLASS.



CLASS zcl_egui_gemini_orq IMPLEMENTATION.
  METHOD constructor.

    lv_queryid = iv_queryid.

  ENDMETHOD.

  METHOD if_bgmc_op_single_tx_uncontr~execute.
    SELECT SINGLE a~attachment, a~mime_type, dc~document_type_name FROM ( ( zegui_attchmnts AS a INNER JOIN zegui_doc_type AS dc ON a~doc_type_id = dc~doc_type_id ) )
    WHERE queryid = @me->lv_queryid INTO @DATA(lv_attchment).
    DATA : lv_imgbase64 TYPE string.
    IF lv_attchment IS NOT INITIAL.
      TRY .
          DATA(lo_gemini) = NEW zcl_egui_gemini_client( ).
          lv_imgbase64 = cl_web_http_utility=>encode_x_base64( unencoded = lv_attchment-attachment ).
          try.
          lo_gemini->summarize_order( EXPORTING iv_attachment = lv_imgbase64 iv_mime_type = lv_attchment-mime_type iv_document_type = lv_attchment-document_type_name
          IMPORTING rv_summary = DATA(lv_summary)
                    rv_error = DATA(ls_error_gem)
          ).
          catch cx_root .
          endtry.

          GET TIME STAMP FIELD DATA(lv_tmp).

          IF ls_error_gem IS INITIAL .

            UPDATE zegui_agent_hdr SET query_status = 'D',
            prompt_string = @lv_imgbase64,
            model_name = 'GEMINI',
            llm_response_string = @lv_summary,
            processed_at = @lv_tmp
            WHERE queryid = @me->lv_queryid.

            COMMIT WORK.
            RETURN.
          ENDIF.

          DATA llm_error TYPE string.

          llm_error = | error code: { ls_error_gem-code } status: { ls_error_gem-status } |.

          UPDATE zegui_agent_hdr SET query_status = 'E',
          model_name = 'GEMINI',
          llm_response_string = @llm_error,
          processed_at = @lv_tmp,
          error_message = @ls_error_gem-message
          WHERE queryid = @me->lv_queryid.

          COMMIT WORK.
          RETURN.

        CATCH cx_bgmc_operation  INTO DATA(lx_bgmc_error).

          GET TIME STAMP FIELD lv_tmp.
          DATA(lv_msg) = lx_bgmc_error->get_text( ).

          UPDATE zegui_agent_hdr SET
            query_status = 'E',
            error_message = @lv_msg,
            processed_at = @lv_tmp
          WHERE queryid = @me->lv_queryid.
          COMMIT WORK.



*        CATCH cx_root INTO DATA(lx_root_error).
*
*          GET TIME STAMP FIELD lv_tmp.
*          DATA(lv_error_msg) = lx_root_error->get_text( ).
*
*          UPDATE zegui_agent_hdr SET
*            query_status = 'E',
*            error_message = @lv_error_msg,
*            processed_at = @lv_tmp
*          WHERE queryid = @me->lv_queryid.
*          COMMIT WORK.


      ENDTRY.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
