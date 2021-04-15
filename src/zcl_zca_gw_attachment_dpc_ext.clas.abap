class ZCL_ZCA_GW_ATTACHMENT_DPC_EXT definition
  public
  inheriting from ZCL_ZCA_GW_ATTACHMENT_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  data GO_ATTACH type ref to ZIF_CA_ATTACHMENT_SERVICE .

  methods ATTACHKEYSET_GET_ENTITY
    redefinition .
  methods ATTACHMENTSET_DELETE_ENTITY
    redefinition .
  methods ATTACHMENTSET_GET_ENTITY
    redefinition .
  methods ATTACHMENTSET_GET_ENTITYSET
    redefinition .
  methods COMMENTSET_CREATE_ENTITY
    redefinition .
  methods COMMENTSET_DELETE_ENTITY
    redefinition .
  methods COMMENTSET_GET_ENTITY
    redefinition .
  methods COMMENTSET_GET_ENTITYSET
    redefinition .
  methods ATTACHMENTSET_UPDATE_ENTITY
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZCA_GW_ATTACHMENT_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.
    CASE iv_entity_set_name.
      WHEN 'AttachmentSet'.
        IF NOT go_attach IS BOUND.
          go_attach = NEW zcl_ca_attachment_service( ).
        ENDIF.
        go_attach->create_attachment_stream(
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            is_media_resource       = is_media_resource
            it_key_tab              = it_key_tab                 " table for name value pairs
            it_navigation_path      = it_navigation_path         " table of navigation paths
            iv_slug                 = iv_slug
            io_tech_request_context = io_tech_request_context    " Request Details for Entity Create Operation
          IMPORTING
            er_entity               = DATA(ls_entity)
        ).

        copy_data_to_ref(
          EXPORTING
            is_data = ls_entity
          CHANGING
            cr_data = er_entity
        ).
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.
    DATA: ls_header    TYPE ihttpnvp,
          lv_name_utf8 TYPE string.

    CASE iv_entity_set_name.
      WHEN 'AttachmentSet'.
        IF NOT go_attach IS BOUND.
          go_attach = NEW zcl_ca_attachment_service( ).
        ENDIF.
        go_attach->get_attachment_stream(
                  EXPORTING
                    iv_entity_name          = iv_entity_name
                    iv_entity_set_name      = iv_entity_set_name
                    iv_source_name          = iv_source_name
                    it_key_tab              = it_key_tab                 " table for name value pairs
                    it_navigation_path      = it_navigation_path         " table of navigation paths
                    io_tech_request_context = io_tech_request_context    " Request Details for Entity Read Operation
                  IMPORTING
                    ev_file_name            = DATA(lv_filename)
                    es_media_resource       = DATA(ls_media)

                ).

        " Passs File Name for Downloadable Content as Header Data
        CLEAR ls_header.
        ls_header-name = 'Content-Disposition'.

        " ABAP Esacping Character Support
        lv_name_utf8 = cl_abap_dyn_prg=>escape_xss_url( val = lv_filename ).

        REPLACE ALL OCCURRENCES OF '%2e' IN lv_name_utf8 WITH '.'.
        CONCATENATE 'attachment; filename*=UTF-8''''' lv_name_utf8 INTO ls_header-value.
        set_header( is_header = ls_header ).

        " Media Resource
        copy_data_to_ref(
          EXPORTING
            is_data = ls_media
          CHANGING
            cr_data = er_stream
        ).
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD attachkeyset_get_entity.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->extrack_key(
      EXPORTING
        it_key_tab = it_key_tab
      IMPORTING
        es_key     = DATA(ls_key)
    ).
    er_entity = CORRESPONDING #( ls_key ).
  ENDMETHOD.


  METHOD attachmentset_delete_entity.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->attachmentset_delete_entity(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        io_tech_request_context = io_tech_request_context
        it_navigation_path      = it_navigation_path
    ).
  ENDMETHOD.


  METHOD attachmentset_get_entity.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->attachmentset_get_entity(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        io_request_object       = io_request_object
        io_tech_request_context = io_tech_request_context
        it_navigation_path      = it_navigation_path
      IMPORTING
        er_entity               = DATA(ls_entity)
        es_response_context     = es_response_context
    ).
    er_entity = CORRESPONDING #( ls_entity ).
  ENDMETHOD.


  METHOD attachmentset_get_entityset.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->attachmentset_get_entityset(
      EXPORTING
        iv_entity_name           = iv_entity_name
        iv_entity_set_name       = iv_entity_set_name
        iv_source_name           = iv_source_name
        it_filter_select_options = it_filter_select_options
        is_paging                = is_paging
        it_key_tab               = it_key_tab
        it_navigation_path       = it_navigation_path
        it_order                 = it_order
        iv_filter_string         = iv_filter_string
        iv_search_string         = iv_search_string
        io_tech_request_context  = io_tech_request_context
      IMPORTING
        et_entityset             = DATA(lt_entityset)
        es_response_context      = es_response_context
    ).
    et_entityset = CORRESPONDING #( lt_entityset ).
  ENDMETHOD.


  METHOD attachmentset_update_entity.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->attachmentset_update_entity(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        io_tech_request_context = io_tech_request_context
        it_navigation_path      = it_navigation_path
        io_data_provider        = io_data_provider
      IMPORTING
        er_entity               = DATA(ls_entity)
    ).
    er_entity = CORRESPONDING #( ls_entity ).
  ENDMETHOD.


  METHOD commentset_create_entity.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->commentset_create_entity(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        io_tech_request_context = io_tech_request_context
        it_navigation_path      = it_navigation_path
        io_data_provider        = io_data_provider
      IMPORTING
        er_entity               = DATA(ls_entity)
    ).
    er_entity = CORRESPONDING #( ls_entity ).
  ENDMETHOD.


  METHOD commentset_delete_entity.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->commentset_delete_entity(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        io_tech_request_context = io_tech_request_context
        it_navigation_path      = it_navigation_path
    ).
  ENDMETHOD.


  METHOD commentset_get_entity.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->commentset_get_entity(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        io_request_object       = io_request_object
        io_tech_request_context = io_tech_request_context
        it_navigation_path      = it_navigation_path
      IMPORTING
        er_entity               = DATA(ls_entity)
        es_response_context     = es_response_context
    ).
    er_entity = CORRESPONDING #( ls_entity ).
  ENDMETHOD.


  METHOD commentset_get_entityset.
    IF NOT go_attach IS BOUND.
      go_attach = NEW zcl_ca_attachment_service( ).
    ENDIF.
    go_attach->commentset_get_entityset(
      EXPORTING
        iv_entity_name           = iv_entity_name
        iv_entity_set_name       = iv_entity_set_name
        iv_source_name           = iv_source_name
        it_filter_select_options = it_filter_select_options
        is_paging                = is_paging
        it_key_tab               = it_key_tab
        it_navigation_path       = it_navigation_path
        it_order                 = it_order
        iv_filter_string         = iv_filter_string
        iv_search_string         = iv_search_string
        io_tech_request_context  = io_tech_request_context
      IMPORTING
        et_entityset             = DATA(lt_entityset)
        es_response_context      = es_response_context
    ).
    et_entityset = CORRESPONDING #( lt_entityset ).
  ENDMETHOD.
ENDCLASS.
