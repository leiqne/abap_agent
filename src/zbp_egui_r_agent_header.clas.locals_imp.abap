CLASS lhc_attachment DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS sendImageGem FOR DETERMINE ON SAVE
      IMPORTING keys FOR Attachment~sendImageGem.
    METHODS checkNumberFiles FOR VALIDATE ON SAVE
      IMPORTING keys FOR Attachment~checkNumberFiles.
    METHODS checkfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Attachment~checkfields.


ENDCLASS.

CLASS lhc_attachment IMPLEMENTATION.

  METHOD sendImageGem.
  ENDMETHOD.


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

    read entities of zegui_r_agent_header in local mode
    entity Attachment
    fields ( DocumentType ) with correSPONDING #( keys )
    result data(lt_attchment).

    loop at lt_attchment assIGNING fieLD-SYMBOL(<ls_attch>).

        if <ls_attch>-DocumentType is initial .

            append value #( %tky = <ls_attch>-%tky ) to failed-attachment.
            appenD value #( %tky = <ls_attch>-%tky
                            %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'Document type is mandatory'     )
                            %element-documenttype = if_abap_behv=>mk-on
                              ) to reported-attachment.

        endiF.

    eNDLOOP.

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
    FIELDS ( Queryid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_parent).

    result = VALUE #( FOR header IN lt_parent (
                      %tky =  header-%tky
                      %assoc-_Attachment = COND #( WHEN  line_exists( lt_attchmnt[  Queryid = header-Queryid ] )
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled   )    ) ).


  ENDMETHOD.



ENDCLASS.
