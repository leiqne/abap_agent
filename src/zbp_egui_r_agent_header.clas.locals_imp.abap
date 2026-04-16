CLASS lsc_zegui_r_agent_header DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zegui_r_agent_header IMPLEMENTATION.

  METHOD save_modified.

    LOOP AT update-header ASSIGNING FIELD-SYMBOL(<ls_upd>) WHERE %control-QueryStatus = if_abap_behv=>mk-on AND QueryStatus = 'P' .

      TRY.


          cl_bgmc_process_factory=>get_default(
                  )->create(
                  )->set_operation_tx_uncontrolled( NEW zcl_egui_gemini_orq( <ls_upd>-Queryid )  "waiting for the async execution
                  )->save_for_execution( ) .
          APPEND VALUE #(
     %key = <ls_upd>-%key
     %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-success
              text     = 'Action added to queue'
            )
     %action-sendToLlm = if_abap_behv=>mk-on
     ) TO reported-header.


        CATCH cx_root INTO DATA(lx).
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_attachment DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS checkNumberFiles FOR VALIDATE ON SAVE
      IMPORTING keys FOR Attachment~checkNumberFiles.
    METHODS checkfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Attachment~checkfields.


ENDCLASS.

CLASS lhc_attachment IMPLEMENTATION.


  METHOD checkNumberFiles.


    READ ENTITIES OF zegui_r_agent_header IN LOCAL MODE
    ENTITY Attachment
    FIELDS ( Queryid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_attchments).

    LOOP AT lt_attchments ASSIGNING FIELD-SYMBOL(<ls_attchments>) GROUP BY <ls_attchments>-Queryid INTO DATA(ls_group) .

      DATA(lv_total_count) = 0.

      LOOP AT GROUP ls_group INTO DATA(ls_member).
        lv_total_count += 1.
      ENDLOOP.

      IF lv_total_count > 1 .

        LOOP AT GROUP ls_group INTO DATA(ls_error).
          APPEND VALUE #( %tky = <ls_attchments>-%tky  ) TO failed-attachment.
          APPEND VALUE #( %tky = <ls_attchments>-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'Only one attchment per header' )
                           ) TO reported-attachment.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD checkfields.

    READ ENTITIES OF zegui_r_agent_header IN LOCAL MODE
    ENTITY Attachment
    FIELDS ( DocumentType ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_attchment).

    LOOP AT lt_attchment ASSIGNING FIELD-SYMBOL(<ls_attch>).

      IF <ls_attch>-DocumentType IS INITIAL .

        APPEND VALUE #( %tky = <ls_attch>-%tky ) TO failed-attachment.
        APPEND VALUE #( %tky = <ls_attch>-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Document type is mandatory'     )
                        %element-documenttype = if_abap_behv=>mk-on
                          ) TO reported-attachment.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Header RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Header RESULT result.
    METHODS sendtollm FOR MODIFY
      IMPORTING keys FOR ACTION header~sendtollm RESULT result.



ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD get_instance_features.

    READ ENTITIES OF zegui_r_agent_header IN LOCAL MODE

    ENTITY Header
    BY \_attachment
    FIELDS ( Attachmentid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_attchmnt).

    READ ENTITIES OF zegui_r_agent_header IN LOCAL MODE
    ENTITY Header
    FIELDS ( Queryid LlmResponseString  ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_parent).

    result = VALUE #( FOR header IN lt_parent (
                      %tky =  header-%tky
                      "for association
                      %assoc-_Attachment = COND #( WHEN  line_exists( lt_attchmnt[  Queryid = header-Queryid ] )
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled   )
                      "for action send to llm
                      %action-sendtollm = COND #( WHEN header-llmresponsestring IS INITIAL AND line_exists( lt_attchmnt[  Queryid = header-Queryid ] )
                                                  THEN   if_abap_behv=>fc-o-enabled
                                                  ELSE if_abap_behv=>fc-o-disabled )
                                                   ) ).



  ENDMETHOD.



  METHOD sendToLlm.

    READ ENTITIES OF zegui_r_agent_header IN LOCAL MODE
    ENTITY  Header
    BY \_attachment
    ALL FIELDS WITH CORRESPONDING #( keys  )
    RESULT DATA(lt_attchment).

    READ ENTITIES OF zegui_R_Agent_header IN LOCAL MODE
    ENTITY header
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF lt_attchment IS INITIAL.
        APPEND VALUE #( %tky = <ls_key>-%tky ) TO failed-header.
        APPEND VALUE #( %tky = <ls_key>-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Please insert an attachment' )
                        %action-sendToLlm = if_abap_behv=>mk-on ) TO reported-header.
        CONTINUE.
      ENDIF.

      "append value #( %tky = <ls_key>-%tky ) to failed-header.

      READ TABLE lt_header
      ASSIGNING FIELD-SYMBOL(<ls_header>)
      WITH TABLE KEY draft COMPONENTS %is_draft = <ls_key>-%is_draft
                                      %key      = <ls_key>-%key.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <ls_header>-LlmResponseString IS INITIAL .
        "then call to llm

        MODIFY ENTITIES OF zegui_r_agent_header IN LOCAL MODE
        ENTITY header
        UPDATE FIELDS ( QueryStatus ) WITH VALUE #( (  %tky = <ls_key>-%tky QueryStatus = 'P' ) )
        FAILED failed
        REPORTED reported.

*        try.
**            cl_bgmc_process_factory=>get_default(
**            )->create(
**            )->set_operation_tx_uncontrolled( new zcl_egui_gemini_orq( <ls_key>-Queryid )  "waiting for the async execution
**            )->save_for_execution( ) .
**            call function 'z_fgui_call_llm'
**            exporting iv_queryid = <ls_key>-Queryid.
*
*        catch cx_root into data(lx_root) .
*        "error message
*        enDTRY.

*        APPEND VALUE #(
*       %tky = <ls_key>-%tky
*       %msg = new_message_with_text(
*                severity = if_abap_behv_message=>severity-success
*                text     = 'Action executed successfully'
*              )
*       %action-sendToLlm = if_abap_behv=>mk-on
*       ) TO reported-header.

        APPEND VALUE #( %tky = <ls_key>-%tky
                        %param-queryid  = <ls_key>-Queryid
                              ) TO result.

      ELSE .
        APPEND VALUE #( %tky = <ls_key>-%tky ) TO failed-header.
        APPEND VALUE #( %tky = <ls_key>-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'BO Already have a response' )
                        %action-sendToLlm = if_abap_behv=>mk-on ) TO reported-header.
      ENDIF.


    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
