CLASS zcl_ca_attachment_service DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_ca_attachment_service .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CA_ATTACHMENT_SERVICE IMPLEMENTATION.


  METHOD zif_ca_attachment_service~attachmentset_create_entity.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~attachmentset_delete_entity.
    DATA: lo_attachments TYPE REF TO zcl_ca_gos_attachments,
          lv_id          TYPE swo_typeid,
          ls_lporb       TYPE sibflporb.

    zif_ca_attachment_service~extrack_key(
      EXPORTING
        it_key_tab               = it_key_tab
      IMPORTING
        es_key                   = DATA(ls_key)
    ).
    IF NOT ls_key IS INITIAL.
      CLEAR: ls_lporb, lv_id.
      ls_lporb-catid = ls_key-catid.
      ls_lporb-typeid = ls_key-typeid.
      ls_lporb-instid = ls_key-instanceid.
      lv_id = ls_key-id.

      TRANSLATE ls_lporb-instid TO UPPER CASE.
      REPLACE ALL OCCURRENCES OF '-' IN ls_lporb-instid WITH ''.

      CREATE OBJECT lo_attachments EXPORTING is_lporb = ls_lporb.
      lo_attachments->delete(
        EXPORTING
          iv_atta_id   = lv_id            " attachment key (folder id plus object id)
        IMPORTING
          et_messages  = DATA(lt_messages)" Table with BAPI Return Information
      ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~attachmentset_get_entity.
    zif_ca_attachment_service~extrack_key(
      EXPORTING
        it_key_tab = it_key_tab
      IMPORTING
        es_key     = DATA(ls_key)
    ).
    er_entity = CORRESPONDING #( ls_key ).
  ENDMETHOD.


  METHOD zif_ca_attachment_service~attachmentset_get_entityset.
    DATA: lo_attachments TYPE REF TO zcl_ca_gos_attachments,
          ls_lporb       TYPE sibflporb.
    zif_ca_attachment_service~extrack_key(
      EXPORTING
        it_key_tab               = it_key_tab
        it_filter_select_options = it_filter_select_options
      IMPORTING
        es_key                   = DATA(ls_key)
    ).
    IF NOT ls_key IS INITIAL.
      ls_lporb-catid = ls_key-catid.
      ls_lporb-typeid = ls_key-typeid.
      ls_lporb-instid = ls_key-instanceid.

      TRANSLATE ls_lporb-instid TO UPPER CASE.
      REPLACE ALL OCCURRENCES OF '-' IN ls_lporb-instid WITH ''.

      CREATE OBJECT lo_attachments EXPORTING is_lporb = ls_lporb.
      lo_attachments->get_attachments(
        IMPORTING
          et_attachments = DATA(lt_attachments)
      ).

      et_entityset = CORRESPONDING #( lt_attachments ).

      " Sort
      IF NOT it_order IS INITIAL.
        DATA(lt_sort_ref) = NEW abap_sortorder_tab( ).
        LOOP AT it_order INTO DATA(ls_order).
          APPEND INITIAL LINE TO lt_sort_ref->* ASSIGNING FIELD-SYMBOL(<lfs_sort>).
          CASE ls_order-property.
            WHEN 'CreatedAt'.
              <lfs_sort>-name = 'CREATEDAT'.
            WHEN OTHERS.
          ENDCASE.
          TRANSLATE ls_order-order TO UPPER CASE.
          IF ls_order-order = 'DESC'.
            <lfs_sort>-descending = abap_true.
          ENDIF.
        ENDLOOP.

        SORT et_entityset BY (lt_sort_ref->*).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~attachmentset_update_entity.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~commentset_create_entity.
    DATA: lo_notes TYPE REF TO zcl_ca_gos_attachments,
          ls_note  TYPE zca_s_comment_srv,
          ls_lporb TYPE sibflporb.

    CLEAR ls_note.
    io_data_provider->read_entry_data(
     IMPORTING
       es_data = ls_note
    ).

    zif_ca_attachment_service~extrack_key(
      EXPORTING
        it_key_tab = it_key_tab
      IMPORTING
        es_key     = DATA(ls_key)
    ).

    IF ls_key IS INITIAL.
      ls_key = CORRESPONDING #( ls_note ).
    ENDIF.
    IF NOT ls_note-note IS INITIAL.
      ls_lporb-catid = ls_key-catid.
      ls_lporb-typeid = ls_key-typeid.
      ls_lporb-instid = ls_note-instanceid.

      CREATE OBJECT lo_notes EXPORTING is_lporb = ls_lporb.

      lo_notes->create_note(
        EXPORTING
          iv_content   = ls_note-note     " Cotent
        IMPORTING
          es_note      = ls_note          " Comment Service
          et_messages  = DATA(lt_messages)" Return Messages
      ).

      er_entity = CORRESPONDING #( ls_note ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~commentset_delete_entity.
    DATA: lo_notes TYPE REF TO zcl_ca_gos_attachments,
          lv_id          TYPE swo_typeid,
          ls_lporb       TYPE sibflporb.

    zif_ca_attachment_service~extrack_key(
      EXPORTING
        it_key_tab               = it_key_tab
      IMPORTING
        es_key                   = DATA(ls_key)
    ).
    IF NOT ls_key IS INITIAL.
      CLEAR: ls_lporb, lv_id.
      ls_lporb-catid = ls_key-catid.
      ls_lporb-typeid = ls_key-typeid.
      ls_lporb-instid = ls_key-instanceid.
      lv_id = ls_key-id.

      TRANSLATE ls_lporb-instid TO UPPER CASE.
      REPLACE ALL OCCURRENCES OF '-' IN ls_lporb-instid WITH ''.

      CREATE OBJECT lo_notes EXPORTING is_lporb = ls_lporb.
      lo_notes->delete(
        EXPORTING
          iv_atta_id   = lv_id            " attachment key (folder id plus object id)
        IMPORTING
          et_messages  = DATA(lt_messages)" Table with BAPI Return Information
      ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~commentset_get_entity.
    zif_ca_attachment_service~extrack_key(
      EXPORTING
        it_key_tab = it_key_tab
      IMPORTING
        es_key     = DATA(ls_key)
    ).
    er_entity = CORRESPONDING #( ls_key ).
  ENDMETHOD.


  METHOD zif_ca_attachment_service~commentset_get_entityset.
    DATA: lo_notes TYPE REF TO zcl_ca_gos_attachments,
          ls_lporb TYPE sibflporb.

    zif_ca_attachment_service~extrack_key(
          EXPORTING
            it_key_tab               = it_key_tab
            it_filter_select_options = it_filter_select_options
          IMPORTING
            es_key                   = DATA(ls_key)
        ).

    IF NOT ls_key IS INITIAL.
      CLEAR et_entityset.

      ls_lporb-catid = ls_key-catid.
      ls_lporb-typeid = ls_key-typeid.
      ls_lporb-instid = ls_key-instanceid.

      TRANSLATE ls_lporb-instid TO UPPER CASE.
      REPLACE ALL OCCURRENCES OF '-' IN ls_lporb-instid WITH ''.

      CREATE OBJECT lo_notes EXPORTING is_lporb = ls_lporb.

      lo_notes->get_notes( IMPORTING et_notes = DATA(lt_notes) ).

      et_entityset = CORRESPONDING #( BASE ( et_entityset ) lt_notes ).

      " Sort
      IF NOT it_order IS INITIAL.
        DATA(lt_sort_ref) = NEW abap_sortorder_tab( ).
        LOOP AT it_order INTO DATA(ls_order).
          APPEND INITIAL LINE TO lt_sort_ref->* ASSIGNING FIELD-SYMBOL(<lfs_sort>).
          CASE ls_order-property.
            WHEN 'CreatedAt'.
              <lfs_sort>-name = 'CREATEDAT'.
            WHEN OTHERS.
          ENDCASE.
          TRANSLATE ls_order-order TO UPPER CASE.
          IF ls_order-order = 'DESC'.
            <lfs_sort>-descending = abap_true.
          ENDIF.
        ENDLOOP.

        SORT et_entityset BY (lt_sort_ref->*).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~commentset_update_entity.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~create_attachment_stream.
    DATA: lo_attachment TYPE REF TO zcl_ca_gos_attachments,
          ls_lporb      TYPE sibflporb,
          lv_content    TYPE xstring.

    zif_ca_attachment_service~extrack_key(
          EXPORTING
            it_key_tab = it_key_tab
          IMPORTING
            es_key     = DATA(ls_key)
        ).

    IF NOT ls_key IS INITIAL.
      ls_lporb-catid = ls_key-catid.
      ls_lporb-typeid = ls_key-typeid.
      ls_lporb-instid = ls_key-instanceid.

      TRANSLATE ls_lporb-instid TO UPPER CASE.
      REPLACE ALL OCCURRENCES OF '-' IN ls_lporb-instid WITH ''.

      CREATE OBJECT lo_attachment EXPORTING is_lporb = ls_lporb.

      " Get file details from slug
      zcl_ca_gos_attachments=>extract_file_dtls_from_slug(
      EXPORTING
        iv_slug            = iv_slug
      IMPORTING
        ev_filename        = DATA(lv_filename)
        ev_filedisplayname = DATA(lv_filedisplayname)
        ev_file_extension  = DATA(lv_extension) ).

      CLEAR lv_content.
      lv_content = is_media_resource-value.
      lo_attachment->create_attachment(
        EXPORTING
          iv_name        = lv_filename          " File Name
          iv_content_hex = lv_content           " Cotent Hex
        IMPORTING
          es_attachment  = DATA(ls_attachment)
          et_messages    = DATA(lt_messages)    " Return Messages
      ).
    ENDIF.
    er_entity = CORRESPONDING #( ls_attachment ).
  ENDMETHOD.


  METHOD zif_ca_attachment_service~extrack_key.
***********************************************************************
* For Generice Attachment Service we get Type ID and Category ID
* from Service Call
* For Specific Attachment Service we redefine this method
* And pass Type ID and Categroy ID from Constant Values of the class
***********************************************************************
    LOOP AT it_key_tab INTO DATA(ls_key).
      TRANSLATE ls_key-value TO UPPER CASE.
      CASE ls_key-name.
        WHEN 'InstanceID'.
          es_key-instanceid = ls_key-value.
          REPLACE ALL OCCURRENCES OF '-' IN ls_key-value WITH ''.
        WHEN 'TypeID'.
          es_key-typeid = ls_key-value.
        WHEN 'CategoryID'.
          es_key-catid = ls_key-value.
        WHEN 'Id'.
          es_key-id = ls_key-value.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
    IF es_key IS INITIAL.
      LOOP AT it_filter_select_options INTO DATA(ls_filter).
        READ TABLE ls_filter-select_options INTO DATA(ls_sel) INDEX 1.
        TRANSLATE ls_sel-low TO UPPER CASE.
        CASE ls_filter-property.
          WHEN 'InstanceID'.
            es_key-instanceid = ls_sel-low.
            REPLACE ALL OCCURRENCES OF '-' IN ls_key-value WITH ''.
          WHEN 'TypeID'.
            es_key-typeid = ls_sel-low.
          WHEN 'CategoryID'.
            es_key-catid = ls_sel-low.
          WHEN 'Id'.
            es_key-id = ls_sel-low.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD zif_ca_attachment_service~get_attachment_stream.
    DATA: lo_attachment TYPE REF TO zcl_ca_gos_attachments,
          ls_header     TYPE ihttpnvp,
          lv_name_utf8  TYPE string,
          ls_lporb      TYPE sibflporb.

    zif_ca_attachment_service~extrack_key(
          EXPORTING
            it_key_tab = it_key_tab
          IMPORTING
            es_key     = DATA(ls_key)
        ).

    IF NOT ls_key IS INITIAL.
      ls_lporb-catid = ls_key-catid.
      ls_lporb-typeid = ls_key-typeid.
      ls_lporb-instid = ls_key-instanceid.

      CREATE OBJECT lo_attachment EXPORTING is_lporb = ls_lporb.

      lo_attachment->get_attachment_content(
        EXPORTING
          iv_id             = ls_key-id
        IMPORTING
          ev_file_name      = ev_file_name
          es_media_resource = es_media_resource
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
